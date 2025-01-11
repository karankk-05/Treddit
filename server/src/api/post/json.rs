use chrono::{DateTime, Utc};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Deserialize, JsonSchema)]
pub struct AddWish {
    pub email: String,
    pub token: String,
    pub post_id: i32,
}

#[derive(Deserialize, JsonSchema)]
pub struct RemoveWish {
    pub email: String,
    pub token: String,
    pub post_id: i32,
}

#[derive(Serialize, JsonSchema)]
pub struct PostCard {
    pub title: String,
    pub price: i32,
    pub image: Option<String>,
}

#[derive(Serialize, JsonSchema)]
pub struct PostInfo {
    pub post_id: i32,
    pub owner: String,
    pub title: String,
    pub body: Option<String>,
    pub opening_timestamp: DateTime<Utc>,
    pub price: i32,
    pub sold: bool,
    pub category: Option<String>,
    pub images: Option<String>,
    pub reports: i32,
}

#[derive(Deserialize, JsonSchema)]
pub struct ChPost {
    pub email: String,
    pub token: String,

    pub title: Option<String>,
    pub body: Option<String>,
    pub category: Option<String>,
    pub price: Option<i32>,
    pub sold: Option<bool>,
}

#[derive(Deserialize, JsonSchema)]
pub struct ReportPost {
    pub email: String,
    pub token: String,
    pub statement: String,
}
