use serde::{Deserialize, Serialize};
use sqlx::{prelude::FromRow, PgPool};
use std::collections::HashMap;
use std::time::SystemTime;

#[derive(Clone, Debug)]
pub struct Otp {
    pub otp: u16,
    pub email: String,
    pub exp: SystemTime,
}
impl Otp {
    pub fn expired(&self) -> bool {
        SystemTime::now() >= self.exp
    }
}

#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
    pub mail_pass: String,
    pub otp_storage: HashMap<String, Otp>,
}

#[derive(Serialize, Deserialize, FromRow)]
pub struct User {
    pub email: String,
    pub username: String,
    pub passwd: String,
    pub address: String,
    pub profile_pic_path: String,
    pub contact_no: String,
    pub reports: i32,
}

#[derive(Serialize, Deserialize)]
pub struct UserDisp {
    pub email: String,
    pub username: String,
    pub address: String,
    pub profile_pic_path: String,
    pub contact_no: String,
}

#[derive(Serialize, Deserialize)]
pub struct NewUser {
    pub user: User,
    pub otp: u16,
}

#[derive(Serialize, Deserialize)]
pub struct LoginInfo {
    pub email: String,
    pub passwd: String,
}

#[derive(Serialize)]
pub struct LoginResponse {
    pub token: String,
}

#[derive(Serialize, Deserialize)]
pub struct Claims {
    pub email: String,
    pub exp: SystemTime,
}

#[derive(Serialize, Deserialize, FromRow)]
pub struct Post {
    pub id: i32,
    pub owner: String,
    pub title: String,
    pub body: String,
    pub price: i32,
    pub images: Vec<String>,
    pub reports: i32,
}
