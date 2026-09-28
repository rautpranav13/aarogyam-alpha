# Comprehensive Architectural Survey Report: Aarogyam Flutter Client

**Survey Date:** 2026-09-28  
**Explorer:** Client Architecture Explorer  
**Target Repository:** `aarogyam-flutter/` (within `/Users/rufbook/aarogyam/`)  
**Scope:** On-device ML Kit OCR, Blister Foil Scanning, Failure Detection, Network / Vision APIs, Local Storage, UI Views, Test Harness, and Gap Analysis for IBM Granite Vision Fallback Mechanism (R1, R2, R3, R4).

---

## Executive Summary

The Aarogyam mobile client is a Flutter 3 application designed for rural Primary Health Centres (PHCs) and elderly/low-literacy patients across India. The application features a hybrid architecture combining on-device intelligence (Google ML Kit Latin text recognition, regex-based clinical token matching, local SharedPreferences persistence) with backend cloud intelligence (IBM Granite Vision 3.2 2B multimodal vision model, IBM Watson TTS, edge PII de-identification).

Currently, all **125 Flutter tests pass** across unit, widget, and integration test suites. The Flutter client provides working foundational implementations for prescription scanning (`ReportSannerWidget`), blister packaging verification (`BlisterVerifierWidget`), local medication storage (`MedicationStorageService`), and trilingual vernacular audio (`VernacularService`).

However, significant architectural gaps exist in edge privacy sanitization (R2), failure-triggered selective escalation for blister foil analysis (R1), and resilient UI error states when cloud services fail or time out (R3). This report provides a detailed technical mapping of each subsystem with file paths, line numbers, algorithm flows, and actionable implementation recommendations.

---

## 1. On-Device Google ML Kit OCR Architecture

### 1.1 Service Implementation: `MLKitOcrService`
* **File:** `aarogyam-flutter/lib/core/services/mlkit_ocr_service.dart` (345 lines)
* **Underlying Dependency:** `google_mlkit_text_recognition: ^0.17.1` (`pubspec.yaml:95`)
* **Singleton Pattern:** Instantiated via `MLKitOcrService._internal()` (`mlkit_ocr_service.dart:7-10`).
* **Text Recognizer Script:** Configured for `TextRecognitionScript.latin` (`mlkit_ocr_service.dart:15`).

### 1.2 Image Ingestion & OCR Processing
The service exposes two primary entry points:
1. `processImageFile(String imagePath)` (`lines 20-29`):
   * Converts image path to `InputImage.fromFilePath(imagePath)`.
   * Invokes `_recognizer.processImage(inputImage)`.
   * Traps exceptions with `debugPrint('ML Kit OCR processImage error: $e')` and returns `null`.
2. `extractText(String imagePath)` (`lines 56-59`):
   * High-level wrapper returning `recognized?.text ?? ''`.

### 1.3 Blister Foil Verification Algorithm: `analyzeFoilText`
* **Method:** `verifyBlisterFoil({required String imagePath, required List<MedicineItem> activeMedicines, MedicineItem? targetMedicine})` (`lines 62-75`).
* **Text Parsing Logic (`lines 78-250`):**
  1. **Empty Text Guard (`lines 83-94`):**
     If `rawText.trim().isEmpty`, immediately yields `VerificationStatus.unclear` with `isSafe: false` and localized messages prompting the user to rescan under better lighting.
  2. **Expiry Detection (`lines 99-100`, `299-322`):**
     * Regex pattern: `(?:exp|expiry|exp\.?date|use\s*before)[\s.:/_-]*([0-9]{1,2}[/-][0-9]{2,4}|[a-z]{3}[/-][0-9]{2,4})` or `\b(0[1-9]|1[0-2])[/-](202[0-9]|2[4-9])\b`.
     * `_isDateExpired(String expString)` computes the end-of-month `DateTime` and checks `expDate.isBefore(DateTime.now())`.
     * If expired, marks `isExpired: true`, `isSafe: false`, and `VerificationStatus.expired`.
  3. **Dosage & Batch Extraction:**
     * Dosage regex (`lines 324-328`): `\b([0-9]+(?:\.[0-9]+)?\s*(?:mg|mcg|ml|g|iu))\b`.
     * Batch number regex (`lines 330-334`): `(?:batch|b\.?no|lot)[\s.:/_-]*([a-z0-9\-_]+)`.
  4. **Fuzzy Token Matching & Levenshtein Distance (`lines 252-297`):**
     * Tokenizer: Strips punctuation and excludes stop words (`tablet`, `capsule`, `syrup`, `drops`, `hydrochloride`, `sodium`, `potassium`, `sustained`, `release`).
     * `_fuzzyMatchScore(query, text)`: Word-by-word Levenshtein distance ratio `1.0 - (dist / maxLen)`.
     * Match Threshold: Match is accepted if `bestMatchScore >= 0.70`.
     * Cross-Schedule Checking: If target medicine does not match, scans all other active medicines in the schedule (`lines 154-184`). If another medicine matches with score >= 0.70, raises `VerificationStatus.mismatchDanger` with a wrong medication alert.

---

## 2. Failure Detection, Confidence Thresholds & Error Handling

### 2.1 Doctor Prescription Scanning Flow (`ReportSannerWidget`)
* **File:** `aarogyam-flutter/lib/main_pages/report_sanner/report_sanner_widget.dart` (815 lines)
* **Image Capture:** `_pickImage(ImageSource source)` (`lines 53-66`) via `ImagePicker.pickImage(maxWidth: 1600, maxHeight: 1600, imageQuality: 90)`.
* **Failure Detection Pipeline (`lines 68-115`):**
  1. On-device ML Kit OCR runs first: `final ocrText = await _mlKitService.extractText(path)`.
  2. If OCR throws an exception:
     ```dart
     catch (ocrErr) {
       debugPrint('On-device OCR failed: $ocrErr. Automatically falling back to Cloud Vision.');
       _model.rawOcrText = '';
     }
     ```
  3. Threshold check for insufficient OCR text:
     ```dart
     final rawOcr = _model.rawOcrText ?? '';
     final isOcrFailed = rawOcr.trim().length < 15;
     ```
  4. Cloud Vision Dispatch: Automatically calls `DigitizeRxAPICall.call(...)` with `ocrFailed: isOcrFailed`.
  5. Fallback Clinical Dataset: If backend is offline or `parsedMeds.isEmpty`, falls back to a hardcoded prescription dataset (`lines 170-198`): Metformin Hydrochloride 500mg and Telmisartan 40mg.
* **Identified Gap in Failure Detection:**
  * The threshold `rawOcr.trim().length < 15` is an arbitrary heuristic. It does not inspect whether recognized text contains clinical entities (e.g. drug name, dosage, frequency) vs unreadable gibberish.
  * If the network is down or backend returns `-1`, the app silently falls back to Metformin/Telmisartan without informing the user that cloud digitization failed or that the prescription shown is a synthetic default.

### 2.2 Blister Strip Verification Flow (`BlisterVerifierWidget`)
* **File:** `aarogyam-flutter/lib/main_pages/blister_verifier/blister_verifier_widget.dart` (666 lines)
* **Failure & Threshold Logic (`lines 88-125`):**
  1. On-device verification runs: `ocrResult = await _mlKitService.verifyBlisterFoil(...)`.
  2. Failure & Inconclusive Criteria:
     ```dart
     final isOcrUnclearOrFailed = ocrResult == null ||
         ocrResult.status == VerificationStatus.unclear ||
         ocrResult.rawDetectedText.trim().length < 4;
     ```
  3. Cloud Vision Escalation: Calls `VerifyStripAPICall.call(...)` with `ocrFailed: isOcrUnclearOrFailed`.
  4. Result Reconciliation: If cloud verification succeeds (`apiResp.succeeded`), updates result with Granite Vision payload; if cloud call throws or fails, catches error and preserves on-device `ocrResult` (`lines 154-156`).
* **Identified Gap in Blister Escalation:**
  * In the current implementation, `VerifyStripAPICall.call` is invoked **unconditionally on every scan**, even when on-device OCR has already established a `matchSafe` verdict with >= 0.70 confidence!
  * According to Requirement R1: cloud multimodal vision analysis should only be triggered when on-device verification fails, encounters errors, or is inconclusive (e.g. `status == VerificationStatus.unclear`, low confidence score < 0.70, or unreadable foil). Calling the cloud on conclusive safe matches adds unnecessary latency and network dependency.

---

## 3. Network & HTTP Client Services for Vision APIs

### 3.1 HTTP Architecture & `ApiManager`
* **File:** `aarogyam-flutter/lib/backend/api_requests/api_manager.dart` (521 lines)
* **Base Package:** `http: ^1.3.0` (`pubspec.yaml:55`)
* **Transport Structure:**
  * `ApiCallResponse`: Models HTTP response with `statusCode`, `jsonBody`, `headers`, `succeeded` (`statusCode >= 200 && statusCode < 300`), and `exception`.
  * `makeApiCall()` (`lines 401-520`): Dispatches HTTP requests. Includes `try / catch (e)` wrapping on line 514, returning `ApiCallResponse(null, {}, -1, exception: e)`.
* **Configuration:**
  * Reads `dotenv.env['BACKEND_URL']` -> `dotenv.env['LVM_API_URL']` -> `'http://localhost:5001'` (`api_calls.dart:9-13`).
  * `.env` contains: `BACKEND_URL=http://localhost:5001` (`.env:2`).

### 3.2 Vision & Backend Endpoints Mapping
* **File:** `aarogyam-flutter/lib/backend/api_requests/api_calls.dart` (265 lines)

| API Call Class | Backend Endpoint | Request Payload | Response Extraction |
| :--- | :--- | :--- | :--- |
| `DigitizeRxAPICall` | `POST /api/digitize-rx` | `imageBase64`, `imageUrl`, `rawOcrText`, `ocrFailed`, `language` | `medicationsList(dynamic response)` -> `$.data.medications` |
| `VerifyStripAPICall` | `POST /api/verify-strip` | `imageBase64`, `imageUrl`, `rawOcrText`, `ocrFailed`, `expectedDrug`, `expectedStrength`, `language` | `isVerified`, `detectedText`, `voiceAlert`, `action` |
| `VernacularTTSAPICall`| `POST /api/vernacular-tts` | `text`, `language` | JSON status or MP3 stream |
| *Missing* | `POST /api/redact-pii` | `text` | *No client wrapper exists in Flutter!* |

### 3.3 Backend Parity (`backend/app.py`)
* The backend provides endpoints matching the above contracts:
  * `/api/digitize-rx` (`app.py:167-399`): Runs IBM Granite Vision 3.2 2B via WatsonX (`_get_watsonx_model`). Includes `_get_demo_rx_response()` fallback.
  * `/api/verify-strip` (`app.py:408-520`): Analyzes blister strip foil images for drug name, dosage, batch, expiry, and returns verdict (`ALLOW_CONSUMPTION` or `BLOCK_CONSUMPTION`).
  * `/api/redact-pii` (`app.py:149-165`): De-identifies Aadhaar, mobile numbers, ABHA IDs.
* **Gaps in Client Networking:**
  1. No client-side call exists for `/api/redact-pii`.
  2. `ApiManager.makeApiCall` lacks an explicit request timeout (default HTTP client can hang indefinitely on slow cellular networks).
  3. No client-side exponential backoff or retry policy.

---

## 4. Local Storage Mechanisms & Data Models

### 4.1 Persistence Mechanism Comparison
The Flutter codebase contains two storage mechanisms:
1. **`SharedPreferences` (Active Primary Engine):**
   * Service: `MedicationStorageService` (`lib/core/services/medication_storage_service.dart`).
   * Serialization: Complete JSON serialization (`jsonEncode` / `jsonDecode`).
   * Keys:
     * `aarogyam_prescriptions_v1`: List of `PrescriptionRecord`.
     * `aarogyam_medicines_v1`: List of `MedicineItem`.
     * `aarogyam_dose_logs_v1`: List of `DoseLogEntry`.
     * `aarogyam_last_dose_date_v1`: Daily date stamp (`YYYY-MM-DD`).
     * `aarogyam_language_code`: Current language (`hi`, `mr`, `en`).
   * Default Seeding: If empty, seeds realistic Indian PHC prescriptions (`_loadDefaultData()`): Metformin 500mg, Telmisartan 40mg, Pantoprazole 40mg.
2. **`SQLite` (`sqflite: ^2.3.3+1`) (Legacy / Secondary):**
   * Implementation: `SQLiteManager` (`lib/backend/sqlite/sqlite_manager.dart`) and `init.dart`.
   * Asset DB: `dbaarogyam.db` loaded from assets.
   * Usage: Legacy table queries (`readmedications`, `updateremainder`). Not wired into the active prescription scanning or blister verifier workflows.
3. **`Hive` / `Isar`:** Not utilized in this codebase.

### 4.2 Core Data Models
* **File:** `aarogyam-flutter/lib/core/models/medication_schedule.dart` (400 lines)

```
                    ┌─────────────────────────┐
                    │   PrescriptionRecord    │
                    ├─────────────────────────┤
                    │ - id: String            │
                    │ - doctorName: String    │
                    │ - clinicHospital: String│
                    │ - diagnosis: String     │
                    │ - scannedDate: DateTime │
                    │ - rawOcrText: String    │
                    │ - redactedPiiProof: Str │
                    │ - medicines: List<Med>  │
                    └───────────┬─────────────┘
                                │ 1..*
                                ▼
                    ┌─────────────────────────┐
                    │      MedicineItem       │
                    ├─────────────────────────┤
                    │ - id: String            │
                    │ - name: String          │
                    │ - dosage: String        │
                    │ - form: String          │
                    │ - frequency: String     │
                    │ - morning/noon/night: b │
                    │ - morning/noon/nightTime│
                    │ - foodRelation: String  │
                    │ - instructionsHi/Mr/En  │
                    │ - pillColorHex/Shape    │
                    └───────────┬─────────────┘
                                │ generates
                                ▼
                    ┌─────────────────────────┐
                    │      DoseLogEntry       │
                    ├─────────────────────────┤
                    │ - id: String            │
                    │ - medicineId: String    │
                    │ - scheduledSlot: String │
                    │ - scheduledTime: String │
                    │ - status: DoseStatus    │
                    │ - takenAt: DateTime?    │
                    │ - verifiedViaFoil: bool │
                    │ - detectedFoilText: Str │
                    └─────────────────────────┘
```

* **`BlisterVerificationResult` Model (`medication_schedule.dart:332-399`):**
  * `isSafe: bool`
  * `status: VerificationStatus` (`matchSafe`, `mismatchDanger`, `expired`, `unclear`)
  * `detectedDrugName: String`, `detectedDosage: String`, `detectedBatch: String`, `detectedExpiry: String`
  * `isExpired: bool`
  * `confidenceScore: double`
  * `matchedMedicineName: String`
  * `vernacularMessageHindi / Marathi / English: String`
  * `rawDetectedText: String`

---

## 5. UI Views, Reminders, Safety Indicators & Vernacular Speech

### 5.1 Prescription Scanning View: `ReportSannerWidget`
* **File:** `aarogyam-flutter/lib/main_pages/report_sanner/report_sanner_widget.dart`
* **UI Features:**
  * Camera and Gallery picker actions (`_pickImage`).
  * Animated processing state during on-device OCR and cloud digitization.
  * Extracted prescription summary cards: Doctor Name, Clinic, Clinical Diagnosis.
  * Edge Privacy Badge: Displays `redactedPiiProof` banner (`"Protected via On-Device De-Identification"`).
  * Medication list cards showing drug name, dosage, schedule slots, and vernacular instructions.
  * "Save to Schedule" action: Adds prescription to `MedicationStorageService` and triggers notification snackbar.
  * Automatic vernacular announcement upon successful digitization.

### 5.2 Blister Strip Verifier View: `BlisterVerifierWidget`
* **File:** `aarogyam-flutter/lib/main_pages/blister_verifier/blister_verifier_widget.dart`
* **UI Features:**
  * Dropdown selector allowing patient to choose their target scheduled medication.
  * Camera capture or gallery upload buttons.
  * Dynamic Verdict Card with strict color-coded safety indicators:
    * **Safe Match:** Green theme, `Icons.check_circle_rounded`, `AppColors.success`.
    * **Wrong Medication / Mismatch:** Red theme, `Icons.cancel_rounded`, `AppColors.error`.
    * **Expired:** Crimson theme, `Icons.event_busy_rounded`, `AppColors.error`.
    * **Unclear / Low Confidence:** Amber theme, `Icons.info_rounded`, `AppColors.warning`.
  * Foil details card displaying Detected Drug, Expected Drug, Dosage, Batch, Expiry Date, and Confidence Score percentage.
  * "Mark Dose Taken" action: Enabled only when verdict is verified and safe, stamping `verifiedViaFoil = true` on the dose log.

### 5.3 Schedule & Reminder Hub: `ReminderPageWidget`
* **File:** `aarogyam-flutter/lib/main_pages/reminder_page/reminder_page_widget.dart`
* **UI Features:**
  * Tab 1: **Today's Dose Logs:** Grouped by Morning, Afternoon, Night slots. Displays pill icon with custom hex colors, scheduled time, food relation chips, and direct shortcut button to launch `BlisterVerifierWidget`.
  * Tab 2: **Active Medicines:** Comprehensive active medication cards with full dosage guidelines.
  * Tab 3: **Prescription History:** Chronological log of scanned prescriptions with doctor name, clinic, de-identification proof, and vernacular audio playback button.
  * FAB: Add manual medicine modal bottom sheet.

### 5.4 Home Dashboard: `HomePageWidget`
* **File:** `aarogyam-flutter/lib/main_pages/home_page/home_page_widget.dart`
* **UI Features:**
  * Language toggle in AppBar (`Hindi`, `Marathi`, `English`).
  * Emergency SOS button with 1-tap call to National Emergency Ambulance Service (`108`).
  * Next Dose card with vernacular audio read-aloud button (`vernService.speakNextDose(nextDose)`).
  * Today's Adherence ring tracker showing percentage of completed doses.
  * Action hub routing to Scanner, Verifier, Schedule, and Dadi-Ma companion.

### 5.5 Vernacular Speech & Audio Subsystem
* **Files:**
  * `aarogyam-flutter/lib/core/services/vernacular_service.dart` (842 lines)
  * `aarogyam-flutter/lib/core/services/audio_service.dart` (94 lines)
* **Dual TTS Engine Strategy:**
  1. Primary: Cloud IBM Watson TTS via `/api/vernacular-tts`, streaming MP3 bytes to `AudioPlayer` (`audio_service.dart:53-63`).
  2. Fallback: Native on-device `flutter_tts` (`vernacular_service.dart:734-744`) configured for `hi-IN`, `mr-IN`, `en-IN` at `0.45` speech rate for clear elderly comprehension.
* **Comprehensive Trilingual Dictionary:** Over 100 localized terms covering all UI labels, warnings, and clinical instructions.

---

## 6. Test Harness & Test Suite Architecture (`flutter test`)

### 6.1 Test Suite Inventory
The test harness is organized into three clean tiers under `aarogyam-flutter/test/`:

| Directory | Files | Total Tests | Status | Key Coverage |
| :--- | :---: | :---: | :---: | :--- |
| `test/unit/` | 8 files | 90 tests | **PASS** | `api_calls_test.dart` (24 tests), `services_test.dart` (7 tests), `vernacular_multilingual_test.dart`, `app_state_test.dart`, `dadi_ma_service_test.dart`, `flutter_flow_util_test.dart`, `schema_util_test.dart`, `base_model_test.dart` |
| `test/widget/` | 10 files | 29 tests | **PASS** | `blister_verifier_widget_test.dart`, `report_sanner_widget_test.dart`, `home_page_widget_test.dart`, `reminder_page_widget_test.dart`, `multilingual_screens_test.dart`, `ai_disclaimer_test.dart`, `dadi_ma_widget_test.dart`, `theme_test.dart`, etc. |
| `test/integration/`| 2 files | 6 tests | **PASS** | `full_flow_test.dart` (E2E Pipeline: Digitize Rx -> Schedule -> Blister Verify), `app_smoke_test.dart` (Environment & Navigation) |
| **Total** | **20 files** | **125 tests** | **100% PASS** | Execution time: ~6.2 seconds |

### 6.2 Test Harness Mocks & Environment
* **Test Initialization:** `TestWidgetsFlutterBinding.ensureInitialized()` in `setUpAll()`.
* **SharedPreferences Mock:** `SharedPreferences.setMockInitialValues({})`.
* **Environment Mock:** `dotenv.testLoad(fileInput: 'BACKEND_URL=http://localhost:5001\n')`.
* **Theme Mock:** `await FlutterFlowTheme.initialize()`.
* **Fake Firestore:** Uses `fake_cloud_firestore: ^3.0.2` (`pubspec.yaml:107`) to eliminate remote database dependencies.

---

## 7. Architectural Gap Analysis & Recommendations (R1 – R4)

### 7.1 Gap 1: On-Device Failure Detection & Selective Escalation (R1)
* **Current State:**
  * Prescription scanning flags `ocr_failed = rawOcr.trim().length < 15` and always calls the backend.
  * Blister strip verification calls the backend vision endpoint on every scan, regardless of whether on-device OCR achieved a high-confidence match.
* **Architectural Recommendations:**
  1. Refine Prescription OCR Failure Detection: Inspect for minimum length (< 25 characters) OR lack of recognized medical tokens (no dosage, no medicine names). Flag `ocr_failed: true` when illegible handwriting is encountered.
  2. Implement Selective Escalation for Blister Strips:
     * If on-device ML Kit finds a safe match with confidence >= 0.70 AND valid non-expired date, accept on-device result immediately (zero cloud network round-trip).
     * If on-device status is `unclear`, text length < 4, confidence < 0.70, or date is inconclusive, escalate to `VerifyStripAPICall.call(...)`.

### 7.2 Gap 2: Edge Privacy & PII Sanitization (R2)
* **Current State:**
  * No client-side PII masking engine exists in Flutter.
  * The backend has `mask_pii()` in `app.py` and `/api/redact-pii`, but the Flutter client sends raw unredacted OCR strings to `/api/digitize-rx`.
* **Architectural Recommendations:**
  1. Implement a Dart edge PII de-identification utility: `EdgePiiSanitizer` in `lib/core/utils/edge_pii_sanitizer.dart`.
  2. Redact 12-digit Indian Aadhaar numbers (`\b(\d{4}[\s-]?\d{4}[\s-]?\d{4})\b`), 10-digit mobile numbers (`(?:\+91[\-\s]?|0)?([6-9]\d{9})\b`), and ABHA IDs before sending `raw_ocr_text` in `DigitizeRxAPICall` and `VerifyStripAPICall`.
  3. Add `RedactPiiAPICall` to `api_calls.dart` for cloud-assisted de-identification verification.

### 7.3 Gap 3: Resilient Response Processing & UI Synchronization (R3)
* **Current State:**
  * When `DigitizeRxAPICall` fails (HTTP -1 or timeout), `report_sanner_widget.dart` silently falls back to hardcoded default clinical data without notifying the user that cloud digitization failed.
  * Blister verification card does not clearly distinguish whether the verdict was rendered by On-Device ML Kit or Cloud IBM Granite Vision.
* **Architectural Recommendations:**
  1. Add an explicit `SourceVerdict` or `verificationSource` enum (`onDeviceOcr`, `cloudGraniteVision`, `offlineFallback`) to `BlisterVerificationResult` and `PrescriptionRecord`.
  2. Surface informative banners in `ReportSannerWidget` when offline fallback is used, providing a "Retry Cloud Vision" button.
  3. Ensure network timeouts in `ApiManager` are bounded (e.g. 10-second timeout) so the UI does not hang before falling back.

### 7.4 Gap 4: Automated Verification & Regression Testing (R4)
* **Current State:**
  * Existing 125 tests pass, but there are no tests specifically asserting the fallback routing when on-device OCR is forced to fail.
* **Architectural Recommendations:**
  1. Add unit tests for `EdgePiiSanitizer` verifying Aadhaar, mobile number, and patient identifier masking.
  2. Add unit tests in `api_calls_test.dart` for fallback response payloads and error status codes (-1).
  3. Add widget tests in `report_sanner_widget_test.dart` and `blister_verifier_widget_test.dart` verifying that empty OCR text triggers cloud dispatch and surfaces appropriate fallback states.

---

## 8. Summary Table: File Locations for Planned Work

| Component | Target File Path | Current Status | Planned Enhancement |
| :--- | :--- | :--- | :--- |
| **OCR Service** | `aarogyam-flutter/lib/core/services/mlkit_ocr_service.dart` | Working on-device ML Kit | Add confidence thresholds & inconclusive detection helper |
| **Edge PII Sanitizer** | `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart` | Missing | Create client-side Aadhaar/Phone/ABHA masking engine |
| **API Client** | `aarogyam-flutter/lib/backend/api_requests/api_calls.dart` | Working Digitize/Verify calls | Add RedactPii call, timeout guards, sanitized payloads |
| **Prescription UI** | `aarogyam-flutter/lib/main_pages/report_sanner/report_sanner_widget.dart` | Working UI, basic fallback | Connect PII sanitizer, improve fallback UI banner |
| **Blister Verifier UI**| `aarogyam-flutter/lib/main_pages/blister_verifier/blister_verifier_widget.dart` | Unconditional cloud call | Implement selective escalation (only on unclear/failure) |
| **Test Suite** | `aarogyam-flutter/test/unit/edge_pii_sanitizer_test.dart` | Missing | Add PII redaction test suite |
| **Widget Fallback Test**| `aarogyam-flutter/test/widget/fallback_routing_test.dart` | Missing | Validate OCR failure -> cloud dispatch UI behavior |
