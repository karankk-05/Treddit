use crate::{schema::*, SharedState};
use argon2::{
    password_hash::{rand_core::OsRng, SaltString},
    Argon2, PasswordHasher,
};
use axum::{extract::State, http::StatusCode, Json};
use chrono::{Duration, Utc};
use lettre::message::header::ContentType;
use lettre::transport::smtp::authentication::Credentials;
use lettre::{Message, SmtpTransport, Transport};
use rand::Rng;
use sqlx::PgPool;
use std::collections::HashMap;

pub async fn send_otp(State(state): State<SharedState>, payload: String) -> StatusCode {
    // TODO implement wait for second time otp
    let mailid = "kampuskonnect@zohomail.in";
    let mut st = state.write().await;
    let otp = generate_otp();

    let email = Message::builder()
        .from(mailid.to_owned().parse().unwrap())
        .to(payload.to_owned().parse().unwrap())
        .subject(String::from("OTP recieved!"))
        .header(ContentType::TEXT_PLAIN)
        .body(format!("Your OTP for Kampus Konnect is {otp}"))
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
            let exp = Utc::now() + Duration::minutes(10);
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
        Err(_) => {
            eprintln!("Cannot mail");
            StatusCode::SERVICE_UNAVAILABLE
        }
    }
}

pub async fn create_user(
    State(state): State<SharedState>,
    Json(payload): Json<NewUser>,
) -> StatusCode {
    let mut st = state.write().await;

    let new_user: NewUser = payload;
    let user = &new_user;

    if verify_otp(&new_user.email, new_user.otp, &mut st.otp_storage) {
        sqlx::query!(
            "INSERT INTO USERS(email,username,address,contact_no) VALUES ($1,$2,$3,$4)",
            user.email,
            user.username,
            user.address,
            user.contact_no,
        )
        .execute(&st.pool)
        .await
        .expect("Cannot create user");

        save_passwd(&st.pool, &new_user.email, &new_user.passwd, true).await
    } else {
        StatusCode::EXPECTATION_FAILED
    }
}

pub async fn change_password(
    State(state): State<SharedState>,
    Json(payload): Json<ChPassd>,
) -> StatusCode {
    let mut st = state.write().await;
    match verify_otp(&payload.email, payload.otp, &mut st.otp_storage) {
        true => save_passwd(&st.pool, &payload.email, &payload.passwd, false).await,
        false => StatusCode::UNAUTHORIZED,
    }
}

async fn save_passwd(pool: &PgPool, email: &str, passwd: &str, new: bool) -> StatusCode {
    let salt = SaltString::generate(&mut OsRng);
    let hash = match Argon2::default().hash_password(passwd.as_bytes(), &salt) {
        Ok(val) => val.to_string(),
        Err(_) => return StatusCode::INTERNAL_SERVER_ERROR,
    };
    match new {
        true => {
            match sqlx::query!(
                "insert into login(email,passwd) values ($1,$2) ",
                email,
                hash
            )
            .execute(pool)
            .await
            {
                Ok(_) => StatusCode::OK,
                Err(_) => StatusCode::CONFLICT,
            }
        }
        false => {
            match sqlx::query!("update login set passwd = $1 where email = $2", hash, email)
                .execute(pool)
                .await
            {
                Ok(_) => StatusCode::OK,
                Err(_) => StatusCode::NOT_FOUND,
            }
        }
    }
}

fn verify_otp(email: &str, otp: u16, otp_storage: &mut HashMap<String, Otp>) -> bool {
    let stored_otp = &otp_storage.remove(email);
    match stored_otp {
        Some(val) => !val.expired() && val.email == email && val.otp == otp,
        None => false,
    }
}

fn generate_otp() -> u16 {
    let mut rng = rand::thread_rng();
    rng.gen_range(1000..=9999)
}
