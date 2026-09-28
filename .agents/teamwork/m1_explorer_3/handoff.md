# Milestone 1 Explorer 3 Handoff Report: API Integration & Cross-Platform Parity

**From**: Explorer 3 (API Integration & Parity)  
**To**: Milestone 1 Orchestrator / Implementer  
**Date**: 2026-09-28  
**Working Directory**: `/Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_3`  
**Handoff Type**: Hard (Task Complete)

---

## 1. Observation

1. **Existing Flutter API layer**: In `aarogyam-flutter/lib/backend/api_requests/api_calls.dart`, `DigitizeRxAPICall` (lines 16-63), `VerifyStripAPICall` (lines 66-126), and `VernacularTTSAPICall` (lines 129-156) exist. `RedactPiiAPICall` is currently missing.
2. **Existing Flutter API unit tests**: In `aarogyam-flutter/test/unit/api_calls_test.dart`, lines 1-168 test `ApiCallResponse`, `ApiPagingParams`, `getJsonField`, and static helpers for `ProcessImageAPICall`, `RagAPICall`, `DigitizeRxAPICall`, and `VerifyStripAPICall`. Running `flutter test test/unit/api_calls_test.dart` passes (24 tests passed in ~2.8s).
3. **Flutter Crypto dependency**: In `aarogyam-flutter/pubspec.yaml` line 35, `crypto: ^3.0.5` is already declared and available in the project, enabling native Dart SHA-256 pre/post digests via `package:crypto/crypto.dart`.
4. **Backend Route & Masking baseline**: In `backend/app.py`, `mask_pii()` (lines 90-119) uses basic regex substitutions (`[MASKED-AADHAAR-XXXX]`, `[MASKED-ABHA-XXXX]`, `[MASKED-PHONE-XXXX]`). `POST /api/redact-pii` (lines 149-165) currently returns:
   ```json
   {
     "status": "success",
     "masked_text": masked_text,
     "redactions_count": len(redactions),
     "redactions": redactions,
     "privacy_verified": True
   }
   ```
   It does not yet return `sanitized_text`, `entities_masked` counts, or the `proof` cryptographic manifest specified in `PROJECT.md § Interface Contracts` lines 78-105.
5. **Backend Tests baseline**: Running `backend/venv/bin/pytest backend/tests/ -v` passes (21 tests passed in 0.16s). There are currently zero tests for `/api/redact-pii` or `mask_pii()`.
6. **Verhoeff Checksum & Parity Verification**: In Python and Dart, the 12-digit number `234567890124` validates as true under dihedral group $D_5$, whereas transposed `234657890124` and batch number `123456789012` fail validation. Deterministic patient name hashing `[PATIENT-ANON-${SHA256(name)[:4].upper()}]` yields `[PATIENT-ANON-F188]` for `"Ramesh Kumar"`, `[PATIENT-ANON-8E96]` for `"सुरेश कुमार"`, and `[PATIENT-ANON-BD5B]` for `"आनंद पाटील"` across both Python and Dart UTF-8 encoders.

---

## 2. Logic Chain

1. **API Integration**: From Observation 1, `RedactPiiAPICall` must be added to `aarogyam-flutter/lib/backend/api_requests/api_calls.dart` using the established `ApiManager.instance.makeApiCall` pattern with `callName: 'redactPiiAPI'` targeting `$backendUrl/api/redact-pii`.
2. **Schema Alignment**: From Observations 4 and 1, `POST /api/redact-pii` in `backend/app.py` must be upgraded to return `sanitized_text`, `entities_masked`, and `proof` manifest. `RedactPiiAPICall` in Dart should include static accessor helpers (`sanitizedText`, `entitiesMasked`, `aadhaarCount`, `phoneCount`, `patientNameCount`, `proof`, `manifestId`, `preHash`, `postHash`, `privacyVerified`) with backward compatibility for `masked_text`.
3. **Cross-Platform Parity**: From Observations 3 and 6, to avoid data leakage or clinical audit discrepancies, both Dart (`EdgePiiSanitizer`) and Python (`mask_pii`) must implement:
   - Verhoeff $D_5$ validation over reversed digits with UIDAI range $[2, 9]$.
   - Batch code exclusion heuristic (preserving 12-digit numbers preceded by `batch`, `lot`, `exp`, `gtin`, `barcode`, `invoice`, `ref`, `rx`).
   - Indian mobile prefix compliance (`+91`, `0`, bare 10-digit starting with 6-9; rejecting serial numbers starting with 0-5).
   - Deterministic multilingual patient name pseudo-token generation (`[PATIENT-ANON-<4-HEX-SHA256>]`), protecting Doctor and Clinic credentials.
   - Identical SHA-256 pre/post digests and proof manifests.
4. **Regression & Dual-Track Verification**: From Observations 2 and 5, neither platform currently tests PII redaction or parity. Adding unit tests in `aarogyam-flutter/test/unit/api_calls_test.dart` and `backend/tests/test_pii_sanitizer.py`, and running the 10 canonical test vectors (V1-V10) across both suites ensures 100% parity and prevents regression.

---

## 3. Caveats

1. **Third-party / Custom OCR Noise**: If ML Kit or on-device OCR misrecognizes a character in a patient name or Aadhaar number, the resulting SHA-256 hash will differ from the ground truth. However, parity between the edge engine and backend engine is strictly defined on identical text inputs.
2. **Read-Only Scope**: Per instructions, Explorer 3 has performed a pure investigation. No code in `aarogyam-flutter/` or `backend/` was altered.
3. **Image Redaction Parity**: Image canvas redaction (blacking out bounding boxes) is executed on the mobile device canvas before Base64 encoding. Backend `mask_pii()` operates on raw text. When `client_sanitized: true` is transmitted, backend verifies the manifest rather than re-masking pixels.

---

## 4. Conclusion

1. The exact Flutter client API integration class `RedactPiiAPICall` has been designed with full code, static helper methods, and test specifications in `report.md § 2`.
2. Cross-platform parity rules and algorithms for Verhoeff $D_5$, phone prefixes, patient name pseudo-tokens (`[PATIENT-ANON-<4-HEX-SHA256>]`), and SHA-256 digests are formulated with 10 benchmark test vectors in `report.md § 3-4`.
3. The regression test plan covering `flutter test` and `pytest backend/` is established in `report.md § 5`.

---

## 5. Verification Method

To verify the findings and specifications independently:

1. **Verify Existing Flutter Tests**:
   ```bash
   cd /Users/rufbook/aarogyam/aarogyam-flutter
   flutter test test/unit/api_calls_test.dart
   ```
   *Expected*: All 24 tests pass.

2. **Verify Existing Backend Tests**:
   ```bash
   cd /Users/rufbook/aarogyam
   backend/venv/bin/pytest backend/tests/ -v
   ```
   *Expected*: All 21 tests pass.

3. **Verify Parity Test Vectors**:
   Inspect Table 4 in `/Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_3/report.md`. Run the Python snippet:
   ```bash
   python3 -c "
   import hashlib
   for name in ['Ramesh Kumar', 'सुरेश कुमार', 'आनंद पाटील']:
       print(name, '-> [PATIENT-ANON-' + hashlib.sha256(name.encode('utf-8')).hexdigest()[:4].upper() + ']')
   "
   ```
   *Expected*: Output matches `[PATIENT-ANON-F188]`, `[PATIENT-ANON-8E96]`, `[PATIENT-ANON-BD5B]`.

4. **Invalidation Conditions**:
   - If `flutter test` or `pytest backend/` fails on baseline code.
   - If Dart `package:crypto/crypto.dart` or Python `hashlib.sha256()` produces inconsistent digests for identical UTF-8 inputs.
   - If UIDAI modifies Aadhaar checksum specification from Dihedral group $D_5$.
