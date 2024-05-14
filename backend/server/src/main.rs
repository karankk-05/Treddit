mod api;
mod auth;
mod schema;

use api::{create_user, AppState};
use axum::{
    routing::{get, post},
    Router,
};
use dotenv::dotenv;
use sqlx::postgres::PgPoolOptions;
use std::env;

#[tokio::main]
async fn main() {
    dotenv().ok();
    let db_url = env::var("DATABASE_URL").expect("Database url not found");
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&db_url)
        .await
        .expect("Cannot connect to db");

    let state = AppState {
        pool,
        mail_pass: env::var("MAIL_PASSWD").expect("Mail password not found"),
    };
    tracing_subscriber::fmt::init();

    let app = Router::new()
        .route("/users", post(create_user))
        .route("/otp", post(auth::send_otp))
        .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
    println!("Listening on port 3000");
}
