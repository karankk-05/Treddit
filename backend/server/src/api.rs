use crate::SharedState;

use super::auth::verify_otp;
use super::schema::*;
use axum::{extract::State, http::StatusCode, Json};

pub async fn create_user(
    State(state): State<SharedState>,
    Json(payload): Json<NewUser>,
) -> Result<(StatusCode, Json<User>), StatusCode> {
    let mut st = state.write().await;
    let user = User {
        email: payload.email,
        username: payload.username,
        address: payload.address,
        passwd: payload.passwd,
        profile: String::from("abc"),
        contact_no: payload.contact_no,
    };

    if verify_otp(user.email.clone(), payload.otp, &mut st.otp_storage) {
        sqlx::query!("INSERT INTO USERS(email,username,passwd,address,profile_pic_path,contact_no) VALUES ($1,$2,$3,$4,$5,$6)",
        user.email,
        user.username,
        user.passwd,
        user.address,
        user.profile,
        user.contact_no,
    )
        .execute(&st.pool)
        .await
        .expect("Cannot create user");

        Ok((StatusCode::CREATED, Json(user)))
    } else {
        Err(StatusCode::TOO_MANY_REQUESTS)
    }
}
