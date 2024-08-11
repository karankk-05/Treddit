use super::super::json::*;
use crate::token_json::{Token, ValidToken};
use crate::utils::sanitize_check_email;
use crate::SharedState;
use axum::{extract::State, http::StatusCode, response::Result, Json};
use chrono::{Duration, Utc};
use jsonwebtoken::{encode, EncodingKey, Header};

use super::utils::{validate_token, verify_otp};

pub async fn login(
    State(state): State<SharedState>,
    Json(payload): Json<LoginInfo>,
) -> Result<Json<Token>, StatusCode> {
    let st = &mut state.write().await;
    let email = sanitize_check_email(payload.email)?;
    // validate_passwd(&st.pool, &email, &payload.passwd).await?;
    verify_otp(&email, payload.otp, &mut st.otp_storage)?;

    let claims = Claims {
        email,
        exp: (Utc::now() + Duration::hours(1)).timestamp() as usize,
    };
    let token = generate_token(claims, st.jwt_secret_key).await?;
    Ok(Json(Token { token }))
}

pub async fn is_token_valid(
    State(state): State<SharedState>,
    Json(payload): Json<ValidToken>,
) -> Result<StatusCode, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    Ok(StatusCode::OK)
}

async fn generate_token(claims: Claims, jwt_secret_key: [u8; 32]) -> Result<String, StatusCode> {
    match encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(&jwt_secret_key),
    ) {
        Ok(tok) => Ok(tok),
        Err(_) => Err(StatusCode::UNAUTHORIZED),
    }
}
