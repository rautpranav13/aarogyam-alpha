# Aarogyam Backend & Cloud Vision Architecture Survey Report

**Date**: 2026-09-28  
**Explorer**: Backend Vision Explorer  
**Scope**: `backend/`, `requirements.txt`, `pytest.ini`, test harnesses, and Flutter API integration contracts  
**Focus**: Cloud Vision Model fallback mechanism (IBM Granite Vision 3.2 2B / WatsonX), structured JSON contracts, error resilience, and automated verification (`pytest`)

---

## 1. Executive Summary

The Aarogyam backend is a lightweight, high-performance **Flask REST service** (`backend/app.py` running on Python 3.14 / Flask 3.1) serving as the cloud intelligence gateway for the Aarogyam Flutter client. It interfaces with **IBM WatsonX AI Foundation Models** (`ibm/granite-vision-3.2-2b`, `ibm/granite-3-8b-instruct`) and **IBM Watson Text-to-Speech** (`hi-IN_Voice`, `en-US_MichaelV3Voice`).

Key operational characteristics:
- **Zero-Crash Resilience**: Every endpoint contains structured fallback logic. If `WATSONX_API_KEY` or `WATSONX_PROJECT_ID` is unconfigured, or if WatsonX experiences network timeouts or JSON parsing errors, the backend automatically serves clinically authentic, multilingual (Hindi/Marathi/English) mock payloads.
- **Multimodal Dual-Input**: Endpoints support both raw base64 image strings (and URLs) for computer vision as well as text payloads for OCR post-processing fallback.
- **Test Integrity**: Full test suite passes via `backend/venv/bin/pytest backend/tests/ -v` (21 passed tests in ~0.23 seconds), leveraging `unittest.mock` to validate both WatsonX cloud invocations and offline demo fallbacks.

---

## 2. Existing Vision & Multimodal Endpoints

The backend routes are implemented across `backend/app.py` and the blueprint in `backend/dadi_ma_service.py`.

### 2.1 Core Gateway Endpoints (`backend/app.py`)

| Method | Endpoint | Description | Input Parameters | Primary Response Fields |
|---|---|---|---|---|
| `GET` | `/api/health` | Service health, model identification, and capability inventory | None | `status`, `service`, `vision_model`, `instruct_model`, `watsonx_configured`, `watson_tts_configured`, `supported_languages`, `features` |
| `POST` | `/api/redact-pii` | On-device / edge regex PII sanitization | `text` (string) | `status`, `masked_text`, `redactions_count`, `redactions` (list of types and matches), `privacy_verified` |
| `POST` | `/api/digitize-rx` | Prescription digitization via IBM Granite Vision 3.2 2B | `image_base64`, `image_url`, `raw_ocr_text`, `language` (`hi`, `mr`, `en`), `ocr_failed` (passed by client) | `status`, `data` containing `doctor_name`, `clinic_name`, `diagnosis`, `pii_redacted_proof`, `vernacular_summary`, `medications` array |
| `POST` | `/api/verify-strip` | Closed-loop blister strip verification via Granite Vision | `image_base64`, `image_url`, `raw_ocr_text`, `expected_drug`, `expected_strength`, `language`, `ocr_failed` | `status`, `verified` (bool), `detected_text`, `detected_batch`, `detected_expiry`, `is_expired` (bool), `confidence`, `voice_alert_vernacular`, `action` (`ALLOW_CONSUMPTION` / `BLOCK_CONSUMPTION`) |
| `POST` | `/api/vernacular-tts`| Indic audio synthesis via IBM Watson TTS | `text` (string), `language` (`hi`, `mr`, `en`) | `audio/mpeg` binary stream (HTTP 200) or mock text response if credentials missing |
| `GET` | `/` | API catalog and endpoint directory | None | Service title, online status, endpoint list |

### 2.2 Conversational & Clinical Blueprint (`backend/dadi_ma_service.py`)
Mounted under `/api/dadi-ma`:
- `POST /api/dadi-ma/chat`: Contextual grandmotherly health triage and advice, includes emergency symptom red-flag detection (e.g. chest pain, stroke, breathing difficulty) that triggers urgent 108 ambulance recommendations.
- `GET /api/dadi-ma/remedies`: Curated catalog of traditional Ayurvedic remedies.
- `POST /api/dadi-ma/daily-greeting`: Time-of-day contextual maternal wellness greetings.
- `POST /api/dadi-ma/explain-prescription`: Spoken explanation generator for prescribed medications.

---

## 3. IBM Granite Vision & WatsonX Integration Architecture

### 3.1 SDK & Model Configuration
- **Library**: `ibm-watsonx-ai>=1.3.11`
- **Model IDs**:
  - Vision: `ibm/granite-vision-3.2-2b` (`WATSONX_VISION_MODEL_ID`)
  - Instruct: `ibm/granite-3-8b-instruct` (`WATSONX_INSTRUCT_MODEL_ID`)
- **Credentials & Config**:
  - `WATSONX_API_KEY`: API key for IBM Cloud IAM
  - `WATSONX_URL`: Default `"https://us-south.ml.cloud.ibm.com"`
  - `WATSONX_PROJECT_ID`: Target WatsonX workspace project GUID

### 3.2 Client Instantiation
In `backend/app.py`:
```python
def _get_watsonx_model(model_id: str = GRANITE_VISION_MODEL_ID):
    from ibm_watsonx_ai import Credentials
    from ibm_watsonx_ai.foundation_models import ModelInference

    credentials = Credentials(url=WATSONX_URL, api_key=WATSONX_API_KEY)
    return ModelInference(
        model_id=model_id,
        credentials=credentials,
        project_id=WATSONX_PROJECT_ID,
        params={"max_tokens": 1024, "temperature": 0.0},
    )
```

### 3.3 Multimodal Prompt Formulation
- **Image Input Handling**:
  - Base64 data URLs (`data:image/jpeg;base64,...`) are stripped via `_clean_base64()`.
  - Remote image URLs are fetched via `requests.get(image_data, timeout=10)` and converted to base64.
  - Chat message structure passed to `model.chat(messages=...)`:
    ```python
    messages = [
        {
            "role": "user",
            "content": [
                {"type": "text", "text": system_instruction},
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{b64_image}"},
                },
            ],
        }
    ]
    ```
- **Text-Only Fallback Prompt**:
  If only OCR text is available (`raw_ocr_text` without image), the backend routes to text-only instruct mode by embedding the text in the prompt string.

### 3.4 Fallback Execution Path
If WatsonX credentials (`WATSONX_API_KEY`, `WATSONX_PROJECT_ID`) are absent:
1. `digitize_rx()` diverts immediately to `_get_demo_rx_response(language)` without attempting network connections.
2. `verify_strip()` diverts immediately to `_get_demo_verify_response(...)`.
3. If credentials exist but WatsonX times out, throws an exception, or returns non-JSON/malformed markdown output, the `except` blocks catch `json.JSONDecodeError` or `Exception` and seamlessly return the demo responses with HTTP 200, guaranteeing frontend stability.

---

## 4. Structured JSON Response Contracts

### 4.1 Prescription Parsing (`POST /api/digitize-rx`)

#### Request Contract:
```json
{
  "image_base64": "<base64_string>",
  "image_url": "<optional_http_url>",
  "raw_ocr_text": "<optional_fallback_ocr_text>",
  "ocr_failed": false,
  "language": "hi"
}
```

#### Response Contract (HTTP 200):
```json
{
  "status": "success",
  "data": {
    "doctor_name": "Dr. S. K. Sharma, MD",
    "clinic_name": "Community Health Centre",
    "diagnosis": "Hypertension & T2 Diabetes",
    "pii_redacted_proof": "Patient Identity Redacted: [MASKED-AADHAAR-XXXX] [MASKED-PHONE-XXXX]",
    "vernacular_summary": "पर्चे का सारांश...",
    "medications": [
      {
        "id": 1,
        "name": "Metformin Hydrochloride",
        "strength": "500mg",
        "form": "Tablet",
        "frequency": "1-0-1",
        "timing_24hr": ["08:30", "20:30"],
        "morning": true,
        "afternoon": false,
        "night": true,
        "food_relation": "After Food",
        "duration_days": 30,
        "instructions": "Take 1 tablet after meals",
        "instructions_vernacular": "खाना खाने के बाद एक गोली पानी के साथ लें।",
        "pill_color_hex": "#00796B",
        "pill_shape": "round"
      }
    ]
  }
}
```

#### Client Alignment:
In `aarogyam-flutter/lib/backend/api_requests/api_calls.dart`, `DigitizeRxAPICall.medicationsList(response)` parses `r'$.data.medications'`. In `report_sanner_widget.dart` (lines 130–166), each item is mapped into a `MedicineItem` and committed to `PrescriptionRecord`, creating SQLite records and Android AlarmManager adherence reminders.

### 4.2 Blister Strip Verification (`POST /api/verify-strip`)

#### Request Contract:
```json
{
  "image_base64": "<base64_string>",
  "expected_drug": "Metformin",
  "expected_strength": "500mg",
  "raw_ocr_text": "<optional_ocr>",
  "ocr_failed": true,
  "language": "hi"
}
```

#### Response Contract (HTTP 200 - Safe Match):
```json
{
  "status": "success",
  "verified": true,
  "detected_text": "METFORMIN HYDROCHLORIDE 500MG IP",
  "detected_batch": "BATCH: IND-8291",
  "detected_expiry": "EXP 12/2026",
  "is_expired": false,
  "confidence": 0.96,
  "voice_alert_vernacular": "सत्यापित: Metformin 500mg। यह आपकी सही दवा है, कृपया इसे लें।",
  "action": "ALLOW_CONSUMPTION"
}
```

#### Response Contract (HTTP 200 - Danger Mismatch):
```json
{
  "status": "success",
  "verified": false,
  "detected_text": "AMLODIPINE 5MG",
  "detected_batch": "BATCH: IND-7712",
  "detected_expiry": "EXP 08/2025",
  "is_expired": false,
  "confidence": 0.99,
  "voice_alert_vernacular": "चेतावनी: यह गलत दवा है! इसे न लें।",
  "action": "BLOCK_CONSUMPTION"
}
```

#### Client Alignment:
In `aarogyam-flutter/lib/backend/api_requests/api_calls.dart`, helper methods extract:
- `VerifyStripAPICall.isVerified(res)` -> `r'$.verified'`
- `VerifyStripAPICall.detectedText(res)` -> `r'$.detected_text'`
- `VerifyStripAPICall.voiceAlert(res)` -> `r'$.voice_alert_vernacular'`
- `VerifyStripAPICall.action(res)` -> `r'$.action'`

In `blister_verifier_widget.dart` (lines 127–152), these values instantiate a `BlisterVerificationResult` and trigger `vernService.speakVerificationResult()`.

### 4.3 PII Sanitization (`POST /api/redact-pii`)
- Redacts:
  1. 12-digit Indian Aadhaar numbers (`\b(\d{4}[\s-]?\d{4}[\s-]?\d{4})\b`)
  2. 14-digit ABHA IDs (`\b(\d{2}-\d{4}-\d{4}-\d{4})\b`)
  3. 10-digit Indian Mobile Numbers starting with 6, 7, 8, 9 (`(?:\+91[\-\s]?|0)?([6-9]\d{9})\b`)
- Returns `masked_text` and list of `redactions`.

---

## 5. Error Handling, Network Timeouts, and Resilience

### 5.1 Timeout Configuration
- `requests.get()` for remote prescription URLs: `timeout=10` seconds.
- `requests.post()` for Watson TTS synthesis: `timeout=10` seconds.
- WatsonX `ModelInference.chat()`: Uses default SDK connection settings.

### 5.2 Markdown Code Fence Stripping
Granite Vision occasionally formats JSON responses inside markdown fences (` ```json ... ``` `). The backend protects against parsing errors using:
```python
def _sanitize_json_markdown(raw_text: str) -> str:
    raw_text = raw_text.strip()
    if raw_text.startswith("```json"):
        raw_text = raw_text[7:]
    elif raw_text.startswith("```"):
        raw_text = raw_text[3:]
    if raw_text.endswith("```"):
        raw_text = raw_text[:-3]
    return raw_text.strip()
```

### 5.3 Exception Handling Hierarchy
In both `digitize_rx` and `verify_strip`:
1. **JSONDecodeError**: If the LLM generates invalid JSON after fence stripping, the handler catches `json.JSONDecodeError`, logs a warning, and returns the deterministic localized demo response.
2. **Generic Exception**: Any connection error, credential failure, or base64 decoding problem is caught by `except Exception as e`, logged with stack trace via `logger.exception()`, and diverted to demo response.
3. **Missing Critical Input**: Missing both image and OCR text returns HTTP 400 with a descriptive error JSON.

---

## 6. Pytest Test Suites & Mocking Patterns

### 6.1 Test Execution Status
- Command: `backend/venv/bin/pytest backend/tests/ -v`
- Result: **21 passed in 0.23s**
- Files:
  - `backend/tests/test_app.py` (13 tests)
  - `backend/tests/test_dadi_ma.py` (8 tests)

### 6.2 Test Suite Breakdown

#### `backend/tests/test_app.py`:
1. `test_clean_base64_helper`: Validates URI header stripping and plain base64 preservation.
2. `test_sanitize_json_markdown_helper`: Validates stripping of markdown code fences.
3. `test_home_endpoint`: Verifies `/` catalog and API listing.
4. `test_health_endpoint`: Verifies `/api/health` reports healthy status, model name, and supported languages.
5. `test_digitize_rx_missing_payload`: Confirms HTTP 400 when no image or text is provided.
6. `test_digitize_rx_demo_fallback_hindi`: Confirms fallback returns valid Hindi clinical structure with Metformin.
7. `test_digitize_rx_demo_fallback_marathi`: Confirms fallback returns valid Marathi clinical structure.
8. `test_digitize_rx_watsonx_success`: Mocks WatsonX model chat response and verifies parsing into `data.medications`.
9. `test_verify_strip_missing_payload`: Confirms HTTP 400 when required fields are missing.
10. `test_verify_strip_demo_fallback`: Confirms fallback returns verified status and `ALLOW_CONSUMPTION`.
11. `test_verify_strip_mismatch_alert`: Mocks WatsonX mismatch and confirms `BLOCK_CONSUMPTION` action.
12. `test_vernacular_tts_missing_text`: Confirms HTTP 400 on empty text.
13. `test_vernacular_tts_mock_delivery`: Confirms mock text return when Watson TTS is unconfigured.

#### `backend/tests/test_dadi_ma.py`:
1. `test_emergency_red_flags_detection`: Validates regex detection for Hindi, Marathi, and English emergency symptoms (108 alerts).
2. `test_remedy_catalog_integrity`: Validates structure and multilingual availability of Ayurvedic remedies.
3. `test_dadi_ma_greeting_generator`: Validates morning and night greetings in Hindi and Marathi.
4. `test_dadi_ma_chat_endpoint_fallback_hindi`: Validates `/api/dadi-ma/chat` response with matching remedy.
5. `test_dadi_ma_chat_endpoint_emergency_trigger`: Validates emergency status and `CALL_108_OR_VISIT_DOCTOR`.
6. `test_dadi_ma_remedies_endpoint`: Validates `/api/dadi-ma/remedies` query and language filter.
7. `test_dadi_ma_daily_greeting_endpoint`: Validates `/api/dadi-ma/daily-greeting`.
8. `test_dadi_ma_explain_prescription_endpoint`: Validates `/api/dadi-ma/explain-prescription` breakdown.

### 6.3 Mocking Conventions
The tests use Python's built-in `unittest.mock`:
- `@mock.patch("app.WATSONX_API_KEY", "mock_key")`
- `@mock.patch("app.WATSONX_PROJECT_ID", "mock_proj")`
- `@mock.patch("app._get_watsonx_model")`
This allows simulating realistic cloud responses and network behavior without incurring WatsonX API costs or requiring live credentials during CI/CD.

---

## 7. Gap Analysis & Architecture Recommendations for R1, R2, R3, R4

Based on the investigation against `ORIGINAL_REQUEST.md`:

### 7.1 Gap Analysis

| Requirement | Current Backend State | Gaps Identified | Required Architecture Action |
|---|---|---|---|
| **R1: On-Device Failure Detection & Cloud Vision Dispatch** | The endpoints accept `image_base64`, `raw_ocr_text`, and `ocr_failed`, but `ocr_failed` is not logged or used to adjust WatsonX prompt strategy. | When `ocr_failed: true` is sent, WatsonX prompt should be explicitly tuned to emphasize handwriting deciphering and contrast recovery. | Enhance prompt construction in `digitize_rx()` and `verify_strip()` to adapt instructions when `ocr_failed` is indicated. |
| **R2: Edge Privacy & PII Sanitization** | `mask_pii()` exists in `backend/app.py` and is exposed at `/api/redact-pii`, but `digitize_rx()` only asks WatsonX to redact PII in output text; it does not sanitize `raw_ocr_text` input prior to WatsonX dispatch. | If patient text/OCR is forwarded to backend, sensitive PII could theoretically reach the cloud model without local sanitization. | Apply `mask_pii()` to `raw_ocr_text` in `digitize_rx()` before assembling the prompt, providing defense-in-depth sanitization and audit proofs. |
| **R3: Structured Response Processing & Synchronization** | The JSON structures for prescription parsing and blister foil verification match Flutter expectations. However, expiry date parsing relies on hardcoded string checks rather than date comparisons. | If a blister pack text has `EXP 01/2023`, the fallback or model response may not reliably compute `is_expired: true` if the model does not know the current date. | Include system date context in prompt and parse expiration dates (MM/YYYY) against the current date in verification logic. |
| **R4: Automated Verification & Regression Testing** | Existing pytest suite has 21 passing tests, but lacks tests for: (1) `ocr_failed` fallback flag handling, (2) WatsonX network connection timeout/failure simulations, (3) `mask_pii` edge cases and `/api/redact-pii` endpoint, (4) Expired blister strip detection. | Test coverage does not explicitly assert fallback trigger behavior on simulated upstream timeouts. | Add dedicated test cases in `backend/tests/test_app.py` covering timeout simulation, PII masking, and explicit `ocr_failed` payload routing. |

---

## 8. Conclusion

The Aarogyam backend provides a solid, zero-crash foundation for the IBM Granite Vision fallback pipeline. The endpoints `/api/digitize-rx` and `/api/verify-strip` already align with the Flutter client's `DigitizeRxAPICall` and `VerifyStripAPICall`. By closing the minor gaps around input PII masking, date-aware expiry validation, and dedicated timeout/fallback test cases, the backend will fully satisfy requirements R1, R2, R3, and R4.
