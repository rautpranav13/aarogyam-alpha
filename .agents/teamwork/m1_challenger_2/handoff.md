# Milestone 1 Challenger 2 Handoff Report: Multilingual Name & Manifest Tamper Testing

**Author**: Milestone 1 Challenger 2 (`m1_challenger_2`)  
**Roles**: critic, specialist  
**Date**: 2026-09-28T01:35:00Z  
**Verdict**: **REQUEST_CHANGES**  
**Assigned Scope**: Adversarial stress-testing of `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart` and `backend/app.py`  
**Parent Orchestrator Conversation ID**: `debcb2f8-6c27-4400-9b21-9904a1a71bab`

---

## 1. Observation

### 1.1 Test Execution Commands & Outputs

We authored and executed two comprehensive empirical stress-test harnesses:
1. Flutter Dart Suite: `aarogyam-flutter/test/unit/edge_pii_adversarial_test.dart`
2. Python Pytest Suite: `backend/tests/test_adversarial_pii.py`

#### Command 1: Flutter Dart Adversarial Test Suite
```bash
flutter test test/unit/edge_pii_adversarial_test.dart
```
**Output**:
```text
00:01 +0 -1: Adversarial Suite 1: Multilingual Patient De-Identification & Punctuation English variations: newline, CRLF, colon, hyphen, trailing punctuation [E]
  Expected: true
    Actual: <false>
  Failed to mask English patient in: "Pt. Name: Ramesh Kumar; Age: 54". Got: "Pt. Name: Ramesh Kumar; Age: [REDACTED]"
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/unit/edge_pii_adversarial_test.dart 19:9       main.<fn>.<fn>

00:01 +0 -2: Adversarial Suite 1: Multilingual Patient De-Identification & Punctuation Hindi variations: मरीज, रोगी, hyphen separator, semicolon, Devanagari punctuation [E]
  Expected: true
    Actual: <false>
  Failed to mask Hindi patient in: "मरीज का नाम: सुरेश शर्मा; उम्र: ४५". Got: "मरीज का नाम: सुरेश शर्मा; उम्र: [REDACTED]"

00:01 +0 -3: Adversarial Suite 1: Multilingual Patient De-Identification & Punctuation Hindi standalone "नाम - सुरेश शर्मा;" stress-test [E]
  Expected: false
    Actual: <true>
  Raw patient name leaked under standalone "नाम -" header
  test/unit/edge_pii_adversarial_test.dart 64:7       main.<fn>.<fn>

00:01 +0 -4: Adversarial Suite 1: Multilingual Patient De-Identification & Punctuation Hindi age boundary without newline: "मरीज का नाम: सुरेश शर्मा उम्र: ४५ वर्ष" [E]
  Expected: false
    Actual: <true>
  test/unit/edge_pii_adversarial_test.dart 73:7       main.<fn>.<fn>
  Age boundary test result: "मरीज का नाम: सुरेश शर्मा उम्र: [REDACTED]"

00:01 +0 -5: Adversarial Suite 1: Multilingual Patient De-Identification & Punctuation Devanagari numerals in Aadhaar and Phone numbers [E]
  Expected: false
    Actual: <true>
  Devanagari Aadhaar leaked unmasked!
  test/unit/edge_pii_adversarial_test.dart 87:7       main.<fn>.<fn>
  Devanagari Aadhaar result: "आधार: २३४५ ६७८९ ०१२४" (counts: {PiiType.aadhaar: 0, PiiType.phone: 0, PiiType.patientName: 0, PiiType.demographic: 0, PiiType.abhaId: 0})
  Devanagari Phone result: "संपर्क: ९८७६५४३२१०" (counts: {PiiType.aadhaar: 0, PiiType.phone: 0, PiiType.patientName: 0, PiiType.demographic: 0, PiiType.abhaId: 0})

00:01 +0 -6: Adversarial Suite 1: Multilingual Patient De-Identification & Punctuation Marathi variations: रुग्णाचे नाव, hyphen separator, semicolon [E]
  Expected: true
    Actual: <false>
  Failed to mask Marathi patient in: "रुग्णाचे नाव - आनंदी पाटील; वय: ४५". Got: "रुग्णाचे नाव - आनंदी पाटील; वय: [REDACTED]"

00:01 +10 -6: Some tests failed. (10 passed, 6 failed)
```

#### Command 2: Python Backend Adversarial Test Suite
```bash
backend/venv/bin/pytest backend/tests/test_adversarial_pii.py -v
```
**Output**:
```text
=================================== FAILURES ===================================
________________ test_hindi_standalone_nam_hyphen_dispatch_case ________________
    text = "नाम - सुरेश शर्मा; उम्र: ४५ वर्ष"
    sanitized, meta = mask_pii(text)
>   assert "सुरेश शर्मा" not in sanitized, f"CRITICAL: Raw patient name leaked in standalone 'नाम -' anchor: {sanitized!r}"
E   AssertionError: CRITICAL: Raw patient name leaked in standalone 'नाम -' anchor: 'नाम - सुरेश शर्मा; उम्र: ४५ वर्ष'
E   assert 'सुरेश शर्मा' not in 'नाम - सुरेश शर्मा; उम्र: ४५ वर्ष'
E     'सुरेश शर्मा' is contained here:
E       नाम - सुरेश शर्मा; उम्र: ४५ वर्ष
backend/tests/test_adversarial_pii.py:76: AssertionError
----------------------------- Captured stdout call -----------------------------
[Python] Standalone 'नाम - सुरेश शर्मा;' masked: False | Output: 'नाम - सुरेश शर्मा; उम्र: ४५ वर्ष'

__________________ test_devanagari_numerals_aadhaar_and_phone __________________
    phone_dev = "संपर्क: ९८७६५४३२१०"
    sanitized_p, meta_p = mask_pii(phone_dev)
>   assert "९८७६५४३२१०" not in sanitized_p, f"Devanagari phone leaked in: {sanitized_p!r}"
E   AssertionError: Devanagari phone leaked in: 'संपर्क: ९८७६५४३२१०'
E   assert '९८७६५४३२१०' not in 'संपर्क: ९८७६५४३२१०'
backend/tests/test_adversarial_pii.py:132: AssertionError
----------------------------- Captured stdout call -----------------------------
[Python] Devanagari phone masked count: 0 | Output: 'संपर्क: ९८७६५४३२१०'

========================= 2 failed, 12 passed in 0.16s =========================
```

### 1.2 Code Inspection Observations

1. **In `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:213-221`**:
   ```dart
   static final RegExp _patientAnchorPattern = RegExp(
     r'(?:patient(?:\s+name)?|pt\.?\s*name|pt\b|मरीज(?:\s+का\s+नाम)?|रोगी(?:\s+का\s+नाम)?|रुग्णाचे\s+नाव)'
     r'\s*[:\-\s]\s*'
     r'((?:(?:Mr|Mrs|Ms|Shri|Smt|Kumari|Master|श्री|श्रीमती|कु)\.?\s+)?'
     r'[A-Za-z\u0900-\u097F]+(?:\s+[A-Za-z\u0900-\u097F]+){0,3})'
     r'(?=\s*(?:,|\n|\r|Age|Sex|Gender|Yrs|Yr|M/F|\bM\b|\bF\b|वर्ष|वय|दिनांक|UHID|OPD|$))',
     caseSensitive: false,
     unicode: true,
   );
   ```
   - Lookahead is restricted to: `(?:,|\n|\r|Age|Sex|Gender|Yrs|Yr|M/F|\bM\b|\bF\b|वर्ष|वय|दिनांक|UHID|OPD|$)`.
   - Semicolons (`;`), dashes, slashes, or other common medical delimiters are missing from this lookahead.
   - Hindi words for age (`उम्र`, `आयु`) are completely missing from the lookahead (only Marathi `वय` and `वर्ष` are present).
   - Standalone `नाम` (Hindi) and `नाव` (Marathi) are omitted from the anchor prefix group.

2. **In `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:247-271`**:
   ```dart
   static final RegExp _aadhaarGeneralPattern = RegExp(
     r'\b([2-9]\d{3}[\s\-]?[0-9]{4}[\s\-]?[0-9]{4})\b',
   );
   static final RegExp _aadhaarExplicitPattern = RegExp(
     r'(?:^|[\s,;:\n])(?:aadhaar|aadhar|adhar|uid|uidai|आधार(?:\s*क्र\.?)?)\s*[:\-\s]*([0-9]{4}[\s\-]?[0-9]{4}[\s\-]?[0-9]{4})\b',
     caseSensitive: false,
     unicode: true,
   );
   static final RegExp _mobilePattern = RegExp(
     r'(?:(?:\+91|0091|91|0)[\s\-]?)?(?:(?:\(0\)\s*))?([6-9]\d{4}[\s\-]?\d{5})\b',
   );
   ```
   - `[0-9]`, `[2-9]`, and `\d` in Dart only match ASCII digits. Devanagari numerals `[\u0966-\u096F]` are excluded.

3. **In `backend/app.py:168-177`**:
   ```python
   PATIENT_HEADER_RE = re.compile(
       r"((?:patient(?:\s+name)?|pt\.?\s*name|pt\b|मरीज(?:\s+का\s+नाम)?|रोगी(?:\s+का\s+नाम)?|रुग्णाचे\s+नाव)\s*[:\-\s]\s*)"
       r"((?:(?:Mr|Mrs|Ms|Miss|Master|Shri|Smt|Kumari|श्री|श्रीमती|कु)\.?\s+)?"
       r"[A-Za-z\u0900-\u097F]+(?:[ \t]+[A-Za-z\u0900-\u097F]+){0,3})",
       re.IGNORECASE,
   )
   MOBILE_PATTERN_RE = re.compile(
       r"(?:\+91[\-\s]?|0091[\-\s]?|\b91[\-\s]|\b0)?(?:\(0\)\s*)?([6-9](?:[\-\s]?\d){9})\b"
   )
   ```
   - `PATIENT_HEADER_RE` omits standalone `नाम` (Hindi) and `नाव` (Marathi).
   - `MOBILE_PATTERN_RE` specifies leading digit `[6-9]`, which matches only ASCII digits 6-9, ignoring Devanagari numerals `[६-९]`.

---

## 2. Logic Chain

1. **From Observation 1.1 & 1.2 (Semicolon Delimiter & Age Lookahead in Dart)**:
   - Prescriptions frequently delimit demographic items with semicolons (e.g. `Pt. Name: Ramesh Kumar; Age: 54; Gender: M`).
   - Because Dart's `_patientAnchorPattern` lookahead requires `(?=\s*(?:,|\n|\r|Age|...))`, the presence of a semicolon immediately following the patient's name causes the lookahead assertion to fail.
   - Consequently, `EdgePiiSanitizer.sanitize` fails to detect or mask `Ramesh Kumar`, `सुरेश शर्मा`, or `आनंदी पाटील` whenever a semicolon terminates the name field. The raw patient name is transmitted verbatim in the payload.
   - Similarly, in Hindi prescriptions without semicolons (`मरीज का नाम: सुरेश शर्मा उम्र: ४५`), because `उम्र` is not present in the lookahead list, the lookahead fails and the name is leaked.

2. **From Observation 1.1 & 1.2 (Standalone Hindi/Marathi Prescription Headers)**:
   - Indian government hospital and clinic OPD slips frequently print `नाम - ` / `नाम: ` (Hindi) or `नाव - ` / `नाव: ` (Marathi).
   - Both Dart and Python require `मरीज का नाम`, `रोगी का नाम`, or `रुग्णाचे नाव`.
   - The test case mandated in the task dispatch (`नाम - सुरेश शर्मा;`) was completely unmasked in both Dart and Python, resulting in `0` patient_name redactions and full PII leakage.

3. **From Observation 1.1 & 1.2 (Devanagari Numerals)**:
   - In rural PHC prescriptions, handwritten or OCR-extracted text often produces Devanagari numerals (`०१२३४५६७८९`).
   - Dart regexes for Aadhaar and mobile numbers strictly check `[0-9]` and `[6-9]`, ignoring Devanagari numerals.
   - Python's mobile pattern requires ASCII `[6-9]`, ignoring Devanagari `[६-९]`.
   - As observed empirically, `आधार: २३४५ ६७८९ ०१२४` and `संपर्क: ९८७६५४३२१०` were unmasked in Dart, and `संपर्क: ९८७६५४३२१०` was unmasked in Python.

4. **From Successful Tests (Robust Features)**:
   - **Doctor & Clinic Credential Preservation**: Tested with `Dr. A.K. Gupta, MD (AIIMS)` vs `Patient: Ramesh Gupta`, Devanagari `डॉ. ए.के. गुप्ता, एम.डी. (एम्स)`, and Marathi `वैद्य शांताराम जोशी` at `ग्रामीण रुग्णालय`. In 100% of cases, healthcare provider credentials, degrees, and hospital names were safely preserved without masking.
   - **Cryptographic Manifest Tamper Resistance**: 1-character mutations at index 0, mid-string, end-of-string, and trailing whitespace all triggered SHA-256 digest mismatches against the manifest proof. Empty inputs (`""`) and whitespace inputs were handled deterministically without crashes.
   - **100KB Large Input Scaling**: Dart processed 141.77 KB in 49–51 ms, and Python processed 103.78 KB in 35 ms (both far below the 2000 ms threshold), proving no ReDoS catastrophic backtracking.
   - **Deterministic Pseudonym Token Parity**: Dart and Python compute identical 4-hex SHA-256 tokens (`Ramesh Kumar` $\to$ `[PATIENT-ANON-F188]`, `सुरेश कुमार` $\to$ `[PATIENT-ANON-8E96]`, `आनंदी पाटील` $\to$ `[PATIENT-ANON-603B]`).

---

## 3. Caveats

- **No Code Modifications**: Per the Empirical Challenger role instructions ("Review-only — do NOT modify implementation code"), we did not patch the production files `edge_pii_sanitizer.dart` or `backend/app.py`. All fixes must be implemented by the worker agent.
- **Test File Locations**: Test harnesses were added to `aarogyam-flutter/test/unit/edge_pii_adversarial_test.dart` and `backend/tests/test_adversarial_pii.py` in accordance with the project layout convention.

---

## 4. Conclusion & Challenges

**Overall risk assessment**: **HIGH**  
**Verdict**: **REQUEST_CHANGES**

### Challenges Summary

#### [Critical] Challenge 1: Semicolon Delimiter & Age Boundary Regex Lookahead Failure in Dart
- **Assumption challenged**: The worker assumed patient names are followed by comma, newline, or a small hardcoded set of English/Marathi words.
- **Attack scenario**: Prescriptions formatted as `Pt. Name: Ramesh Kumar; Age: 54` or `मरीज का नाम: सुरेश शर्मा; उम्र: ४५` or `मरीज का नाम: सुरेश शर्मा उम्र: ४५ वर्ष`.
- **Blast radius**: The entire patient de-identification subsystem fails silently. Full patient names are transmitted unmasked to external cloud vision services.
- **Mitigation**:
  1. Add `;` to the lookahead delimiter list in `_patientAnchorPattern`: `(?=\s*(?:[;,|/\n\r]|Age|Sex|Gender|Yrs|Yr|M/F|\bM\b|\bF\b|वर्ष|वय|उम्र|आयु|दिनांक|UHID|OPD|$))`
  2. Include `उम्र` and `आयु` in the positive lookahead delimiter list.

#### [High] Challenge 2: Missing Standalone Hindi `नाम` and Marathi `नाव` Header Anchors
- **Assumption challenged**: The worker assumed Hindi/Marathi forms always prefix with `मरीज का / रोगी का / रुग्णाचे`.
- **Attack scenario**: Form slips printed with `नाम - <Name>` or `नाव - <Name>` (e.g. `नाम - सुरेश शर्मा;`).
- **Blast radius**: Patient names in standard vernacular forms are completely bypassed by the PII sanitizer.
- **Mitigation**:
  Expand the anchor regex in both `edge_pii_sanitizer.dart` and `backend/app.py`:
  Add `\bनाम\b` and `\bनाव\b` (e.g. `(?:patient(?:\s+name)?|pt\.?\s*name|pt\b|मरीज(?:\s+का\s+नाम)?|रोगी(?:\s+का\s+नाम)?|रुग्णाचे\s+नाव|नाम(?:\s*[:\-])|नाव(?:\s*[:\-]))`).

#### [Medium] Challenge 3: Unhandled Devanagari Numerals in Contact & Identification Numbers
- **Assumption challenged**: The worker assumed numbers in OCR extracts are always normalized to ASCII `0-9`.
- **Attack scenario**: OCR text extracts Devanagari numerals: `आधार: २३४५ ६७८९ ०१२४` or `संपर्क: ९८७६५४३२१०`.
- **Blast radius**: Devanagari phone numbers and Aadhaar numbers leak unmasked into cloud logs.
- **Mitigation**:
  In Dart and Python, either:
  1. Normalize Devanagari digits `०-९` (U+0966 to U+096F) to ASCII `0-9` prior to regex matching, OR
  2. Include `[\u0966-\u096F]` in the regex patterns and numeric parsers.

### Stress Test Results Matrix

| Scenario / Vector | Expected Behavior | Actual Behavior | Result |
|---|---|---|---|
| `Pt. Name: Ramesh Kumar; Age: 54` | Masked to `[PATIENT-ANON-F188]` | Raw name `Ramesh Kumar` leaked | **FAIL** (Dart) |
| `मरीज का नाम: सुरेश शर्मा; उम्र: ४५` | Masked to `[PATIENT-ANON-BA83]` | Raw name `सुरेश शर्मा` leaked | **FAIL** (Dart) |
| `नाम - सुरेश शर्मा; उम्र: ४५ वर्ष` | Masked to `[PATIENT-ANON-BA83]` | Raw name `सुरेश शर्मा` leaked | **FAIL** (Dart & Python) |
| `मरीज का नाम: सुरेश शर्मा उम्र: ४५ वर्ष` | Masked to `[PATIENT-ANON-BA83]` | Raw name `सुरेश शर्मा` leaked | **FAIL** (Dart) |
| `रुग्णाचे नाव - आनंदी पाटील; वय: ४५` | Masked to `[PATIENT-ANON-603B]` | Raw name `आनंदी पाटील` leaked | **FAIL** (Dart) |
| `आधार: २३४५ ६७८९ ०१२४` (Devanagari) | Masked to `XXXXXXXX0124` / `[MASKED...]` | Unmasked in Dart (count = 0) | **FAIL** (Dart) |
| `संपर्क: ९८७६५४३२१०` (Devanagari) | Masked to `[MASKED-PHONE-XXXX]` | Unmasked in Dart and Python (count = 0) | **FAIL** (Dart & Python) |
| `Dr. A.K. Gupta, MD (AIIMS)` vs `Patient: Ramesh Gupta` | Doctor preserved; Patient masked | Doctor preserved; Patient masked | **PASS** (Dart & Python) |
| `डॉ. ए.के. गुप्ता, एम.डी. (एम्स)` vs `मरीज: रमेश गुप्ता` | Doctor preserved; Patient masked | Doctor preserved; Patient masked | **PASS** (Dart & Python) |
| 1-character mutation at index 0, mid, end | SHA-256 mismatch detected | SHA-256 mismatch detected | **PASS** (Dart & Python) |
| Empty input `""` and whitespace `"\n\t"` | Valid digest, no crash | Valid digest, no crash | **PASS** (Dart & Python) |
| 100KB prescription text scaling | Complete < 2000 ms, no ReDoS | 49 ms (Dart), 35 ms (Python) | **PASS** (Dart & Python) |
| Deterministic Token Parity (V1-V10) | Exact cross-platform match | Exact cross-platform match | **PASS** (Dart & Python) |

---

## 5. Verification Method

To independently verify these empirical failure modes:

1. **Run Flutter Adversarial Test Harness**:
   ```bash
   cd /Users/rufbook/aarogyam/aarogyam-flutter
   flutter test test/unit/edge_pii_adversarial_test.dart
   ```
   *Expected outcome*: 6 failing tests demonstrating semicolon leakage, standalone `नाम -`, Hindi `उम्र` boundary, and Devanagari numerals.

2. **Run Python Backend Adversarial Test Harness**:
   ```bash
   cd /Users/rufbook/aarogyam
   backend/venv/bin/pytest backend/tests/test_adversarial_pii.py -v
   ```
   *Expected outcome*: 2 failing tests demonstrating standalone `नाम -` leakage and Devanagari phone number leakage.

3. **Invalidation Conditions (For Acceptance after Fixes)**:
   - `flutter test test/unit/edge_pii_adversarial_test.dart` passes with 100% (16/16 tests).
   - `backend/venv/bin/pytest backend/tests/test_adversarial_pii.py -v` passes with 100% (14/14 tests).
   - Existing baseline test suites (`edge_pii_sanitizer_test.dart` and `test_pii_sanitizer.py`) continue to pass without regression.
