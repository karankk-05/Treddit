use super::json::*;
use super::search::{search_post_ids, PageFilter};
use crate::{auth::utils::validate_token, token_json::*, SharedState};
use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    response::Result,
    Json,
};
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
    Purpose,
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

pub async fn search_posts(
    State(state): State<SharedState>,
    Query(filters): Query<PageFilter>,
) -> Result<Json<Vec<i32>>, StatusCode> {
    let st = state.read();
    search_post_ids(&st.await.pool, filters, false).await
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
