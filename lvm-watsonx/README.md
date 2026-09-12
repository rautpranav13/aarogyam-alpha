# lvm-watsonx

Medical image analysis backend for Aarogyam. Accepts a public image URL and a natural-language query, fetches and base64-encodes the image, then passes both to **Mistral Pixtral-12B** on IBM Watsonx.ai. Returns HTML-formatted analysis suitable for display in the Flutter app.

---

## Use case

The Flutter report scanner screen uploads a medical report image (lab results, prescriptions, X-ray reports) and submits the image URL together with a prompt such as _"Extract all medications and their dosages from this report."_ This service handles the Watsonx.ai multimodal inference and returns structured HTML.

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
cd lvm-watsonx
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

Edit `.env` with your credentials. See [Environment Variables](#environment-variables).

### 4. Run locally

```bash
gunicorn flask_app.app:app --bind 0.0.0.0:5001 --workers 2 --timeout 120
```

The API is available at `http://localhost:5001`.

---

## Environment Variables

| Name | Required | Description | Example |
|---|---|---|---|
| `WATSONX_API_KEY` | ✅ | IBM Cloud API key with Watsonx.ai access | `abc123...` |
| `WATSONX_PROJECT_ID` | ✅ | Watsonx.ai project ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `WATSONX_URL` | ✅ | Watsonx.ai regional endpoint | `https://eu-de.ml.cloud.ibm.com` |
| `IMAGE_FETCH_TIMEOUT` | — | Timeout (seconds) for the upstream image fetch | `10` |
| `CORS_ORIGINS` | — | Allowed CORS origins | `*` |

---

## API Endpoints

### `POST /process-image`

Analyze a medical image with a custom query.

**Request body**

```json
{
  "image_url": "https://storage.example.com/reports/lab-report-2024.jpg",
  "user_query": "Extract all medications and dosages from this report."
}
```

Both fields are required and must be non-empty strings.

**Response `200`**

```json
{
  "status": "success",
  "response": "<body><h3>Medications Found</h3><ul><li><b>Metformin</b> 500mg twice daily</li></ul></body>"
}
```

**Error responses**

| Status | Body | Condition |
|---|---|---|
| `400` | `{"error": "image_url and user_query are required"}` | Missing or empty field |
| `500` | `{"status": "error", "message": "..."}` | Image fetch failure or model error |

---

### `GET /health`

Liveness check.

**Response `200`**

```json
{
  "status": "ok"
}
```

---

## Deployment on Render.com

Configured in [`render.yaml`](render.yaml).

**Required env vars to set in the Render dashboard:**

- `WATSONX_API_KEY`
- `WATSONX_PROJECT_ID`

`WATSONX_URL` and `IMAGE_FETCH_TIMEOUT` have defaults in `render.yaml`.

**Start command:**
```
gunicorn flask_app.app:app --bind 0.0.0.0:$PORT --workers 2 --timeout 120
```

---

## Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flask` | 3.1.0 | Web framework |
| `gunicorn` | 23.0.0 | WSGI server |
| `ibm-watsonx-ai` | 1.3.11 | Watsonx.ai SDK (Pixtral-12B inference) |
| `requests` | 2.32.x | Upstream image fetch |
| `python-dotenv` | 1.0.1 | `.env` loading |
