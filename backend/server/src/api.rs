use super::schema::*;
use axum::{extract::State, http::StatusCode, Json};
use sqlx::PgPool;

#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
}

pub async fn create_user(
    State(pool): State<AppState>,
    Json(payload): Json<NewUser>,
) -> (StatusCode, Json<User>) {
    let user = User {
        email: payload.email,
        username: payload.username,
        address: payload.address,
        passwd: payload.passwd,
        profile: String::from("abc"),
        contact_no: payload.contact_no,
    };
    sqlx::query!(
        "INSERT INTO USERS VALUES ('ABBA','HARMONIUM','KHATE','THE','ABE','2024-05-20','123423')",
    )
    .execute(&pool.pool)
    .await
    .expect("Cannot create user");

    (StatusCode::CREATED, Json(user))
}
