use super::super::models::*;

use axum::http::StatusCode;
use chrono::Utc;
use jsonwebtoken::{decode, DecodingKey, Validation};

pub async fn validate_token(token: String, email: &str, key: [u8; 32]) -> Result<(), StatusCode> {
    let claims = decode_token(token, key).await?;
    match claims.email == email && claims.exp > Utc::now().timestamp() as usize {
        true => Ok(()),
        false => Err(StatusCode::UNAUTHORIZED),
    }
}

pub async fn decode_token(token: String, key: [u8; 32]) -> Result<Claims, StatusCode> {
    match decode::<Claims>(
        &token,
        &DecodingKey::from_secret(&key),
        &Validation::default(),
    ) {
        Ok(val) => Ok(val.claims),
        Err(_) => Err(StatusCode::UNAUTHORIZED),
    }
}
