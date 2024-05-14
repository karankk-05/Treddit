use crate::SharedState;

use super::schema::OTP;
use axum::{self, extract::State, http::StatusCode};
use lettre::message::header::ContentType;
use lettre::transport::smtp::authentication::Credentials;
use lettre::{Message, SmtpTransport, Transport};
use rand::Rng;
use std::collections::HashMap;
use std::time::{Duration, SystemTime};

fn generate_otp() -> u16 {
    let mut rng = rand::thread_rng();
    let otp = rng.gen_range(1000..=9999);
    otp
}

pub fn verify_otp(email: String, otp: u16, otp_storage: &mut HashMap<String, OTP>) -> bool {
    let stored_otp = &otp_storage.remove(&email);
    println!("{:?}", otp_storage);
    println!("Hallo ");
    match stored_otp {
        Some(val) => {
            println!("bacho");
            println!("{}{}{}{}", otp, email, val.otp, val.email);
            if !val.expired() && val.email == email && val.otp == otp {
                true
            } else {
                false
            }
        }
        None => false,
    }
}

pub async fn send_otp(State(state): State<SharedState>, payload: String) -> StatusCode {
    let mailid = "kampuskonnect@zohomail.in";
    let mut st = state.write().await;
    let otp = generate_otp();

    let email = Message::builder()
        .from(mailid.to_owned().parse().unwrap())
        .to(payload.to_owned().parse().unwrap())
        .subject(String::from("OTP recieved!"))
        .header(ContentType::TEXT_PLAIN)
        .body(String::from(format!(
            "Your OTP for Kampus Konnect is {}",
            &otp
        )))
        .unwrap();

    let creds = Credentials::new(mailid.to_owned(), st.mail_pass.to_owned());

    // Open a remote connection to mail
    let mailer = SmtpTransport::relay("smtp.zoho.in")
        .unwrap()
        .credentials(creds)
        .build();

    // Send the email
    match mailer.send(&email) {
        Ok(_) => {
            let exp = SystemTime::now() + Duration::from_secs(10 * 60);
            st.otp_storage.insert(
                payload.clone(),
                OTP {
                    otp,
                    email: payload,
                    exp,
                },
            );
            println!("{:?}", st.otp_storage);
            StatusCode::OK
        }
        Err(_) => StatusCode::SERVICE_UNAVAILABLE,
    }
}
