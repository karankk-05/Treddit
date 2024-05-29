use crate::{auth::utils::validate_token, models::SendPostChat, SharedState};
use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};

pub async fn send_chat(
    State(state): State<SharedState>,
    Path(post_id): Path<i32>,
    Json(payload): Json<SendPostChat>,
) -> Result<StatusCode, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.sender, st.jwt_secret_key).await?;
    match sqlx::query!(
        "insert into post_chats(post_id,sender,reciever,message) values($1,$2,$3,$4)",
        post_id,
        payload.sender,
        payload.reciever,
        payload.message
    )
    .execute(&st.pool)
    .await
    {
        Ok(_) => Ok(StatusCode::OK),
        Err(_) => Err(StatusCode::NOT_FOUND),
    }
}
