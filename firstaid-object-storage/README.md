# firstaid-object-storage

IBM Cloud Object Storage (COS) proxy for Aarogyam's first-aid media. The Flutter app calls this service to retrieve lists of image and video URLs stored in a COS bucket, organised by first-aid category folder.

---

## How it works

Each first-aid category (e.g. `burns/`, `choking/`, `cpr/`) is a folder prefix in the COS bucket. The service lists all objects under the requested prefix and returns their public URLs. The Flutter app then renders the media directly from COS.

---

## Prerequisites

| Requirement | Version |
|---|---|
| Python | 3.11 |
| pip | latest |
| IBM Cloud account | — |
| IBM COS bucket | — |

---

## IBM Cloud Object Storage Setup

1. Log in to [IBM Cloud](https://cloud.ibm.com) and create a **Cloud Object Storage** service instance.
2. Create a bucket (e.g. `aarogyamfirstaid`) in your preferred region.
3. Upload first-aid media organised as folder prefixes: `burns/`, `cpr/`, `choking/`, etc.
4. Create a **Service credential** with the **Writer** role and note down the `apikey` and `resource_instance_id` (the CRN).
5. Find your bucket's endpoint from the COS console (e.g. `https://s3.ap.cloud-object-storage.appdomain.cloud`).

Official guide: [IBM Cloud Object Storage documentation](https://cloud.ibm.com/docs/cloud-object-storage)

---

## Local Setup

### 1. Create and activate a virtual environment

```bash
cd firstaid-object-storage
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

Edit `.env` with your COS credentials. See [Environment Variables](#environment-variables).

### 4. Run locally

```bash
gunicorn -w 4 -b 0.0.0.0:5002 app:app --timeout 60
```

The API is available at `http://localhost:5002`.

---

## Environment Variables

| Name | Required | Description | Example |
|---|---|---|---|
| `COS_API_KEY_ID` | ✅ | IBM COS service credential API key | `abc123...` |
| `COS_INSTANCE_CRN` | ✅ | COS service instance CRN (`resource_instance_id`) | `crn:v1:bluemix:public:cloud-object-storage:global:a/xxx:yyy::` |
| `COS_ENDPOINT` | ✅ | COS regional endpoint | `https://s3.ap.cloud-object-storage.appdomain.cloud` |
| `BUCKET_NAME` | ✅ | COS bucket name | `aarogyamfirstaid` |
| `CORS_ORIGINS` | — | Allowed CORS origins | `*` |

---

## API Endpoints

### `GET /list_objects?folder_name=<name>`

List all media objects in a first-aid category folder.

**Query parameters**

| Parameter | Required | Description |
|---|---|---|
| `folder_name` | ✅ | Folder prefix in the COS bucket (e.g. `burns/`) |

**Response `200`**

```json
{
  "folder": "burns/",
  "objects": [
    "https://s3.ap.cloud-object-storage.appdomain.cloud/aarogyamfirstaid/burns/step1.jpg",
    "https://s3.ap.cloud-object-storage.appdomain.cloud/aarogyamfirstaid/burns/step2.jpg"
  ]
}
```

An empty folder returns `"objects": []` — not an error.

**Error responses**

| Status | Body | Condition |
|---|---|---|
| `400` | `{"error": "folder_name query parameter is required"}` | Missing `folder_name` |

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

- `COS_API_KEY_ID`
- `COS_INSTANCE_CRN`

`COS_ENDPOINT` and `BUCKET_NAME` have defaults in `render.yaml` but should be overridden if you use a different bucket or region.

**Start command:**
```
gunicorn -w 4 -b 0.0.0.0:$PORT app:app --timeout 60
```

---

## Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flask` | 3.1.0 | Web framework |
| `gunicorn` | 23.0.0 | WSGI server |
| `ibm-cos-sdk` | 2.14.2 | IBM Cloud Object Storage client |
| `python-dotenv` | 1.0.1 | `.env` loading |
