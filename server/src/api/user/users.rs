use super::json::*;
use crate::post::search::{search_post_ids, PageFilter};
use crate::token_json::ValidToken;
use crate::utils::write_file;
use crate::{auth::utils::validate_token, utils::bytes_to_string, SharedState};
use axum::{
    extract::{Multipart, Query, State},
    http::StatusCode,
    response::Result,
    Json,
};
use sea_query::{Expr, Iden, PostgresQueryBuilder, Query as SeaQuery};
use sqlx::{Pool, Postgres};

#[derive(Iden)]
enum Users {
    Email,
    Username,
    ContactNo,
    Address,
    Table,
}

pub async fn get_user(
    State(state): State<SharedState>,
    Json(payload): Json<Email>,
) -> Result<Json<UserDisp>, StatusCode> {
    let st = state.read().await;
    let user = find_user(&payload.email, &st.pool, false).await?;
    Ok(Json(user.disp))
}

pub async fn get_user_private(
    State(state): State<SharedState>,
    Json(payload): Json<ValidToken>,
) -> Result<Json<User>, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    let user = find_user(&payload.email, &st.pool, true).await?;
    Ok(Json(user))
}

fn build_update_query(payload: ChUser) -> String {
    let mut update_query = SeaQuery::update()
        .table(Users::Table)
        .and_where(Expr::col(Users::Email).eq(payload.email))
        .to_owned();

    if let Some(username) = payload.username {
        update_query.value(Users::Username, username);
    }
    if let Some(contact_no) = payload.contact_no {
        update_query.value(Users::ContactNo, contact_no);
    }
    if let Some(address) = payload.address {
        update_query.value(Users::Address, address);
    }
    update_query.to_string(PostgresQueryBuilder)
}

pub async fn change_user_info(
    State(state): State<SharedState>,
    Json(payload): Json<ChUser>,
) -> Result<StatusCode, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token.clone(), &payload.email, st.jwt_secret_key).await?;
    match sqlx::query(&build_update_query(payload))
        .execute(&st.pool)
        .await
    {
        Ok(_) => Ok(StatusCode::OK),
        Err(err) => {
            eprintln!("{}", err);
            Err(StatusCode::NOT_MODIFIED)
        }
    }
}

async fn find_user(
    email: &str,
    pool: &Pool<Postgres>,
    is_master: bool,
) -> Result<User, StatusCode> {
    let row = match sqlx::query!("select * from users where email = $1", email)
        .fetch_one(pool)
        .await
    {
        Ok(val) => val,
        Err(_) => return Err(StatusCode::NOT_FOUND),
    };

    Ok(User {
        disp: UserDisp {
            email: row.email,
            username: row.username,
            address: row.address,
            profile_pic_path: row.profile_pic_path,
            contact_no: {
                match row.contact_visible || is_master {
                    true => Some(row.contact_no),
                    false => None,
                }
            },
        },
        reports: row.reports,
    })
}

pub async fn change_profile_pic(
    State(state): State<SharedState>,
    mut multipart: Multipart,
) -> Result<StatusCode, StatusCode> {
    let mut fname = String::new();
    let mut email = String::new();
    let mut fdata: Vec<u8> = vec![];
    let mut token = String::new();

    while let Some(field) = multipart.next_field().await.unwrap() {
        let name = &field.name().expect("Cannot get name from user").to_owned();
        let data = field.bytes().await.expect("Cannot get data from user");

        match name as &str {
            "fname" => fname = bytes_to_string(data)?,
            "email" => email = bytes_to_string(data)?,
            "data" => fdata = data.to_vec(),
            "token" => token = bytes_to_string(data)?,
            &_ => return Err(StatusCode::UNAUTHORIZED),
        }
    }

    let ext = &fname[&fname.len() - 4..];
    if !(ext == ".png" || ext == ".jpg") {
        return Err(StatusCode::UNSUPPORTED_MEDIA_TYPE);
    }

    let st = state.read().await;
    validate_token(token, &email, st.jwt_secret_key).await?;

    write_file(&format!("{email}_profile_{fname}"), &fdata).await?;

    match sqlx::query!(
        "update users set profile_pic_path = $1 where email = $2",
        fname,
        email
    )
    .execute(&st.pool)
    .await
    {
        Ok(_) => Ok(StatusCode::OK),
        Err(err) => {
            eprintln!("{}", err);
            Err(StatusCode::NOT_MODIFIED)
        }
    }
}

pub async fn get_posts(
    State(state): State<SharedState>,
    Query(mut filters): Query<PageFilter>,
    Json(payload): Json<Email>,
) -> Result<Json<Vec<i32>>, StatusCode> {
    let pool = &state.read().await.pool;
    filters.owner = Some(payload.email);
    search_post_ids(pool, filters, true).await
}

pub async fn report_user(
    State(state): State<SharedState>,
    Json(payload): Json<ReportUser>,
) -> Result<StatusCode, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    match sqlx::query!(
        "select exists (
    select 1
    from user_reports
    where accused = $1 and email = $2)",
        payload.accused,
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
        "insert into user_reports(email,statement,accused) values ($1,$2,$3)",
        payload.email,
        payload.statement,
        payload.accused
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
