mod api;
mod schema;

use api::{create_user, AppState};
use axum::{
    routing::{get, post},
    Router,
};
use sqlx::postgres::PgPoolOptions;

#[tokio::main]
async fn main() {
    let db_url = "postgres://postgres:secret@localhost:5432/KONNECT";
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(db_url)
        .await
        .expect("Cannot connect to db");

    let state = AppState { pool };
    tracing_subscriber::fmt::init();

    let app = Router::new()
        .route("/users", post(create_user))
        .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
    println!("Listening on port 3000");
}
