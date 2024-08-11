mod api;
mod storage;
mod token_json;
mod utils;

use api::{
    chat,
    post::{self, posts, search as post_search, update as post_update, wishlist},
    user::{auth, users},
};
use axum::{
    http::Method,
    routing::{delete, get, post, put},
    Router,
};
use dotenvy::dotenv;
use rand::{thread_rng, RngCore};
use sqlx::{postgres::PgPoolOptions, Pool, Postgres};
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
        .route("/user/post", post(post::new::create_post))
        .route("/user/report", post(users::report_user))
        .route("/posts/:id", get(posts::get_post))
        .route("/posts/:id", put(post_update::update_post))
        .route("/posts/:id", delete(posts::delete_post))
        .route("/posts/:id/owned", get(posts::get_post_as_owner))
        .route("/posts/cards", post(posts::get_post_cards))
        .route("/posts/unsold", get(post_search::get_post_ids))
        .route("/posts/:id/chats/new", post(chat::postchat::send_chat))
        .route("/posts/:id/chats", post(chat::postchat::get_chat_ids))
        .route("/posts/:id/chatters", post(chat::postchat::get_chatters))
        .route("/posts/:id/report", post(posts::report_post))
        .route("/chats/:id", post(chat::postchat::get_chat))
        .route("/chats/bulk", post(chat::postchat::get_chats))
        .layer(cors)
        .with_state(Arc::clone(&state))
        .nest_service("/res", ServeDir::new("res"))
}

async fn configure_db() -> Pool<Postgres> {
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
    pool
}

async fn create_state() -> AppState {
    let pool = configure_db().await;
    let otp_storage: HashMap<String, Otp> = HashMap::new();
    let mail_pass = env::var("MAIL_PASSWD").expect("Mail password not found");
    let mail_id = env::var("MAIL_ID").unwrap_or("kampuskonnect@zohomail.in".to_owned());

    let mut jwt_secret_key = [0u8; 32];
    thread_rng().fill_bytes(&mut jwt_secret_key);

    AppState {
        pool,
        mail_id,
        mail_pass,
        otp_storage,
        jwt_secret_key: b"secretsecretsecretsecretsecretse".to_owned(), //Just for Testing
    }
}
