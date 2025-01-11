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
    pub fn expired(&self) -> bool {
        Utc::now() > self.exp
    }
}

#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
    pub mail_id: String,
    pub mail_pass: String,
    pub otp_storage: HashMap<String, Otp>,
    pub jwt_secret_key: [u8; 32],
}
