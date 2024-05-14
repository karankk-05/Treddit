mod api;
mod auth;
mod schema;

use api::create_user;
use axum::{
    routing::{get, post},
    Router,
};
use dotenv::dotenv;
use schema::{AppState, OTP};
use sqlx::postgres::PgPoolOptions;
use std::{collections::HashMap, env, sync::Arc};
use tokio::sync::{Mutex, RwLock};

#[tokio::main]
async fn main() {
    dotenv().ok();
    let db_url = env::var("DATABASE_URL").expect("Database url not found");
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&db_url)
        .await
        .expect("Cannot connect to db");
    let otp_storage: HashMap<String, OTP> = HashMap::new();
    let mail_pass = env::var("MAIL_PASSWD").expect("Mail password not found");

    let st = AppState {
        pool,
        mail_pass,
        otp_storage,
    };
    // let state = Arc::new(RwLock::new(st));

    tracing_subscriber::fmt::init();
    let app = Router::new()
        .route("/users", post(create_user))
        .route("/otp", post(auth::send_otp))
        .with_state(st);

    println!("Listening on port: 3000");
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
