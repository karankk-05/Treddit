mod api;
mod storage;
mod token_json;
mod utils;

use aide::{
    axum::{
        routing::{delete, get, post, put},
        ApiRouter as Router, IntoApiResponse,
    },
    openapi::{Info, OpenApi},
};
use api::{
    chat,
    post::{self, posts, update as post_update, wishlist},
    user::{auth, users},
};
use axum::{http::Method, Extension, Json};
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
    let mut api = OpenApi {
        info: Info {
            description: Some("an example API".to_string()),
            ..Info::default()
        },
        ..OpenApi::default()
    };

    let port = env::var("PORT").expect("PORT not found");
    println!("Listening on port: {port}");
    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{port}"))
        .await
        .expect("Cannot bind to port");

    axum::serve(
        listener,
        app.finish_api(&mut api)
            .layer(Extension(api))
            .into_make_service(),
    )
    .await
    .expect("Cannot start axum server");
}

fn docs_setup() {
    if env::var_os("DOCS_RS").is_some() {
        println!("cargo:rustc-env=SQLX_OFFLINE=true");
    }
}
async fn serve_api(Extension(api): Extension<OpenApi>) -> impl IntoApiResponse {
    Json(api)
}

async fn create_router() -> Router {
    let cors = CorsLayer::new()
        .allow_methods([Method::GET, Method::POST, Method::PUT, Method::DELETE])
        .allow_origin(Any)
        .allow_headers(Any);

    let state = Arc::new(RwLock::new(create_state().await));
    let user_service = Router::new()
        .api_route("/new", post(auth::signup::create_user))
        .api_route("/update", put(users::change_user_info))
        .api_route("/wishlist", post(wishlist::get_wishlist))
        .api_route("/wishlist/add", post(wishlist::add_to_wishlist))
        .api_route("/wishlist/rm", delete(wishlist::remove_from_wishlist))
        .api_route("/jwt/verify", post(auth::login::is_token_valid))
        .api_route("/otp", post(auth::signup::send_otp))
        .api_route("/login", post(auth::login::login))
        .api_route("/info", post(users::get_user))
        .api_route("/info/private", post(users::get_user_private))
        .api_route("/profile/pic", put(users::change_profile_pic))
        .api_route("/posts", post(users::get_posts_as_owner))
        .api_route("/report", post(users::report_user))
        .api_route("/post", post(post::new::create_post));

    Router::new()
        .api_route("/posts/:id", get(posts::get_post))
        .api_route("/posts/:id", put(post_update::update_post))
        .api_route("/posts/:id", delete(posts::delete_post))
        .api_route("/posts/:id/owned", get(posts::get_post_as_owner))
        .api_route("/posts/cards", post(posts::get_post_cards))
        .api_route("/posts/unsold", get(posts::search_posts))
        .api_route("/posts/:id/chats/new", post(chat::postchat::send_chat))
        .api_route("/posts/:id/chats", post(chat::postchat::get_chat_ids))
        .api_route("/posts/:id/chatters", post(chat::postchat::get_chatters))
        .api_route("/posts/:id/report", post(posts::report_post))
        .api_route("/chats/:id", post(chat::postchat::get_chat))
        .api_route("/chats/bulk", post(chat::postchat::get_chats))
        .nest("/user", user_service)
        .route("/api.json", get(serve_api))
        .with_state(Arc::clone(&state))
        .nest_service("/res", ServeDir::new("res"))
        .layer(cors)
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
