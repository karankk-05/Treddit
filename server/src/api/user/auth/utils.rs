use super::super::json::*;

use crate::Otp;
use axum::http::StatusCode;
use jsonwebtoken::{decode, DecodingKey, Validation};
use std::collections::HashMap;

pub async fn validate_token(token: String, email: &str, key: [u8; 32]) -> Result<(), StatusCode> {
    let claims = decode_token(token, key).await?;
    match claims.is_valid(email) {
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

pub fn verify_otp(
    email: &str,
    otp: u16,
    otp_storage: &mut HashMap<String, Otp>,
) -> Result<(), StatusCode> {
    let stored_otp = &otp_storage.remove(email);
    match stored_otp {
        Some(val) => match !val.expired() && val.email == email && val.otp == otp {
            true => Ok(()),
            false => Err(StatusCode::UNAUTHORIZED),
        },
        None => Err(StatusCode::UNAUTHORIZED),
    }
}
