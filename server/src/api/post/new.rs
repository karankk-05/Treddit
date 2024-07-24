use chrono::Utc;
use sqlx::{prelude::FromRow, PgPool};
use std::collections::HashSet;
use std::path::Path as OsPath;

use crate::{
    auth::utils::validate_token,
    utils::{bytes_to_string, random_string, write_file},
    SharedState,
};
use axum::{
    extract::{Multipart, State},
    http::StatusCode,
    response::Result,
};

#[derive(FromRow)]
struct Post {
    email: String,
    title: String,
    body: String,
    price: i32,
    visible: bool,
    images: Vec<(String, Vec<u8>)>,
    category: Option<String>,
}
impl Default for Post {
    fn default() -> Self {
        Post {
            email: String::new(),
            title: String::new(),
            body: String::new(),
            price: 0,
            visible: true,
            category: None,
            images: Vec::new(),
        }
    }
}
impl Post {
    fn get_img_paths(&self) -> String {
        let paths = &self
            .images
            .iter()
            .map(|x| x.0.clone())
            .collect::<Vec<String>>()
            .join(",");
        paths.to_string()
    }
    async fn savepost(&self, pool: &PgPool) -> Result<(), StatusCode> {
        if let Err(err) = sqlx::query!(
        "insert into posts(owner,title,body,price,visible,image_paths,category) values($1,$2,$3,$4,$5,$6,$7)",
        self.email,
        self.title,
        self.body,
        self.price,
        self.visible,
        self.get_img_paths(),
        self.category
        )
    .execute(pool)
    .await
    {
        eprintln!("{}", err);
        return Err(StatusCode::EXPECTATION_FAILED);
    }

        for (name, img) in &self.images {
            write_file(name, img).await?;
        }
        Ok(())
    }
}

fn get_extension(name: &str) -> Result<String, StatusCode> {
    let err = Err(StatusCode::UNSUPPORTED_MEDIA_TYPE);
    match OsPath::new(name).extension() {
        Some(val) => Ok(match val.to_str() {
            Some(val) => val.to_owned(),
            None => return err,
        }),
        None => err,
    }
}

fn validate_extenstion(ext: &str) -> Result<(), StatusCode> {
    match HashSet::from(["png", "jpg", "jpeg"]).contains(ext) {
        true => Ok(()),
        false => Err(StatusCode::UNSUPPORTED_MEDIA_TYPE),
    }
}

pub async fn create_post(
    State(state): State<SharedState>,
    mut multipart: Multipart,
) -> Result<StatusCode, StatusCode> {
    let mut token = String::new();
    let mut post = Post::default();
    let required_fields = HashSet::from(["email", "token", "title", "body", "price"]);
    let mut acquired_fields: HashSet<String> = HashSet::new();

    while let Ok(Some(field)) = multipart.next_field().await {
        let name = field.name().expect("Cannot get name from user").to_owned();
        let data = match field.bytes().await {
            Ok(val) => val,
            Err(err) => {
                eprintln!("{:?}", err);
                return Err(StatusCode::PARTIAL_CONTENT);
            }
        };

        match &name as &str {
            "token" => token = bytes_to_string(data)?,
            "email" => post.email = bytes_to_string(data)?,
            "title" => post.title = bytes_to_string(data)?,
            "body" => post.body = bytes_to_string(data)?,
            "category" => post.category = Some(bytes_to_string(data)?),
            "price" => {
                post.price = match bytes_to_string(data)?.parse() {
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
                let ext = get_extension(&name)?;
                validate_extenstion(&ext)?;
                post.images
                    .push((format!("{path_prefix}.{ext}"), data.to_vec()));
            }
            _ => (),
        }
        acquired_fields.insert(name);
    }
    if !required_fields.is_subset(&acquired_fields.iter().map(|x| x as &str).collect()) {
        return Err(StatusCode::EXPECTATION_FAILED);
    }

    let st = state.read().await;
    validate_token(token, &post.email, st.jwt_secret_key).await?;
    post.savepost(&st.pool).await?;

    Ok(StatusCode::CREATED)
}
