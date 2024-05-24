use axum::{body::Bytes, http::StatusCode};
use rand::{distributions::Alphanumeric, thread_rng, Rng};

pub fn bytes_to_string(data: Bytes) -> Result<String, StatusCode> {
    match String::from_utf8(data.to_vec()) {
        Ok(val) => Ok(val),
        Err(_) => Err(StatusCode::UNPROCESSABLE_ENTITY),
    }
}

pub fn random_string(n: usize) -> String {
    thread_rng()
        .sample_iter(&Alphanumeric)
        .take(n)
        .map(char::from)
        .collect()
}
