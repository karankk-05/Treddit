use axum::{body::Bytes, http::StatusCode};
use rand::{distributions::Alphanumeric, thread_rng, Rng};
use tokio::{
    fs::{create_dir, File},
    io::{self, AsyncWriteExt},
};

pub async fn write_file(name: &str, data: &[u8]) -> Result<(), StatusCode> {
    let mut file = match File::create(format!("res/{name}")).await {
        Ok(val) => val,
        Err(err) => {
            eprintln!("Cannot save file! {err}");
            return Err(StatusCode::INTERNAL_SERVER_ERROR);
        }
    };
    match file.write_all(data).await {
        Ok(_) => Ok(()),
        Err(err) => {
            eprintln!("{}", err);
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}

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

pub async fn mkdir_or_panic(path: &str) {
    match create_dir(path).await {
        Ok(_) => println!("created directory {}", path),
        Err(err) => match err.kind() {
            io::ErrorKind::AlreadyExists => println!("{} already exists", path),
            _ => panic!("Cannot create directory"),
        },
    }
}
