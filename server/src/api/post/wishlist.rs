use super::models::*;
use crate::auth::utils::validate_token;
use crate::models::ValidToken;
use crate::SharedState;
use axum::{
    extract::{Json, State},
    http::StatusCode,
    response::Result,
};

pub async fn add_to_wishlist(
    State(state): State<SharedState>,
    Json(payload): Json<AddWish>,
) -> Result<StatusCode, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    match sqlx::query!(
        "insert into wishlist(email,post_id) values ($1,$2)",
        payload.email,
        payload.post_id
    )
    .execute(&st.pool)
    .await
    {
        Ok(_) => Ok(StatusCode::OK),
        Err(err) => {
            eprintln!("{}", err);
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}

pub async fn remove_from_wishlist(
    State(state): State<SharedState>,
    Json(payload): Json<RemoveWish>,
) -> Result<StatusCode, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    match sqlx::query!(
        "delete from wishlist where wishlist_id = $1 and email = $2",
        payload.wish_id,
        payload.email
    )
    .execute(&st.pool)
    .await
    {
        Ok(_) => Ok(StatusCode::OK),
        Err(err) => {
            eprintln!("{}", err);
            Err(StatusCode::NOT_MODIFIED)
        }
    }
}

pub async fn get_wishlist(
    State(state): State<SharedState>,
    Json(payload): Json<ValidToken>,
) -> Result<Json<Vec<i32>>, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    match sqlx::query!(
        "select post_id from wishlist where email = $1",
        payload.email
    )
    .fetch_all(&st.pool)
    .await
    {
        Ok(val) => Ok(Json(val.iter().map(|x| x.post_id).collect())),
        Err(err) => {
            eprintln!("{}", err);
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}
