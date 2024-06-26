use crate::{models::*, utils::write_file};
use axum::{
    extract::{Multipart, State},
    http::StatusCode,
    response::Result,
    Json,
};

use sqlx::{Pool, Postgres};

use crate::{
    auth::utils::validate_token,
    models::{ReportUser, UserDisp},
    utils::bytes_to_string,
    SharedState,
};

pub async fn get_user(
    State(state): State<SharedState>,
    Json(payload): Json<Email>,
) -> Result<Json<UserDisp>, StatusCode> {
    let st = state.read().await;
    let user = find_user(payload.email, &st.pool).await?;
    Ok(Json(user.disp))
}

pub async fn get_user_private(
    State(state): State<SharedState>,
    Json(payload): Json<ValidToken>,
) -> Result<Json<User>, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    let user = find_user(payload.email, &st.pool).await?;
    Ok(Json(user))
}

pub async fn change_user_info(
    State(state): State<SharedState>,
    Json(payload): Json<ChUser>,
) -> Result<StatusCode, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    let user = find_user(payload.email.clone(), &st.pool).await?;
    match sqlx::query!(
        "update users set username = $1,contact_no = $2,address = $3 where email = $4",
        payload.username.unwrap_or(user.disp.username),
        payload.contact_no.unwrap_or(user.contact_no),
        payload.address.unwrap_or(user.disp.address),
        payload.email,
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

async fn find_user(email: String, pool: &Pool<Postgres>) -> Result<User, StatusCode> {
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
            profile_pic_path: row.profile_pic_path.unwrap_or(String::from("generic.jpg")),
        },
        contact_no: row.contact_no,
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
            "name" => fname = bytes_to_string(data)?,
            "email" => email = bytes_to_string(data)?,
            "data" => fdata = data.to_vec(),
            "token" => token = bytes_to_string(data)?,
            &_ => return Err(StatusCode::UNAUTHORIZED),
        }
    }

    let st = state.read().await;
    validate_token(token, &email, st.jwt_secret_key).await?;

    write_file(&format!("res/{email}_profile_{fname}"), &fdata).await?;

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
    Json(payload): Json<Email>,
) -> Result<Json<Vec<i32>>, StatusCode> {
    let pool = &state.read().await.pool;
    match sqlx::query!(
        "select post_id from posts where owner = $1 and visible= $2",
        payload.email,
        true
    )
    .fetch_all(pool)
    .await
    {
        Ok(val) => Ok(Json(val.iter().map(|x| x.post_id).collect())),
        Err(_) => Err(StatusCode::NOT_FOUND),
    }
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
