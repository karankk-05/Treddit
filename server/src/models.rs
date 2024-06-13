use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;

#[derive(Deserialize)]
pub struct AddWish {
    pub email: String,
    pub token: String,
    pub post_id: i32,
}

#[derive(Deserialize)]
pub struct RemoveWish {
    pub email: String,
    pub token: String,
    pub wish_id: i32,
}

#[derive(Serialize, Deserialize)]
pub struct UserDisp {
    pub email: String,
    pub username: String,
    pub address: String,
    pub profile_pic_path: String,
}

#[derive(Serialize, Deserialize)]
pub struct SendPostChat {
    pub token: String,
    pub message: String,
    pub sender: String,
    pub reciever: String,
}

#[derive(Serialize, Deserialize)]
pub struct RecievePostChat {
    pub chat: String,
    pub sender: String,
    pub reciever: String,
    pub chat_timestamp: DateTime<Utc>,
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
pub struct Email {
    pub email: String,
}

#[derive(Deserialize)]
pub struct LoginInfo {
    pub email: String,
    pub passwd: String,
}

#[derive(Deserialize)]
pub struct ValidToken {
    pub email: String,
    pub token: String,
}

#[derive(Serialize, Deserialize)]
pub struct Token {
    pub token: String,
}

#[derive(Deserialize)]
pub struct ReportPost {
    pub email: String,
    pub token: String,
    pub statement: String,
}

#[derive(Deserialize)]
pub struct ReportUser {
    pub email: String,
    pub token: String,
    pub accused: String,
    pub statement: String,
}

#[derive(Deserialize)]
pub struct UpdateStatus {
    pub token: String,
    pub email: String,
    pub status: bool,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Claims {
    pub email: String,
    pub exp: usize,
}

#[derive(Serialize)]
pub struct PostCard {
    pub title: String,
    pub price: i32,
    pub image: String,
}

#[derive(Serialize, FromRow)]
pub struct Post {
    pub post_id: i32,
    pub owner: String,
    pub title: String,
    pub body: String,
    pub opening_timestamp: DateTime<Utc>,
    pub price: i32,
    pub sold: bool,
    pub images: String,
    pub reports: i32,
}
