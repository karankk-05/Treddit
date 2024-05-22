use crate::schema::*;
use axum::http::StatusCode;
use chrono::Utc;
use jsonwebtoken::{decode, DecodingKey, Validation};

pub async fn validate_token(token: String, email: &str, key: [u8; 32]) -> Result<(), StatusCode> {
    let claims = match decode_token(token, key).await {
        Ok(val) => val,
        Err(_) => {
            return Err(StatusCode::UNAUTHORIZED);
        }
    };
    match claims.email == email && claims.exp > Utc::now().timestamp() as usize {
        true => Ok(()),
        false => Err(StatusCode::UNAUTHORIZED),
    }
}

async fn decode_token(token: String, key: [u8; 32]) -> Result<Claims, jsonwebtoken::errors::Error> {
    Ok(decode::<Claims>(
        &token,
        &DecodingKey::from_secret(&key),
        &Validation::default(),
    )?
    .claims)
}
