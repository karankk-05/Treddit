use std::collections::HashMap;

use super::auth::login::is_token_valid;
use crate::schema::Post;
use crate::SharedState;
use axum::{
    extract::{Multipart, Path, State},
    http::StatusCode,
    response::Result,
    Json,
};
use chrono::Utc;
use serde::Deserialize;
use tokio::fs::File;
use tokio::io::AsyncWriteExt;

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
            None => String::new(),
        },
        reports: row.reports,
    };
    Ok(Json(post))
}

pub async fn create_post(State(state): State<SharedState>, mut multipart: Multipart) -> StatusCode {
    let mut email = String::new();
    let mut token = String::new();
    let mut title = String::new();
    let mut body = String::new();
    let mut price: i32 = 0;
    let mut images: HashMap<String, Vec<u8>> = HashMap::new();
    let path_prefix = format!("{}{}", Utc::now().format("%Y-%m-%d %H:%M:%S"), email);

    while let Some(field) = multipart.next_field().await.unwrap() {
        let name = &field.name().expect("Cannot get name from user").to_string() as &str;
        let data = field.bytes().await.expect("Cannot get data from user");

        match name {
            "token" => token = String::from_utf8(data.to_vec()).unwrap(),
            "email" => email = String::from_utf8(data.to_vec()).unwrap(),
            "title" => title = String::from_utf8(data.to_vec()).unwrap(),
            "body" => body = String::from_utf8(data.to_vec()).unwrap(),
            "price" => price = String::from_utf8(data.to_vec()).unwrap().parse().unwrap(),
            _ if name[..3] == "img".to_string() => {
                images.insert(format!("{path_prefix}_{name}"), data.to_vec());
            }
            &_ => (),
        }
    }

    let st = state.read().await;
    match is_token_valid(token, &email, st.jwt_secret_key).await {
        true => (),
        false => {
            return StatusCode::UNAUTHORIZED;
        }
    };

    for (name, img) in &images {
        let mut file = File::create(format!("res/{name}")).await.unwrap();
        match file.write_all(&img).await {
            Ok(_) => (),
            Err(_) => return StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
    let img_paths: Vec<String> = images.keys().cloned().collect();
    let img_paths = img_paths.join(",");

    sqlx::query!(
        "insert into posts(owner,title,body,price,visible,image_paths) values($1,$2,$3,$4,$5,$6)",
        email,
        title,
        body,
        price,
        true,
        img_paths
    )
    .execute(&st.pool)
    .await
    .unwrap();

    StatusCode::CREATED
}

#[derive(Deserialize)]
pub struct ChangePostVis {
    token: String,
    email: String,
    visible: bool,
}
pub async fn change_post_visibility(
    State(state): State<SharedState>,
    Path(post_id): Path<i32>,
    Json(payload): Json<ChangePostVis>,
) -> StatusCode {
    let st = state.read().await;
    match is_token_valid(payload.token, &payload.email, st.jwt_secret_key).await {
        true => (),
        false => {
            return StatusCode::UNAUTHORIZED;
        }
    };
    match sqlx::query!(
        "update posts set visible = $1 where owner = $2 and post_id = $3",
        payload.visible,
        payload.email,
        post_id,
    )
    .execute(&st.pool)
    .await
    {
        Ok(_) => StatusCode::OK,
        Err(_) => StatusCode::NOT_FOUND,
    }
}
