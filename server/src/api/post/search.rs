use super::posts::Posts;
use crate::SharedState;
use axum::{
    extract::{Query, State},
    http::StatusCode,
    Json,
};
use sea_query::{Expr, PostgresQueryBuilder, Query as SeaQuery};
use serde::Deserialize;
use sqlx::Row;

#[derive(Deserialize)]
pub struct PageFilter {
    pub search_str: Option<String>,
    pub category: Option<String>,
    pub min_price: Option<i32>,
    pub max_price: Option<i32>,
    pub owner: Option<String>,
}

fn build_search_query(filters: PageFilter) -> String {
    let mut search_query = SeaQuery::select()
        .column(Posts::PostId)
        .from(Posts::Table)
        .and_where(Expr::col(Posts::Visible).is(true))
        .and_where(Expr::col(Posts::Sold).is(false))
        .to_owned();

    if let Some(owner) = filters.owner {
        search_query.and_where(Expr::col(Posts::Owner).eq(owner));
    };

    if let Some(category) = filters.category {
        search_query.and_where(Expr::col(Posts::Category).eq(category));
    };

    if let Some(min) = filters.min_price {
        search_query.and_where(Expr::col(Posts::Price).gte(min));
    };

    if let Some(max) = filters.max_price {
        search_query.and_where(Expr::col(Posts::Price).lte(max));
    };

    if let Some(search_str) = &filters.search_str {
        if !search_str.is_empty() {
            search_query.and_where(Expr::cust_with_values(
                "text_search @@ plainto_tsquery($1)",
                [search_str],
            ));
            search_query.order_by_expr(
                Expr::cust_with_values("ts_rank(text_search, plainto_tsquery($1))", [search_str]),
                sea_query::Order::Desc,
            );
        }
    }

    search_query.to_string(PostgresQueryBuilder)
}

pub async fn get_post_ids(
    State(state): State<SharedState>,
    Query(filters): Query<PageFilter>,
) -> Result<Json<Vec<i32>>, StatusCode> {
    let st = state.read();
    let search_query = build_search_query(filters);

    match sqlx::query(&search_query).fetch_all(&st.await.pool).await {
        Ok(val) => Ok(Json(
            val.into_iter().map(|row| row.get("post_id")).collect(),
        )),
        Err(err) => {
            eprintln!("{:?}", err);
            Err(StatusCode::EXPECTATION_FAILED)
        }
    }
}
