use crate::{schema::*, SharedState};
use argon2::{Argon2, PasswordHash, PasswordVerifier};
use axum::{extract::State, http::StatusCode, response::Result, Json};
use chrono::{Duration, Utc};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use sqlx::PgPool;

pub async fn login(
    State(state): State<SharedState>,
    Json(payload): Json<LoginInfo>,
) -> Result<Json<LoginResponse>, StatusCode> {
    let st = &state.read().await;
    if is_passwd_correct(&st.pool, payload.email.clone(), payload.passwd.clone()).await {
        let claims = Claims {
            email: payload.email,
            exp: (Utc::now() + Duration::hours(1)).timestamp() as usize,
        };
        let token = match encode(
            &Header::default(),
            &claims,
            &EncodingKey::from_secret(&st.jwt_secret_key),
        ) {
            Ok(tok) => tok,
            Err(_) => return Err(StatusCode::UNAUTHORIZED),
        };
        Ok(Json(LoginResponse { token }))
    } else {
        Err(StatusCode::NOT_FOUND)
    }
}

async fn is_passwd_correct(pool: &PgPool, email: String, passwd: String) -> bool {
    let record = match sqlx::query!("select passwd from login where email = $1", email)
        .fetch_one(pool)
        .await
    {
        Ok(val) => val,
        Err(_) => return false,
    };
    let parsed_hash = match PasswordHash::new(&record.passwd) {
        Ok(val) => val,
        Err(_) => return false,
    };
    Argon2::default()
        .verify_password(passwd.as_bytes(), &parsed_hash)
        .is_ok()
}

fn decode_token(token: String, key: [u8; 32]) -> Result<Claims, jsonwebtoken::errors::Error> {
    let tok = decode::<Claims>(
        &token,
        &DecodingKey::from_secret(&key),
        &Validation::default(),
    );
    Ok(tok?.claims)
}

pub fn is_token_valid(token: String, email: &str, key: [u8; 32]) -> bool {
    let claims = match decode_token(token, key) {
        Ok(val) => val,
        Err(_) => {
            return false;
        }
    };
    claims.email == email && claims.exp > Utc::now().timestamp() as usize
}
