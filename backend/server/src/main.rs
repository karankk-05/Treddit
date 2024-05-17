mod api;
mod schema;

use api::auth;
use axum::{routing::post, Router};
use dotenv::dotenv;
use schema::{AppState, Otp};
use sqlx::postgres::PgPoolOptions;
use std::{collections::HashMap, env, sync::Arc};
use tokio::sync::RwLock;

type SharedState = Arc<RwLock<AppState>>;

#[tokio::main]
async fn main() {
    dotenv().ok();
    let db_url = env::var("DATABASE_URL").expect("Database url not found");
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&db_url)
        .await
        .expect("Cannot connect to db");
    let otp_storage: HashMap<String, Otp> = HashMap::new();
    let mail_pass = env::var("MAIL_PASSWD").expect("Mail password not found");

    let st = AppState {
        pool,
        mail_pass,
        otp_storage,
    };
    let state = Arc::new(RwLock::new(st));

    tracing_subscriber::fmt::init();
    let app = Router::new()
        .route("/new", post(auth::signup::create_user))
        .route("/otp", post(auth::signup::send_otp))
        .route("/login", post(auth::login::login))
        .with_state(Arc::clone(&state));

    println!("Listening on port: 3000");
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
