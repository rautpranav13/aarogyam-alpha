# Milestone 1 Explorer 3 Report: API Integration, RedactPiiAPICall & Cross-Platform Parity Design

**Project**: Aarogyam  
**Milestone**: M1 (Edge Privacy & PII Sanitization Subsystem)  
**Role**: Explorer 3 (API Integration & Parity)  
**Date**: 2026-09-28  
**Working Directory**: `/Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_3`  
**Authoritative References**: `PROJECT.md`, `.agents/teamwork/survey_spec_miner_privacy/spec_report.md`, `aarogyam-flutter/lib/backend/api_requests/`, `backend/app.py`

---

## 1. Executive Summary & Architectural Overview

The Aarogyam system uses a hybrid edge-cloud privacy model. Sensitive prescription documents and OCR text must be sanitized before transmission to IBM WatsonX Granite Vision foundation models. To achieve zero privacy leakage and clinical auditability, PII sanitization operates on two levels:
1. **Edge Client Level (Dart)**: An on-device engine (`EdgePiiSanitizer`) sanitizes OCR text, masks image bounding boxes, and generates cryptographic manifests on the handset.
2. **Backend Gateway Level (Python)**: The gateway provides `POST /api/redact-pii` for server-side text sanitization and serves as a defense-in-depth validator inside `/api/digitize-rx`.

### The Parity Imperative
Cross-platform parity between Dart (`aarogyam-flutter`) and Python (`backend`) is critical. If a prescription containing Aadhaar numbers, phone numbers, and patient names is processed on either the mobile client or the backend gateway, both engines must produce:
- **Identical Entity Detections**: Exactly the same Aadhaar numbers, phone numbers, and patient names must be flagged.
- **Identical False Positive Rejections**: Medicine batch numbers (e.g. `1234-5678-9012`), device serial numbers, and doctor/clinic credentials (`Dr. S. K. Sharma, MD`) must remain untouched on both platforms.
- **Character-for-Character Consistent Masking**: The sanitized text produced by Dart must match the text produced by Python, ensuring reproducible SHA-256 digests and audit logs.
- **Interoperable Cryptographic Manifests**: The proof structure (`SanitizationManifest`) produced by Dart must be parsed, validated, and echoed by Python without schema mismatch.

---

## 2. Flutter Client API Integration: `RedactPiiAPICall`

### 2.1 File Location & Target Contract
- **File to Modify**: `/Users/rufbook/aarogyam/aarogyam-flutter/lib/backend/api_requests/api_calls.dart`
- **Target Endpoint**: `POST /api/redact-pii`
- **Request Schema** (matching `PROJECT.md § Interface Contracts` & `spec_report.md § 9.1`):
  ```json
  {
    "text": "string (required, raw OCR or prescription text)",
    "patient_id": "string (optional)",
    "generate_proof": true
  }
  ```
- **Response Schema** (200 OK):
  ```json
  {
    "status": "success",
    "sanitized_text": "string",
    "masked_text": "string (backward-compatible alias)",
    "entities_masked": {
      "aadhaar": 0,
      "phone": 0,
      "patient_name": 0
    },
    "redactions_count": 0,
    "privacy_verified": true,
    "proof": {
      "manifest_id": "uuid-string",
      "pre_hash_sha256": "64-character lowercase hex",
      "post_hash_sha256": "64-character lowercase hex",
      "timestamp": "ISO-8601 UTC timestamp",
      "algorithm": "verhoeff-d5-regex-ner-v1",
      "proof_token": "PRV-XXXX-XXXX"
    }
  }
  ```

### 2.2 Proposed Dart Implementation (`api_calls.dart`)

```dart
/// Step 1: De-Identify & Redact PII via Backend Gateway
class RedactPiiAPICall {
  static Future<ApiCallResponse> call({
    required String text,
    String? patientId,
    bool generateProof = true,
  }) async {
    final Map<String, dynamic> body = {
      'text': text,
      'generate_proof': generateProof,
    };
    if (patientId != null && patientId.isNotEmpty) {
      body['patient_id'] = patientId;
    }

    final backendUrl = _getBackendUrl();
    return ApiManager.instance.makeApiCall(
      callName: 'redactPiiAPI',
      apiUrl: '$backendUrl/api/redact-pii',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: jsonEncode(body),
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  /// Extracts the sanitized text, falling back to legacy masked_text.
  static String sanitizedText(dynamic response) {
    final sanitized = getJsonField(response, r'$.sanitized_text');
    if (sanitized != null && sanitized.toString().isNotEmpty) {
      return sanitized.toString();
    }
    return getJsonField(response, r'$.masked_text')?.toString() ?? '';
  }

  /// Extracts entities_masked map.
  static Map<String, dynamic> entitiesMasked(dynamic response) {
    final map = getJsonField(response, r'$.entities_masked');
    if (map is Map<String, dynamic>) return map;
    if (map is Map) return Map<String, dynamic>.from(map);
    return {};
  }

  /// Number of Aadhaar numbers masked.
  static int aadhaarCount(dynamic response) {
    final count = getJsonField(response, r'$.entities_masked.aadhaar');
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  /// Number of phone numbers masked.
  static int phoneCount(dynamic response) {
    final count = getJsonField(response, r'$.entities_masked.phone');
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  /// Number of patient names de-identified.
  static int patientNameCount(dynamic response) {
    final count = getJsonField(response, r'$.entities_masked.patient_name');
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  /// Total redactions count.
  static int redactionsCount(dynamic response) {
    final count = getJsonField(response, r'$.redactions_count');
    if (count is int) return count;
    if (count is num) return count.toInt();
    return aadhaarCount(response) + phoneCount(response) + patientNameCount(response);
  }

  /// Whether backend validated privacy.
  static bool privacyVerified(dynamic response) =>
      getJsonField(response, r'$.privacy_verified') == true;

  /// Returns the proof manifest object.
  static dynamic proof(dynamic response) =>
      getJsonField(response, r'$.proof') ??
      getJsonField(response, r'$.proof_manifest');

  /// Returns the manifest ID / proof ID.
  static String manifestId(dynamic response) =>
      getJsonField(response, r'$.proof.manifest_id')?.toString() ??
      getJsonField(response, r'$.proof_manifest.proof_id')?.toString() ??
      '';

  /// Pre-sanitization SHA-256 digest.
  static String preHash(dynamic response) =>
      getJsonField(response, r'$.proof.pre_hash_sha256')?.toString() ??
      getJsonField(response, r'$.proof_manifest.raw_text_sha256')?.toString() ??
      '';

  /// Post-sanitization SHA-256 digest.
  static String postHash(dynamic response) =>
      getJsonField(response, r'$.proof.post_hash_sha256')?.toString() ??
      getJsonField(response, r'$.proof_manifest.masked_text_sha256')?.toString() ??
      '';

  /// Verification proof token for UI display.
  static String proofToken(dynamic response) =>
      getJsonField(response, r'$.proof.proof_token')?.toString() ??
      getJsonField(response, r'$.proof_manifest.proof_token')?.toString() ??
      '';
}
```

### 2.3 Companion Augmentation: `DigitizeRxAPICall` in `api_calls.dart`
To forward edge sanitization proof to `/api/digitize-rx`:
```dart
class DigitizeRxAPICall {
  static Future<ApiCallResponse> call({
    String? imageBase64,
    String? imageUrl,
    String? rawOcrText,
    bool ocrFailed = false,
    String language = 'hi',
    Map<String, dynamic>? piiManifest,
    bool clientSanitized = false,
  }) async {
    final Map<String, dynamic> body = {
      'language': language,
      'ocr_failed': ocrFailed,
      'client_sanitized': clientSanitized || (piiManifest != null),
    };
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      body['image_base64'] = imageBase64;
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      body['image_url'] = imageUrl;
    }
    if (rawOcrText != null && rawOcrText.isNotEmpty) {
      body['raw_ocr_text'] = rawOcrText;
    }
    if (piiManifest != null && piiManifest.isNotEmpty) {
      body['pii_manifest'] = piiManifest;
    }
    ...
```

---

## 3. Cross-Platform Parity Specification: Dart vs. Python

Both engines must implement identical mathematical algorithms, regex semantics, and token generation formats.

### 3.1 Verhoeff $D_5$ Algorithm Parity
The 12th digit of an Aadhaar number is the check digit under dihedral group $D_5$.

#### Checksum Algorithm Definition:
- Strip all non-digit characters: `digits = text.replaceAll(RegExp(r'\D'), '')` (Dart) or `re.sub(r'\D', '', text)` (Python).
- Condition 1: `digits.length == 12`.
- Condition 2: Leading digit $d_0 \in [2, 9]$ (UIDAI standard: 0 and 1 are never issued).
- Condition 3: Verhoeff validation over reversed digits $r_0 \dots r_{11}$ with accumulator $c = 0$:
  $$c = d[c][p[i \pmod 8][\text{int}(r_i)]]$$
  Valid iff $c == 0$.

#### Exact Verhoeff Matrices:
```
d (10x10 multiplication table):
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
[1, 2, 3, 4, 0, 6, 7, 8, 9, 5]
[2, 3, 4, 0, 1, 7, 8, 9, 5, 6]
[3, 4, 0, 1, 2, 8, 9, 5, 6, 7]
[4, 0, 1, 2, 3, 9, 5, 6, 7, 8]
[5, 9, 8, 7, 6, 0, 4, 3, 2, 1]
[6, 5, 9, 8, 7, 1, 0, 4, 3, 2]
[7, 6, 5, 9, 8, 2, 1, 0, 4, 3]
[8, 7, 6, 5, 9, 3, 2, 1, 0, 4]
[9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

p (8x10 permutation table):
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
[1, 5, 7, 6, 2, 8, 3, 0, 9, 4]
[5, 8, 0, 3, 7, 9, 6, 1, 4, 2]
[8, 9, 1, 6, 0, 4, 3, 5, 2, 7]
[9, 4, 5, 3, 1, 2, 6, 8, 7, 0]
[4, 2, 8, 6, 5, 7, 3, 9, 0, 1]
[2, 7, 9, 3, 8, 0, 6, 4, 1, 5]
[7, 0, 4, 6, 9, 1, 3, 2, 5, 8]

inv (inversion table):
[0, 4, 3, 2, 1, 5, 6, 7, 8, 9]
```

#### Batch Code & Non-Aadhaar Exclusions:
1. **Negative Prefix Filter**: If the 12-digit number is preceded (within 30 characters) by any of:
   `batch`, `lot`, `exp`, `gtin`, `barcode`, `invoice`, `ref`, `rx`, `sn` (case-insensitive),
   do **NOT** mask as Aadhaar, even if the Verhoeff check passes.
2. **Positive Label Override**: If preceded by an explicit Aadhaar label:
   `aadhaar`, `aadhar`, `uid`, `uidai`, `आधार`, `adhar`,
   mask as Aadhaar even if single-digit OCR noise caused Verhoeff check failure.
3. **Masking Format**: Replace digits with `XXXXXXXX` followed by the last 4 digits (e.g., `XXXXXXXX0124`).

### 3.2 Indian Phone Number Detection & Masking Parity
- **Format**: 10 digits starting with `6`, `7`, `8`, or `9`.
- **Prefixes**: Optional `+91[\-\s]?`, `0091[\-\s]?`, `\b91[\-\s]`, or trunk `\b0`.
- **Digit Groupings**:
  - Contiguous: `9876543210`
  - $5+5$ Indian format: `98765 43210` or `98765-43210`
  - $3+3+4$ format: `987-654-3210`
- **Exclusion of Serial Numbers**: 10-digit numbers starting with `0`, `1`, `2`, `3`, `4`, `5` without explicit phone context (`tel:`, `ph:`, `call:`) are **NOT** masked.
- **Masking Format**:
  - If `+91` prefix present: `+91-XXXXX-XX` + last 3 digits (e.g. `+91-XXXXX-XX210`).
  - If bare 10-digit: `XXXXXXX` + last 3 digits (e.g. `XXXXXXX210`).

### 3.3 Multilingual Patient Name De-Identification Parity
- **Multilingual Anchors**:
  - English: `Patient Name:`, `Pt Name:`, `Pt:`, `Patient:`
  - Hindi: `मरीज का नाम:`, `मरीज:`, `रोगी का नाम:`, `रोगी:`
  - Marathi: `रुग्णाचे नाव:`, `रुग्ण:`
- **Doctor Safeguard (Negative Lookahead / Exclusions)**:
  - If a matched entity contains `Dr.`, `Dr `, `Doctor`, `डॉ.`, `डॉ `, `वैद्य`, `MBBS`, `MD`, `MS`, `BAMS`, `BHMS`, `BDS`, `FRCS`, `DM`, `MCh`, `Clinic`, `Hospital`, `AIIMS`, `PHC`,
    the entity MUST NOT be redacted. Doctor and clinic identities must remain visible for clinical verification.
- **Deterministic Pseudo-Token Generation**:
  To guarantee that Dart and Python produce identical replacement tokens:
  $$\text{Token} = \text{"[PATIENT-ANON-" } \parallel \text{SHA256}(\text{utf8}(\text{TrimmedName}))[:4].\text{upper()} \parallel \text{"]"}$$
  - For example:
    - `"Ramesh Kumar"` $\to$ `SHA256("Ramesh Kumar")` starts with `f188...` $\to$ `[PATIENT-ANON-F188]`.
    - `"सुरेश कुमार"` $\to$ `SHA256("सुरेश कुमार")` starts with `8e96...` $\to$ `[PATIENT-ANON-8E96]`.
    - `"आनंद पाटील"` $\to$ `SHA256("आनंद पाटील")` starts with `bd5b...` $\to$ `[PATIENT-ANON-BD5B]`.

### 3.4 Cryptographic Manifest & Digest Parity
- **Pre-Sanitization Digest**: `pre_hash_sha256 = SHA256(utf8(raw_text)).lower()` (64-character lowercase hex string).
- **Post-Sanitization Digest**: `post_hash_sha256 = SHA256(utf8(sanitized_text)).lower()`.
- **Proof Token**: `PRV-<manifest_id[:6]>-<post_hash[:8]>` (uppercase/lowercase alphanumeric).
- Both Dart (`package:crypto/crypto.dart`) and Python (`hashlib.sha256()`) use standard RFC 6234 SHA-256 over UTF-8 encoded bytes.

---

## 4. Canonical Cross-Platform Test Vectors (10 Benchmark Test Cases)

The following 10 benchmark test vectors must produce matching outputs in both `flutter test` and `pytest backend/`:

| # | Test Vector Name | Input String | Expected Sanitized String | Entities Masked | Parity Invariant |
|---|---|---|---|---|---|
| **V1** | Valid Aadhaar (spaced) | `Patient Aadhaar: 2345 6789 0124` | `Patient Aadhaar: XXXXXXXX0124` | `{"aadhaar": 1, "phone": 0, "patient_name": 0}` | Verhoeff D5 passes ($c=0$); leading digit 2 $\in [2,9]$. |
| **V2** | Valid Aadhaar (hyphenated) | `UID: 2345-6789-0124` | `UID: XXXXXXXX0124` | `{"aadhaar": 1, "phone": 0, "patient_name": 0}` | Hyphenated 4-4-4 format recognized and normalized. |
| **V3** | Batch Number Protection | `Batch Number: 1234-5678-9012 Exp: 12/2026` | `Batch Number: 1234-5678-9012 Exp: 12/2026` | `{"aadhaar": 0, "phone": 0, "patient_name": 0}` | Batch keyword + leading digit 1 + checksum failure prevent redaction. |
| **V4** | Aadhaar Transposition Error | `Ref: 2346 5789 0124` (adjacent digits 5 and 6 transposed) | `Ref: 2346 5789 0124` | `{"aadhaar": 0, "phone": 0, "patient_name": 0}` | Unlabeled 12-digit number with invalid Verhoeff checksum is NOT masked. |
| **V5** | Indian Mobile (+91 format) | `Contact: +91 98765 43210` | `Contact: +91-XXXXX-XX210` | `{"aadhaar": 0, "phone": 1, "patient_name": 0}` | +91 prefix and 10 digits starting with 9 recognized. |
| **V6** | Serial Number Rejection | `Device SN: 5432109876, Lot: 4567` | `Device SN: 5432109876, Lot: 4567` | `{"aadhaar": 0, "phone": 0, "patient_name": 0}` | 10 digits starting with 5 without phone keyword are preserved. |
| **V7** | English Patient Name | `Patient Name: Ramesh Kumar, Age: 54` | `Patient Name: [PATIENT-ANON-F188], Age: 54` | `{"aadhaar": 0, "phone": 0, "patient_name": 1}` | Deterministic SHA-256 token `[PATIENT-ANON-F188]`. |
| **V8** | Hindi Patient Name | `मरीज का नाम: सुरेश कुमार, उम्र: ४५ वर्ष` | `मरीज का नाम: [PATIENT-ANON-8E96], उम्र: ४५ वर्ष` | `{"aadhaar": 0, "phone": 0, "patient_name": 1}` | Devanagari script matching and deterministic token `[PATIENT-ANON-8E96]`. |
| **V9** | Doctor & Clinic Safeguard | `Dr. S. K. Sharma, MD, Community Health Centre, AIIMS` | `Dr. S. K. Sharma, MD, Community Health Centre, AIIMS` | `{"aadhaar": 0, "phone": 0, "patient_name": 0}` | Doctor and hospital identifiers protected from redaction. |
| **V10** | Composite Full Prescription | `Dr. Rajesh Verma, MBBS\nApex Clinic\nPatient: Ramesh Kumar\nPh: +91 98765 43210\nAadhaar: 2345 6789 0124\nBatch: 1234-5678-9012\nRx: Paracetamol 500mg` | `Dr. Rajesh Verma, MBBS\nApex Clinic\nPatient: [PATIENT-ANON-F188]\nPh: +91-XXXXX-XX210\nAadhaar: XXXXXXXX0124\nBatch: 1234-5678-9012\nRx: Paracetamol 500mg` | `{"aadhaar": 1, "phone": 1, "patient_name": 1}` | All 3 categories masked; Doctor and Batch number preserved. |

---

## 5. Comprehensive Regression & Integration Test Plan

### 5.1 Flutter Test Suite (`flutter test`)

#### Test Target 1: `aarogyam-flutter/test/unit/api_calls_test.dart`
Add test groups verifying `RedactPiiAPICall`:
```dart
group('RedactPiiAPICall static helpers', () {
  test('sanitizedText extracts sanitized_text and falls back to masked_text', () {
    final mockBody1 = {'sanitized_text': 'Sanitized prescription', 'status': 'success'};
    expect(RedactPiiAPICall.sanitizedText(mockBody1), equals('Sanitized prescription'));

    final mockBody2 = {'masked_text': 'Masked prescription', 'status': 'success'};
    expect(RedactPiiAPICall.sanitizedText(mockBody2), equals('Masked prescription'));

    expect(RedactPiiAPICall.sanitizedText(null), equals(''));
  });

  test('entitiesMasked and entity counters extract correct values', () {
    final mockBody = {
      'entities_masked': {
        'aadhaar': 2,
        'phone': 1,
        'patient_name': 1,
      },
      'redactions_count': 4,
      'privacy_verified': true,
    };
    expect(RedactPiiAPICall.aadhaarCount(mockBody), equals(2));
    expect(RedactPiiAPICall.phoneCount(mockBody), equals(1));
    expect(RedactPiiAPICall.patientNameCount(mockBody), equals(1));
    expect(RedactPiiAPICall.redactionsCount(mockBody), equals(4));
    expect(RedactPiiAPICall.privacyVerified(mockBody), isTrue);
  });

  test('proof helper extracts manifest details and digests', () {
    final mockBody = {
      'proof': {
        'manifest_id': 'manifest-uuid-1234',
        'pre_hash_sha256': 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        'post_hash_sha256': '4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b',
        'proof_token': 'PRV-1234-4a5e1e4b',
      }
    };
    expect(RedactPiiAPICall.manifestId(mockBody), equals('manifest-uuid-1234'));
    expect(RedactPiiAPICall.preHash(mockBody), contains('e3b0c442'));
    expect(RedactPiiAPICall.postHash(mockBody), contains('4a5e1e4b'));
    expect(RedactPiiAPICall.proofToken(mockBody), equals('PRV-1234-4a5e1e4b'));
  });
});
```

#### Test Target 2: `aarogyam-flutter/test/unit/edge_pii_sanitizer_test.dart`
Unit tests designed by Explorer 1 validating:
- Verhoeff D5 mathematical properties.
- Masking of Aadhaar to `XXXXXXXX1234`.
- Indian phone number masking.
- Multilingual patient name de-identification.
- Cryptographic SHA-256 pre/post digests.

#### Test Target 3: `aarogyam-flutter/test/unit/pii_parity_test.dart`
Cross-platform parity test suite:
- Runs all 10 canonical test vectors (V1-V10) through `EdgePiiSanitizer.sanitize()`.
- Asserts that output strings and entity maps match Table 4 above.

---

### 5.2 Backend Test Suite (`pytest backend/tests/ -v`)

#### Test Target 1: `backend/tests/test_app.py`
Add integration tests for `POST /api/redact-pii`:
```python
def test_redact_pii_missing_text(client):
    """Verify /api/redact-pii returns 400 Bad Request on empty or missing payload."""
    response = client.post("/api/redact-pii", json={})
    assert response.status_code == 400
    data = response.get_json()
    assert data["status"] == "error"

def test_redact_pii_success_contract(client):
    """Verify /api/redact-pii returns complete contract with proof manifest."""
    payload = {
        "text": "Patient Name: Ramesh Kumar, Aadhaar: 2345 6789 0124, Phone: +91 98765 43210",
        "generate_proof": True
    }
    response = client.post("/api/redact-pii", json=payload)
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "success"
    assert "sanitized_text" in data
    assert data["entities_masked"]["aadhaar"] == 1
    assert data["entities_masked"]["phone"] == 1
    assert data["entities_masked"]["patient_name"] == 1
    assert data["privacy_verified"] is True
    assert "proof" in data
    assert "pre_hash_sha256" in data["proof"]
    assert "post_hash_sha256" in data["proof"]
```

#### Test Target 2: `backend/tests/test_pii_sanitizer.py`
Dedicated unit and parity test file:
- `test_verhoeff_d5_aadhaar_validation()`
- `test_pharmaceutical_batch_code_preservation()`
- `test_indian_mobile_prefix_compliance()`
- `test_multilingual_patient_name_deidentification()`
- `test_doctor_clinic_safeguard()`
- `test_canonical_parity_vectors_v1_through_v10()`
- `test_sha256_cryptographic_manifest_integrity()`

---

### 5.3 Test Execution Matrix

| Test Suite | Command | Expected Execution Time | Target Pass Rate |
|---|---|---|---|
| **Flutter Unit & Parity** | `flutter test test/unit/api_calls_test.dart test/unit/edge_pii_sanitizer_test.dart` | < 5.0s | 100% (0 failures) |
| **Backend Unit & Parity** | `backend/venv/bin/pytest backend/tests/test_pii_sanitizer.py backend/tests/test_app.py -v` | < 1.0s | 100% (0 failures) |
| **Full Flutter Regression** | `flutter test` | < 15.0s | 100% |
| **Full Backend Regression** | `backend/venv/bin/pytest backend/tests/ -v` | < 1.0s | 100% (21+ tests passing) |

---

## 6. Implementation Recommendations for Milestone 1 Builder

1. **Step 1: Implement `RedactPiiAPICall` in `api_calls.dart`**:
   Add the class and static accessor helpers specified in §2.2 without modifying existing `DigitizeRxAPICall` logic. Add unit test in `test/unit/api_calls_test.dart`.
2. **Step 2: Align `POST /api/redact-pii` in `backend/app.py`**:
   Ensure `POST /api/redact-pii` outputs both `sanitized_text` and `masked_text`, `entities_masked` dictionary, and `proof` manifest matching §2.1.
3. **Step 3: Execute Canonical Parity Vectors (V1-V10)**:
   Verify both Dart `EdgePiiSanitizer` (from Explorer 1) and Python `mask_pii` (from Explorer 2) against the 10 benchmark vectors in Table 4.
4. **Step 4: Verify Both Regression Suites**:
   Run `flutter test` and `backend/venv/bin/pytest backend/tests/ -v` to ensure zero regressions across both codebases.
