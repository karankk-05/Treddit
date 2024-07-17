use super::super::json::*;
use crate::utils::sanitize_check_email;
use crate::{Otp, SharedState};
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

pub async fn send_otp(
    State(state): State<SharedState>,
    Json(payload): Json<Email>,
) -> Result<StatusCode, StatusCode> {
    let otp_lifetime = Duration::minutes(10);
    let min_resend_time = Duration::minutes(5);
    let mut st = state.write().await;
    if let Some(val) = st.otp_storage.get(&payload.email) {
        let left_time = val.exp - Utc::now();
        if otp_lifetime - left_time < min_resend_time {
            return Err(StatusCode::TEMPORARY_REDIRECT);
        }
    }

    let mailid = st.mail_id.to_owned();
    let otp = generate_otp();

    let email = prepare_mail(&mailid, &payload.email, otp)?;

    let creds = Credentials::new(mailid, st.mail_pass.to_owned());

    // Open a remote connection to mail
    let mailer = match SmtpTransport::relay("smtp.zoho.in") {
        Ok(val) => val.credentials(creds).build(),
        Err(err) => {
            eprintln!("{}", err);
            return Err(StatusCode::SERVICE_UNAVAILABLE);
        }
    };

    // Send the email
    match mailer.send(&email) {
        Ok(_) => {
            let exp = Utc::now() + otp_lifetime;
            st.otp_storage.insert(
                payload.email.clone(),
                Otp {
                    otp,
                    email: payload.email,
                    exp,
                },
            );
            Ok(StatusCode::OK)
        }
        Err(err) => {
            eprintln!("Cannot mail {:?}", err);
            Err(StatusCode::SERVICE_UNAVAILABLE)
        }
    }
}

pub async fn create_user(
    State(state): State<SharedState>,
    Json(payload): Json<NewUser>,
) -> Result<StatusCode, StatusCode> {
    let mut st = state.write().await;

    let mut new_user = payload;
    new_user.email = sanitize_check_email(new_user.email)?;

    verify_otp(&new_user.email, new_user.otp, &mut st.otp_storage)?;
    match sqlx::query!(
        "INSERT INTO USERS(email,username,address,contact_no) VALUES ($1,$2,$3,$4)",
        new_user.email,
        new_user.username,
        new_user.address,
        new_user.contact_no,
    )
    .execute(&st.pool)
    .await
    {
        Ok(_) => (),
        Err(_) => return Err(StatusCode::CONFLICT),
    }

    save_passwd(&st.pool, &new_user.email, &new_user.passwd).await?;
    Ok(StatusCode::OK)
}

pub async fn change_password(
    State(state): State<SharedState>,
    Json(payload): Json<ChPassd>,
) -> Result<StatusCode, StatusCode> {
    let mut st = state.write().await;
    verify_otp(&payload.email, payload.otp, &mut st.otp_storage)?;
    update_passwd(&st.pool, &payload.email, &payload.passwd).await?;
    Ok(StatusCode::OK)
}

async fn update_passwd(pool: &PgPool, email: &str, passwd: &str) -> Result<(), StatusCode> {
    let hash = get_hash(passwd).await?;
    match sqlx::query!("update login set passwd = $1 where email = $2", hash, email)
        .execute(pool)
        .await
    {
        Ok(_) => Ok(()),
        Err(_) => Err(StatusCode::NOT_FOUND),
    }
}

async fn save_passwd(pool: &PgPool, email: &str, passwd: &str) -> Result<(), StatusCode> {
    let hash = get_hash(passwd).await?;
    match sqlx::query!(
        "insert into login(email,passwd) values ($1,$2) ",
        email,
        hash
    )
    .execute(pool)
    .await
    {
        Ok(_) => Ok(()),
        Err(_) => Err(StatusCode::CONFLICT),
    }
}

async fn get_hash(passwd: &str) -> Result<String, StatusCode> {
    let salt = SaltString::generate(&mut OsRng);
    match Argon2::default().hash_password(passwd.as_bytes(), &salt) {
        Ok(val) => Ok(val.to_string()),
        Err(err) => {
            eprintln!("{}", err);
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}

fn prepare_mail(
    sender_mailid: &str,
    reciever_mailid: &str,
    otp: u16,
) -> Result<Message, StatusCode> {
    match Message::builder()
        .from(match sender_mailid.to_owned().parse() {
            Ok(val) => val,
            Err(err) => {
                eprintln!("{}", err);
                return Err(StatusCode::INTERNAL_SERVER_ERROR);
            }
        })
        .to(match reciever_mailid.to_owned().parse() {
            Ok(val) => val,
            Err(err) => {
                eprintln!("{}", err);
                return Err(StatusCode::EXPECTATION_FAILED);
            }
        })
        .subject(String::from("OTP recieved!"))
        .header(ContentType::TEXT_PLAIN)
        .body(format!("Your OTP for Kampus Konnect is {otp}"))
    {
        Ok(val) => Ok(val),
        Err(err) => {
            eprintln!("{}", err);
            Err(StatusCode::INTERNAL_SERVER_ERROR)
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
