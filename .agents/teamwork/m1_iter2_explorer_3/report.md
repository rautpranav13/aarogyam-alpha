# Milestone 1 Iteration 2: Adversarial Parity & Test Harness Report

**Author**: Explorer 3 (`m1_iter2_explorer_3`)  
**Role**: Adversarial Parity & Test Harness Specialist  
**Working Directory**: `/Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_explorer_3`  
**Parent Orchestrator Conversation ID**: `debcb2f8-6c27-4400-9b21-9904a1a71bab`  
**Date**: 2026-09-28T01:42:00Z  

---

## 1. Executive Summary

Milestone 1 Iteration 1 concluded with a **REQUEST_CHANGES** verdict due to 7 specific edge-case defects uncovered during adversarial stress testing. As Explorer 3, our mission is to formulate the complete **test integration and cross-platform verification plan** so that **100% of all adversarial stress tests and regression tests pass with identical parity across Flutter (Dart) and Backend (Python)**.

### 1.1 The Critical Test Suite Inversion Discovery
During our empirical investigation of the four adversarial test suites:
- `backend/tests/test_adversarial_pii.py`
- `backend/tests/test_adversarial_numerical_stress.py`
- `aarogyam-flutter/test/unit/edge_pii_adversarial_test.dart`
- `aarogyam-flutter/test/unit/adversarial_numerical_stress_test.dart`

We uncovered a fundamental structural asymmetry in how the test suites were constructed:
1. **Security Contract Test Suites** (`test_adversarial_pii.py` and `edge_pii_adversarial_test.dart`):
   - Authored by Challenger 2 (`m1_challenger_2`).
   - These tests assert the **ideal, secure behavior** (e.g., patient names masked even with semicolons, Devanagari numerals masked, standalone `नाम -` handled).
   - **Current status**: They fail (2 failed in Python, 6 failed in Dart) because the implementation code contains defects.
   - **When source code is fixed**: These tests will immediately turn **GREEN (100% PASS)**.

2. **Vulnerability Demonstration Test Suites** (`test_adversarial_numerical_stress.py` and `adversarial_numerical_stress_test.dart`):
   - Authored by Challenger 1 (`m1_challenger_1`).
   - These tests were designed to **empirically prove the presence of defects**. Specifically, they assert:
     * That 12-digit batch codes **are** corrupted by phone regex (`assert phone_masked == 1`).
     * That `SN:`, `Item:`, and `Rx#` **are** wrongly masked as Aadhaar (`assert aadhaar == 1`).
     * That 11-digit numbers **have** their trailing 10 digits stripped (`assert phone == 1`).
     * That non-standard spaced phone numbers (`9876 543210`) in Dart **leak unmasked** (`expect(phone, equals(0))`).
   - **Current status**: They currently pass **only because the implementation is broken**!
   - **The Inversion Hazard**: When the worker agent patches `edge_pii_sanitizer.dart` and `backend/app.py` to fix these vulnerabilities, **these tests will immediately turn RED (FAIL)** because the bug they are asserting is no longer present!

### 1.2 The Resolution Strategy
To achieve a certified 100% pass across both platforms:
1. **Source Code Remediation**: Apply the 7 fixes designed by Explorer 1 (`edge_pii_sanitizer.dart`) and Explorer 2 (`backend/app.py`).
2. **Test Harness Hardening**: Transition Challenger 1's numerical stress tests from "vulnerability proof mode" to "hardened regression guard mode", asserting that batch numbers are preserved (`phone == 0`), keywords prevent Aadhaar masking (`aadhaar == 0`), 11-digit numbers remain intact (`phone == 0`), and spaced phones are masked (`phone == 1`).
3. **Parity Guarantee**: Maintain identical token generation (`[PATIENT-ANON-XXXX]`), Verhoeff $D_5$ validation, keyword coverage, and boundary handling across Dart and Python.

---

## 2. Test Suite Architecture & Current Execution State

### 2.1 Inventory Table

| Suite | File Path | Language | Authored By | Intent | Current Status | Expected Post-Fix Status |
|---|---|---|---|---|---|---|
| **A** | `backend/tests/test_adversarial_pii.py` | Python (pytest) | Challenger 2 | Security Contract | **2 FAILED**, 12 PASSED | **14 PASSED (100%)** |
| **B** | `aarogyam-flutter/test/unit/edge_pii_adversarial_test.dart` | Dart (flutter_test) | Challenger 2 | Security Contract | **6 FAILED**, 10 PASSED | **16 PASSED (100%)** |
| **C** | `backend/tests/test_adversarial_numerical_stress.py` | Python (pytest) | Challenger 1 | Vulnerability Proof | 11 PASSED (Asserts bugs) | **11 PASSED (100%)** *(after assertion transition)* |
| **D** | `aarogyam-flutter/test/unit/adversarial_numerical_stress_test.dart` | Dart (flutter_test) | Challenger 1 | Vulnerability Proof | 11 PASSED (Asserts bugs) | **11 PASSED (100%)** *(after assertion transition)* |
| **R1**| `backend/tests/test_pii_sanitizer.py` | Python (pytest) | Worker | Baseline Regression | 21 PASSED | **21 PASSED (100%)** |
| **R2**| `backend/tests/test_app.py` | Python (pytest) | Worker | Baseline API Regression| 13 PASSED | **13 PASSED (100%)** |
| **R3**| `aarogyam-flutter/test/unit/edge_pii_sanitizer_test.dart` | Dart (flutter_test) | Worker | Baseline Regression | 32 PASSED | **32 PASSED (100%)** |
| **R4**| `aarogyam-flutter/test/unit/fallback_e2e_test.dart` | Dart (flutter_test) | Worker | Baseline Regression | 59 PASSED | **59 PASSED (100%)** |

---

### 2.2 Deep Dive: Current Failures in Security Contract Suites

#### 1. `backend/tests/test_adversarial_pii.py` (2 Failures)
- **Failure 1**: `test_hindi_standalone_nam_hyphen_dispatch_case`
  * Input: `"नाम - सुरेश शर्मा; उम्र: ४५ वर्ष"`
  * Assertion: `assert "सुरेश शर्मा" not in sanitized`
  * Error: Raw patient name leaked because `PATIENT_HEADER_RE` in `backend/app.py` requires `मरीज का नाम`, `रोगी का नाम`, or `रुग्णाचे नाव`, omitting standalone `नाम` and `नाव`.
- **Failure 2**: `test_devanagari_numerals_aadhaar_and_phone`
  * Input: `phone_dev = "संपर्क: ९८७६५४३२१०"`
  * Assertion: `assert "९८७६५४३२१०" not in sanitized_p`
  * Error: `MOBILE_PATTERN_RE` specifies leading digit `[6-9]`, which matches only ASCII digits 6-9, ignoring Devanagari numerals `[६-९]`.

#### 2. `aarogyam-flutter/test/unit/edge_pii_adversarial_test.dart` (6 Failures)
- **Failure 1**: `English variations: newline, CRLF, colon, hyphen, trailing punctuation`
  * Input: `'Pt. Name: Ramesh Kumar; Age: 54'`
  * Got: `'Pt. Name: Ramesh Kumar; Age: [REDACTED]'`
  * Error: Semicolon `;` is missing from the lookahead delimiter list in `_patientAnchorPattern`.
- **Failure 2**: `Hindi variations: मरीज, रोगी, hyphen separator, semicolon, Devanagari punctuation`
  * Input: `'मरीज का नाम: सुरेश शर्मा; उम्र: ४५'`
  * Got: `'मरीज का नाम: सुरेश शर्मा; उम्र: [REDACTED]'`
  * Error: Semicolon `;` and inline `उम्र` are missing from the lookahead delimiter list.
- **Failure 3**: `Hindi standalone "नाम - सुरेश शर्मा;" stress-test`
  * Input: `'नाम - सुरेश शर्मा; उम्र: ४५ वर्ष'`
  * Error: Standalone `नाम -` is not recognized as a patient anchor.
- **Failure 4**: `Hindi age boundary without newline: "मरीज का नाम: सुरेश शर्मा उम्र: ४५ वर्ष"`
  * Input: `'मरीज का नाम: सुरेश शर्मा उम्र: ४५ वर्ष'`
  * Got: `'मरीज का नाम: सुरेश शर्मा उम्र: [REDACTED]'`
  * Error: Lookahead does not break on inline `उम्र`.
- **Failure 5**: `Devanagari numerals in Aadhaar and Phone numbers`
  * Input: `'आधार: २३४५ ६७८९ ०१२४'` and `'संपर्क: ९८७६५४३२१०'`
  * Error: Dart `RegExp` `\d` and `[0-9]` are ASCII-only; Devanagari digits `[०-९]` are completely unhandled.
- **Failure 6**: `Marathi variations: रुग्णाचे नाव, hyphen separator, semicolon`
  * Input: `'रुग्णाचे नाव - आनंदी पाटील; वय: ४५'`
  * Error: Lookahead fails to terminate on semicolon `;`.

---

### 2.3 Deep Dive: The Inverted Tests in Numerical Stress Suites

In `backend/tests/test_adversarial_numerical_stress.py` and `aarogyam-flutter/test/unit/adversarial_numerical_stress_test.dart`, several tests were explicitly written to pass when the defect exists:

#### Inverted Test 1: Batch Code Phone Cross-Interference
- **Current Test Code** (Python line 205 / Dart line 156):
  ```python
  # Python:
  assert phone_masked == 1, "Demonstrated phone cross-interference on batch code"
  assert "[MASKED-PHONE-XXXX]" in sanitized_spaced
  ```
  ```dart
  // Dart:
  expect(result.entityCounts[PiiType.phone], equals(1));
  expect(result.sanitizedText, contains('98XXXXX-XX096'));
  ```
- **What happens after Worker fixes phone regex**:
  `MOBILE_PATTERN_RE` and `_mobilePattern` will have `(?<!\d)` leading lookbehind. The 12-digit batch code `9876 5432 1096` will NOT be matched as a phone. `phone_masked` will be `0`.
- **Test Failure if not updated**:
  `AssertionError: Expected 1, got 0`.

#### Inverted Test 2: Missing Batch Keywords in Python
- **Current Test Code** (Python lines 225-227):
  ```python
  assert m_sn["entities_masked"]["aadhaar"] == 1
  assert m_item["entities_masked"]["aadhaar"] == 1
  assert m_rx["entities_masked"]["aadhaar"] == 1
  ```
- **What happens after Worker fixes `BATCH_LABEL_RE`**:
  `SN:`, `Item:`, and `Rx#` will be recognized as batch keywords. The Aadhaar masking is correctly suppressed. `aadhaar` count will be `0`.
- **Test Failure if not updated**:
  `AssertionError: assert 0 == 1`.

#### Inverted Test 3: Rx# Word-Boundary Defect in Dart
- **Current Test Code** (Dart lines 169-170):
  ```dart
  expect(result.entityCounts[PiiType.aadhaar], equals(1));
  expect(result.sanitizedText, contains('XXXXXXXX0124'));
  ```
- **What happens after Worker fixes `rx#\b` to `rx(?:\s*#|\b)`**:
  `Rx#` is recognized as a pharmaceutical keyword. Aadhaar masking is suppressed. `aadhaar` count will be `0`.
- **Test Failure if not updated**:
  `Expected: <1>, Actual: <0>`.

#### Inverted Test 4: 11-Digit Suffix Matching Boundary
- **Current Test Code** (Python lines 269-270 / Dart lines 195-196):
  ```python
  # Python:
  assert meta["entities_masked"]["phone"] == 1
  assert "9[MASKED-PHONE-XXXX]" in sanitized
  ```
  ```dart
  // Dart:
  expect(result.entityCounts[PiiType.phone], equals(1));
  expect(result.sanitizedText, contains('9XXXXX-XX101'));
  ```
- **What happens after Worker fixes phone regex**:
  `(?<!\d)` prevents capturing trailing 10 digits of an 11-digit identifier. `phone` count will be `0`, and the original 11-digit identifier is preserved intact.
- **Test Failure if not updated**:
  `AssertionError: Expected 1, got 0`.

#### Inverted Test 5: Spaced Phone Delimiters in Dart
- **Current Test Code** (Dart lines 203-210):
  ```dart
  // 4+6 format
  expect(res4_6.entityCounts[PiiType.phone], equals(0)); // Asserts it LEAKED!
  expect(res4_6.sanitizedText, contains('9876 543210'));

  // 3+3+4 format
  expect(res3_3_4.entityCounts[PiiType.phone], equals(0)); // Asserts it LEAKED!
  expect(res3_3_4.sanitizedText, contains('987 654 3210'));
  ```
- **What happens after Worker adds flexible spacing `(?:[\s\-]?\d){9}` to Dart**:
  Both formats will be detected and masked! `phone` count will be `1`, and the raw numbers will NOT be present in sanitized output.
- **Test Failure if not updated**:
  `Expected: <0>, Actual: <1>`.

---

## 3. Cross-Platform Parity & Remediation Matrix (The 7 Pillars)

To guarantee that Dart and Python achieve 100% identical de-identification outcomes, the two codebases must align across all 7 defect pillars:

| Pillar | Defect Description | Dart Remediation (`edge_pii_sanitizer.dart`) | Python Remediation (`backend/app.py`) | Parity Verification Invariant |
|---|---|---|---|---|
| **1. Delimiters** | Semicolons and inline `उम्र`/`आयु` leak patient names | Add `[;,|/\n\r]` and `उम्र`, `आयु` to lookahead in `_patientAnchorPattern` | Add positive lookahead `(?=\s*(?:[;,|/\n\r]|Age|Sex|Gender|Yrs|Yr|M/F|\bM\b|\bF\b|उम्र|आयु|वर्ष|वय|दिनांक|UHID|OPD|$))` to `PATIENT_HEADER_RE` | `Pt. Name: Ramesh Kumar; Age: 54` $\to$ `[PATIENT-ANON-F188]` in both |
| **2. Standalone Headers** | Standalone `नाम -` and `नाव -` headers omitted from anchor regex | Add `नाम` and `नाव` to `_patientAnchorPattern` prefix alternation: `(?:...|नाम|नाव)` | Add `(?:मरीज\s*)?नाम` and `(?:रुग्णाचे\s*)?नाव` to `PATIENT_HEADER_RE` | `नाम - सुरेश शर्मा;` $\to$ `[PATIENT-ANON-BA83]` in both |
| **3. Leading Mobile Boundary** | Missing leading boundary causes suffix matching on 11/12-digit codes | Add `(?<!\d)` leading lookbehind and `(?!\d)` trailing lookahead to `_mobilePattern` | Add `(?<!\d)` leading lookbehind and `(?!\d)` trailing lookahead to `MOBILE_PATTERN_RE` | `Batch: 987654321096` and `Ref: 98765432101` preserved intact with `phone: 0` in both |
| **4. Flexible Phone Spacing** | Dart enforced rigid 5+5 (`\d{4}[\s\-]?\d{5}`), leaking 4+6, 3+3+4, etc. | Change `[6-9]\d{4}[\s\-]?\d{5}` to `[6-9](?:[\s\-]?\d){9}` in `_mobilePattern` | Already uses `[6-9](?:[\-\s]?\d){9}`; retain with boundaries | `9876 543210` masked with `phone: 1` in both |
| **5. Batch Keyword Parity** | `SN:`, `Item:`, `Rx#`, and vernacular terms missing; `rx#\b` syntax broken | Add `b\.?\s*no\.?`, `mfd`, `बैच`, `लॉट`, `कालबाह्य`, `घटक`, and fix `rx(?:\s*#|\b)` in `_pharmaContextPattern` | Add `sn`, `serial`, `item`, `बैच`, `लॉट`, `कालबाह्य`, `घटक`, and `rx(?:\s*#|\b)` in `BATCH_LABEL_RE` | `SN: 2345 6789 0124` and `Rx# 2345 6789 0124` preserved with `aadhaar: 0` in both |
| **6. Devanagari Numerals** | Devanagari digits `[०-९]` (`\u0966-\u096F`) unhandled by ASCII-only digit regexes | Add `normalizeDevanagariDigits` preprocessing to convert `[०-९]` to `[0-9]` | Add `normalize_devanagari_digits` preprocessing or regex digit normalization | `आधार: २३४५ ६७८९ ०१२४` $\to$ `XXXXXXXX0124`, `संपर्क: ९८७६५४३२१०` $\to$ masked in both |
| **7. Substring Collision** | `replaceFirst(rawName, ...)` in Dart replaces prefix tokens if name collides | Use exact index replacement: `fullMatch.substring(0, index) + anonToken + fullMatch.substring(index + length)` | Python uses `match.group(1) + token`, which is already immune to prefix collision | `Patient Name: Name` $\to$ `Patient Name: [PATIENT-ANON-XXXX]` in both |

---

## 4. Test Harness Hardening Specification

Below are the exact, drop-in replacement snippets for the test files that need to be transitioned from vulnerability-asserting to security-verifying.

### 4.1 Changes for `backend/tests/test_adversarial_numerical_stress.py`

#### 1. Transition `test_batch_code_phone_cross_interference_vulnerability`
Replace lines 182-207:
```python
def test_batch_code_phone_cross_interference_vulnerability():
    """
    Verifies that a valid 12-digit Verhoeff batch number containing digits
    starting with 6-9 is NOT falsely captured or mutilated by the phone regex.
    """
    v_code = "987654321096"
    assert validate_verhoeff(v_code) is True

    text_spaced = "Rx: Amoxicillin 500mg, Batch No: 9876 5432 1096, Exp: 12/2027"
    sanitized_spaced, meta_spaced = mask_pii(text_spaced)

    phone_masked = meta_spaced["entities_masked"]["phone"]
    aadhaar_masked = meta_spaced["entities_masked"]["aadhaar"]

    # In Iteration 2 (Hardened):
    # Phone regex with (?<!\d) must NOT match inside the 12-digit batch code.
    assert aadhaar_masked == 0, "Aadhaar shield worked"
    assert phone_masked == 0, "Batch code must NOT be falsely masked by phone regex"
    assert "9876 5432 1096" in sanitized_spaced, "Batch number preserved intact"
```

#### 2. Transition `test_missing_batch_labels_in_python_backend`
Replace lines 209-228:
```python
def test_missing_batch_labels_in_python_backend():
    """
    Verifies that SN:, Item:, and Rx# are recognized as pharmaceutical batch labels,
    preventing valid Verhoeff batch codes from being falsely redacted as Aadhaar.
    """
    code = "2345 6789 0124"
    assert validate_verhoeff(code) is True

    # SN:
    s_sn, m_sn = mask_pii(f"Medical device SN: {code}")
    # Item:
    s_item, m_item = mask_pii(f"Pharmacy Item: {code}")
    # Rx#
    s_rx, m_rx = mask_pii(f"Prescription Rx# {code}")

    # In Iteration 2 (Hardened):
    # All 3 labels must be recognized, suppressing Aadhaar masking:
    assert m_sn["entities_masked"]["aadhaar"] == 0, "SN: must shield batch number"
    assert m_item["entities_masked"]["aadhaar"] == 0, "Item: must shield batch number"
    assert m_rx["entities_masked"]["aadhaar"] == 0, "Rx# must shield batch number"
    assert code in s_sn
    assert code in s_item
    assert code in s_rx
```

#### 3. Transition `test_phone_11digit_suffix_matching_vulnerability`
Replace lines 257-271:
```python
def test_phone_11digit_suffix_matching_vulnerability():
    """
    Verifies that MOBILE_PATTERN_RE with leading lookbehind (?<!\d) does NOT
    match the trailing 10 digits of an 11-digit number.
    """
    text = "Transaction Ref: 98765432101"
    sanitized, meta = mask_pii(text)

    # In Iteration 2 (Hardened):
    # Must reject 11-digit numbers and leave them uncorrupted:
    assert meta["entities_masked"]["phone"] == 0, "11-digit identifier must NOT be masked as phone"
    assert "Transaction Ref: 98765432101" == sanitized
```

---

### 4.2 Changes for `aarogyam-flutter/test/unit/adversarial_numerical_stress_test.dart`

#### 1. Transition `Demonstrates Phone Regex Cross-Interference on contiguous 12-digit batch codes`
Replace lines 144-159:
```dart
    test('Demonstrates Phone Regex Cross-Interference on contiguous 12-digit batch codes', () {
      // 987654321096 is a valid Verhoeff batch code
      const input = 'Medication: Paracetamol, Batch: 987654321096';
      final result = EdgePiiSanitizer.sanitize(input);

      // In Iteration 2 (Hardened):
      // Both Aadhaar and Phone masking must be suppressed:
      expect(result.entityCounts[PiiType.aadhaar], equals(0),
          reason: 'Aadhaar shield must protect batch code');
      expect(result.entityCounts[PiiType.phone], equals(0),
          reason: 'Phone regex must NOT capture inside 12-digit batch code');
      expect(result.sanitizedText, contains('987654321096'),
          reason: 'Batch code must be preserved intact');
    });
```

#### 2. Transition `Demonstrates Rx# regex word-boundary defect in Dart`
Replace lines 161-171:
```dart
    test('Demonstrates Rx# regex word-boundary defect in Dart', () {
      const input = 'Pharmacy: Rx# 2345 6789 0124';
      final result = EdgePiiSanitizer.sanitize(input);

      // In Iteration 2 (Hardened):
      // Rx# must be recognized, suppressing Aadhaar masking:
      expect(result.entityCounts[PiiType.aadhaar], equals(0),
          reason: 'Rx# must successfully shield the batch code from Aadhaar masking');
      expect(result.sanitizedText, contains('2345 6789 0124'),
          reason: 'Prescription batch code under Rx# must be preserved');
    });
```

#### 3. Transition `Demonstrates 11-digit boundary defect in Dart`
Replace lines 188-197:
```dart
    test('Demonstrates 11-digit boundary defect in Dart', () {
      const input = 'Transaction Ref: 98765432101';
      final result = EdgePiiSanitizer.sanitize(input);

      // In Iteration 2 (Hardened):
      // 11-digit identifier must NOT be masked as phone:
      expect(result.entityCounts[PiiType.phone], equals(0),
          reason: '11-digit identifier must not have trailing 10 digits masked');
      expect(result.sanitizedText, equals('Transaction Ref: 98765432101'),
          reason: 'Transaction reference must be preserved intact');
    });
```

#### 4. Transition `Demonstrates non-standard spaced phone numbers LEAKING unmasked in Dart`
Replace lines 199-211:
```dart
    test('Demonstrates non-standard spaced phone numbers LEAKING unmasked in Dart', () {
      // 4+6 format
      final res4_6 = EdgePiiSanitizer.sanitize('Call 9876 543210 immediately');
      expect(res4_6.entityCounts[PiiType.phone], equals(1),
          reason: '4+6 spaced Indian phone number must be masked');
      expect(res4_6.sanitizedText, isNot(contains('9876 543210')),
          reason: 'Raw 4+6 phone number must not leak');

      // 3+3+4 format
      final res3_3_4 = EdgePiiSanitizer.sanitize('Call 987 654 3210 immediately');
      expect(res3_3_4.entityCounts[PiiType.phone], equals(1),
          reason: '3+3+4 spaced Indian phone number must be masked');
      expect(res3_3_4.sanitizedText, isNot(contains('987 654 3210')),
          reason: 'Raw 3+3+4 phone number must not leak');
    });
```

---

## 5. Canonical Parity Test Vectors (Cross-Platform Invariants)

Below is the definitive verification table for all 15 core test vectors across both platforms.

| Vector ID | Category | Raw Input String | Expected Dart Sanitized Text | Expected Python Sanitized Text | Entities Masked Count |
|---|---|---|---|---|---|
| **V1** | Aadhaar Spaced | `Patient Aadhaar: 2345 6789 0124` | `Patient Aadhaar: XXXXXXXX0124` | `Patient Aadhaar: XXXXXXXX0124` (uidai) | `aadhaar: 1` |
| **V2** | Aadhaar Hyphen | `UID: 2345-6789-0124` | `UID: XXXXXXXX0124` | `UID: XXXXXXXX0124` (uidai) | `aadhaar: 1` |
| **V3** | Batch Protection | `Batch Number: 1234-5678-9012 Exp: 12/2026` | `Batch Number: 1234-5678-9012 Exp: 12/2026` | `Batch Number: 1234-5678-9012 Exp: 12/2026` | `aadhaar: 0` |
| **V4** | Aadhaar Transposition | `Ref: 2346 5789 0124` | `Ref: 2346 5789 0124` | `Ref: 2346 5789 0124` | `aadhaar: 0` |
| **V5** | Mobile +91 | `Contact: +91 98765 43210` | `Contact: +91-XXXXX-XX210` | `Contact: [MASKED-PHONE-XXXX]` | `phone: 1` |
| **V6** | Mobile Bare 5+5 | `Call 98765 43210 immediately` | `Call XXXXX-XX210 immediately` | `Call [MASKED-PHONE-XXXX] immediately` | `phone: 1` |
| **V7** | Mobile Bare 4+6 | `Call 9876 543210 immediately` | `Call XXXXX-XX210 immediately` | `Call [MASKED-PHONE-XXXX] immediately` | `phone: 1` |
| **V8** | Mobile 3+3+4 | `Call 987 654 3210 immediately` | `Call XXXXX-XX210 immediately` | `Call [MASKED-PHONE-XXXX] immediately` | `phone: 1` |
| **V9** | 11-digit ID Protection| `Transaction Ref: 98765432101` | `Transaction Ref: 98765432101` | `Transaction Ref: 98765432101` | `phone: 0` |
| **V10**| 12-digit Batch Shield | `Medication: Paracetamol, Batch: 987654321096` | `Medication: Paracetamol, Batch: 987654321096` | `Medication: Paracetamol, Batch: 987654321096` | `aadhaar: 0, phone: 0` |
| **V11**| Supply Chain Rx# | `Pharmacy: Rx# 2345 6789 0124` | `Pharmacy: Rx# 2345 6789 0124` | `Pharmacy: Rx# 2345 6789 0124` | `aadhaar: 0` |
| **V12**| Supply Chain SN | `Medical device SN: 2345 6789 0124` | `Medical device SN: 2345 6789 0124` | `Medical device SN: 2345 6789 0124` | `aadhaar: 0` |
| **V13**| English Patient Semicolon | `Pt. Name: Ramesh Kumar; Age: 54` | `Pt. Name: [PATIENT-ANON-F188]; Age: [REDACTED]` | `Pt. Name: [PATIENT-ANON-F188]; Age: 54` | `patient_name: 1` |
| **V14**| Hindi Patient Semicolon | `मरीज का नाम: सुरेश शर्मा; उम्र: ४५` | `मरीज का नाम: [PATIENT-ANON-BA83]; उम्र: [REDACTED]` | `मरीज का नाम: [PATIENT-ANON-BA83]; उम्र: ४५` | `patient_name: 1` |
| **V15**| Standalone Hindi Header| `नाम - सुरेश शर्मा; उम्र: ४५ वर्ष` | `नाम - [PATIENT-ANON-BA83]; उम्र: [REDACTED]` | `नाम - [PATIENT-ANON-BA83]; उम्र: ४५ वर्ष` | `patient_name: 1` |
| **V16**| Hindi Inline Age | `मरीज का नाम: सुरेश शर्मा उम्र: ४५ वर्ष` | `मरीज का नाम: [PATIENT-ANON-BA83] उम्र: [REDACTED]` | `मरीज का नाम: [PATIENT-ANON-BA83] उम्र: ४५ वर्ष` | `patient_name: 1` |
| **V17**| Marathi Patient Semicolon | `रुग्णाचे नाव - आनंदी पाटील; वय: ४५` | `रुग्णाचे नाव - [PATIENT-ANON-603B]; वय: [REDACTED]` | `रुग्णाचे नाव - [PATIENT-ANON-603B]; वय: ४५` | `patient_name: 1` |
| **V18**| Devanagari Aadhaar | `आधार: २३४५ ६७८९ ०१२४` | `आधार: XXXXXXXX0124` | `आधार: XXXXXXXX0124` (uidai) | `aadhaar: 1` |
| **V19**| Devanagari Phone | `संपर्क: ९८७६५४३२१०` | `संपर्क: XXXXX-XX210` | `संपर्क: [MASKED-PHONE-XXXX]` | `phone: 1` |
| **V20**| Doctor Preservation | `Dr. A.K. Gupta, MD (AIIMS); Patient: Ramesh Gupta` | Preserves Dr. Gupta; masks Ramesh Gupta $\to$ `[PATIENT-ANON-C85F]` | Preserves Dr. Gupta; masks Ramesh Gupta $\to$ `[PATIENT-ANON-C85F]` | `patient_name: 1` |

---

## 6. End-to-End Verification Runbook & Acceptance Criteria

When the worker agent implements the source fixes and updates the test assertions according to Section 4, the following sequence of verification commands must execute cleanly with zero failures.

### Step 1: Run Dart Adversarial Test Suites
```bash
cd /Users/rufbook/aarogyam/aarogyam-flutter
flutter test test/unit/edge_pii_adversarial_test.dart test/unit/adversarial_numerical_stress_test.dart
```
**Expected Outcome**: `All tests passed!` (27 tests passed: 16 in `edge_pii_adversarial_test.dart` + 11 in `adversarial_numerical_stress_test.dart`).

### Step 2: Run Dart Baseline Regression Test Suites
```bash
cd /Users/rufbook/aarogyam/aarogyam-flutter
flutter test test/unit/edge_pii_sanitizer_test.dart test/unit/fallback_e2e_test.dart
```
**Expected Outcome**: `All tests passed!` (91 tests passed: 32 in `edge_pii_sanitizer_test.dart` + 59 in `fallback_e2e_test.dart`).

### Step 3: Run Full Flutter Test Suite
```bash
cd /Users/rufbook/aarogyam/aarogyam-flutter
flutter test
```
**Expected Outcome**: `+216: All tests passed!` (or higher with adversarial suites included).

### Step 4: Run Backend Adversarial Test Suites
```bash
cd /Users/rufbook/aarogyam
backend/venv/bin/pytest backend/tests/test_adversarial_pii.py backend/tests/test_adversarial_numerical_stress.py -v
```
**Expected Outcome**: `25 passed in ~0.20s` (14 in `test_adversarial_pii.py` + 11 in `test_adversarial_numerical_stress.py`).

### Step 5: Run Backend Full Regression Suite
```bash
cd /Users/rufbook/aarogyam
backend/venv/bin/pytest backend/tests/ -v
```
**Expected Outcome**: `124 passed in ~0.25s` (0 failures, 0 errors).

---

## 7. Gate Milestone 1 Acceptance Criteria

A **CLEAN PASS** / **APPROVE** verdict for Milestone 1 Iteration 2 requires:
1. `backend/tests/test_adversarial_pii.py`: **14/14 tests pass** (0 failures).
2. `aarogyam-flutter/test/unit/edge_pii_adversarial_test.dart`: **16/16 tests pass** (0 failures).
3. `backend/tests/test_adversarial_numerical_stress.py`: **11/11 tests pass** (0 failures).
4. `aarogyam-flutter/test/unit/adversarial_numerical_stress_test.dart`: **11/11 tests pass** (0 failures).
5. All baseline suites (`test_pii_sanitizer.py`, `test_app.py`, `edge_pii_sanitizer_test.dart`, `fallback_e2e_test.dart`) continue to pass without regression.
6. Zero PII leakage across all 20 canonical parity test vectors.
7. Zero corruption of 11-digit or 12-digit pharmaceutical batch codes.
