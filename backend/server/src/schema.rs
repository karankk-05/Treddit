use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct NewUser {
    pub email: String,
    pub username: String,
    pub passwd: String,
    pub address: String,
    pub profile: String,
    pub contact_no: String,
}

#[derive(Serialize, Deserialize)]
pub struct User {
    pub email: String,
    pub username: String,
    pub passwd: String,
    pub address: String,
    pub profile: String,
    pub contact_no: String,
}

#[derive(Serialize, Deserialize)]
pub struct Post {
    pub id: i32,
    pub owner: String,
    pub title: String,
    pub body: String,
    pub price: i32,
    pub images: Vec<String>,
}
