# Aarogyam Dual Track Testing Infrastructure & Architecture Specification

## 1. Overview & Objectives

The Aarogyam subsystem implements a privacy-preserving, resilient fallback architecture connecting an on-device Flutter mobile edge client (`aarogyam-flutter/`) with a cloud Python backend (`backend/app.py`) powered by IBM Granite Vision 3.2 2B and WatsonX.

To guarantee zero regression, clinical reliability, patient privacy (DPDP Act 2023 / HIPAA Safe Harbor), and crash-resilient edge degradation, Aarogyam employs a **Dual-Track Testing Architecture**:
- **Track A (Implementation Track)**: Module-level unit tests and internal service behavior co-located with implementation artifacts.
- **Track B (Opaque-Box E2E Testing Track)**: Comprehensive end-to-end integration and boundary test suites that validate the complete hybrid pipeline from image capture failure heuristics to cryptographic PII redaction, cloud API escalation, local medication storage synchronization, and vernacular spoken alerts.

This document specifies the test harness architecture, test tiers, authoritative test oracles, and execution protocol.

---

## 2. Test Hierarchy (Tiers 1–4)

The test suites are organized into four progressive tiers designed to test both nominal behavior and hostile edge conditions.

```
+-------------------------------------------------------------------------------+
| Tier 4: Real-World Clinical Scenarios                                         |
| (5 End-to-End Field Scenarios: Remote Clinic, Expired Strips, Complex Regimen)|
+-------------------------------------------------------------------------------+
                                        ^
+-------------------------------------------------------------------------------+
| Tier 3: Cross-Feature Combinations                                            |
| (Pairwise interactions: OCR Fail + PII + Dispatch; Blister + Timeout + Local) |
+-------------------------------------------------------------------------------+
                                        ^
+-------------------------------------------------------------------------------+
| Tier 2: Boundary & Corner Cases                                               |
| (0-char/14-char/15-char OCR, Verhoeff invalid checksums, batch code collision)|
+-------------------------------------------------------------------------------+
                                        ^
+-------------------------------------------------------------------------------+
| Tier 1: Feature Coverage (>=5 test cases per feature)                         |
| (F1-F12: Prescription Failure, Blister Escalation, PII Redaction, Local Sync) |
+-------------------------------------------------------------------------------+
```

### 2.1 Tier 1: Feature Coverage (>= 5 tests per feature group)
Validates primary happy-path behavior and contract compliance across all 12 core features:
1. **F1 & F2: Prescription Failure Detection & Cloud Vision Model Dispatch**
   - Detection of empty OCR, illegible handwriting, or text length $< 15$ characters.
   - Dispatch payload serialization (`image_base64`, `raw_ocr_text`, `ocr_failed`, `language`).
   - Structured JSON response receipt and deserialization.
   - Multi-language request handling (`hi`, `mr`, `en`).
   - System instruction adherence and mock/live Granite Vision routing.
2. **F3 & F4: Blister Foil Inconclusive Detection & Cloud Escalation**
   - Detection of low confidence score ($< 0.70$), short OCR ($< 4$ characters), or missing drug tokens.
   - Escalation dispatch to `POST /api/verify-strip`.
   - Matching verification (`verified: true`, `ALLOW_CONSUMPTION`).
   - Mismatch detection (`verified: false`, `BLOCK_CONSUMPTION`).
   - Packaging batch and expiry date extraction.
3. **F5: Network Timeout / Error Recovery & Offline Fallback**
   - Upstream WatsonX connection timeout handling without server 500 error.
   - Malformed/non-JSON model response recovery.
   - Graceful fallback payload returning clinically valid fallback data.
   - Unconfigured credentials handling with structured demo response.
   - Edge client zero-crash guarantee during network severance.
4. **F6 & F7: Aadhaar (Verhoeff D5) and Phone Number Masking**
   - Standard 12-digit Aadhaar masking (`XXXXXXXX1234` or `[MASKED-AADHAAR-XXXX]`).
   - Space-separated (`1234 5678 9012`) and hyphen-separated (`1234-5678-9012`) formatting.
   - Standard 10-digit Indian mobile number masking (`+91-XXXXX-XX210` or `[MASKED-PHONE-XXXX]`).
   - Country code variations (`+91`, `0`, bare 10-digit).
   - `/api/redact-pii` endpoint integration and redaction entity tracking.
5. **F8 & F9: Patient Name De-Identification & SHA-256 Proof Manifest**
   - Multilingual demographic header extraction (`Patient Name:`, `मरीज का नाम:`, `रुग्णाचे नाव:`).
   - Synthetic token pseudonymization (`[PATIENT-ANON-XXXX]`).
   - Negative filter safeguarding Doctor credentials (`Dr.`, `MD`, `MBBS`) and Hospital names (`PHC`, `AIIMS`).
   - Pre-sanitization and post-sanitization SHA-256 digest computation.
   - Audit manifest structure compliance (`proof_id`, `timestamp_utc`, `digests`, `redaction_summary`).
6. **F10 & F11: Structured Medication Schedule Extraction & Storage Sync**
   - Clinical schema parsing (name, strength, form, frequency, timings_24hr).
   - Normalization of clinical Latin abbreviations (OD $\to$ 1 dose, BD $\to$ 2 doses, TDS $\to$ 3 doses).
   - Morning/afternoon/night boolean slot mapping.
   - Food relation assignment (`Before Food`, `After Food`, `With Food`).
   - Dynamic synchronization with `MedicationStorageService` and `SharedPreferences`.
7. **F12: Blister Safety Verdicts & Vernacular Audio Alert Generation**
   - Verification status classification (`matchSafe`, `mismatchDanger`, `expired`, `unclear`).
   - Spoken vernacular verdict generation in Hindi and Marathi.
   - Text-to-speech fallback handling via `/api/vernacular-tts`.
   - Adherence dose marking gating (blocking dose logging on expired or mismatched strips).
   - UI status card badge state transitions.

---

### 2.2 Tier 2: Boundary & Corner Cases (>= 5 tests per category)
Evaluates critical limits, edge thresholds, and format collisions:
- **Prescription OCR Text Length Boundaries**:
  - $0$ characters (empty OCR payload).
  - $1$ character (`"R"`).
  - $14$ characters (strict lower boundary for failure threshold $< 15$).
  - $15$ characters (strict upper boundary triggering on-device parsing).
  - $10,000$ characters (extreme payload stress testing).
- **Blister OCR Text Length Boundaries**:
  - $0$ characters (blank scan).
  - $3$ characters (strict lower boundary for foil failure $< 4$).
  - $4$ characters (boundary condition for foil parsing).
  - Pure non-alphanumeric noise (`"---///###!!!"`).
  - Mixed noisy OCR artifacts with fragmented text.
- **Aadhaar & Verhoeff Checksum Edge Cases**:
  - Single digit transposition in valid Aadhaar (`2346-5789-0124` vs valid `2345-6789-0124`).
  - Jump transposition (`2345-6789-0142`).
  - Non-digit string formatted with 12 characters (`ABCD-EFGH-IJKL`).
  - Invalid leading digits (`0123-4567-8901` starting with 0, `1234-5678-9012` starting with 1).
  - Medicine batch code collision: `Batch: 1234-5678-9012` (fails Verhoeff and has batch prefix context, must not be falsely masked).
- **Phone Number Boundary Cases**:
  - 9-digit number (`987654321`, below 10 digits $\to$ not a phone).
  - 10-digit number starting with 1-5 (`5432109876`, invalid DoT mobile series $\to$ not masked).
  - Valid 10-digit mobile starting with 6, 7, 8, 9 (`6123456789`, `9876543210`).
  - Phone with $5+5$ spacing (`+91 98765 43210`).
  - Serial number prefix (`SN: 5432109876`, protected from false redaction).
- **Expiry Date Boundary Cases**:
  - Far past expired: `EXP 01/2020` (expired $\to$ BLOCK).
  - Recent past expired: `EXP 03/2024` (expired $\to$ BLOCK).
  - Far future: `EXP 12/2030` (valid $\to$ ALLOW).
  - Current cycle edge: `EXP 12/2026` (valid $\to$ ALLOW).
  - Malformed expiry date strings (`EXP 99/9999`, `EXP AB/2025`).
- **Network & Socket Timeout Boundaries**:
  - Ultra-short socket timeout simulation ($0.1$s) recovering to fallback.
  - HTTP 500/503 upstream error simulation gracefully intercepted.

---

### 2.3 Tier 3: Cross-Feature Combinations (Pairwise Integration)
Tests simultaneous feature interactions and failure cascading:
1. **OCR Failure + PII Masking + Cloud Dispatch**:
   An unreadable doctor prescription containing patient PII is captured. Edge heuristic triggers `ocr_failed = true`, masks Aadhaar and phone, generates a pre-dispatch manifest, and dispatches sanitized payload to the backend vision model.
2. **Inconclusive Blister + Network Timeout + Local Fallback**:
   A torn blister strip produces low OCR confidence. Client escalates to cloud vision. Cloud network request times out ($0.1$s). System catches the timeout without crashing and returns local safety assessment with clear user alert.
3. **Tampered PII Manifest + Integrity Verification**:
   A pre-sanitization or post-sanitization payload is deliberately altered after digest calculation. Verification oracle recomputes SHA-256 and detects cryptographic mismatch, preventing unverified transmission.
4. **Expired Medication + Vernacular TTS Alert + Schedule Block**:
   Scanned strip matches the scheduled drug name but has an expired date (`EXP 03/2024`). System triggers `is_expired: true`, `status: expired`, `action: BLOCK_CONSUMPTION`, passes emergency warning text to `VernacularService`, and prevents the dose log from being marked as taken.

---

### 2.4 Tier 4: Real-World Clinical Field Scenarios
End-to-end integration workflows modeling genuine Indian healthcare contexts:
1. **Scenario 1: Illegible Handwritten Prescription with Patient PII**:
   Rural PHC patient arrives with handwritten doctor slip containing `"Patient: Ramesh Kumar, Aadhaar: 2345-6789-0124, Rx: Metformin 500mg BD PC"`. System masks PII, calls digitizer, maps `BD` to `["08:30", "20:30"]`, and populates morning and night medication cards.
2. **Scenario 2: Blurry Blister Pack with Expired Date**:
   Elderly patient scans Metformin blister foil with faint printing and `EXP 03/2024`. Verification detects expired status, sets action to `BLOCK_CONSUMPTION`, and announces vernacular audio warning in Hindi: *"चेतावनी! यह दवा एक्सपायर हो चुकी है!"*.
3. **Scenario 3: Complete Offline Mode during Village Clinic Visit**:
   Health worker visits a remote area with zero cellular connectivity. Fallback engine intercepts network errors, supplies local cached clinical structure, displays offline alert badge, and preserves full UI interactivity without crash.
4. **Scenario 4: Valid Prescription with Medicine Batch Code Preservation**:
   Prescription contains both patient Aadhaar and medicine manufacturer batch code `Batch Number: 1234-5678-9012`. System verifies Aadhaar via Verhoeff and masks it, while preserving the pharmaceutical batch code intact.
5. **Scenario 5: Multi-Drug Complex Regimen Extraction**:
   Complex multi-condition prescription with 3 medicines: Metformin 500mg (BD after food), Telmisartan 40mg (OD after breakfast), and Pantoprazole 40mg (OD before food). All three are parsed, validated, assigned distinct 24-hr timings, and synchronized to the local schedule database.

---

## 3. Authoritative Test Oracles

All test assertions are derived from documented standards, statutory specifications, and algorithmic truths:

| Domain | Standard / Oracle Source | Authoritative Truth |
|---|---|---|
| **Aadhaar Checksum** | UIDAI Aadhaar Act 2016; Dihedral Group $D_5$ Verhoeff Algorithm | Multiplication table $d_{10\times10}$, permutation table $p_{8\times10}$, inversion table $inv_{10}$. Valid Aadhaar numbers produce $c=0$. |
| **Phone Numbers** | DoT National Numbering Plan (NNP); ITU-T E.164 | Indian mobile series must begin with 6, 7, 8, or 9 and contain exactly 10 national digits. Numbers starting with 1-5 are landlines or serials. |
| **Privacy Compliance** | DPDP Act 2023 Sec 8; HIPAA Safe Harbor 45 CFR § 164.514 | Patient demographic fields are sanitized; pre/post SHA-256 digests provide cryptographic audit proof. |
| **Medical Abbreviations** | Indian Pharmacopoeia (IP) & WHO Clinical Transcription Guidelines | OD = Once Daily (1 dose); BD/BID = Twice Daily (2 doses); TDS/TID = Thrice Daily (3 doses); QID = Four Times Daily (4 doses); AC = Before Food; PC = After Food; HS = Bedtime. |
| **Expiry Verification** | Calendar & ISO Date Calculation | Strip is expired if `last_day_of_month(expiry_year, expiry_month) < current_date`. |

---

## 4. Test Suite Implementation Files

| Suite | File Path | Framework | Focus |
|---|---|---|---|
| **Backend Opaque-Box Suite** | `backend/tests/test_e2e_fallback.py` | Python `pytest` | API contracts, WatsonX mock resilience, Verhoeff D5 oracle, PII masking, 24-hr timing extraction, blister verification actions. |
| **Flutter Edge Client Suite** | `aarogyam-flutter/test/unit/fallback_e2e_test.dart` | Flutter `flutter_test` | On-device failure detection, blister heuristic scoring, SharedPreferences persistence, Vernacular TTS alerts, cross-feature combinations, clinical scenarios. |

---

## 5. Execution Commands

### Run Backend Test Suite:
```bash
cd /Users/rufbook/aarogyam
backend/venv/bin/pytest backend/tests/test_e2e_fallback.py -v
```

### Run Flutter Test Suite:
```bash
cd /Users/rufbook/aarogyam/aarogyam-flutter
flutter test test/unit/fallback_e2e_test.dart
```

### Run Full Test Regressions:
```bash
# Backend all tests
backend/venv/bin/pytest backend/tests/ -v

# Flutter all unit tests
cd /Users/rufbook/aarogyam/aarogyam-flutter
flutter test test/unit/
```
