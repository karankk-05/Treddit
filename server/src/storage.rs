use axum::http::StatusCode;
use chrono::DateTime;
use chrono::Utc;
use sqlx::PgPool;
use std::collections::HashMap;

#[derive(Clone)]
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
