# Milestone 1 Reviewer 1 & Adversarial Critic Report

**Reviewer**: Reviewer 1 (`m1_reviewer_1`)  
**Roles**: Reviewer, Adversarial Critic  
**Date**: 2026-09-28T01:36:00Z  
**Verdict**: **REQUEST_CHANGES**  
**Working Directory**: `/Users/rufbook/aarogyam/.agents/teamwork/m1_reviewer_1`  
**Parent Orchestrator ID**: `debcb2f8-6c27-4400-9b21-9904a1a71bab`

---

## 1. Observation

### 1.1 Test Suite Execution Results
1. **Target Unit Test Suite**: `aarogyam-flutter/test/unit/edge_pii_sanitizer_test.dart`
   - Command: `flutter test test/unit/edge_pii_sanitizer_test.dart`
   - Result: `00:01 +32: All tests passed!` (32 passed, 0 failed).
2. **Dual-Track Fallback E2E Test Suite**: `aarogyam-flutter/test/unit/fallback_e2e_test.dart`
   - Command: `flutter test test/unit/fallback_e2e_test.dart`
   - Result: `00:01 +59: All tests passed!` (59 passed, 0 failed).
3. **Full Flutter Regression Suite**:
   - Command: `flutter test`
   - Result: `00:11 +216: All tests passed!` (216 passed, 0 failed).
4. **Backend PII Test Suite**: `backend/tests/test_pii_sanitizer.py`
   - Command: `backend/venv/bin/pytest backend/tests/test_pii_sanitizer.py -v`
   - Result: `21 passed in 0.14s` (21 passed, 0 failed).
5. **Backend Full Test Suite**:
   - Command: `backend/venv/bin/pytest backend/tests/ -v`
   - Result: **FAILED** (1 failed, 123 passed in 0.22s).
   - Verbatim Error:
     ```
     FAILED backend/tests/test_adversarial_pii.py::test_hindi_standalone_nam_hyphen_dispatch_case - AssertionError: CRITICAL: Raw patient name leaked in standalone 'नाम -' anchor: 'नाम - सुरेश शर्मा; उम्र: ४५ वर्ष'
     assert 'सुरेश शर्मा' not in 'नाम - सुरेश शर्मा; उम्र: ४५ वर्ष'
     ```
6. **Adversarial Flutter Test Suites**:
   - Command: `flutter test test/unit/edge_pii_adversarial_test.dart`
   - Result: **FAILED** (10 passed, 6 failed).
     - Failure 1: `मरीज का नाम: सुरेश शर्मा; उम्र: ४५` -> Raw name leaked because semicolon `;` is missing from lookahead.
     - Failure 2: `नाम - सुरेश शर्मा;` -> Raw name leaked because standalone `नाम -` is not recognized as an anchor.
     - Failure 3: `मरीज का नाम: सुरेश शर्मा उम्र: ४५ वर्ष` -> Inline age without delimiter leaked because `उम्र` is not in lookahead.
     - Failure 4: `आधार: २३४५ ६७८९ ०१२४` -> Devanagari numerals unmasked.
     - Failure 5: `रुग्णाचे नाव - आनंदी पाटील; वय: ४५` -> Marathi name leaked due to semicolon delimiter.
   - Command: `flutter test test/unit/adversarial_numerical_stress_test.dart`
   - Result: **FAILED** (0 passed, 1 failed).
     - Verbatim Error:
       ```
       Pharmacy: Rx# 2345 6789 0124 -> Pharmacy: Rx# XXXXXXXX0124 Aadhaar count: 1
       Expected: <0>
         Actual: <1>
       ```

### 1.2 Source Code Inspection
1. **Integrity & Facade Analysis**:
   - `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart`:
     - Genuine implementation of `VerhoeffAlgorithm` (Cayley multiplication table $D_5$, permutation matrix $P$, inverse table $Inv$).
     - No hardcoded test vectors (e.g. `Ramesh Kumar`, `3675 9834 5212`, `F188`, `8E96`) found in source code. SHA-256 tokens are computed dynamically via `crypto` package.
     - No dummy stubs or fake returns detected.
2. **Defect Locations**:
   - **File**: `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:214-221`
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
     - Semicolon `;` is omitted from lookahead delimiters.
     - Standalone `नाम` and `नाव` are omitted from anchor prefixes.
     - Inline `उम्र` is omitted from lookahead.
   - **File**: `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:257-260`
     ```dart
     static final RegExp _pharmaContextPattern = RegExp(
       r'\b(batch(?:\s*no\.?|\s*#)?|lot(?:\s*no\.?)?|exp(?:\.|\s*date)?|expiry|mfg(?:\.|\s*date)?|barcode|gtin|invoice|sn|serial(?:\s*no\.?)?|item|rx#)\b',
       caseSensitive: false,
     );
     ```
     - `rx#` is followed by `\b`. Because `#` is non-word (`\W`), the word boundary assertion `\b` fails when followed by non-word characters such as space or colon (`rx# `).
   - **File**: `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:364`
     ```dart
     final anonToken = deidentifyPatientName(rawName);
     final replaced = fullMatch.replaceFirst(rawName, anonToken);
     ```
     - `fullMatch.replaceFirst` replaces the first occurrence of `rawName` in `fullMatch`. If `rawName` collides with a token in the anchor prefix (e.g. `Name` or `Pt`), the prefix is replaced rather than the patient's name (`Patient [PATIENT-ANON-XXXX]: Name`).
   - **File**: `aarogyam-flutter/lib/backend/api_requests/api_calls.dart:16-131`
     - `RedactPiiAPICall` is fully implemented and correctly exposes `sanitizedText`, `entitiesMasked`, `aadhaarCount`, `phoneCount`, `patientNameCount`, `redactionsCount`, `privacyVerified`, `manifestId`, `preHash`, `postHash`, and `proofToken`. Fully conforms to `PROJECT.md § Interface Contracts`.

---

## 2. Logic Chain

1. **Integrity Validation**:
   - Observations in Section 1.2 show genuine algorithmic calculations for Verhoeff $D_5$ matrices and SHA-256 cryptographic manifests.
   - There are **no integrity violations** (no hardcoded test outputs, no facade implementations, no test bypassing).
2. **Failure of PII De-Identification on Standard Clinical Punctuation**:
   - Observation 1.1(5, 6) shows that in clinical prescriptions containing semicolons `;` (e.g., `मरीज का नाम: सुरेश शर्मा; उम्र: ४५` and `रुग्णाचे नाव - आनंदी पाटील; वय: ४५`), the patient name fails to be de-identified because `;` is absent from `_patientAnchorPattern` lookahead.
   - Semicolons and standalone headers (`नाम -`, `नाव -`) are widespread in Indian hospital prescription slips (both handwritten OCR and EMR printouts).
   - Leaking raw patient names in plaintext violates Project Feature F8 ("Zero PII Leakage: Patient names in English, Hindi, and Marathi are de-identified") and DPDP Act 2023 Section 8 compliance.
3. **Failure of Batch Number False-Positive Protection on `Rx#`**:
   - In Section 1.2(2), `_pharmaContextPattern` specifies `rx#\b`.
   - In regular expression syntax, `\b` requires a transition between `\w` and `\W`. Because `#` is `\W`, followed by space `' '` (`\W`), the assertion `\b` cannot match.
   - As observed in Section 1.1(6), `Rx# 2345 6789 0124` fails the pharma context lookback check, causing valid 12-digit batch numbers to be falsely masked as Aadhaar (`XXXXXXXX0124`), violating Project Feature F6.
4. **Conclusion Derivation**:
   - Because these defects cause real PII data leakage into cloud vision payloads and false-positive corruption of prescription batch codes, Milestone 1 cannot be approved in its current state.
   - The required verdict is **REQUEST_CHANGES**.

---

## 3. Findings

### [Critical] Finding 1: PII Leakage on Semicolon Delimiter & Inline Age in Multilingual Patient Names
- **What**: Patient names in Hindi and Marathi leak unmasked when separated by a semicolon `;` or followed by inline `उम्र`.
- **Where**: `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:218` and `backend/app.py:171`.
- **Why**: Semicolon is one of the most common delimiters in Indian prescriptions (`मरीज का नाम: सुरेश शर्मा; उम्र: ४५ वर्ष`). Omitting `;` and `उम्र` from the lookahead causes the regex to skip the match completely, transmitting raw patient names to cloud vision APIs.
- **Suggestion**: Update the lookahead in `_patientAnchorPattern` and `PATIENT_HEADER_RE`:
  ```dart
  r'(?=\s*(?:[,;\n\r]|Age|उम्र|Sex|Gender|Yrs|Yr|M/F|\bM\b|\bF\b|वर्ष|वय|दिनांक|UHID|OPD|$))'
  ```

### [Critical] Finding 2: PII Leakage on Standalone Hindi & Marathi Name Headers (`नाम`, `नाव`)
- **What**: Prescriptions formatted with standalone `नाम - <Name>` (Hindi) or `नाव - <Name>` (Marathi) are not recognized as patient name anchors.
- **Where**: `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:214` and `backend/app.py:169`.
- **Why**: Fails `backend/tests/test_adversarial_pii.py::test_hindi_standalone_nam_hyphen_dispatch_case`. Many prescription slips use abbreviated `नाम:` or `नाव:` rather than `मरीज का नाम:` or `रुग्णाचे नाव:`.
- **Suggestion**: Include standalone `नाम` and `नाव` (with optional preceding whitespace/hyphen/colon) in the anchor group:
  ```dart
  r'(?:patient(?:\s+name)?|pt\.?\s*name|pt\b|मरीज(?:\s+का\s+नाम)?|रोगी(?:\s+का\s+नाम)?|रुग्णाचे\s+नाव|(?:मरीज\s*)?नाम|(?:रुग्णाचे\s*)?नाव)'
  ```

### [Major] Finding 3: False-Positive Aadhaar Masking on `Rx#` Medicine Batch Codes
- **What**: Medicine batch numbers labeled with `Rx#` (e.g. `Rx# 2345 6789 0124`) are falsely masked as Aadhaar.
- **Where**: `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:258`.
- **Why**: `rx#\b` contains a word boundary after `#`. Since `#` is a non-word character (`\W`), `\b` fails when followed by space or colon (`\W`), rendering the `rx#` alternative permanently non-matching.
- **Suggestion**: Replace `rx#` in `_pharmaContextPattern` with `rx(?:#|\b)` or `rx(?:\s*#)?\b`.

### [Major] Finding 4: Substring Collision in `replaceFirst` for Patient Names
- **What**: If a patient's name happens to match a token in the anchor prefix (e.g. `Name` or `Pt`), `replaceFirst` replaces the anchor word rather than the patient's name.
- **Where**: `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:364`.
- **Why**: `fullMatch.replaceFirst(rawName, anonToken)` searches from index 0 of `fullMatch`. For `Patient Name: Name`, this yields `Patient [PATIENT-ANON-XXXX]: Name`.
- **Suggestion**: Replace using slice indices: `fullMatch.substring(0, fullMatch.length - rawName.length) + anonToken`.

### [Minor] Finding 5: Exclusion of Apostrophes and Hyphens in Patient Names
- **What**: Names with hyphens or apostrophes (e.g. `Mary-Ann`, `D'Souza`) or 5+ words (`Konda Venkata Ranga Reddy Rao`) fail to match `_patientAnchorPattern`.
- **Where**: `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:216-217`.
- **Why**: The character class `[A-Za-z\u0900-\u097F]` omits `['-]` and the word multiplier `{0,3}` caps at 4 words.
- **Suggestion**: Permit `['-]` in name characters and expand quantifier to `{0,5}`.

---

## 4. Caveats

- **No Integrity Violations**: The worker acted in good faith; all mathematical implementations of Verhoeff and SHA-256 manifests are genuine and mathematically sound.
- **Baseline Test Success**: All baseline test suites specified in the initial dispatch (`edge_pii_sanitizer_test.dart`, `fallback_e2e_test.dart`, and full `flutter test`) pass 100%. The findings were uncovered via adversarial stress testing and cross-file regression execution.

---

## 5. Conclusion

Milestone 1 is of high engineering quality and satisfies core Verhoeff arithmetic, SHA-256 manifest generation, and basic de-identification. However, due to regex delimiter omissions causing raw patient PII leakage under common clinical delimiters (semicolons and standalone `नाम -`) and a regex word-boundary defect on `Rx#` batch codes, Milestone 1 cannot be certified as production-ready.

**Final Verdict**: **REQUEST_CHANGES**  
The Milestone 1 Worker must address Findings 1, 2, and 3 in `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart` and `backend/app.py`.

---

## 6. Verification Method

To verify the remediation when returned:

1. **Verify Baseline Tests**:
   ```bash
   cd /Users/rufbook/aarogyam/aarogyam-flutter
   flutter test test/unit/edge_pii_sanitizer_test.dart
   flutter test test/unit/fallback_e2e_test.dart
   flutter test
   ```
2. **Verify Adversarial Stress Suites**:
   ```bash
   cd /Users/rufbook/aarogyam/aarogyam-flutter
   flutter test test/unit/edge_pii_adversarial_test.dart
   flutter test test/unit/adversarial_numerical_stress_test.dart
   ```
3. **Verify Full Backend Regression**:
   ```bash
   cd /Users/rufbook/aarogyam
   backend/venv/bin/pytest backend/tests/test_adversarial_pii.py -v
   backend/venv/bin/pytest backend/tests/ -v
   ```
4. **Invalidation Conditions**:
   - Any test failure in `test_adversarial_pii.py` or `edge_pii_adversarial_test.dart`.
   - Any raw patient name leaking in `मरीज का नाम: सुरेश शर्मा; उम्र: ४५` or `नाम - सुरेश शर्मा;`.
   - `Rx# 2345 6789 0124` being masked as Aadhaar.
