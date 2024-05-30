mod api;
mod models;
mod utils;

use api::{auth, chat, post, user};
use axum::{
    routing::{get, post, put},
    Router,
};
use dotenvy::dotenv;
use models::{AppState, Otp};
use rand::{thread_rng, RngCore};
use sqlx::postgres::PgPoolOptions;
use std::{collections::HashMap, env, sync::Arc};
use tokio::sync::RwLock;
use tower_http::services::ServeDir;

type SharedState = Arc<RwLock<AppState>>;

#[tokio::main]
async fn main() {
    dotenv().ok();
    tracing_subscriber::fmt::init();

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

async fn create_router() -> Router {
    let state = Arc::new(RwLock::new(create_state().await));
    Router::new()
        .route("/user/new", post(auth::signup::create_user))
        .route("/user/otp", post(auth::signup::send_otp))
        .route("/user/login", post(auth::login::login))
        .route("/user/info", post(user::get_user))
        .route("/user/profile/pic", put(user::change_profile_pic))
        .route("/user/posts", post(user::get_posts))
        .route("/user/passwd", put(auth::signup::change_password))
        .route("/user/post", post(post::create_post))
        .route("/user/report", post(user::report_user))
        .route("/posts/:id", get(post::get_post))
        .route("/posts/:id/chats/new", post(chat::postchat::send_chat))
        .route("/posts/:id/chats", post(chat::postchat::get_chat_ids))
        .route("/posts/:id/visible", put(post::change_post_visibility))
        .route("/posts/:id/report", post(post::report_post))
        .route("/chats/:id", post(chat::postchat::get_chat))
        .with_state(Arc::clone(&state))
        .nest_service("/res", ServeDir::new("res"))
}

async fn create_state() -> AppState {
    let db_url = env::var("DATABASE_URL").expect("DATABASE_URL not found");
    let pool = PgPoolOptions::new()
        .max_connections(5)
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
        mail_pass,
        otp_storage,
        jwt_secret_key: b"secretsecretsecretsecretsecretse".to_owned(), //Just for Testing
    }
}
