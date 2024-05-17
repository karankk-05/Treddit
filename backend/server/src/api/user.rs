use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::Result,
    Json,
};

use crate::schema::UserDisp;

use super::super::SharedState;

pub async fn get_user(
    State(state): State<SharedState>,
    Path(path): Path<String>,
) -> Result<Json<UserDisp>, StatusCode> {
    let email = path;

    let pool = &state.read().await.pool;
    let row = match sqlx::query!("select * from users where email = $1", email)
        .fetch_one(pool)
        .await
    {
        Ok(val) => val,
        Err(_) => return Err(StatusCode::NOT_FOUND),
    };
    let user = UserDisp {
        email: row.email,
        username: row.username,
        address: row.address,
        profile_pic_path: match row.profile_pic_path {
            Some(val) => val,
            None => String::from("generic.jpg"),
        },
        contact_no: row.contact_no,
    };
    Ok(Json(user))
}
