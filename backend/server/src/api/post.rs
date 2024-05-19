use crate::schema::Post;
use crate::SharedState;
use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::Result,
    Json,
};

pub async fn get_post(
    State(state): State<SharedState>,
    Path(id): Path<i32>,
) -> Result<Json<Post>, StatusCode> {
    let row = match sqlx::query!("select * from posts where owner = $1", id.to_string())
        .fetch_one(&state.write().await.pool)
        .await
    {
        Ok(val) => val,
        Err(_) => return Err(StatusCode::NOT_FOUND),
    };
    let post = Post {
        post_id: row.post_id,
        owner: row.owner,
        title: row.title,
        body: match row.body {
            Some(val) => val,
            None => String::new(),
        },
        opening_timestamp: row.open_timestamp,
        price: row.price,
        images: match row.image_paths {
            Some(val) => val,
            None => vec![String::new()],
        },
        reports: row.reports,
    };
    Ok(Json(post))
}
