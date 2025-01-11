use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Deserialize, JsonSchema)]
pub struct ValidToken {
    pub email: String,
    pub token: String,
}

#[derive(Serialize, Deserialize, JsonSchema)]
pub struct Token {
    pub token: String,
}
