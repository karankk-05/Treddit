use super::super::super::{schema::*, SharedState};
use argon2::{Argon2, PasswordHash, PasswordVerifier};
use axum::{extract::State, http::StatusCode, response::Result, Json};
use jsonwebtoken::{encode, EncodingKey, Header};
use sqlx::PgPool;
use std::time::{Duration, SystemTime};

pub async fn login(
    State(state): State<SharedState>,
    Json(payload): Json<LoginInfo>,
) -> Result<Json<LoginResponse>, StatusCode> {
    let st = &state.read().await;
    if is_passwd_correct(&st.pool, payload.email.clone(), payload.passwd.clone()).await {
        let claims = Claims {
            email: payload.email,
            exp: SystemTime::now() + Duration::from_secs(60 * 60),
        };
        // https://www.youtube.com/watch?v=p2ljQrRl0Mg&t=774s
        let token = match encode(
            &Header::default(),
            &claims,
            &EncodingKey::from_secret("secret".as_ref()),
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
