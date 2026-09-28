# Handoff Report: Flutter Client Architecture Survey

## 1. Observation

1. **Flutter Project Layout & Dependencies:**
   * Flutter application root is located at `/Users/rufbook/aarogyam/aarogyam-flutter/`.
   * `pubspec.yaml` specifies Flutter SDK `>=3.0.0 <4.0.0`, `google_mlkit_text_recognition: ^0.17.1` (line 95), `http: ^1.3.0` (line 55), `flutter_tts: ^4.2.5` (line 96), `audioplayers: ^6.8.1` (line 58), `shared_preferences: ^2.5.2` (line 22), `sqflite: ^2.3.3+1` (line 65), `flutter_dotenv: ^5.2.1` (line 23), `fake_cloud_firestore: ^3.0.2` (line 107).
   * `.env` file (`aarogyam-flutter/.env:2`) defines `BACKEND_URL=http://localhost:5001`.

2. **On-Device OCR & Blister Matching:**
   * `MLKitOcrService` (`aarogyam-flutter/lib/core/services/mlkit_ocr_service.dart:7-344`) initializes `TextRecognizer(script: TextRecognitionScript.latin)`.
   * `extractText(imagePath)` calls `processImageFile(imagePath)` returning recognized text or `''` upon error (`mlkit_ocr_service.dart:56-59`).
   * `verifyBlisterFoil` and `analyzeFoilText` (`mlkit_ocr_service.dart:62-250`) parse raw text:
     * Empty raw text check (`lines 83-94`) yields `VerificationStatus.unclear`.
     * Expiry check regex `(?:exp|expiry|exp\.?date|use\s*before)[\s.:/_-]*...` (`lines 299-308`) and `_isDateExpired` (`lines 310-322`).
     * Token extraction strips stop words (`tablet`, `capsule`, `syrup`, `hydrochloride`, etc.) (`lines 252-258`).
     * Fuzzy matching using word-by-word Levenshtein distance ratio (`lines 260-297`).
     * Match threshold is `bestMatchScore >= 0.70` for `VerificationStatus.matchSafe` (`line 137`).

3. **Prescription Scanning Flow & Fallback Trigger:**
   * `ReportSannerWidget` (`aarogyam-flutter/lib/main_pages/report_sanner/report_sanner_widget.dart`):
     * `_processImageFromPath` (`lines 68-100`) runs `_mlKitService.extractText(path)`. Any caught exception sets `_model.rawOcrText = ''` (`lines 87-90`).
     * `_digitizeWithGraniteVision` (`lines 102-224`) sets `isOcrFailed = rawOcr.trim().length < 15` (`line 107`).
     * Calls `DigitizeRxAPICall.call(imageBase64: _model.imageBase64, rawOcrText: rawOcr, ocrFailed: isOcrFailed, language: vernService.langCode)` (`lines 110-115`).
     * If `parsedMeds.isEmpty` (including when API fails with `-1`), silently seeds default medications: Metformin 500mg and Telmisartan 40mg (`lines 170-198`).
     * Saves to `MedicationStorageService` via `_saveToSchedule` (`lines 226-257`).

4. **Blister Foil Verification Flow & Escalation:**
   * `BlisterVerifierWidget` (`aarogyam-flutter/lib/main_pages/blister_verifier/blister_verifier_widget.dart`):
     * `_verifyImage(path)` (`lines 71-167`) runs `_mlKitService.verifyBlisterFoil` (`lines 91-95`).
     * Inconclusive check (`lines 100-102`):
       `final isOcrUnclearOrFailed = ocrResult == null || ocrResult.status == VerificationStatus.unclear || ocrResult.rawDetectedText.trim().length < 4;`
     * Calls `VerifyStripAPICall.call` unconditionally on every image scan (`lines 118-125`).
     * UI verdict card displays color-coded status: Green for `matchSafe`, Red for `mismatchDanger` or `expired`, Amber for `unclear` (`lines 380-450`).
     * Vernacular spoken verdict is announced via `vernService.speakVerificationResult(finalResult)` (`line 165`).

5. **Networking Services & Backend Parity:**
   * `ApiManager.makeApiCall` (`aarogyam-flutter/lib/backend/api_requests/api_manager.dart:401-520`) catches network errors on line 514 and returns `ApiCallResponse(null, {}, -1, exception: e)`.
   * `api_calls.dart` (`aarogyam-flutter/lib/backend/api_requests/api_calls.dart:16-156`) defines `DigitizeRxAPICall`, `VerifyStripAPICall`, and `VernacularTTSAPICall`.
   * Backend `backend/app.py` defines `/api/health` (line 122), `/api/redact-pii` (line 149), `/api/digitize-rx` (line 167), `/api/verify-strip` (line 408), `/api/vernacular-tts` (line 527).
   * **Missing:** No `RedactPiiAPICall` exists in `api_calls.dart`, and no client-side PII sanitizer exists in `aarogyam-flutter/lib/` before sending raw OCR text.

6. **Local Storage & Data Models:**
   * Primary storage engine: `MedicationStorageService` (`aarogyam-flutter/lib/core/services/medication_storage_service.dart:6-305`), extending `ChangeNotifier` and persisting to `SharedPreferences` as JSON strings under keys `aarogyam_prescriptions_v1`, `aarogyam_medicines_v1`, `aarogyam_dose_logs_v1`, `aarogyam_last_dose_date_v1`.
   * Data models in `aarogyam-flutter/lib/core/models/medication_schedule.dart`: `MedicineItem` (lines 7-168), `DoseLogEntry` (lines 170-263), `PrescriptionRecord` (lines 265-330), `BlisterVerificationResult` (lines 332-399).
   * Secondary/legacy SQLite database exists via `SQLiteManager` (`dbaarogyam.db`), but is not used in active prescription/blister flows.

7. **Test Harness Verification:**
   * Executed command: `flutter test` in `/Users/rufbook/aarogyam/aarogyam-flutter`.
   * Result: **125 passed**, 0 failed across unit (90 tests), widget (29 tests), and integration (6 tests) suites in 6.2 seconds.

---

## 2. Logic Chain

1. **Requirement R1 (Failure Detection & Fallback Routing):**
   * *Observation 3 & 4* show that on-device failure detection exists via heuristic thresholding (`rawOcr.length < 15` for prescriptions; `status == unclear` or `rawDetectedText.length < 4` for blister foils).
   * However, *Observation 4* shows that `BlisterVerifierWidget` currently calls `VerifyStripAPICall` unconditionally on every foil scan, even when on-device OCR produced a safe, high-confidence (>= 0.70) match with valid expiry.
   * *Inference:* To fulfill R1 accurately and minimize latency/cloud usage, blister verification must selectively escalate to cloud vision ONLY when on-device OCR fails, produces low confidence (< 0.70), or yields inconclusive expiry dates.

2. **Requirement R2 (Edge Privacy & PII Sanitization):**
   * *Observation 3 & 5* show that `ReportSannerWidget` sends `rawOcrText` directly to `/api/digitize-rx` without prior de-identification.
   * Although `backend/app.py` has `mask_pii()` and `/api/redact-pii`, the client lacks a Dart edge PII masking engine.
   * *Inference:* A Dart-native `EdgePiiSanitizer` utility must be implemented in Flutter to de-identify Indian Aadhaar numbers, phone numbers, and patient identifiers on edge before network dispatch.

3. **Requirement R3 (Structured Response Processing & Local Synchronization):**
   * *Observation 3 & 6* demonstrate that `ReportSannerWidget` parses the response into `MedicineItem` and `PrescriptionRecord`, saving directly to `MedicationStorageService`.
   * However, when network calls fail (status code -1), it silently generates a default prescription without notifying the user of network failure.
   * *Inference:* The UI state must distinguish between cloud-digitized results, local on-device verified results, and offline fallback mode, displaying appropriate warning banners and retry options.

4. **Requirement R4 (Automated Verification & Test Quality):**
   * *Observation 7* confirms all 125 existing tests currently pass cleanly.
   * However, there are no tests specifically asserting the fallback triggering behavior when OCR text is unreadable/empty, nor verifying edge PII redaction.
   * *Inference:* New unit and widget tests targeting fallback triggers and PII sanitization can be added safely without breaking existing test harnesses.

---

## 3. Caveats

1. **Camera Hardware Testing:** On-device camera hardware and live video streams cannot be executed in headless CLI environments; tests rely on `ImagePicker` mocks and synthetic image file paths.
2. **WatsonX Remote Credentials:** Live cloud calls to IBM WatsonX Vision endpoints require valid credentials (`WATSONX_API_KEY`, `WATSONX_PROJECT_ID`). In local test environments without WatsonX keys, backend endpoints execute realistic mock fallbacks (`_get_demo_rx_response()` and `_get_demo_verify_response()`).

---

## 4. Conclusion

The Aarogyam Flutter client architecture is healthy, modular, and possesses a fully functional 125-test baseline. To implement the end-to-end fallback mechanism to IBM Granite Vision / WatsonX according to R1–R4, the following targeted enhancements are required:
1. **Edge PII Sanitizer (`lib/core/utils/edge_pii_sanitizer.dart`):** Implement on-device regex masking for Aadhaar, mobile numbers, and ABHA IDs.
2. **Selective Blister Escalation (`blister_verifier_widget.dart`):** Bypass cloud API when on-device ML Kit achieves >= 0.70 confidence and valid non-expired date; escalate immediately when inconclusive or failed.
3. **Resilient Prescription Fallback UI (`report_sanner_widget.dart`):** Add clear offline fallback indicators and retry actions when network fails.
4. **API Client Additions (`api_calls.dart`):** Add `RedactPiiAPICall`, sanitize outgoing OCR text, and add request timeout handling.
5. **Test Harness Additions:** Add unit tests for edge PII masking, fallback condition routing, and offline recovery.

---

## 5. Verification Method

To independently verify all observations and test results documented in this report:

1. **Verify Baseline Test Suite:**
   ```bash
   cd /Users/rufbook/aarogyam/aarogyam-flutter
   flutter test
   ```
   *Expected outcome:* All 125 tests pass (0 failures).

2. **Verify OCR Service & Foil Matcher Unit Tests:**
   ```bash
   flutter test test/unit/services_test.dart test/unit/api_calls_test.dart
   ```
   *Expected outcome:* All 31 tests pass.

3. **Verify Core Widget Tests:**
   ```bash
   flutter test test/widget/blister_verifier_widget_test.dart test/widget/report_sanner_widget_test.dart test/widget/reminder_page_widget_test.dart test/widget/home_page_widget_test.dart
   ```
   *Expected outcome:* All 7 widget tests pass.

4. **Verify End-to-End Integration Flow:**
   ```bash
   flutter test test/integration/full_flow_test.dart
   ```
   *Expected outcome:* Full pipeline test passes.

5. **Inspect Survey Report:**
   ```bash
   cat /Users/rufbook/aarogyam/.agents/teamwork/survey_explorer_client/survey_report.md
   ```
