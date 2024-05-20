use axum::{
    extract::{Multipart, State},
    http::StatusCode,
    response::Result,
    Json,
};

use crate::schema::UserDisp;
use tokio::fs::File;
use tokio::io::AsyncWriteExt;

use crate::SharedState;

use super::auth::login::is_token_valid;

pub async fn get_user(
    State(state): State<SharedState>,
    email: String,
) -> Result<Json<UserDisp>, StatusCode> {
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
) -> StatusCode {
    let st = state.write().await;
    let mut fname = String::new();
    let mut email = String::new();
    let mut fdata: Vec<u8> = vec![];
    let mut token = String::new();

    while let Some(field) = multipart.next_field().await.unwrap() {
        let name = &field.name().expect("Cannot get name from user").to_string() as &str;
        let data = field.bytes().await.expect("Cannot get data from user");

        match name {
            "name" => fname = String::from_utf8(data.to_vec()).unwrap(),
            "email" => email = String::from_utf8(data.to_vec()).unwrap(),
            "data" => fdata = data.to_vec(),
            "token" => token = String::from_utf8(data.to_vec()).unwrap(),
            &_ => return StatusCode::UNAUTHORIZED,
        }
    }

    match is_token_valid(token, &email, st.jwt_secret_key) {
        true => (),
        false => {
            return StatusCode::UNAUTHORIZED;
        }
    };

    let mut file = File::create(format!("res/{email}_profile_{fname}"))
        .await
        .unwrap();
    match file.write_all(&fdata).await {
        Ok(_) => (),
        Err(_) => return StatusCode::INTERNAL_SERVER_ERROR,
    }
    match sqlx::query!(
        "update users set profile_pic_path = $1 where email = $2",
        fname,
        email
    )
    .execute(&st.pool)
    .await
    {
        Ok(_) => StatusCode::OK,
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR,
    }
}

pub async fn get_posts(
    State(state): State<SharedState>,
    email: String,
) -> Result<Json<Vec<i32>>, StatusCode> {
    let pool = &state.read().await.pool;
    let rows = match sqlx::query!(
        "select post_id from posts where owner = $1 and visible= $2",
        email,
        true
    )
    .fetch_all(pool)
    .await
    {
        Ok(val) => val,
        Err(_) => return Err(StatusCode::NOT_FOUND),
    };
    let mut posts: Vec<i32> = vec![];
    for row in rows.iter() {
        posts.push(row.post_id);
    }
    Ok(Json(posts))
}
