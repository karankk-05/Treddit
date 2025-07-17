**Treddit/KampusKonnect**

A full-stack marketplace and community app for IIT Kanpur, allowing users to signup/login, post items (buy/sell/lost & found), chat, and manage profiles via a Flutter frontend and a Rust backend.

---

## Table of Contents

1. [Features](#features)
2. [Tech Stack](#tech-stack)
3. [Architecture](#architecture)
4. [Repository Structure](#repository-structure)
5. [Prerequisites](#prerequisites)
6. [Environment Variables](#environment-variables)
7. [Installation & Setup](#installation--setup)

   * [Backend](#backend)
   * [Frontend](#frontend)
8. [Running the Application](#running-the-application)
9. [API Reference](#api-reference)
10. [Domain Modules Overview](#domain-modules-overview)
11. [Deployment](#deployment)
12. [Contributing](#contributing)
13. [License](#license)

---

## Features

* **Authentication**: Signup, login, and secure JWT-based sessions
* **Posts**: Create, read, update, delete marketplace posts with images
* **Lost & Found**: Separate module for reporting and finding lost items
* **Chat**: Direct messaging between users
* **Wishlist & Reports**: Save posts to wishlist and report inappropriate content
* **User Profiles**: View and edit user details, change password

## Tech Stack

* **Frontend**: Flutter (Dart)
* **Backend**: Rust (Actix-web)
* **Database**: PostgreSQL (via SQLx and migrations)
* **Containerization**: Docker, Docker Compose
* **Hosting**: Render.com

## Architecture

The app follows a domain-driven structure:

* **Frontend**: Organized under `lib/domains`, each domain (auth, addpost, homepage, chat, lost\_n\_found, myposts, user\_details) contains screens, services, providers, and widgets.
* **Backend**: Actix-web server in Rust under `src`, with route modules for `api/user`, `api/post`, and `api/chat`. Migrations manage database schema.

## Repository Structure

```bash
├── frontend/Treddit/        # Flutter mobile app
│   ├── lib/
│   │   └── domains/         # Feature modules
│   ├── main.dart
│   └── pubspec.yaml
├── server/                  # Actix-web backend
│   ├── src/
│   │   ├── api/             # Route handlers
│   │   ├── main.rs
│   │   └── utils.rs
│   ├── migrations/          # SQL migration files
│   ├── Dockerfile
│   └── docker-compose.test.yaml
└── README.md                # <-- You are here
```

## Prerequisites

* **Flutter SDK**
* **Rust & Cargo**
* **PostgreSQL**
* **Docker & Docker Compose**

## Environment Variables

Create a `.env` file in the `server/` directory with:

```
DATABASE_URL=postgres://<user>:<pass>@<host>:<port>/<db_name>
JWT_SECRET=<your_jwt_secret>
PORT=8000
```

## Installation & Setup

### Backend

1. Navigate to the server folder:

   ```bash
   cd server
   ```
2. Install Rust dependencies and build:

   ```bash
   cargo build --release
   ```
3. Run migrations:

   ```bash
   sqlx migrate run
   ```
4. Start the server:

   ```bash
   cargo run --release
   ```

### Frontend

1. Navigate to the Flutter project:

   ```bash
   cd frontend/Treddit
   ```
2. Install dependencies:

   ```bash
   flutter pub get
   ```
3. Run on emulator or device:

   ```bash
   flutter run
   ```

## Running the Application

* Backend will run by default on `http://localhost:8000`
* Frontend connects to the server URL (ensure correct base API URL in Flutter services)

## API Reference

### Authentication

| Endpoint           | Method | Description        |
| ------------------ | ------ | ------------------ |
| `/api/user/signup` | POST   | Create new account |
| `/api/user/login`  | POST   | Obtain JWT token   |

### Posts

| Endpoint                       | Method | Description          |
| ------------------------------ | ------ | -------------------- |
| `/api/post/new`                | POST   | Create a new post    |
| `/api/post/posts`              | GET    | Fetch all posts      |
| `/api/post/search`             | GET    | Search posts by text |
| `/api/post/update/{post_id}`   | PUT    | Update post details  |
| `/api/post/wishlist/{user_id}` | GET    | Fetch user wishlist  |

### Chat

| Endpoint             | Method | Description                 |
| -------------------- | ------ | --------------------------- |
| `/api/chat/postchat` | POST   | Send message in chat thread |

## Domain Modules Overview

* **Auth**: Screens (`login.dart`, `signup.dart`), Services (`auth_action.dart`), Widgets (`custom_text_field.dart`)
* **AddPost**: Screens (`add_post_page.dart`), Image upload service
* **Homepage**: Post list, search bar, detail viewer
* **MyPosts**: CRUD operations for user’s own posts
* **Lost\_N\_Found**: Reporting lost/found items
* **Chat**: Provider-based chat service and detail screen
* **User\_Details**: Profile view/edit, password change

## Deployment

* Build and containerize backend using `Dockerfile`, deploy to Render platform
* Use Flutter web build or package the mobile app for Play Store/App Store
