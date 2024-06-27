use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct ValidToken {
    pub email: String,
    pub token: String,
}

#[derive(Serialize, Deserialize)]
pub struct Token {
    pub token: String,
}
