use chrono::{DateTime, Utc};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Deserialize, JsonSchema)]
pub struct SendPostChat {
    pub token: String,
    pub message: String,
    pub sender: String,
    pub reciever: String,
}

#[derive(Serialize, JsonSchema)]
pub struct RecievePostChat {
    pub chat: String,
    pub sender: String,
    pub reciever: String,
    pub chat_timestamp: DateTime<Utc>,
}

#[derive(Deserialize, JsonSchema)]
pub struct BulkGet {
    pub email: String,
    pub token: String,
    pub chats: Vec<i32>,
}
