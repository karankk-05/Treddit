use axum::{
    extract::{Multipart, Path, State},
    http::StatusCode,
    response::Result,
    Json,
};

use crate::schema::UserDisp;
use tokio::fs::File;
use tokio::io::AsyncWriteExt;

use crate::SharedState;

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

pub async fn change_profile_pic(
    State(state): State<SharedState>,
    mut multipart: Multipart,
) -> Result<String, StatusCode> {
    let mut fname = String::new();
    let mut email = String::new();
    while let Some(field) = multipart.next_field().await.unwrap() {
        let name = field.name().unwrap().to_string();
        let data = field.bytes().await.unwrap();
        if name == "name" {
            fname = String::from_utf8(data.to_vec()).unwrap();
        } else if name == "email" {
            email = String::from_utf8(data.to_vec()).unwrap();
        } else {
            let mut file = File::create(format!("res/{fname}")).await.unwrap();
            file.write_all(&data).await.unwrap();
        }
    }
    match sqlx::query!(
        "update users set profile_pic_path = $1 where email = $2",
        fname,
        email
    )
    .execute(&state.write().await.pool)
    .await
    {
        Ok(_) => Ok(fname),
        Err(_) => Err(StatusCode::INTERNAL_SERVER_ERROR),
    }
}
