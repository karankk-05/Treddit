mod api;
mod models;
mod storage;
mod utils;

use api::{
    chat,
    post::{posts, wishlist},
    user::{auth, users},
};
use axum::{
    http::Method,
    routing::{delete, get, post, put},
    Router,
};
use dotenvy::dotenv;
use rand::{thread_rng, RngCore};
use sqlx::postgres::PgPoolOptions;
use std::{collections::HashMap, env, sync::Arc};
use storage::{AppState, Otp};
use tokio::sync::RwLock;
use tower_http::{
    cors::{Any, CorsLayer},
    services::ServeDir,
};

type SharedState = Arc<RwLock<AppState>>;

#[tokio::main]
async fn main() {
    dotenv().ok();
    docs_setup();
    tracing_subscriber::fmt::init();

    create_dir_str().await;
    let app = create_router().await;

    let port = env::var("PORT").expect("PORT not found");
    println!("Listening on port: {port}");
    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{port}"))
        .await
        .expect("Cannot bind to port");

    axum::serve(listener, app)
        .await
        .expect("Cannot start axum server");
}

fn docs_setup() {
    if std::env::var_os("DOCS_RS").is_some() {
        println!("cargo:rustc-env=SQLX_OFFLINE=true");
    }
}

async fn create_dir_str() {
    println!("Creating directory structure!");
    utils::mkdir_or_panic("res").await;
    utils::mkdir_or_panic("pgdata").await;
    println!("Directory structure completed!")
}

async fn create_router() -> Router {
    let cors = CorsLayer::new()
        .allow_methods([Method::GET, Method::POST, Method::PUT, Method::DELETE])
        .allow_origin(Any)
        .allow_headers(Any);

    let state = Arc::new(RwLock::new(create_state().await));
    Router::new()
        .route("/user/new", post(auth::signup::create_user))
        .route("/user/update", put(users::change_user_info))
        .route("/user/wishlist", post(wishlist::get_wishlist))
        .route("/user/wishlist/add", post(wishlist::add_to_wishlist))
        .route("/user/wishlist/rm", delete(wishlist::remove_from_wishlist))
        .route("/user/jwt/verify", post(auth::login::is_token_valid))
        .route("/user/otp", post(auth::signup::send_otp))
        .route("/user/login", post(auth::login::login))
        .route("/user/info", post(users::get_user))
        .route("/user/info/private", post(users::get_user_private))
        .route("/user/profile/pic", put(users::change_profile_pic))
        .route("/user/posts", post(users::get_posts))
        .route("/user/passwd", put(auth::signup::change_password))
        .route("/user/post", post(posts::create_post))
        .route("/user/report", post(users::report_user))
        .route("/posts/:id", get(posts::get_post))
        .route("/posts/:id", put(posts::change_post))
        .route("/posts/:id", delete(posts::delete_post))
        .route("/posts/:id/owned", get(posts::get_post_as_owner))
        .route("/posts/cards", post(posts::get_post_cards))
        .route("/posts/all", get(posts::get_all_posts_id))
        .route("/posts/unsold", get(posts::get_all_posts_id_unsold))
        .route("/posts/:id/chats/new", post(chat::postchat::send_chat))
        .route("/posts/:id/chats", get(chat::postchat::get_chat_ids))
        .route("/posts/:id/report", post(posts::report_post))
        .route("/chats/:id", get(chat::postchat::get_chat))
        .layer(cors)
        .with_state(Arc::clone(&state))
        .nest_service("/res", ServeDir::new("res"))
}

async fn create_state() -> AppState {
    let db_url = env::var("DATABASE_URL").expect("DATABASE_URL not found");
    let pool = PgPoolOptions::new()
        .max_connections(10)
        .connect(&db_url)
        .await
        .expect("Cannot Connect to DB");
    sqlx::migrate!("./migrations")
        .run(&pool)
        .await
        .expect("Cannot create db structure");
    let otp_storage: HashMap<String, Otp> = HashMap::new();
    let mail_pass = env::var("MAIL_PASSWD").expect("Mail password not found");
    let mut jwt_secret_key = [0u8; 32];
    thread_rng().fill_bytes(&mut jwt_secret_key);

    AppState {
        pool,
        mail_id: env::var("MAIL_ID").unwrap_or("kampuskonnect@zohomail.in".to_owned()),
        mail_pass,
        otp_storage,
        jwt_secret_key: b"secretsecretsecretsecretsecretse".to_owned(), //Just for Testing
    }
}
