use axum::http::StatusCode;
use chrono::DateTime;
use chrono::Utc;
use serde::{Deserialize, Serialize};
use sqlx::{prelude::FromRow, PgPool};
use std::collections::HashMap;

#[derive(Clone, Debug)]
pub struct Otp {
    pub otp: u16,
    pub email: String,
    pub exp: DateTime<Utc>,
}
impl Otp {
    pub fn expired(&self) -> Result<bool, StatusCode> {
        match Utc::now() > self.exp {
            false => Ok(false),
            true => Err(StatusCode::UNAUTHORIZED),
        }
    }
}

#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
    pub mail_pass: String,
    pub otp_storage: HashMap<String, Otp>,
    pub jwt_secret_key: [u8; 32],
}

#[derive(Serialize, Deserialize)]
pub struct UserDisp {
    pub email: String,
    pub username: String,
    pub address: String,
    pub profile_pic_path: String,
    pub contact_no: String,
}

#[derive(Serialize, Deserialize, FromRow)]
pub struct User {
    #[serde(flatten)]
    pub disp: UserDisp,
    pub contact_no: String,
    pub reports: i32,
}

#[derive(Deserialize)]
pub struct NewUser {
    pub email: String,
    pub username: String,
    pub passwd: String,
    pub address: String,
    pub contact_no: String,
    pub otp: u16,
}

#[derive(Deserialize)]
pub struct ChPassd {
    pub email: String,
    pub otp: u16,
    pub passwd: String,
}

#[derive(Deserialize)]
pub struct LoginInfo {
    pub email: String,
    pub passwd: String,
}

#[derive(Serialize)]
pub struct LoginResponse {
    pub token: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Claims {
    pub email: String,
    pub exp: usize,
}

#[derive(Serialize, FromRow)]
pub struct Post {
    pub post_id: i32,
    pub owner: String,
    pub title: String,
    pub body: String,
    pub opening_timestamp: DateTime<Utc>,
    pub price: i32,
    pub images: String,
    pub reports: i32,
}
