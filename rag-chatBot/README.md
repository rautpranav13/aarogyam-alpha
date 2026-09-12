# rag-chatBot

RAG (Retrieval-Augmented Generation) chatbot backend for Aarogyam. Answers health queries with Ayurvedic guidance using **IBM Granite-13B-Instruct-v2**, **LangChain**, and **ChromaDB** as the vector store.

---

## How it works

1. At startup, `AarogyamDataset.pdf` (Ayurvedic knowledge base) is split into chunks and embedded using IBM Slate-30M-English-RTRVR.
2. Embeddings are persisted to `./chroma_db/`. Subsequent starts skip re-embedding and load the existing store (<5 s cold start vs. ~60 s on first run).
3. Incoming queries are augmented with a prompt that requests HTML-formatted Ayurvedic guidance, then passed through a `RetrievalQA` chain backed by Granite-13B.
4. Identical queries within a session are served from an in-process dict cache.

---

## Prerequisites

| Requirement | Version |
|---|---|
| Python | 3.11 |
| pip | latest |

---

## Local Setup

### 1. Create and activate a virtual environment

```bash
cd rag-chatBot
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. 🔧 Configure environment variables

```bash
cp .env.example .env
```

Edit `.env` with your IBM Cloud credentials. See [Environment Variables](#environment-variables).

### 4. Run locally

```bash
gunicorn flask_app.app:app --bind 0.0.0.0:5000 --workers 2 --timeout 120
```

The API is available at `http://localhost:5000`.

> **First startup note:** On first run, the service builds the Chroma vector store by embedding the PDF. This takes approximately 60 seconds. All subsequent startups load the persisted store in under 5 seconds.

---

## Environment Variables

| Name | Required | Description | Example |
|---|---|---|---|
| `WATSONX_API_KEY` | ✅ | IBM Cloud API key with Watsonx.ai access | `abc123...` |
| `WATSONX_PROJECT_ID` | ✅ | Watsonx.ai project ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `WATSONX_URL` | ✅ | Watsonx.ai regional endpoint | `https://eu-gb.ml.cloud.ibm.com` |
| `CHROMA_DIR` | — | Path to persist/load the Chroma vector store | `./chroma_db` |
| `CHUNK_SIZE` | — | Token chunk size for PDF splitting | `512` |
| `CHUNK_OVERLAP` | — | Overlap between adjacent chunks | `50` |
| `CORS_ORIGINS` | — | Allowed CORS origins (`*` permits all) | `https://your-app.onrender.com` |

---

## API Endpoints

### `POST /watsonchat`

Submit a natural-language health question. Returns HTML-formatted Ayurvedic guidance.

**Request**

```json
{
  "query": "What are Ayurvedic remedies for managing blood pressure?"
}
```

**Response `200`**

```json
{
  "response": "<body><h3>Ayurvedic Remedies for Blood Pressure</h3><ul>...</ul></body>"
}
```

**Error responses**

| Status | Condition |
|---|---|
| `400` | `query` field is missing or empty |
| `500` | Vector store not initialised, or model invocation failed |

---

### `GET /health`

Liveness check. Also reports vector store readiness.

**Response `200`**

```json
{
  "status": "ok",
  "vectorstore": "ready"
}
```

---

## Deployment on Render.com

This service is deployed on Render.com using the configuration in [`render.yaml`](render.yaml).

**Required env vars to set in the Render dashboard** (marked `sync: false` in `render.yaml` — not committed):

- `WATSONX_API_KEY`
- `WATSONX_PROJECT_ID`

All other values (`WATSONX_URL`, `CHROMA_DIR`, `CHUNK_SIZE`, `CHUNK_OVERLAP`) have defaults set in `render.yaml` and do not need to be set manually unless you want to override them.

**Start command:**
```
gunicorn flask_app.app:app --bind 0.0.0.0:$PORT --workers 2 --timeout 120
```

> **Render free tier note:** The Chroma vector store is built into the ephemeral filesystem on first deploy. If the service is spun down (Render free tier sleeps inactive services), the next cold start will rebuild the store (~60 s). Upgrade to a paid plan with a persistent disk for zero-rebuild behaviour.

---

## Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flask` | 3.1.0 | Web framework |
| `gunicorn` | 23.0.0 | WSGI server |
| `ibm-watsonx-ai` | 1.3.11 | Watsonx.ai SDK |
| `langchain` | 0.3.x | RAG orchestration |
| `langchain-ibm` | 0.3.x | LangChain ↔ Watsonx bridge |
| `langchain-chroma` | 0.2.x | LangChain ↔ Chroma bridge |
| `chromadb` | 0.6.x | Vector store |
| `pypdf` | 5.x | PDF text extraction |
| `python-dotenv` | 1.0.1 | `.env` loading |
