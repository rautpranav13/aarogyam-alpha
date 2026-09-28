# Project: Aarogyam End-to-End Fallback Mechanism to IBM Granite Vision / WatsonX

## Architecture
The Aarogyam fallback subsystem establishes a resilient, privacy-preserving hybrid processing pipeline connecting the Flutter mobile edge client (`aarogyam-flutter/`) and the Python backend (`backend/`):
1. **Edge On-Device Vision**: Google ML Kit OCR extracts text from prescription slips and blister strips on-device. Heuristic engines compute confidence scores and identify failure/ambiguity conditions (illegible handwriting, text length < 15 chars for prescriptions; token match ratio < 0.70, text length < 4 chars, or unreadable expiry for blister foils).
2. **Edge Privacy & PII Sanitization Engine**: Prior to cloud dispatch, an on-device sanitization pipeline applies Verhoeff-validated Aadhaar masking (`XXXXXXXX1234`), DoT-compliant phone number masking, and multilingual patient name de-identification (`[PATIENT-ANON-XXXX]`). A tamper-evident `SanitizationManifest` with SHA-256 pre/post digests is generated.
3. **Cloud Multimodal Vision Dispatch**: Low-confidence or failed scans are dispatched to `/api/digitize-rx` and `/api/verify-strip`. The backend leverages IBM WatsonX Granite Vision 3.2 2B with contextual prompt tailoring for OCR-failed imagery, returning structured JSON schemas.
4. **Structured Response Processing & Local Synchronization**: The client parses structured medication schedules into `MedicationStorageService` (persisting to `SharedPreferences`), populating the schedule and reminder views. Blister safety verdicts update UI state indicators and trigger vernacular audio announcements (`VernacularService`).
5. **Zero-Crash Graceful Degradation**: Network disconnects, API timeouts, or unconfigured cloud credentials fall back gracefully to local offline datasets or structured fallback responses with clear UI indicators without crashing the app.

```
+-----------------------------------------------------------------------------------+
| Flutter Mobile Client (aarogyam-flutter/)                                         |
|                                                                                   |
|  [ Camera Capture ]                                                               |
|         |                                                                         |
|         v                                                                         |
|  [ MLKitOcrService ]                                                              |
|         |                                                                         |
|    Confidence / Failure Heuristic                                                 |
|     /                            \                                                |
|  (Pass / High Confidence)     (Fail / Low Confidence / Inconclusive)              |
|   |                               \                                               |
|   v                                v                                              |
|  [ Local Processing ]       [ EdgePiiSanitizer ]                                  |
|   |                                | (Mask Aadhaar, Phone, Patient Name)          |
|   |                                | (Generate SHA-256 SanitizationManifest)      |
|   |                                v                                              |
|   |                         [ Cloud Vision API Dispatch ]                         |
|   |                                |                                              |
|   +--------------------------------+----------------------------------------+     |
|                                    |                                         |    |
|                                    v                                         v    |
|                          [ MedicationStorageService ]              [ VernacularTTS ]|
|                          [ Schedule / Reminder UI ]                [ UI Status Card]|
+------------------------------------|-----------------------------------------|----+
                                     | HTTP POST (JSON + Base64)               |
                                     v                                         |
+------------------------------------------------------------------------------|----+
| Python Backend (backend/)                                                    |    |
|                                                                              |    |
|  [ /api/digitize-rx ]               [ /api/verify-strip ]                    |    |
|         |                                  |                                 |    |
|  [ mask_pii validation ]            [ Calendar-Aware Expiry Check ]          |    |
|         |                                  |                                 |    |
|  [ WatsonX Granite Vision 3.2 2B ]  <------+                                 |    |
|  (or Resilient Multilingual Fallback Engine)                                 |    |
+------------------------------------------------------------------------------+----+
```

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Prescription Failure Detection | Detect empty, unreadable (< 15 chars), or error states in ML Kit prescription OCR | M3 | ORIGINAL_REQUEST §R1 |
| 2 | Prescription Cloud Vision Dispatch | Transmit sanitized image/OCR payload to `/api/digitize-rx` with handwriting prompt | M2, M3 | ORIGINAL_REQUEST §R1 |
| 3 | Blister Inconclusive Detection | Detect low-confidence (< 0.70 match), short (< 4 chars), or unclear expiry on-device | M3 | ORIGINAL_REQUEST §R1 |
| 4 | Blister Cloud Vision Escalation | Selectively escalate inconclusive blister scans to `/api/verify-strip` | M2, M3 | ORIGINAL_REQUEST §R1 |
| 5 | Network Failure & Graceful Degradation | Handle timeouts, offline status, or backend errors without crash; show UI alert | M2, M3 | ORIGINAL_REQUEST §R1 |
| 6 | Aadhaar Masking with Verhoeff D5 | Mask 12-digit Aadhaar (`XXXXXXXX1234`) with D5 checksum, avoiding batch code false positives | M1 | ORIGINAL_REQUEST §R2 |
| 7 | Phone Number Masking | Mask Indian mobile/landline numbers (+91, 10 digits starting with 6-9) | M1 | ORIGINAL_REQUEST §R2 |
| 8 | Patient Name De-Identification | De-identify patient names with multilingual heuristics and doctor exclusions | M1 | ORIGINAL_REQUEST §R2 |
| 9 | Cryptographic Sanitization Proof | Produce tamper-evident `SanitizationManifest` with SHA-256 pre/post digests | M1, M2 | ORIGINAL_REQUEST §R2 |
| 10 | Structured Schedule Extraction | Parse vision responses into medication schedules (names, strengths, timings, food) | M2 | ORIGINAL_REQUEST §R3 |
| 11 | Client Storage & UI Synchronization | Synchronize parsed medications to `MedicationStorageService` and schedule view | M3 | ORIGINAL_REQUEST §R3 |
| 12 | Blister Safety & Vernacular Alerts | Evaluate match/expiry verdicts, update UI status badges, announce vernacular audio | M2, M3 | ORIGINAL_REQUEST §R3 |
| 13 | Automated Verification Suites | Complete end-to-end regression test suite passing `flutter test` and `pytest backend/` | M4, E2E | ORIGINAL_REQUEST §R4 |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Edge Privacy & PII Sanitization Subsystem | Dart `EdgePiiSanitizer` + Backend `mask_pii` Verhoeff D5 + name de-identification + SHA-256 proof manifests | none | IN_PROGRESS |
| M2 | Backend Cloud Vision & Structured Response Engine | Backend `/api/digitize-rx` OCR-failed prompt adaptation + `/api/verify-strip` expiry logic + mock resilience + pytest suites | M1 | PLANNED |
| M3 | Client Failure Detection, Selective Escalation & Local Sync | Flutter `ReportSannerWidget` fallback + `BlisterVerifierWidget` selective escalation + `MedicationStorageService` sync + UI status cards | M1, M2 | PLANNED |
| M4 | Final Milestone: Full Dual Track E2E Verification & Adversarial Hardening | Phase 1: 100% pass on Tiers 1-4 tests; Phase 2: Tier 5 adversarial stress testing | M1, M2, M3 | PLANNED |

## Interface Contracts

### 1. `POST /api/redact-pii`
- **Request**:
  ```json
  {
    "text": "string (raw OCR text)",
    "patient_id": "string (optional)",
    "generate_proof": true
  }
  ```
- **Response**:
  ```json
  {
    "status": "success",
    "sanitized_text": "string",
    "entities_masked": {
      "aadhaar": 0,
      "phone": 0,
      "patient_name": 0
    },
    "proof": {
      "manifest_id": "uuid",
      "pre_hash_sha256": "64-char-hex",
      "post_hash_sha256": "64-char-hex",
      "timestamp": "ISO-8601",
      "algorithm": "verhoeff-d5-regex-ner-v1"
    }
  }
  ```

### 2. `POST /api/digitize-rx`
- **Request**:
  ```json
  {
    "image_base64": "string (base64 image data)",
    "raw_ocr_text": "string (optional pre-extracted text)",
    "ocr_failed": true,
    "language": "hi | mr | en",
    "pii_manifest": "object (optional SanitizationManifest)"
  }
  ```
- **Response**:
  ```json
  {
    "status": "success",
    "data": {
      "medications": [
        {
          "name": "string",
          "strength": "string",
          "frequency": "string",
          "timing": "string",
          "food_relation": "before_food | after_food | with_food",
          "timings_24hr": ["08:00", "20:00"],
          "duration_days": 10,
          "notes": "string"
        }
      ]
    },
    "pii_redacted_proof": "string",
    "fallback_used": false,
    "model_id": "ibm/granite-vision-3.2-2b"
  }
  ```

### 3. `POST /api/verify-strip`
- **Request**:
  ```json
  {
    "image_base64": "string",
    "raw_ocr_text": "string (optional)",
    "ocr_failed": true,
    "expected_drug": "string",
    "expected_strength": "string",
    "language": "hi | mr | en"
  }
  ```
- **Response**:
  ```json
  {
    "status": "success",
    "verified": true,
    "detected_text": "string",
    "detected_batch": "string",
    "detected_expiry": "MM/YYYY",
    "is_expired": false,
    "confidence": 0.95,
    "voice_alert_vernacular": "string",
    "action": "ALLOW_CONSUMPTION | BLOCK_CONSUMPTION"
  }
  ```

### 4. Dart Client Contracts
- `EdgePiiSanitizer.sanitize(String text)` -> `PiiSanitizationResult(sanitizedText, manifest, entityCounts)`
- `MedicationStorageService.savePrescription(PrescriptionRecord record)` -> `Future<void>`
- `VernacularService.speakVerificationResult(BlisterVerificationResult result)` -> `Future<void>`

## Code Layout
```
aarogyam/
├── aarogyam-flutter/
│   ├── lib/
│   │   ├── core/
│   │   │   ├── utils/
│   │   │   │   └── edge_pii_sanitizer.dart          (NEW: Edge PII masking & Verhoeff algorithm)
│   │   │   ├── services/
│   │   │   │   ├── mlkit_ocr_service.dart           (EXISTING: On-device OCR & blister heuristics)
│   │   │   │   ├── medication_storage_service.dart  (EXISTING: Local schedule persistence)
│   │   │   │   └── vernacular_service.dart          (EXISTING: Multilingual TTS & audio alerts)
│   │   │   └── models/
│   │   │       └── medication_schedule.dart         (EXISTING: Data models & schemas)
│   │   ├── backend/
│   │   │   └── api_requests/
│   │   │       ├── api_calls.dart                   (EXISTING: DigitizeRx, VerifyStrip, RedactPii)
│   │   │       └── api_manager.dart                 (EXISTING: HTTP client & timeout resilience)
│   │   └── main_pages/
│   │       ├── report_sanner/
│   │       │   ├── report_sanner_widget.dart        (EXISTING: Fallback routing & offline banner)
│   │       │   └── report_sanner_model.dart         (EXISTING: PII state management)
│   │       └── blister_verifier/
│   │           ├── blister_verifier_widget.dart     (EXISTING: Selective escalation & UI indicators)
│   │           └── blister_verifier_model.dart      (EXISTING: Blister verifier state)
│   └── test/
│       ├── unit/
│       │   ├── edge_pii_sanitizer_test.dart         (NEW: Comprehensive PII masking tests)
│       │   ├── fallback_routing_test.dart           (NEW: OCR failure detection & routing tests)
│       │   └── ...
│       └── widget/
│           ├── report_sanner_fallback_test.dart     (NEW: Offline banner & fallback widget tests)
│           └── blister_verifier_escalation_test.dart(NEW: Selective escalation widget tests)
└── backend/
    ├── app.py                                       (EXISTING: Flask routes, Verhoeff PII, WatsonX)
    ├── requirements.txt                             (EXISTING: Backend dependencies)
    └── tests/
        ├── test_app.py                              (EXISTING: API route tests)
        ├── test_pii_sanitizer.py                    (NEW: Verhoeff D5, batch code, name redaction tests)
        └── test_fallback_vision.py                  (NEW: WatsonX timeout & OCR-failed mock tests)
```
