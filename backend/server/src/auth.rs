use crate::SharedState;

use super::schema::*;
use argon2::{
    password_hash::{rand_core::OsRng, SaltString},
    Argon2, PasswordHash, PasswordVerifier,
};
use axum::{extract::State, http::StatusCode, Json};
use lettre::transport::smtp::authentication::Credentials;
use lettre::{address, message::header::ContentType};
use lettre::{Message, SmtpTransport, Transport};
use rand::Rng;
use sqlx::PgPool;
use std::collections::HashMap;
use std::time::{Duration, SystemTime};

fn generate_otp() -> u16 {
    let mut rng = rand::thread_rng();
    rng.gen_range(1000..=9999)
}

async fn save_passwd(pool: &PgPool, email: &String, passwd: &String) -> Result<(), StatusCode> {
    let salt = SaltString::generate(&mut OsRng).to_string();
    let mut output_key_material = [0u8; 32]; // Can be any desired size
    Argon2::default()
        .hash_password_into(passwd.as_bytes(), salt.as_bytes(), &mut output_key_material)
        .expect("Cannot hash");
    match sqlx::query!(
        "insert into login(email,passwd) values ($1,$2) ",
        email,
        &output_key_material
    )
    .execute(pool)
    .await
    {
        Ok(_) => Ok(()),
        Err(_) => Err(StatusCode::INTERNAL_SERVER_ERROR),
    }
}

async fn is_passwd_correct(pool: PgPool, email: String, passwd: String) -> bool {
    let q = sqlx::query!("select passwd from login where email = $1", email)
        .fetch_one(&pool)
        .await
        .unwrap();
    let pass = String::from_utf8(q.passwd.to_vec()).unwrap();
    let parsed_hash = PasswordHash::new(pass.as_str());
    match Argon2::default().verify_password(passwd.as_bytes(), &parsed_hash.unwrap()) {
        Ok(_) => true,
        Err(_) => false,
    }
}

fn verify_otp(email: String, otp: u16, otp_storage: &mut HashMap<String, Otp>) -> bool {
    let stored_otp = &otp_storage.remove(&email);
    match stored_otp {
        Some(val) => !val.expired() && val.email == email && val.otp == otp,
        None => false,
    }
}

pub async fn send_otp(State(state): State<SharedState>, payload: String) -> StatusCode {
    let mailid = "kampuskonnect@zohomail.in";
    let mut st = state.write().await;
    let otp = generate_otp();

    let email = Message::builder()
        .from(mailid.to_owned().parse().unwrap())
        .to(payload.to_owned().parse().unwrap())
        .subject(String::from("OTP recieved!"))
        .header(ContentType::TEXT_PLAIN)
        .body(format!("Your OTP for Kampus Konnect is {}", &otp))
        .unwrap();

    let creds = Credentials::new(mailid.to_owned(), st.mail_pass.to_owned());

    // Open a remote connection to mail
    let mailer = SmtpTransport::relay("smtp.zoho.in")
        .unwrap()
        .credentials(creds)
        .build();

    // Send the email
    match mailer.send(&email) {
        Ok(_) => {
            let exp = SystemTime::now() + Duration::from_secs(10 * 60);
            st.otp_storage.insert(
                payload.clone(),
                Otp {
                    otp,
                    email: payload,
                    exp,
                },
            );
            println!("{:?}", st.otp_storage);
            StatusCode::OK
        }
        Err(_) => StatusCode::SERVICE_UNAVAILABLE,
    }
}

pub async fn create_user(
    State(state): State<SharedState>,
    Json(payload): Json<NewUser>,
) -> StatusCode {
    let mut st = state.write().await;
    let new_user: NewUser = payload;
    let user = &new_user.user;

    if verify_otp(
        new_user.user.email.clone(),
        new_user.otp,
        &mut st.otp_storage,
    ) {
        sqlx::query!("INSERT INTO USERS(email,username,address,profile_pic_path,contact_no) VALUES ($1,$2,$3,$4,$5)"
        ,user.email
        ,user.username
        ,user.address
        ,user.profile
        ,user.contact_no)
        .execute(&st.pool)
        .await
        .expect("Cannot create user");
        save_passwd(&st.pool, &new_user.user.email, &new_user.user.passwd)
            .await
            .expect("Cannot save password");

        StatusCode::CREATED
    } else {
        StatusCode::EXPECTATION_FAILED
    }
}
