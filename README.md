# Aarogyam

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python)](https://python.org)
[![Flask](https://img.shields.io/badge/Flask-3.1-000000?logo=flask)](https://flask.palletsprojects.com)
[![IBM Watsonx](https://img.shields.io/badge/IBM-Watsonx.ai-052FAD?logo=ibm)](https://www.ibm.com/watsonx)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**AI-powered health literacy app with Ayurvedic guidance, medical report scanning, and first-aid guides.**

Aarogyam is an open-source mobile application that bridges traditional Ayurvedic knowledge with modern AI. Users can chat with an AI trained on Ayurvedic datasets, upload medical reports for plain-language summaries, and browse guided first-aid procedures — all in a single Flutter app backed by three Python microservices running on IBM Watsonx.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                       │
│  (Material 3 · Firebase Auth · flutter_dotenv · go_router)  │
└───────────────────────┬─────────────────────────────────────┘
                        │  HTTPS REST
          ┌─────────────┼──────────────┐
          │             │              │
          ▼             ▼              ▼
  ┌──────────────┐ ┌──────────┐ ┌─────────────────────┐
  │  rag-chatBot │ │lvm-watsonx│ │firstaid-object-     │
  │  (Flask 3.1) │ │(Flask 3.1)│ │storage (Flask 3.1)  │
  └──────┬───────┘ └────┬─────┘ └──────────┬──────────┘
         │              │                   │
         ▼              ▼                   ▼
  ┌─────────────────────────────┐  ┌────────────────────┐
  │       IBM Watsonx.ai        │  │  IBM Cloud Object  │
  │  Granite-13B + Slate-30M    │  │  Storage (COS)     │
  │  Mistral Pixtral-12B        │  └────────────────────┘
  └─────────────────────────────┘
         │
         ▼
  ┌─────────────────────┐
  │  IBM Watson TTS/STT │
  │  (voice in/out)     │
  └─────────────────────┘
         │
         ▼
  ┌──────────────────────┐
  │  Firebase (Auth +    │
  │  Cloud Firestore)    │
  └──────────────────────┘
```

---

## Tech Stack

| Layer | Technology | Version |
|---|---|---|
| Mobile app | Flutter (iOS & Android) | 3.x |
| App language | Dart | 3.x |
| Backend framework | Flask | 3.1.0 |
| Backend language | Python | 3.11 |
| RAG LLM | IBM Granite-13B-Instruct-v2 | via Watsonx.ai |
| RAG embeddings | IBM Slate-30M-English-RTRVR | via Watsonx.ai |
| Medical image AI | Mistral Pixtral-12B | via Watsonx.ai |
| Vector store | ChromaDB | 0.6.x |
| RAG framework | LangChain + LangChain-IBM | 0.3.x |
| Auth & database | Firebase Auth + Cloud Firestore | Firebase 3.x |
| Voice input | IBM Watson Speech-to-Text | REST API |
| Voice output | IBM Watson Text-to-Speech | REST API |
| First-aid media | IBM Cloud Object Storage | ibm-cos-sdk 2.x |
| Secret management | flutter_dotenv / python-dotenv | — |
| Deployment | Render.com (pip-based) | — |

---

## Repository Structure

```
aarogyam/
├── aarogyam-flutter/          # Flutter mobile application
│   ├── lib/
│   │   ├── authentication/    # Login, register, forgot-password screens
│   │   ├── backend/           # Firebase + API call helpers
│   │   ├── core/              # Router, base model, constants
│   │   ├── custom_code/       # TTS/STT action wrappers
│   │   ├── l10n/              # ARB translation files (en, hi, ar)
│   │   ├── main_pages/        # Chat, report scanner, first-aid, etc.
│   │   ├── theme/             # Material 3 AppTheme, AppColors
│   │   └── widgets/           # Shared widgets
│   ├── .env.example           # Required environment keys
│   └── pubspec.yaml
│
├── rag-chatBot/               # RAG chatbot (Granite-13B + LangChain + Chroma)
│   ├── flask_app/app.py
│   ├── AarogyamDataset.pdf    # Ayurvedic knowledge base
│   ├── .env.example
│   ├── render.yaml
│   └── requirements.txt
│
├── lvm-watsonx/               # Medical image analysis (Pixtral-12B)
│   ├── flask_app/app.py
│   ├── .env.example
│   ├── render.yaml
│   └── requirements.txt
│
├── firstaid-object-storage/   # IBM COS API for first-aid media
│   ├── app.py
│   ├── .env.example
│   ├── render.yaml
│   └── requirements.txt
│
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

---

## Quick Start

### 1 — RAG Chatbot (`rag-chatBot`)

```bash
cd rag-chatBot
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env          # fill in your Watsonx credentials
gunicorn flask_app.app:app --bind 0.0.0.0:5000 --workers 2
```

➡ API available at `http://localhost:5000`. See [`rag-chatBot/README.md`](rag-chatBot/README.md).

### 2 — LVM Image Analysis (`lvm-watsonx`)

```bash
cd lvm-watsonx
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
gunicorn flask_app.app:app --bind 0.0.0.0:5001 --workers 2
```

➡ API available at `http://localhost:5001`. See [`lvm-watsonx/README.md`](lvm-watsonx/README.md).

### 3 — First Aid Storage (`firstaid-object-storage`)

```bash
cd firstaid-object-storage
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
gunicorn -w 4 -b 0.0.0.0:5002 app:app
```

➡ API available at `http://localhost:5002`. See [`firstaid-object-storage/README.md`](firstaid-object-storage/README.md).

### 4 — Flutter App (`aarogyam-flutter`)

```bash
cd aarogyam-flutter
cp .env.example .env          # fill in all keys
flutter pub get
flutterfire configure         # links Firebase project
flutter run
```

See [`aarogyam-flutter/README.md`](aarogyam-flutter/README.md) for full setup.

---

## Environment Variables

All services use `.env` files locally. On Render.com, set these via the dashboard. **Never commit real `.env` files** — only `.env.example` is tracked.

### Flutter App (`aarogyam-flutter/.env`)

| Name | Required | Description |
|---|---|---|
| `WATSON_TTS_API_KEY` | ✅ | IBM Watson Text-to-Speech API key |
| `WATSON_TTS_ENDPOINT` | ✅ | Watson TTS instance endpoint URL |
| `WATSON_STT_API_KEY` | ✅ | IBM Watson Speech-to-Text API key |
| `WATSON_STT_ENDPOINT` | ✅ | Watson STT instance endpoint URL |
| `RAG_API_URL` | ✅ | Base URL of the deployed `rag-chatBot` service |
| `LVM_API_URL` | ✅ | Base URL of the deployed `lvm-watsonx` service |
| `FIRSTAID_API_URL` | ✅ | Base URL of the deployed `firstaid-object-storage` service |
| `FIREBASE_API_KEY` | ✅ | Firebase Web API key |
| `FIREBASE_AUTH_DOMAIN` | ✅ | Firebase Auth domain |
| `FIREBASE_PROJECT_ID` | ✅ | Firebase project ID |
| `FIREBASE_STORAGE_BUCKET` | ✅ | Firebase Storage bucket |
| `FIREBASE_MESSAGING_SENDER_ID` | ✅ | Firebase Cloud Messaging sender ID |
| `FIREBASE_APP_ID` | ✅ | Firebase App ID |
| `FIREBASE_MEASUREMENT_ID` | ✅ | Firebase Analytics measurement ID |

### RAG Chatbot (`rag-chatBot/.env`)

| Name | Required | Description |
|---|---|---|
| `WATSONX_API_KEY` | ✅ | IBM Cloud API key with Watsonx.ai access |
| `WATSONX_PROJECT_ID` | ✅ | Watsonx.ai project ID |
| `WATSONX_URL` | ✅ | Watsonx.ai regional endpoint (e.g. `https://eu-gb.ml.cloud.ibm.com`) |
| `CHROMA_DIR` | — | Chroma persistence path (default: `./chroma_db`) |
| `CHUNK_SIZE` | — | PDF chunk size in tokens (default: `512`) |
| `CHUNK_OVERLAP` | — | Chunk overlap (default: `50`) |
| `CORS_ORIGINS` | — | Allowed CORS origins (default: `*`) |

### LVM Image Analysis (`lvm-watsonx/.env`)

| Name | Required | Description |
|---|---|---|
| `WATSONX_API_KEY` | ✅ | IBM Cloud API key with Watsonx.ai access |
| `WATSONX_PROJECT_ID` | ✅ | Watsonx.ai project ID |
| `WATSONX_URL` | ✅ | Watsonx.ai regional endpoint (e.g. `https://eu-de.ml.cloud.ibm.com`) |
| `IMAGE_FETCH_TIMEOUT` | — | Timeout in seconds for upstream image fetch (default: `10`) |
| `CORS_ORIGINS` | — | Allowed CORS origins (default: `*`) |

### First Aid Storage (`firstaid-object-storage/.env`)

| Name | Required | Description |
|---|---|---|
| `COS_API_KEY_ID` | ✅ | IBM Cloud Object Storage API key |
| `COS_INSTANCE_CRN` | ✅ | COS service instance CRN |
| `COS_ENDPOINT` | ✅ | COS regional endpoint URL |
| `BUCKET_NAME` | ✅ | COS bucket containing first-aid media |

---

## API Endpoints

| Service | Method | Path | Description |
|---|---|---|---|
| rag-chatBot | `POST` | `/watsonchat` | Submit a health query; returns HTML-formatted Ayurvedic guidance |
| rag-chatBot | `GET` | `/health` | Liveness check; reports vector store state |
| lvm-watsonx | `POST` | `/process-image` | Analyze a medical report image; body: `{"image_url": "...", "user_query": "..."}` |
| lvm-watsonx | `GET` | `/health` | Liveness check |
| firstaid-object-storage | `GET` | `/list_objects?folder_name=<name>` | List first-aid media objects in a COS folder |
| firstaid-object-storage | `GET` | `/health` | Liveness check |

---

## Screenshots

> 📸 Screenshots coming soon. Run the app locally to preview.

---

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for the fork → branch → PR workflow, code style guidelines, and issue template notes.

---

## License

[MIT](LICENSE) © 2024 Aarogyam Contributors

---

## Authors

- Pranav Raut — [@rautpranav13](https://github.com/rautpranav13)
- Prit Thombare — [@thombareprit](https://github.com/thombareprit)
