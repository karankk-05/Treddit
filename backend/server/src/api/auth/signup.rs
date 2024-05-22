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
    let otp_lifetime = Duration::minutes(10);
    let min_resend_time = Duration::minutes(5);
    let mut st = state.write().await;
    match st.otp_storage.get(&payload) {
        Some(val) => {
            let left_time = val.exp - Utc::now();
            if otp_lifetime - left_time < min_resend_time {
                return StatusCode::TEMPORARY_REDIRECT;
            }
        }
        None => (),
    }

    let mailid = "kampuskonnect@zohomail.in";
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
            let exp = Utc::now() + otp_lifetime;
            st.otp_storage.insert(
                payload.clone(),
                Otp {
                    otp,
                    email: payload,
                    exp,
                },
            );
            //Remove in prod.
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
) -> Result<StatusCode, StatusCode> {
    let mut st = state.write().await;

    let new_user: NewUser = payload;
    let user = &new_user;

    verify_otp(&new_user.email, new_user.otp, &mut st.otp_storage)?;
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
}

pub async fn change_password(
    State(state): State<SharedState>,
    Json(payload): Json<ChPassd>,
) -> Result<StatusCode, StatusCode> {
    let mut st = state.write().await;
    verify_otp(&payload.email, payload.otp, &mut st.otp_storage)?;
    save_passwd(&st.pool, &payload.email, &payload.passwd, false).await
}

async fn save_passwd(
    pool: &PgPool,
    email: &str,
    passwd: &str,
    new: bool,
) -> Result<StatusCode, StatusCode> {
    let salt = SaltString::generate(&mut OsRng);
    let hash = match Argon2::default().hash_password(passwd.as_bytes(), &salt) {
        Ok(val) => val.to_string(),
        Err(_) => return Err(StatusCode::INTERNAL_SERVER_ERROR),
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
                Ok(_) => Ok(StatusCode::OK),
                Err(_) => Err(StatusCode::CONFLICT),
            }
        }
        false => {
            match sqlx::query!("update login set passwd = $1 where email = $2", hash, email)
                .execute(pool)
                .await
            {
                Ok(_) => Ok(StatusCode::OK),
                Err(_) => Err(StatusCode::NOT_FOUND),
            }
        }
    }
}

fn verify_otp(
    email: &str,
    otp: u16,
    otp_storage: &mut HashMap<String, Otp>,
) -> Result<(), StatusCode> {
    let stored_otp = &otp_storage.remove(email);
    match stored_otp {
        Some(val) => match !val.expired()? && val.email == email && val.otp == otp {
            true => Ok(()),
            false => Err(StatusCode::UNAUTHORIZED),
        },
        None => Err(StatusCode::UNAUTHORIZED),
    }
}

fn generate_otp() -> u16 {
    let mut rng = rand::thread_rng();
    rng.gen_range(1000..=9999)
}
