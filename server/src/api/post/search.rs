use super::posts::Posts;
use axum::{http::StatusCode, Json};
use sea_query::{Expr, PostgresQueryBuilder, Query as SeaQuery};
use serde::Deserialize;
use sqlx::postgres::PgPool;
use sqlx::Row;

#[derive(Deserialize, Clone)]
pub struct PageFilter {
    pub search_query: Option<String>,
    pub category: Option<String>,
    pub purpose: Option<String>,
    pub min_price: Option<i32>,
    pub max_price: Option<i32>,
    pub owner: Option<String>,
}

fn sanitize_query(search_query: String) -> String {
    let max_length = 50;
    let mut sanitized_query = search_query.trim().to_owned();
    sanitized_query = sanitized_query.chars().take(max_length).collect();
    sanitized_query
        .retain(|c| c.is_alphanumeric() || c.is_ascii_punctuation() || c.is_ascii_whitespace());
    sanitized_query
}

fn build_filter_query(filters: PageFilter, is_owner: bool) -> String {
    let mut search_sql = SeaQuery::select()
        .column(Posts::PostId)
        .from(Posts::Table)
        .to_owned();

    if !is_owner {
        search_sql.and_where(Expr::col(Posts::Visible).is(true));
        search_sql.and_where(Expr::col(Posts::Sold).is(false));
    }

    if let Some(owner) = filters.owner {
        search_sql.and_where(Expr::col(Posts::Owner).eq(owner));
    };

    if let Some(category) = filters.category {
        search_sql.and_where(Expr::col(Posts::Category).eq(category));
    };

    if let Some(min) = filters.min_price {
        search_sql.and_where(Expr::col(Posts::Price).gte(min));
    };

    if let Some(max) = filters.max_price {
        search_sql.and_where(Expr::col(Posts::Price).lte(max));
    };

    if let Some(purpose) = filters.purpose {
        search_sql.and_where(Expr::col(Posts::Purpose).eq(purpose));
    }

    if let Some(search_query) = filters.search_query {
        let sanitized_query = sanitize_query(search_query);
        if !sanitized_query.is_empty() {
            search_sql.and_where(Expr::cust_with_values(
                "text_search @@ plainto_tsquery($1)",
                [&sanitized_query],
            ));
            search_sql.order_by_expr(
                Expr::cust_with_values(
                    "ts_rank(text_search, plainto_tsquery($1))",
                    [sanitized_query],
                ),
                sea_query::Order::Desc,
            );
        }
    }

    search_sql.to_string(PostgresQueryBuilder)
}

pub async fn search_post_ids(
    pool: &PgPool,
    filters: PageFilter,
    is_owner: bool,
) -> Result<Json<Vec<i32>>, StatusCode> {
    let filter_query = build_filter_query(filters, is_owner);
    match sqlx::query(&filter_query).fetch_all(pool).await {
        Ok(val) => Ok(Json(
            val.into_iter().map(|row| row.get("post_id")).collect(),
        )),
        Err(err) => {
            eprintln!("{:?}", err);
            Err(StatusCode::EXPECTATION_FAILED)
        }
    }
}
