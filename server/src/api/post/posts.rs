use super::json::*;
use crate::{
    auth::utils::validate_token,
    token_json::*,
    utils::{bytes_to_string, random_string, write_file},
    SharedState,
};
use axum::{
    extract::{Multipart, Path, State},
    http::StatusCode,
    response::Result,
    Json,
};
use chrono::Utc;
use sea_query::Iden;
use sqlx::{Pool, Postgres};
use tokio::fs::remove_file;

#[derive(Iden)]
pub enum Posts {
    PostId,
    Owner,
    Table,
    Title,
    Body,
    Visible,
    Sold,
    Price,
    Category,
}

async fn fetch_post(
    id: i32,
    seeker: Option<String>,
    pool: &Pool<Postgres>,
) -> Result<PostInfo, StatusCode> {
    match sqlx::query_as!(
        PostInfo,
        "select post_id,owner,title,
        body, category,open_timestamp as opening_timestamp,price,sold,image_paths as images,reports 
        from posts where post_id = $1 and (visible or owner = $2)",
        id,
        seeker
    )
    .fetch_one(pool)
    .await
    {
        Ok(val) => Ok(val),
        Err(_) => Err(StatusCode::NOT_FOUND),
    }
}

pub async fn get_post(
    State(state): State<SharedState>,
    Path(id): Path<i32>,
) -> Result<Json<PostInfo>, StatusCode> {
    Ok(Json(fetch_post(id, None, &state.read().await.pool).await?))
}

pub async fn get_post_as_owner(
    State(state): State<SharedState>,
    Path(id): Path<i32>,
    Json(payload): Json<ValidToken>,
) -> Result<Json<PostInfo>, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    Ok(Json(fetch_post(id, Some(payload.email), &st.pool).await?))
}

pub async fn get_post_cards(
    State(state): State<SharedState>,
    Json(payload): Json<Vec<i32>>,
) -> Result<Json<Vec<PostCard>>, StatusCode> {
    match sqlx::query!(
        "select title,price,image_paths from posts where post_id = any($1) and visible = $2",
        &payload,
        true
    )
    .fetch_all(&state.read().await.pool)
    .await
    {
        Ok(val) => Ok(Json(
            val.into_iter()
                .map(|row| PostCard {
                    title: row.title,
                    price: row.price,
                    image: match row.image_paths {
                        Some(paths) => match paths.split_once(',') {
                            Some(path) => Some(path.0.to_owned()),
                            None => Some(paths),
                        },
                        None => None,
                    },
                })
                .collect(),
        )),
        Err(_) => Err(StatusCode::NOT_FOUND),
    }
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
        Err(err) => {
            eprintln!("{}", err);
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}

pub async fn delete_post(
    State(state): State<SharedState>,
    Path(post_id): Path<i32>,
    Json(payload): Json<ValidToken>,
) -> Result<StatusCode, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    let img_paths = match sqlx::query!(
        "select image_paths from posts where post_id = $1 and owner = $2",
        post_id,
        payload.email
    )
    .fetch_one(&st.pool)
    .await
    {
        Ok(val) => val.image_paths,
        Err(_) => return Err(StatusCode::NOT_FOUND),
    };
    if let Some(img_paths) = img_paths {
        for f_path in img_paths.split(',') {
            if let Err(err) = remove_file(format!("res/{}", f_path)).await {
                eprintln!("{}", err);
            }
        }
    }

    match sqlx::query!(
        "delete from posts where post_id = $1 and owner = $2",
        post_id,
        payload.email
    )
    .execute(&st.pool)
    .await
    {
        Ok(_) => Ok(StatusCode::OK),
        Err(_) => Err(StatusCode::NOT_MODIFIED),
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
    let mut category: Option<String> = None;
    let mut price: i32 = 0;
    let mut images: Vec<(String, Vec<u8>)> = vec![];

    while let Some(field) = multipart.next_field().await.unwrap() {
        let name = &field.name().expect("Cannot get name from user").to_owned();
        let data = field.bytes().await.expect("Cannot get data from user");

        match name as &str {
            "token" => token = bytes_to_string(data)?,
            "email" => email = bytes_to_string(data)?,
            "title" => title = bytes_to_string(data)?,
            "body" => body = bytes_to_string(data)?,
            "category" => category = Some(bytes_to_string(data)?),
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
                let ext = &name[&name.len() - 4..];
                if !(ext == ".png" || ext == ".jpg") {
                    return Err(StatusCode::UNSUPPORTED_MEDIA_TYPE);
                }
                images.push((format!("{path_prefix}_{ext}"), data.to_vec()));
            }
            &_ => (),
        }
    }

    let st = state.read().await;
    validate_token(token, &email, st.jwt_secret_key).await?;

    let img_paths = images
        .iter()
        .map(|x| x.0.clone())
        .collect::<Vec<String>>()
        .join(",");

    if let Err(err) = sqlx::query!(
        "insert into posts(owner,title,body,price,visible,image_paths,category) values($1,$2,$3,$4,$5,$6,$7)",
        email,
        title,
        body,
        price,
        true,
        img_paths,
        category
    )
    .execute(&st.pool)
    .await
    {
        eprintln!("{}", err);
        return Err(StatusCode::EXPECTATION_FAILED);
    }

    for (name, img) in &images {
        write_file(name, img).await?;
    }
    Ok(StatusCode::CREATED)
}
