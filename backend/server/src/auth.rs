use super::api::AppState;
use axum::{self, extract::State, http::StatusCode};
use lettre::message::header::ContentType;
use lettre::transport::smtp::authentication::Credentials;
use lettre::{Message, SmtpTransport, Transport};
use rand::Rng;

fn generate_otp() -> u16 {
    let mut rng = rand::thread_rng();
    let otp = rng.gen_range(1000..=9999);
    otp
}

pub async fn send_otp(State(state): State<AppState>, payload: String) -> StatusCode {
    let email = Message::builder()
        .from("kampuskonnect@zohomail.in".parse().unwrap())
        .to(payload.parse().unwrap())
        .subject(String::from("OTP recieved!"))
        .header(ContentType::TEXT_PLAIN)
        .body(String::from(format!(
            "Your OTP for Kampus Konnect is {}",
            generate_otp()
        )))
        .unwrap();

    let creds = Credentials::new(
        "kampuskonnect@zohomail.in".to_owned(),
        state.mail_pass.to_owned(),
    );

    // Open a remote connection to gmail
    let mailer = SmtpTransport::relay("smtp.zoho.in")
        .unwrap()
        .credentials(creds)
        .build();

    // Send the email
    match mailer.send(&email) {
        Ok(_) => StatusCode::OK,
        Err(_) => StatusCode::SERVICE_UNAVAILABLE,
    }
}
