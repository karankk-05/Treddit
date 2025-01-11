use chrono::Utc;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Serialize, JsonSchema)]
pub struct UserDisp {
    pub email: String,
    pub username: String,
    pub address: String,
    pub profile_pic_path: Option<String>,
    pub contact_no: Option<String>,
}

#[derive(Serialize, JsonSchema)]
pub struct User {
    #[serde(flatten)]
    pub disp: UserDisp,
    pub reports: i32,
}

#[derive(Deserialize, JsonSchema)]
pub struct ChUser {
    pub token: String,
    pub email: String,
    pub username: Option<String>,
    pub address: Option<String>,
    pub contact_no: Option<String>,
}

#[derive(Deserialize, JsonSchema)]
pub struct NewUser {
    pub email: String,
    pub username: String,
    pub address: String,
    pub contact_no: String,
    pub otp: u16,
}

#[derive(Deserialize, JsonSchema)]
pub struct Email {
    pub email: String,
}

#[derive(Deserialize, JsonSchema)]
pub struct LoginInfo {
    pub email: String,
    pub otp: u16,
}

#[derive(Deserialize, JsonSchema)]
pub struct ReportUser {
    pub email: String,
    pub token: String,
    pub accused: String,
    pub statement: String,
}

#[derive(Serialize, Deserialize, JsonSchema)]
pub struct Claims {
    pub email: String,
    pub exp: usize,
}
impl Claims {
    pub fn expired(&self) -> bool {
        Utc::now().timestamp() as usize > self.exp
    }
    pub fn is_valid(&self, email: &str) -> bool {
        self.email == email && !self.expired()
    }
}
