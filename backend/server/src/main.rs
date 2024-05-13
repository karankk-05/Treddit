// use axum::{
//     routing::{get, post},
//     Router,
// };
//
// mod api;
// use api::{create_user, root};
use sqlx::Row;

#[tokio::main]
async fn main() {
    let db_url = "postgres://postgres:secret@localhost:5432";
    let pool = sqlx::postgres::PgPool::connect(db_url)
        .await
        .expect("Cannot connect to db");

    let res = sqlx::query("SELECT 1+1 AS SUM")
        .fetch_one(&pool)
        .await
        .unwrap();
    let sum: i32 = res.get("sum");
    println!("{}", sum);

    // tracing_subscriber::fmt::init();
    //
    // let app = Router::new()
    //     .route("/", get(root))
    //     .route("/users", post(create_user));
    //
    // let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    // axum::serve(listener, app).await.unwrap();
}
