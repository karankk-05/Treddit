use axum::{body::Bytes, http::StatusCode};

pub fn bytes_to_string(data: Bytes) -> Result<String, StatusCode> {
    match String::from_utf8(data.to_vec()) {
        Ok(val) => Ok(val),
        Err(_) => return Err(StatusCode::UNPROCESSABLE_ENTITY),
    }
}
