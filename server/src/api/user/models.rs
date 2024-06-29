use serde::{Deserialize, Serialize};

#[derive(Serialize)]
pub struct UserDisp {
    pub email: String,
    pub username: String,
    pub address: String,
    pub profile_pic_path: String,
}

#[derive(Serialize)]
pub struct User {
    #[serde(flatten)]
    pub disp: UserDisp,
    pub contact_no: String,
    pub reports: i32,
}

#[derive(Deserialize)]
pub struct ChUser {
    pub token: String,
    pub email: String,
    pub username: Option<String>,
    pub address: Option<String>,
    pub contact_no: Option<String>,
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
pub struct ReportUser {
    pub email: String,
    pub token: String,
    pub accused: String,
    pub statement: String,
}

#[derive(Serialize, Deserialize)]
pub struct Claims {
    pub email: String,
    pub exp: usize,
}
