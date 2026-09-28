# Handoff Report: Survey Explorer - Backend Vision Architecture

**Agent**: Backend Vision Explorer  
**Working Directory**: `/Users/rufbook/aarogyam/.agents/teamwork/survey_explorer_backend`  
**Handoff Type**: Hard (Investigation & Survey Complete)  

---

## 1. Observation

1. **Framework & Dependencies** (`backend/requirements.txt:1-8`):
   - `flask>=3.1.0`
   - `flask-cors>=5.0.0`
   - `ibm-watsonx-ai>=1.3.11`
   - `requests>=2.31.0`
   - `python-dotenv>=1.0.1`
   - `pytest>=7.4.0`
   - Execution command `backend/venv/bin/pytest backend/tests/ -v` passes **21 of 21 tests in 0.23s**.

2. **Endpoints & Implementation** (`backend/app.py`):
   - Line 116: `@app.route("/api/health", methods=["GET"])` returns service readiness, model IDs (`ibm/granite-vision-3.2-2b`), and language support.
   - Line 143: `@app.route("/api/redact-pii", methods=["POST"])` provides Indian PII regex redaction (Aadhaar, ABHA ID, Indian Mobile numbers).
   - Line 161: `@app.route("/api/digitize-rx", methods=["POST"])` handles prescription digitization with base64 image or raw OCR text. If `WATSONX_API_KEY` is missing or on error, returns `_get_demo_rx_response(language)` with HTTP 200.
   - Line 402: `@app.route("/api/verify-strip", methods=["POST"])` verifies blister strips with `expected_drug` and `expected_strength`. On missing credentials or error, returns `_get_demo_verify_response(...)` with HTTP 200.
   - Line 521: `@app.route("/api/vernacular-tts", methods=["POST"])` synthesizes speech via IBM Watson TTS or returns mock payload.
   - Line 30: Blueprint `dadi_ma_bp` registered under prefix `/api/dadi-ma` (`chat`, `remedies`, `daily-greeting`, `explain-prescription`).

3. **IBM WatsonX Configuration & Fallback** (`backend/app.py:29-60`, `backend/.env.example:1-14`):
   - `WATSONX_API_KEY`, `WATSONX_URL` (default `"https://us-south.ml.cloud.ibm.com"`), `WATSONX_PROJECT_ID`, `WATSONX_VISION_MODEL_ID` (default `"ibm/granite-vision-3.2-2b"`).
   - In `_get_watsonx_model()`, credentials instantiate `ibm_watsonx_ai.foundation_models.ModelInference` with `params={"max_tokens": 1024, "temperature": 0.0}`.
   - In `digitize_rx()` and `verify_strip()`, fallback is triggered if credentials are missing OR if `json.JSONDecodeError` / generic `Exception` occurs.

4. **Structured JSON Contracts & Client Alignment**:
   - `backend/app.py:188-213`: Response schema returns `{"status": "success", "data": {"medications": [...]}}`.
   - `aarogyam-flutter/lib/backend/api_requests/api_calls.dart:58-62`: `DigitizeRxAPICall.medicationsList(response)` parses `r'$.data.medications'`.
   - `backend/app.py:435-444`: Blister verification response returns `{"status": "success", "verified": bool, "detected_text": str, "detected_batch": str, "detected_expiry": str, "is_expired": bool, "confidence": float, "voice_alert_vernacular": str, "action": str}`.
   - `aarogyam-flutter/lib/backend/api_requests/api_calls.dart:115-126`: `VerifyStripAPICall` extracts `r'$.verified'`, `r'$.detected_text'`, `r'$.voice_alert_vernacular'`, and `r'$.action'`.
   - `aarogyam-flutter/lib/main_pages/report_sanner/report_sanner_widget.dart:107-115`: Client determines `isOcrFailed = rawOcr.trim().length < 15` and transmits `ocrFailed: isOcrFailed` in `DigitizeRxAPICall.call()`.
   - `aarogyam-flutter/lib/main_pages/blister_verifier/blister_verifier_widget.dart:100-125`: Client transmits `ocrFailed: isOcrUnclearOrFailed` in `VerifyStripAPICall.call()`.

5. **Test Harness & Mocking** (`backend/tests/test_app.py:98-140, 164-202`):
   - Mocks WatsonX via `@mock.patch("app._get_watsonx_model")` returning MagicMock with `chat.return_value = {"choices": [{"message": {"content": "..."}}]}`.
   - Validates unconfigured credential paths, missing field validations (HTTP 400), and Hindi/Marathi fallback structures.

---

## 2. Logic Chain

1. **Alignment with Requirements R1 & R3**:
   - Observation 2 & 4 show that the backend already implements `POST /api/digitize-rx` and `POST /api/verify-strip` with the exact JSON contracts expected by the Flutter client.
   - The Flutter client passes `ocr_failed: true` whenever on-device ML Kit OCR returns less than 15 characters for prescriptions or less than 4 characters for blister strips (Observation 4).
   - The backend accepts this payload without crashing, but Observation 2 reveals that `backend/app.py` does not currently inspect or adapt prompt instructions based on `ocr_failed`.

2. **Alignment with Requirement R2 (PII Privacy)**:
   - Observation 2 shows `backend/app.py` has `mask_pii()` redacting Aadhaar, ABHA ID, and mobile numbers.
   - However, in `POST /api/digitize-rx`, `mask_pii()` is NOT executed on the incoming `raw_ocr_text` parameter before it is passed to WatsonX in the prompt string.

3. **Resilience & Fallback Strategy**:
   - Observation 2 & 3 demonstrate that the backend is crash-proof: any missing key, network disconnect, or upstream JSON decoding error falls back to multilingual structured demo data with HTTP 200.
   - However, WatsonX SDK `model.chat()` call does not specify a timeout parameter, relying on default socket timeouts which could delay client response during poor connectivity.

4. **Testing Harness (Requirement R4)**:
   - Observation 1 & 5 show that `pytest` is configured via `pytest.ini` and all 21 existing tests pass.
   - Gaps in test coverage include: simulating upstream network timeouts, testing `mask_pii` directly, and asserting `ocr_failed: true` execution paths.

---

## 3. Caveats

1. **WatsonX Live Cloud Execution**: Tests and fallback verification were performed using simulated mocks and local fallback responses because live IBM WatsonX production API keys (`WATSONX_API_KEY`) were not configured in the test environment.
2. **Local Weight Execution (`download_granite.py`)**: `scripts/download_granite.py` provides snapshot downloads from HuggingFace, but `app.py` uses the cloud SDK (`ibm-watsonx-ai`), not local HuggingFace weight execution.

---

## 4. Conclusion

The Aarogyam backend vision architecture is healthy, modular, and directly compatible with the Flutter mobile client contracts.
To fulfill R1, R2, R3, and R4 during subsequent implementation phases, the following discrete changes are recommended:
1. **R1**: In `backend/app.py`, check `data.get("ocr_failed")` and augment the prompt to prioritize deep handwriting deciphering and visual enhancement when on-device OCR has failed.
2. **R2**: In `backend/app.py` (`digitize_rx`), automatically sanitize `raw_ocr_text` through `mask_pii()` prior to assembling the WatsonX prompt, and include sanitization metadata in `pii_redacted_proof`.
3. **R3**: In `backend/app.py` (`verify_strip`), add calendar-aware date comparison for `EXP MM/YYYY` to dynamically flag expired medications (`is_expired: true`, `action: "BLOCK_CONSUMPTION"`).
4. **R4**: Add unit tests in `backend/tests/test_app.py` for:
   - Upstream network timeout / exception triggering fallback.
   - Input PII sanitization in `digitize_rx`.
   - Expired blister packaging verification.

---

## 5. Verification Method

1. **Run Pytest Suite**:
   ```bash
   backend/venv/bin/pytest backend/tests/ -v
   ```
   *Expected outcome*: 21 passed tests in < 0.5s.

2. **Verify Health Endpoint**:
   ```bash
   PYTHONPATH=backend backend/venv/bin/python -c "from app import app; client = app.test_client(); res = client.get('/api/health'); print(res.status_code, res.get_json()['status'])"
   ```
   *Expected outcome*: `200 healthy`.

3. **Verify Prescription Fallback Contract**:
   ```bash
   PYTHONPATH=backend backend/venv/bin/python -c "from app import app; client = app.test_client(); res = client.post('/api/digitize-rx', json={'image_base64': 'dGVzdA==', 'language': 'hi'}); print(res.status_code, res.get_json()['data']['medications'][0]['name'])"
   ```
   *Expected outcome*: `200 Metformin Hydrochloride`.

4. **Verify Blister Verifier Fallback Contract**:
   ```bash
   PYTHONPATH=backend backend/venv/bin/python -c "from app import app; client = app.test_client(); res = client.post('/api/verify-strip', json={'image_base64': 'dGVzdA==', 'expected_drug': 'Metformin', 'expected_strength': '500mg'}); print(res.status_code, res.get_json()['action'])"
   ```
   *Expected outcome*: `200 ALLOW_CONSUMPTION`.
