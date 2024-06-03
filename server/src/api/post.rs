use std::collections::HashMap;

use crate::{
    auth::utils::validate_token,
    models::{ChangePostVis, Post, ReportPost},
    utils::{bytes_to_string, random_string},
    SharedState,
};
use axum::{
    extract::{Multipart, Path, State},
    http::StatusCode,
    response::Result,
    Json,
};
use chrono::Utc;
use tokio::fs::File;
use tokio::io::AsyncWriteExt;

pub async fn get_all_posts_id(
    State(state): State<SharedState>,
) -> Result<Json<Vec<i32>>, StatusCode> {
    match sqlx::query!("select post_id from posts")
        .fetch_all(&state.write().await.pool)
        .await
    {
        Ok(val) => Ok(Json(val.iter().map(|x| x.post_id).collect())),
        Err(err) => {
            eprintln!("{}", err);
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}

pub async fn get_post(
    State(state): State<SharedState>,
    Path(id): Path<i32>,
) -> Result<Json<Post>, StatusCode> {
    let row = match sqlx::query!("select * from posts where post_id = $1", id)
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

pub async fn report_post(
    State(state): State<SharedState>,
    Path(post_id): Path<i32>,
    Json(payload): Json<ReportPost>,
) -> Result<StatusCode, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    match sqlx::query!(
        "select exists (
    select 1
    from post_reports
    where post_id = $1 and email = $2)",
        post_id,
        payload.email
    )
    .fetch_one(&st.pool)
    .await
    {
        Ok(rec) => match rec.exists {
            Some(exists) => {
                if exists {
                    return Err(StatusCode::ALREADY_REPORTED);
                }
            }
            None => return Err(StatusCode::INTERNAL_SERVER_ERROR),
        },
        Err(err) => {
            eprintln!("{:?}", err);
            return Err(StatusCode::INTERNAL_SERVER_ERROR);
        }
    };

    match sqlx::query!(
        "insert into post_reports(email,statement,post_id) values ($1,$2,$3)",
        payload.email,
        payload.statement,
        post_id
    )
    .execute(&st.pool)
    .await
    {
        Ok(_) => Ok(StatusCode::OK),
        Err(_) => Err(StatusCode::INTERNAL_SERVER_ERROR),
    }
}

pub async fn create_post(
    State(state): State<SharedState>,
    mut multipart: Multipart,
) -> Result<StatusCode, StatusCode> {
    let mut email = String::new();
    let mut token = String::new();
    let mut title = String::new();
    let mut body = String::new();
    let mut price: i32 = 0;
    let mut images: HashMap<String, Vec<u8>> = HashMap::new();

    while let Some(field) = multipart.next_field().await.unwrap() {
        let name = &field.name().expect("Cannot get name from user").to_owned();
        let data = field.bytes().await.expect("Cannot get data from user");

        match name as &str {
            "token" => token = bytes_to_string(data)?,
            "email" => email = bytes_to_string(data)?,
            "title" => title = bytes_to_string(data)?,
            "body" => body = bytes_to_string(data)?,
            "price" => {
                price = match bytes_to_string(data)?.parse() {
                    Ok(val) => val,
                    Err(_) => return Err(StatusCode::UNPROCESSABLE_ENTITY),
                }
            }
            _ if name[..3] == *"img" => {
                let path_prefix = format!(
                    "{}_{}",
                    Utc::now().format("%Y-%m-%d %H:%M:%S"),
                    random_string(5)
                );
                images.insert(format!("{path_prefix}_{name}"), data.to_vec());
            }
            &_ => (),
        }
    }

    let st = state.read().await;
    validate_token(token, &email, st.jwt_secret_key).await?;

    let img_paths: Vec<String> = images.keys().cloned().collect();
    let img_paths = img_paths.join(",");

    match sqlx::query!(
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
    {
        Ok(_) => (),
        Err(_) => return Err(StatusCode::INTERNAL_SERVER_ERROR),
    }

    for (name, img) in &images {
        let mut file = match File::create(format!("res/{name}")).await {
            Ok(val) => val,
            Err(err) => {
                eprintln!("Cannot save file! {err}");
                return Err(StatusCode::INTERNAL_SERVER_ERROR);
            }
        };
        match file.write_all(img).await {
            Ok(_) => (),
            Err(_) => return Err(StatusCode::INTERNAL_SERVER_ERROR),
        }
    }
    Ok(StatusCode::CREATED)
}

pub async fn change_post_visibility(
    State(state): State<SharedState>,
    Path(post_id): Path<i32>,
    Json(payload): Json<ChangePostVis>,
) -> Result<StatusCode, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    match sqlx::query!(
        "update posts set visible = $1 where owner = $2 and post_id = $3",
        payload.visible,
        payload.email,
        post_id,
    )
    .execute(&st.pool)
    .await
    {
        Ok(_) => Ok(StatusCode::OK),
        Err(_) => Err(StatusCode::NOT_FOUND),
    }
}
