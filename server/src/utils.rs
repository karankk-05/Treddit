use axum::{body::Bytes, http::StatusCode};
use rand::{distributions::Alphanumeric, thread_rng, Rng};
use regex::Regex;
use tokio::{fs::File, io::AsyncWriteExt};

pub async fn write_file(name: &str, data: &[u8]) -> Result<(), StatusCode> {
    let mut file = match File::create(format!("res/{name}")).await {
        Ok(val) => val,
        Err(err) => {
            eprintln!("Cannot save file! {err}");
            return Err(StatusCode::INTERNAL_SERVER_ERROR);
        }
    };
    if let Err(err) = file.write_all(data).await {
        eprintln!("{}", err);
        return Err(StatusCode::INTERNAL_SERVER_ERROR);
    };
    Ok(())
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

pub fn sanitize_check_email(email: String) -> Result<String, StatusCode> {
    let email = email.trim().to_lowercase();
    let reg = Regex::new(r"^[a-zA-Z0-9-_\.]+@([a-zA-Z0-9-_\.]+\.)+[a-zA-Z0-9-_\.]{2,4}$").unwrap();
    match reg.is_match(&email) {
        true => Ok(email),
        false => Err(StatusCode::EXPECTATION_FAILED),
    }
}

#[cfg(test)]
mod tests {
    use crate::utils::sanitize_check_email;
    use axum::http::StatusCode;

    #[test]
    fn check_email_sanitization() {
        let sanitized_email = vec!["hallo@iitk.ac.in", "capital@h.com"];
        let unsanitized_email = vec![" hallo@iitk.ac.in ", "Capital@H.com "];
        for (unsanitezed, sanitized) in unsanitized_email
            .into_iter()
            .zip(sanitized_email.into_iter())
        {
            assert_eq!(
                sanitized,
                sanitize_check_email(unsanitezed.to_string()).unwrap()
            );
        }
    }

    #[test]
    fn check_mail_validation() {
        let invalid_emails = vec!["bh@@iitk.ac.in", "@iitk.ac.in", "abc@cd", "ab.df@hallo"];
        for invalid in invalid_emails {
            assert_eq!(
                sanitize_check_email(invalid.to_string()),
                Err(StatusCode::EXPECTATION_FAILED)
            );
        }
    }
}
