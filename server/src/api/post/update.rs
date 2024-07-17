use super::json::*;
use super::posts::Posts;
use crate::{api::user::auth::utils::validate_token, SharedState};
use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use sea_query::{Expr, PostgresQueryBuilder, Query as SeaQuery};

fn build_update_query(payload: ChPost, id: i32) -> String {
    let mut update_query = SeaQuery::update().table(Posts::Table).to_owned();
    if let Some(title) = payload.title {
        update_query.value(Posts::Title, title);
    }
    if let Some(body) = payload.body {
        update_query.value(Posts::Body, body);
    }
    if let Some(price) = payload.price {
        update_query.value(Posts::Price, price);
    }
    if let Some(category) = payload.category {
        update_query.value(Posts::Category, category);
    }
    if let Some(sold) = payload.sold {
        update_query.value(Posts::Sold, sold);
    }

    update_query.and_where(Expr::col(Posts::PostId).eq(id));
    update_query.and_where(Expr::col(Posts::Owner).eq(payload.email));

    update_query.to_string(PostgresQueryBuilder)
}

pub async fn update_post(
    State(state): State<SharedState>,
    Path(post_id): Path<i32>,
    Json(payload): Json<ChPost>,
) -> Result<StatusCode, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token.clone(), &payload.email, st.jwt_secret_key).await?;
    let update_query = build_update_query(payload, post_id);
    match sqlx::query(&update_query).execute(&st.pool).await {
        Ok(_) => Ok(StatusCode::OK),
        Err(_) => Err(StatusCode::NOT_MODIFIED),
    }
}
