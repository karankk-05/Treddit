use crate::{models::*, SharedState};
use argon2::{Argon2, PasswordHash, PasswordVerifier};
use axum::{extract::State, http::StatusCode, response::Result, Json};
use chrono::{Duration, Utc};
use jsonwebtoken::{encode, EncodingKey, Header};
use sqlx::PgPool;

pub async fn login(
    State(state): State<SharedState>,
    Json(payload): Json<LoginInfo>,
) -> Result<Json<Token>, StatusCode> {
    let st = &state.read().await;
    validate_passwd(&st.pool, &payload.email, &payload.passwd).await?;
    let claims = Claims {
        email: payload.email,
        exp: (Utc::now() + Duration::hours(1)).timestamp() as usize,
    };
    let token = generate_token(claims, st.jwt_secret_key).await?;
    Ok(Json(Token { token }))
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

async fn validate_passwd(pool: &PgPool, email: &str, passwd: &str) -> Result<(), StatusCode> {
    let record = match sqlx::query!("select passwd from login where email = $1", email)
        .fetch_one(pool)
        .await
    {
        Ok(val) => val,
        Err(_) => return Err(StatusCode::UNAUTHORIZED),
    };
    match_hash(passwd, &record.passwd).await
}

async fn match_hash(passwd: &str, saved_pass: &str) -> Result<(), StatusCode> {
    let parsed_hash = match PasswordHash::new(saved_pass) {
        Ok(val) => val,
        Err(_) => return Err(StatusCode::UNAUTHORIZED),
    };
    match Argon2::default()
        .verify_password(passwd.as_bytes(), &parsed_hash)
        .is_ok()
    {
        true => Ok(()),
        false => Err(StatusCode::UNAUTHORIZED),
    }
}
