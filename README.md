# Aarogyam 🏥

> **AI-powered health literacy platform** — bringing medical knowledge, first-aid guidance, and intelligent health assistance to every pocket.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.9%2B-3776AB?logo=python)](https://python.org)
[![Flask](https://img.shields.io/badge/Flask-3.1-black?logo=flask)](https://flask.palletsprojects.com)
[![IBM WatsonX](https://img.shields.io/badge/IBM-WatsonX%20AI-0530AD?logo=ibm)](https://www.ibm.com/watsonx)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Flutter App Setup](#flutter-app-setup)
  - [Backend Services Setup](#backend-services-setup)
- [Environment Variables](#environment-variables)
- [Running Tests](#running-tests)
- [Deployment](#deployment)
- [API Reference](#api-reference)
- [Tech Stack](#tech-stack)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

**Aarogyam** (Sanskrit: *आरोग्यम्* — "state of good health") is a production-grade, cross-platform health literacy application that combines a Flutter mobile app with three specialized AI/ML backend microservices:

| Service | Purpose | Technology |
|---------|---------|-----------|
| **Flutter App** | Cross-platform mobile client | Flutter 3, Firebase, Material 3 |
| **RAG Chatbot** | Health Q&A via Retrieval-Augmented Generation | LangChain, IBM WatsonX, ChromaDB |
| **LVM WatsonX** | Medical image analysis | IBM WatsonX (Pixtral-12B), Flask |
| **First Aid Storage** | First-aid image library | IBM Cloud Object Storage, Flask |

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                Flutter Mobile App                    │
│  Material 3 UI · GoRouter · Firebase Auth/Firestore  │
└────────────┬────────────┬──────────────┬─────────────┘
             │            │              │
    ┌────────▼──┐  ┌──────▼──────┐ ┌────▼──────────────┐
    │RAG Chatbot│  │LVM WatsonX  │ │First Aid Storage  │
    │  Flask    │  │  Flask      │ │  Flask            │
    │  /watsonchat│ │/process-image│ │/first-aid-images  │
    └────────┬──┘  └──────┬──────┘ └────┬──────────────┘
             │            │              │
    ┌────────▼──┐  ┌──────▼──────┐ ┌────▼──────────────┐
    │IBM WatsonX│  │IBM WatsonX  │ │IBM Cloud Object   │
    │Granite LLM│  │Pixtral-12B  │ │Storage (COS)      │
    │ChromaDB   │  │             │ │                   │
    └───────────┘  └─────────────┘ └───────────────────┘
```

---

## Features

### 📱 Mobile App
- **AI Health Chat** — RAG-powered chatbot answering health queries from curated medical PDFs
- **Medical Image Analysis** — Upload medical images for AI-powered analysis (lab reports, skin conditions, X-rays)
- **First Aid Guide** — Step-by-step visual first-aid instructions with cloud-hosted images
- **Medication Reminders** — Local push notifications with timezone-aware scheduling
- **Health Tracking** — Personal health metrics with Firestore persistence
- **Dark / Light Mode** — Material 3 adaptive theming with teal seed color
- **Offline-Ready** — Graceful degradation when backend services are unavailable

### 🔒 Security
- All API keys stored in `.env` files — never hardcoded
- Firebase Authentication (email/password + Google Sign-In)
- Input validation on all backend endpoints (length limits, type checks, URL scheme validation)
- Path traversal protection on file-serving endpoints
- CORS configured per environment

---

## Project Structure

```
aarogyam/
├── aarogyam-flutter/           # Flutter mobile application
│   ├── lib/
│   │   ├── app_state.dart      # Global app state
│   │   ├── main.dart           # Entry point + GoRouter
│   │   ├── flutter_flow/       # Core utilities (theme, navigation, etc.)
│   │   ├── custom_code/        # Custom actions & widgets
│   │   │   ├── actions/
│   │   │   │   ├── awesome_notification.dart   # Scheduled notifications
│   │   │   │   └── immediate_notification.dart # Immediate notifications
│   │   │   └── widgets/
│   │   └── pages/              # App screens
│   ├── android/                # Android build config
│   │   ├── app/build.gradle    # compileSdk 36, AGP 8.11.1
│   │   └── settings.gradle     # Kotlin 2.2.20
│   ├── test/
│   │   ├── unit/               # 65 unit tests
│   │   ├── widget/             # 20 widget tests
│   │   └── integration/        # Smoke integration tests
│   └── pubspec.yaml
│
├── rag-chatBot/                # RAG chatbot backend
│   ├── flask_app/
│   │   └── app.py              # LCEL chain, WatsonX LLM + Embeddings
│   ├── tests/
│   │   └── test_app.py         # 13 pytest tests
│   ├── requirements.txt
│   └── .env.example
│
├── lvm-watsonx/                # Large Vision Model backend
│   ├── flask_app/
│   │   └── app.py              # Image analysis, URL validation
│   ├── tests/
│   │   └── test_app.py         # 10 pytest tests
│   ├── requirements.txt
│   └── .env.example
│
├── firstaid-object-storage/    # First Aid image storage backend
│   ├── app.py                  # COS integration, path traversal protection
│   ├── tests/
│   │   └── test_app.py         # 13 pytest tests
│   ├── requirements.txt
│   └── .env.example
│
├── pytest.ini                  # Pytest configuration
├── conftest.py                 # Root conftest
└── README.md
```

---

## Getting Started

### Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter SDK | ≥ 3.22.x | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | ≥ 3.4.x | Bundled with Flutter |
| Android Studio / Xcode | Latest stable | For device/emulator |
| Python | ≥ 3.9 | [python.org](https://python.org) |
| Firebase CLI | Latest | `npm install -g firebase-tools` |
| IBM Cloud account | — | [cloud.ibm.com](https://cloud.ibm.com) |

---

### Flutter App Setup

```bash
# 1. Clone the repository
git clone https://github.com/your-org/aarogyam.git
cd aarogyam/aarogyam-flutter

# 2. Install Flutter dependencies
flutter pub get

# 3. Configure environment variables
cp .env.example .env
# Edit .env with your API endpoints and keys (see Environment Variables section)

# 4. Set up Firebase
# a. Create a Firebase project at https://console.firebase.google.com
# b. Enable Authentication (Email/Password + Google)
# c. Enable Firestore Database
# d. Download google-services.json → android/app/
# e. Download GoogleService-Info.plist → ios/Runner/

# 5. Run the app
flutter run

# 6. Build for Android
flutter build apk --release
```

---

### Backend Services Setup

Each backend is an independent Flask microservice. Set up each one you need:

#### RAG Chatbot

```bash
cd rag-chatBot

# Create virtual environment
python3 -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your IBM WatsonX credentials

# Add your medical PDF documents to flask_app/pdfs/

# Run locally
cd flask_app && flask run --port 5001

# Production
gunicorn app:app --bind 0.0.0.0:5001 --workers 2
```

#### LVM WatsonX

```bash
cd lvm-watsonx
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env
cd flask_app && flask run --port 5002
```

#### First Aid Storage

```bash
cd firstaid-object-storage
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env
flask run --port 5003
```

---

## Environment Variables

### Flutter App (`aarogyam-flutter/.env`)

```env
# Backend API URLs
RAG_CHATBOT_URL=https://your-rag-chatbot.onrender.com
LVM_WATSONX_URL=https://your-lvm-watsonx.onrender.com
FIRSTAID_STORAGE_URL=https://your-firstaid-storage.onrender.com
```

### RAG Chatbot (`rag-chatBot/.env`)

```env
WATSONX_API_KEY=your_ibm_watsonx_api_key
WATSONX_URL=https://us-south.ml.cloud.ibm.com
WATSONX_PROJECT_ID=your_watsonx_project_id
CORS_ORIGINS=*
```

### LVM WatsonX (`lvm-watsonx/.env`)

```env
WATSONX_API_KEY=your_ibm_watsonx_api_key
WATSONX_URL=https://eu-de.ml.cloud.ibm.com
WATSONX_PROJECT_ID=your_watsonx_project_id
IMAGE_FETCH_TIMEOUT=10
CORS_ORIGINS=*
```

### First Aid Storage (`firstaid-object-storage/.env`)

```env
COS_API_KEY_ID=your_ibm_cos_api_key
COS_INSTANCE_CRN=crn:v1:bluemix:public:cloud-object-storage:...
COS_ENDPOINT=https://s3.ap.cloud-object-storage.appdomain.cloud
BUCKET_NAME=aarogyamfirstaid
CORS_ORIGINS=*
```

> ⚠️ **Never commit `.env` files.** They are listed in `.gitignore`. Use `.env.example` as a template.

---

## Running Tests

### Flutter Tests

```bash
cd aarogyam-flutter

# Unit tests (65 tests)
flutter test test/unit/

# Widget tests (20 tests)
flutter test test/widget/

# Integration tests
flutter test test/integration/

# All tests
flutter test

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Python Backend Tests

Run each service's tests independently:

```bash
# RAG Chatbot — 13 tests
cd rag-chatBot && python -m pytest tests/ -v

# LVM WatsonX — 10 tests
cd lvm-watsonx && python -m pytest tests/ -v

# First Aid Storage — 13 tests
cd firstaid-object-storage && python -m pytest tests/ -v
```

Or run all Python tests at once (from repo root):

```bash
python -m pytest rag-chatBot/tests/ lvm-watsonx/tests/ firstaid-object-storage/tests/ -v
```

**Test summary:**

| Suite | Tests | Status |
|-------|-------|--------|
| Flutter Unit | 65 | ✅ Passing |
| Flutter Widget | 20 | ✅ Passing |
| Flutter Integration | ~5 | ✅ Passing |
| RAG Chatbot (Python) | 13 | ✅ Passing |
| LVM WatsonX (Python) | 10 | ✅ Passing |
| First Aid Storage (Python) | 13 | ✅ Passing |
| **Total** | **~126** | ✅ **All Passing** |

---

## Deployment

All three Python backends are designed for **[Render.com](https://render.com)** free-tier deployment.

### Render.com Deployment

1. Push your code to GitHub
2. Create a new **Web Service** on Render for each backend
3. Set **Build Command**: `pip install -r requirements.txt`
4. Set **Start Command**:
   - RAG Chatbot: `gunicorn app:app --chdir flask_app`
   - LVM WatsonX: `gunicorn app:app --chdir flask_app`
   - First Aid: `gunicorn app:app`
5. Add environment variables in the Render dashboard (from `.env.example`)

### Flutter Release Build

```bash
cd aarogyam-flutter

# Android APK
flutter build apk --release

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

---

## API Reference

### RAG Chatbot

**Base URL:** `https://your-rag-chatbot.onrender.com`

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check |
| `POST` | `/watsonchat` | Ask a health question |

**POST /watsonchat**
```json
// Request
{ "query": "What are the side effects of Ibuprofen?" }

// Response 200
{ "response": "Ibuprofen can cause ...", "query": "..." }

// Response 400 — validation error
{ "error": "query must be a non-empty string" }
```

---

### LVM WatsonX

**Base URL:** `https://your-lvm-watsonx.onrender.com`

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check |
| `POST` | `/process-image` | Analyse a medical image |

**POST /process-image**
```json
// Request
{
  "image_url": "https://example.com/lab-report.jpg",
  "user_query": "Summarize the key findings in this lab report"
}

// Response 200
{ "status": "success", "response": "<body>...</body>" }

// Response 400 — invalid URL scheme
{ "status": "error", "message": "Invalid URL scheme 'ftp'. Only http and https are allowed." }
```

**Constraints:**
- `image_url` must use `http://` or `https://` scheme
- `user_query` max length: 5,000 characters

---

### First Aid Storage

**Base URL:** `https://your-firstaid-storage.onrender.com`

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check |
| `GET` | `/first-aid-images?folder_name=burns` | List images in a folder |

**GET /first-aid-images**
```
?folder_name=burns

// Response 200
{ "folder": "burns", "images": ["https://cos.../burns/step1.jpg", ...] }

// Response 400 — path traversal attempt
{ "error": "folder_name contains invalid or unsafe characters" }

// Response 404 — folder is empty
{ "folder": "burns", "images": [] }
```

**Security:** Path traversal (`../`), null bytes, shell injection characters, and folder names > 128 chars are all rejected with 400.

---

## Tech Stack

### Flutter App

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_local_notifications` | ^18.0.1 | Push notifications |
| `timezone` | ^0.9.4 | Timezone-aware scheduling |
| `firebase_core` | latest | Firebase SDK |
| `firebase_auth` | latest | Authentication |
| `cloud_firestore` | latest | Database |
| `google_fonts` | latest | Poppins / Manrope typography |
| `font_awesome_flutter` | ^11.0.0 | Icons |
| `audioplayers` | ^6.8.1 | Audio playback |
| `record` | ^7.1.1 | Audio recording |
| `flutter_dotenv` | latest | Environment variables |
| `go_router` | latest | Navigation |

### Android Build Stack

| Component | Version |
|-----------|---------|
| Gradle | 8.13 |
| Android Gradle Plugin | 8.11.1 |
| Kotlin | 2.2.20 |
| compileSdk / targetSdk | 36 |
| minSdk | 23 |
| coreLibraryDesugaring | enabled |

### Python Backends

| Package | Version | Purpose |
|---------|---------|---------|
| `flask` | 3.1.0 | Web framework |
| `flask-cors` | 5.0.0 | CORS support |
| `gunicorn` | 23.0.0 | WSGI server |
| `ibm-watsonx-ai` | 1.3.11 | IBM WatsonX SDK |
| `langchain` | 0.3.20 | LLM orchestration |
| `langchain-core` | 0.3.55 | LCEL chain primitives |
| `langchain-ibm` | 0.3.8 | WatsonX LLM/Embeddings |
| `langchain-chroma` | 0.2.2 | ChromaDB vector store |
| `langchain-text-splitters` | 0.3.8 | Document chunking |
| `chromadb` | 0.6.3 | Vector database |
| `pypdf` | 5.3.0 | PDF processing |
| `ibm-boto3` | latest | IBM Cloud Object Storage |
| `python-dotenv` | 1.0.1 | Environment variables |

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Make your changes, ensuring:
   - `flutter analyze` returns **0 issues**
   - All Flutter tests pass: `flutter test`
   - All Python tests pass per service: `python -m pytest tests/ -v`
   - No API keys or secrets are hardcoded
4. Commit: `git commit -m "feat: description"`
5. Push: `git push origin feat/your-feature`
6. Open a Pull Request

### Code Style
- **Flutter/Dart**: follow `flutter_lints` rules; run `dart format .`
- **Python**: PEP 8; use `black` for formatting, `flake8` for linting

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ for better health literacy everywhere
</p>
