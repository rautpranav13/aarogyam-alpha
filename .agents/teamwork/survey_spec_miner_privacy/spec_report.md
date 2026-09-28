# R2: Edge Privacy & PII Sanitization Specification Report
**Project**: Aarogyam (Alpha Gateway & Flutter Client)  
**Author**: Privacy Specification Miner  
**Date**: 2026-09-28  
**Compliance Frameworks**: Digital Personal Data Protection Act 2023 (DPDP Act, India), HIPAA Safe Harbor (45 CFR § 164.514), Ayushman Bharat Digital Mission (ABDM) Health Data Management Policy.

---

## 1. Executive Summary & Objective

In healthcare AI architectures involving cloud vision foundation models (such as IBM Granite Vision 3.2 2B / WatsonX), transmitting raw doctor prescription images or unfiltered OCR transcripts directly to external or cloud endpoints violates patient privacy regulations and clinical ethics. Prescription artifacts contain sensitive Personal Identifiable Information (PII) and Protected Health Information (PHI)—predominantly **patient names, Aadhaar numbers, contact phone numbers, residential addresses, and demographic details**.

Requirement **R2 (Edge Privacy & PII Sanitization)** mandates:
> *"Before dispatching image or text payloads to the cloud vision model, apply de-identification/masking to sensitive personal identifiers (Aadhaar, phone numbers, patient names) where applicable, maintaining compliance and returning verification proofs."*

This document provides the authoritative, unambiguous technical specification for the PII sanitization subsystem across both the Flutter mobile client (`aarogyam-flutter`) and Python backend (`backend/app.py`).

---

## 2. Current Baseline & Architectural Gap Analysis

### 2.1 Existing Codebase Findings

| Component | Current State | Code Location | Architectural Gap |
|---|---|---|---|
| **Python Backend `mask_pii()`** | Basic regex replacements for Aadhaar, ABHA, and Phone numbers. | `backend/app.py:84-114` | - **No Verhoeff validation**: Any 12-digit number (e.g. medicine batch numbers, GTIN barcodes) is falsely masked as Aadhaar.<br>- **No Patient Name detection**: Patient names are completely unmasked in text.<br>- **No Image redaction**: Images are not sanitized before inference.<br>- **No Cryptographic Proof**: Proof returned is a static string template. |
| **Backend Endpoint `/api/redact-pii`** | Standalone POST endpoint returning `masked_text` and `redactions`. | `backend/app.py:143-158` | Unused by the prescription digitization pipeline; no unit tests exist in `backend/tests/`. |
| **Backend Endpoint `/api/digitize-rx`** | Receives `image_base64` and `raw_ocr_text`. Prompt asks LLM to redact PII. | `backend/app.py:161-230` | **Privacy Leak Risk**: Raw image and OCR text are forwarded to the vision model before sanitization; relies solely on generative model prompt instructions rather than deterministic edge redaction. |
| **Flutter Client `ReportSannerModel`** | Contains flag `bool piiMaskingEnabled = true;` | `lib/main_pages/report_sanner/report_sanner_model.dart:12` | Declared but never checked or used anywhere in the widget logic. |
| **Flutter Client `ReportSannerWidget`** | Calls `MLKitOcrService.extractText()`, then dispatches raw base64 image and OCR text directly via `DigitizeRxAPICall.call()`. Displays `_buildPrivacyBadge`. | `lib/main_pages/report_sanner/report_sanner_widget.dart:84-135, 539-568` | - **Zero client-side redaction**: The image and text leave the handset unredacted.<br>- Privacy badge renders a mock string (`'Protected via On-Device De-Identification'`). |
| **Flutter Data Model `PrescriptionRecord`** | Has field `final String redactedPiiProof`. | `lib/core/models/medication_schedule.dart:273` | Stores a cosmetic string rather than a tamper-evident cryptographic token or manifest. |

---

## 3. Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|---|---|---|---|---|---|---|
| 1 | Backend API | `/api/redact-pii` | Dedicated text de-identification endpoint. | JSON `{"text": string}` | JSON `{"status": "success", "masked_text": string, "redactions_count": int, "redactions": list, "privacy_verified": bool}` | Returns 400 Bad Request on empty or missing `text`. | `backend/app.py:143` |
| 2 | Backend Function | `mask_pii()` | Core rule-based text sanitizer using regex patterns for Aadhaar, ABHA, and Phone. | `text: str` | `Tuple[str, List[Dict[str, str]]]` | Silent pass-through if no match found. | `backend/app.py:84` |
| 3 | Backend API | `/api/digitize-rx` | Prescription parsing endpoint with embedded prompt instruction to redact PII. | JSON `{"image_base64": string, "raw_ocr_text": string, "language": string}` | JSON clinical schema with `pii_redacted_proof` field | Returns 400 if image and OCR text are both empty; fallback mock payload if WatsonX fails. | `backend/app.py:161` |
| 4 | Flutter Model | `piiMaskingEnabled` | Model property to toggle edge privacy protection. | Boolean flag | Boolean state | Unused in widget code (dead state). | `report_sanner_model.dart:12` |
| 5 | Flutter UI | `_buildPrivacyBadge` | Visual compliance badge showing DPDP 2023 status and proof string. | `VernacularService vern`, `_redactedProof` | Flutter Widget (`Container` with security icon and text) | Falls back to `vern.t('privacyBadgeDesc')` if proof empty. | `report_sanner_widget.dart:539` |
| 6 | Flutter Model | `PrescriptionRecord.redactedPiiProof` | Local storage field for proof of sanitization. | String proof token | Persisted in SQLite / JSON | Defaults to static fallback string if missing. | `medication_schedule.dart:273` |
| 7 | ML Service | `MLKitOcrService` | On-device text recognition returning raw OCR string. | File path or byte buffer | String `rawText` (discards `TextBlock` bounding boxes) | Returns empty string on OCR failure. | `mlkit_ocr_service.dart:56` |

---

## 4. Edge Cases

| # | Feature | Input | Observed Behavior | Required Expected Behavior |
|---|---|---|---|---|
| 1 | Aadhaar Validation | `Batch Number: 1234-5678-9012` | Naive regex masks as `[MASKED-AADHAAR-XXXX]`. | Fails Verhoeff checksum & has batch keyword context; MUST NOT be masked. |
| 2 | Aadhaar Transposition | `2346 5789 0124` (adjacent digits 5 and 6 swapped) | Naive regex treats as valid Aadhaar. | Verhoeff validation MUST reject checksum and prevent false identity verification. |
| 3 | Aadhaar Zero/One Lead | `0123 4567 8901` or `1234 5678 9012` | Naive regex masks as Aadhaar. | UIDAI standard rejects numbers starting with 0 or 1. Flag as non-Aadhaar unless explicit `"Aadhaar"` label is present. |
| 4 | Phone Separation | `+91 98765 43210` (Indian $5+5$ spacing) | Standard regex failed to match formatted blocks. | Must match contiguous, $5+5$, and $3+3+4$ groupings with `+91`, `0`, or bare 10-digit prefixes. |
| 5 | Phone Number Prefix | `SN: 5432109876` (10-digit serial number starting with 5) | Naive 10-digit regex falsely masks. | DoT NNP only allocates mobile numbers starting with 6, 7, 8, 9. Must NOT mask serial numbers starting with 1-5. |
| 6 | Patient Name Extraction | `Patient Name: Ramesh Kumar, Age: 54, Male` | `mask_pii()` leaves `"Ramesh Kumar"` completely untouched. | Must extract `"Ramesh Kumar"`, replace with synthetic pseudonym `[PATIENT-ANON-7F4A]`, and log character span. |
| 7 | Doctor vs. Patient Name | `Dr. S. K. Sharma, MD, Clinic: AIIMS` | Overly broad name matcher could redact doctor or clinic. | Must protect Doctor prefix/qualification (`Dr.`, `MD`, `MBBS`) and Hospital names (`AIIMS`, `PHC`) to preserve prescription legitimacy. |
| 8 | Image Base64 Dispatch | High-resolution photo containing patient header. | Transmitted directly to WatsonX without edge visual masking. | Image bounding boxes for detected PII elements must be blacked out on the edge canvas prior to Base64 encoding. |
| 9 | Cryptographic Proof | Repeated sanitization runs. | Produces identical static string `"[MASKED-AADHAAR-XXXX]"`. | Must generate unique cryptographic nonce, SHA-256 pre/post digests, and tamper-evident manifest token. |

---

## 5. Formal Specification: Aadhaar Redaction & Validation

### 5.1 Format & Structural Specification
- **Standard**: Unique Identification Authority of India (UIDAI) Aadhaar Act 2016 & Regulations 2021.
- **Length**: Exactly 12 decimal digits.
- **Valid First Digit**: Must be in the range `[2, 9]` (digits `0` and `1` are not issued).
- **Separators**: May be contiguous (`123456789012`), space-separated (`1234 5678 9012`), or hyphen-separated (`1234-5678-9012`).
- **Contextual Labels**: Labeled when preceded or accompanied by: `Aadhaar`, `Aadhar`, `UID`, `UIDAI`, `आधार`, `आधार क्र.`, `Adhar`.

### 5.2 The Verhoeff Checksum Algorithm
The 12th digit of an Aadhaar number is a checksum calculated using the dihedral group $D_5$ (symmetries of a regular pentagon).

#### Table 1: Multiplication Table ($d_{10 \times 10}$)
```
d[j][k]:
   0  1  2  3  4  5  6  7  8  9
0 [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
1 [1, 2, 3, 4, 0, 6, 7, 8, 9, 5]
2 [2, 3, 4, 0, 1, 7, 8, 9, 5, 6]
3 [3, 4, 0, 1, 2, 8, 9, 5, 6, 7]
4 [4, 0, 1, 2, 3, 9, 5, 6, 7, 8]
5 [5, 9, 8, 7, 6, 0, 4, 3, 2, 1]
6 [6, 5, 9, 8, 7, 1, 0, 4, 3, 2]
7 [7, 6, 5, 9, 8, 2, 1, 0, 4, 3]
8 [8, 7, 6, 5, 9, 3, 2, 1, 0, 4]
9 [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
```

#### Table 2: Permutation Table ($p_{8 \times 10}$)
```
p[pos][num]:
   0  1  2  3  4  5  6  7  8  9
0 [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
1 [1, 5, 7, 6, 2, 8, 3, 0, 9, 4]
2 [5, 8, 0, 3, 7, 9, 6, 1, 4, 2]
3 [8, 9, 1, 6, 0, 4, 3, 5, 2, 7]
4 [9, 4, 5, 3, 1, 2, 6, 8, 7, 0]
5 [4, 2, 8, 6, 5, 7, 3, 9, 0, 1]
6 [2, 7, 9, 3, 8, 0, 6, 4, 1, 5]
7 [7, 0, 4, 6, 9, 1, 3, 2, 5, 8]
```

#### Table 3: Inversion Table ($inv_{10}$)
```
inv = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9]
```

#### Algorithm Definition: Validation
Given a 12-digit string $S = s_0 s_1 \dots s_{11}$:
1. Strip all non-digit characters. Verify $\text{length}(S) == 12$ and $s_0 \in [2, 9]$.
2. Initialize check accumulator $c = 0$.
3. Reverse the string: $R = \text{reverse}(S) = r_0 r_1 \dots r_{11}$ where $r_0$ is the 12th digit (checksum).
4. For index $i \in [0, 11]$:
   $$c = d[c][p[i \pmod 8][\text{int}(r_i)]]$$
5. Valid if and only if $c == 0$.

#### Algorithm Definition: Checksum Generation
Given an 11-digit prefix $P = p_0 p_1 \dots p_{10}$:
1. Reverse prefix: $R = \text{reverse}(P)$.
2. Initialize $c = 0$.
3. For index $i \in [0, 10]$:
   $$c = d[c][p[(i + 1) \pmod 8][\text{int}(r_i)]]$$
4. Checksum digit $= inv[c]$.

### 5.3 Redaction Behavior
1. **Labeled Aadhaar**: If preceded by an Aadhaar keyword within 30 characters, redact immediately (even if Verhoeff fails due to minor OCR character noise).
2. **Unlabeled 12-Digit Sequence**: Redact ONLY if Verhoeff passes and leading digit $\in [2, 9]$. If preceded by pharmaceutical keywords (`Batch`, `Lot`, `Exp`, `GTIN`, `Barcode`, `Invoice`), do NOT redact.
3. **Text Masking Format**:
   - UIDAI Compliant Partial Mask: `XXXXXXXX` followed by last 4 digits (e.g. `XXXXXXXX0124` or `XXXX-XXXX-0124`).
   - Strict De-Identification Token: `[MASKED-AADHAAR-XXXX-XXXX-0124]`.
4. **Visual / Image Redaction**:
   - Overlay a solid black rectangle (`#000000`, 100% opacity) covering the bounding box of the Aadhaar text element expanded by $+4\text{px}$ horizontally and $+2\text{px}$ vertically.

---

## 6. Formal Specification: Phone Number Sanitization

### 6.1 Format & Structural Specification
- **Standard**: Department of Telecommunications (DoT) National Numbering Plan (NNP) & ITU-T E.164.
- **National Number Length**: Exactly 10 digits.
- **Valid Mobile First Digit**: Must begin with `6`, `7`, `8`, or `9`.
- **Landline STD Codes**: 2 to 4 digits starting with `0` (e.g., `011` New Delhi, `022` Mumbai, `020` Pune, `080` Bengaluru) followed by a 6-8 digit local subscriber number.
- **Prefixes**: `+91`, `+91-`, `0091`, `91`, or trunk `0`.

### 6.2 Regex Patterns
#### Pattern A: Indian Mobile Numbers
```regex
(?:\+91[\-\s]?|0091[\-\s]?|\b91[\-\s]|\b0)?(?:\(0\)\s*)?([6-9](?:[\-\s]?\d){9})\b
```
Matches:
- `+91 98765 43210`
- `+91-98765-43210`
- `09876543210`
- `9876543210`
- `87654 32109`
- `7654-321098`
- `6543210987`

#### Pattern B: Clinic Landline Numbers (Contextual)
```regex
(?i)(?:tel|phone|ph|contact|call|फोन|संपर्क)\s*[:\-\s]\s*(?:\+91[\-\s]?)?(0\d{2,4}[\-\s]?\d{6,8})\b
```

### 6.3 Redaction Behavior
1. **Text Masking Format**:
   - Standard: Mask the leading 7 digits of the national number, preserving the prefix and last 3 digits: `+91-XXXXX-XX210`.
   - Tokenized: `[MASKED-PHONE-XXXX]`.
2. **Visual / Image Redaction**:
   - Solid black rectangle (`#000000`) over the bounding box coordinates with $+4\text{px}$ padding.

---

## 7. Formal Specification: Patient Name & Demographic De-identification

### 7.1 Clinical Entity Differentiation
Prescriptions must preserve healthcare provider legitimacy while sanitizing patient demographics:
- **Doctor / Clinic Entities (MUST PRESERVE)**:
  - Doctor name: `Dr. S. K. Sharma, MD`, `Dr. Anand Deshmukh, MBBS`, `डॉ. राजेश वर्मा`.
  - Clinic / Hospital name: `Community Health Centre`, `AIIMS`, `PHC Shirur`, `District Civil Hospital`.
  - Registration / Council numbers: `MCI-12345`, `MMC-98765`.
- **Patient Entities (MUST REDACT)**:
  - Patient personal name: `Ramesh Kumar`, `Sunita Devi`, `सुरेश पाटील`.
  - Age / DOB: `Age: 54 Yrs`, `54 / M`, `उम्र: ५४ वर्ष`, `वय: ४८`.
  - Gender: `Male`, `Female`, `M`, `F`, `पुरुष`, `स्त्री`.
  - Patient Address / Residence: `Flat 402, Gandhi Nagar, Pune`.
  - Unique Hospital ID / OPD Slip No: `UHID-98214`, `OPD No: 4421`.

### 7.2 Multilingual Anchor Heuristics
Extract patient names by anchoring to demographic headers across English, Hindi, and Marathi:

```regex
(?i)(?:patient(?:\s+name)?|pt\.?\s*name|pt\b|मरीज(?:\s+का\s+नाम)?|रोगी(?:\s+का\s+नाम)?|रुग्णाचे\s+नाव)
\s*[:\-\s]\s*
((?:(?:Mr|Mrs|Ms|Shri|Smt|Kumari|Master|श्री|श्रीमती|कु)\.?\s+)?
[A-Za-z\u0900-\u097F]+(?:\s+[A-Za-z\u0900-\u097F]+){1,3})
(?=\s*(?:,|\n|\r|Age|Sex|Gender|Yrs|Yr|M/F|\bM\b|\bF\b|वर्ष|वय|दिनांक|UHID|OPD|$))
```

#### Negative Filter (Doctor Safeguard):
Reject any match containing doctor salutations or medical credentials:
`Dr\.?|Doctor|डॉ\.?|वैद्य|MBBS|MD|MS|BAMS|BHMS|BDS|FRCS|DM|MCh`

### 7.3 Synthetic Token Generation
To preserve grammatical structure for the vision model while preventing re-identification:
- Compute deterministic pseudo-token: `[PATIENT-ANON-<CRC16/ShortSHA>]` (e.g. `[PATIENT-ANON-8F2B]`).
- Example transformation:
  - Raw: `"Prescription for Ramesh Kumar, Age: 54, Male, UHID: 98124"`
  - Sanitized: `"Prescription for [PATIENT-ANON-8F2B], Age: [REDACTED], Sex: [REDACTED], UHID: [REDACTED]"`

---

## 8. Formal Specification: Verification Proofs & Cryptographic Audit

### 8.1 Cryptographic Integrity Framework
To satisfy DPDP Act Section 8 and HIPAA Technical Safeguards:
1. **Pre-Sanitization Digest**:
   $$\text{Digest}_{\text{raw}} = \text{SHA256}(\text{RawOCRText} \parallel \text{ImageRawSHA256})$$
2. **Post-Sanitization Digest**:
   $$\text{Digest}_{\text{clean}} = \text{SHA256}(\text{SanitizedText} \parallel \text{RedactedImageSHA256})$$
3. **Proof Nonce / Token**:
   Generated uniquely per scan session:
   $$\text{ProofToken} = \text{"PRV-" } \parallel \text{UUIDv4()[:8]} \parallel \text{"-" } \parallel \text{Digest}_{\text{clean}}[:8]$$

### 8.2 Sanitization Manifest (Audit Proof Structure)
The edge device generates a `SanitizationManifest` before any network transmission:

```json
{
  "proof_id": "PRV-8f2b1a-4e7a89bc",
  "version": "2.0.0-production",
  "timestamp_utc": "2026-09-28T01:15:30Z",
  "client_origin": "aarogyam-edge-flutter-android",
  "compliance_standards": [
    "DPDP_ACT_2023_SEC_8",
    "HIPAA_SAFE_HARBOR_164_514",
    "ABDM_HEALTH_DATA_POLICY"
  ],
  "digests": {
    "raw_input_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    "sanitized_payload_sha256": "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b"
  },
  "redaction_summary": {
    "total_redactions": 3,
    "aadhaar_redacted": 1,
    "phone_redacted": 1,
    "patient_name_redacted": 1,
    "image_bounding_boxes_masked": 3
  },
  "audit_entities": [
    {
      "entity_type": "AADHAAR",
      "verhoeff_validated": true,
      "masked_value": "[MASKED-AADHAAR-XXXX-XXXX-0124]",
      "char_span": [45, 64],
      "visual_bounding_box": [120, 310, 240, 42]
    },
    {
      "entity_type": "PHONE",
      "masked_value": "+91-XXXXX-XX210",
      "char_span": [85, 105],
      "visual_bounding_box": [120, 360, 210, 38]
    },
    {
      "entity_type": "PATIENT_NAME",
      "masked_value": "[PATIENT-ANON-8F2B]",
      "char_span": [15, 27],
      "visual_bounding_box": [120, 180, 280, 45]
    }
  ],
  "proof_signature": "HMAC-SHA256:7f9a2b..."
}
```
> **Security Invariant**: The manifest MUST NEVER contain raw PII strings (no unmasked names, numbers, or Aadhaar). It records strictly entity types, validation flags, character spans, bounding boxes, and cryptographic digests.

---

## 9. Data Contracts & JSON Schemas

### 9.1 Endpoint: `POST /api/redact-pii`

#### Request Payload Contract:
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "RedactPIIRequest",
  "type": "object",
  "properties": {
    "text": {
      "type": "string",
      "minLength": 1,
      "description": "Raw unredacted OCR text or prescription note."
    },
    "mask_level": {
      "type": "string",
      "enum": ["full_token", "partial_masked", "synthetic"],
      "default": "full_token"
    },
    "generate_proof": {
      "type": "boolean",
      "default": true
    }
  },
  "required": ["text"]
}
```

#### Response Payload Contract (200 OK):
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "RedactPIIResponse",
  "type": "object",
  "properties": {
    "status": { "type": "string", "enum": ["success"] },
    "masked_text": { "type": "string" },
    "redactions_count": { "type": "integer", "minimum": 0 },
    "redactions": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "type": { "type": "string", "enum": ["AADHAAR", "PHONE", "PATIENT_NAME", "ABHA_ID", "DEMOGRAPHIC"] },
          "masked": { "type": "string" },
          "char_offset": { "type": "integer" },
          "verhoeff_valid": { "type": "boolean" }
        },
        "required": ["type", "masked"]
      }
    },
    "privacy_verified": { "type": "boolean" },
    "proof_manifest": {
      "type": "object",
      "properties": {
        "proof_id": { "type": "string" },
        "timestamp_utc": { "type": "string", "format": "date-time" },
        "raw_text_sha256": { "type": "string" },
        "masked_text_sha256": { "type": "string" },
        "proof_token": { "type": "string" }
      },
      "required": ["proof_id", "timestamp_utc", "masked_text_sha256", "proof_token"]
    }
  },
  "required": ["status", "masked_text", "redactions_count", "privacy_verified", "proof_manifest"]
}
```

### 9.2 Augmented Endpoint: `POST /api/digitize-rx`

#### Augmented Request Contract:
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "DigitizeRxRequestWithPrivacy",
  "type": "object",
  "properties": {
    "image_base64": { "type": "string" },
    "image_url": { "type": "string" },
    "raw_ocr_text": { "type": "string" },
    "language": { "type": "string", "enum": ["hi", "mr", "en"], "default": "hi" },
    "ocr_failed": { "type": "boolean", "default": false },
    "client_sanitized": { "type": "boolean", "default": false },
    "sanitization_proof": {
      "type": "object",
      "properties": {
        "proof_id": { "type": "string" },
        "timestamp_utc": { "type": "string", "format": "date-time" },
        "sanitized_payload_sha256": { "type": "string" },
        "proof_token": { "type": "string" },
        "total_redactions": { "type": "integer" }
      },
      "required": ["proof_id", "proof_token", "sanitized_payload_sha256"]
    }
  },
  "anyOf": [
    { "required": ["image_base64"] },
    { "required": ["image_url"] },
    { "required": ["raw_ocr_text"] }
  ]
}
```

#### Response Contract additions:
```json
{
  "status": "success",
  "data": {
    "doctor_name": "Dr. S. K. Sharma, MD",
    "clinic_name": "Community Health Centre",
    "diagnosis": "Hypertension & T2 Diabetes",
    "pii_redacted_proof": "DPDP-VERIFIED: [2 AADHAAR, 1 PHONE REDACTED] | Proof ID: PRV-8f2b1a | Digest: 4a5e...a33b",
    "sanitization_manifest": { ... },
    "medications": [ ... ]
  }
}
```

---

## 10. Edge vs. Backend Architecture & Execution Protocol

### 10.1 Edge Client Processing Flow (`aarogyam-flutter`)
1. **Camera Acquisition**: User captures prescription image.
2. **On-Device OCR & Bounding Box Extraction**:
   - `MLKitOcrService` executes `processImageFile(path)` returning full `RecognizedText`.
   - Iterates through `TextBlock` -> `TextLine` -> `TextElement`.
3. **Edge Privacy Filter Execution**:
   - Scan lines for Aadhaar candidates -> execute Dart Verhoeff checksum.
   - Scan lines for Phone candidates -> execute Indian mobile prefix regex.
   - Scan lines for Patient Demographic candidates -> match patient anchor heuristics & exclude doctor lines.
4. **Visual Redaction (Canvas Masking)**:
   - For every detected PII entity with a `Rect boundingBox`:
   - Draw filled black rectangle on the in-memory image canvas before Base64 encoding.
5. **Cryptographic Proof Generation**:
   - Compute SHA-256 of raw text, sanitized text, and redacted image bytes.
   - Construct `SanitizationManifest` and generate `proof_token`.
6. **Cloud Dispatch**:
   - Transmit ONLY redacted Base64 image and sanitized OCR text along with `sanitization_proof` to `/api/digitize-rx`.
7. **UI Update**:
   - Render `_buildPrivacyBadge` with genuine verifiable proof token and audit details.
   - Persist `PrescriptionRecord` with complete `redactedPiiProof` into SQLite.

### 10.2 Backend Fallback Defense-in-Depth (`backend/app.py`)
If a third-party client calls `/api/digitize-rx` with `client_sanitized: false` (or unverified):
1. Backend runs internal `mask_pii()` with Verhoeff validation and patient name regex.
2. Replaces any unmasked text in `raw_ocr_text` with synthetic tokens.
3. Injects sanitized text into the WatsonX prompt context.
4. Returns the verified audit proof in the response.

---

## 11. Verification & Testing Requirements (R4 Traceability)

### Backend Tests (`pytest backend/tests/`):
1. `test_verhoeff_algorithm_validation`: Verify valid Aadhaar numbers, adjacent transpositions, jump transpositions, and non-digit inputs.
2. `test_aadhaar_false_positive_rejection`: Verify medicine batch numbers (`1234-5678-9012`), barcodes, and dates are not falsely redacted.
3. `test_indian_mobile_number_formats`: Verify contiguous, $5+5$, and landlines with $+91$ and $0$ prefixes.
4. `test_patient_name_deidentification`: Verify English, Hindi, and Marathi patient names are masked, while Doctor and Clinic names are preserved.
5. `test_redact_pii_endpoint_cryptographic_proof`: Verify `/api/redact-pii` returns valid SHA-256 digests and proof tokens.
6. `test_digitize_rx_with_privacy_manifest`: Verify `/api/digitize-rx` respects `client_sanitized` and echoes verifiable audit proofs.

### Flutter Tests (`flutter test`):
1. `test_edge_verhoeff_validator`: Dart unit test for dihedral $D_5$ Aadhaar validation.
2. `test_edge_pii_sanitizer`: Dart unit test for text redaction and tokenization.
3. `test_edge_image_redactor`: Unit test verifying bounding boxes are masked on image bytes.
4. `test_sanitization_manifest_hashing`: Verify SHA-256 pre/post digests and proof string construction.
5. `test_report_scanner_privacy_badge`: Widget test verifying privacy badge displays real proof tokens.
