# Milestone 1 Challenger 1 Handoff Report: Numerical, Verhoeff & Phone Adversarial Testing

**Author**: Milestone 1 Challenger 1 (`m1_challenger_1`)  
**Date**: 2026-09-28T01:37:00Z  
**Verdict**: **REQUEST_CHANGES**  
**Assigned Subsystem**: Milestone 1 (M1: Edge Privacy & PII Sanitization Subsystem)  
**Parent Orchestrator Conversation ID**: `debcb2f8-6c27-4400-9b21-9904a1a71bab`  

---

## 1. Observation

### 1.1 Verhoeff D5 Algorithm Mathematical Integrity
1. **Adjacent Digit Transposition**:
   - Tested 19,805 adjacent digit transpositions across authentic 12-digit Aadhaar candidates.
   - Command: `backend/venv/bin/pytest backend/tests/test_adversarial_numerical_stress.py::test_verhoeff_adjacent_transpositions_100pct_detection -v`
   - Result: 0 missed transpositions out of 19,805. **Detection rate: 100.00%**.
2. **Twin Errors ($aa \to bb$)**:
   - Command: `backend/venv/bin/pytest backend/tests/test_adversarial_numerical_stress.py::test_verhoeff_twin_errors_empirical_rate -v`
   - Result: Python detected **95.41%** (18,849 / 19,755); Dart detected **97.53%** (79 / 81). This empirically matches the theoretical properties of the non-abelian dihedral group $D_5$.
3. **Jump Transposition Errors ($abc \to cba$)**:
   - Command: `backend/venv/bin/pytest backend/tests/test_adversarial_numerical_stress.py::test_verhoeff_jump_transpositions_empirical_rate -v`
   - Result: Python detected **94.62%** (17,035 / 18,003); Dart detected **100.00%** across sample.
4. **Boundary and Repdigit Inputs**:
   - `validate_verhoeff("000000000000")` -> `False`
   - `validate_verhoeff("111111111111")` -> `False`
   - `validate_verhoeff("012345678901")` -> `False`
   - Repdigit checksum invariance: `333333333333`, `666666666666`, and `999999999999` mathematically satisfy the $D_5$ checksum equation $c = 0$.

---

### 1.2 Empirical Defect Observations

#### Defect 1 (CRITICAL): Missing Leading Boundary on Mobile Regex Mutilates 11-digit Identifiers and 12-digit Batch Numbers
- **Code Location**:
  * Python: `backend/app.py:175-177`
    ```python
    MOBILE_PATTERN_RE = re.compile(
        r"(?:\+91[\-\s]?|0091[\-\s]?|\b91[\-\s]|\b0)?(?:\(0\)\s*)?([6-9](?:[\-\s]?\d){9})\b"
    )
    ```
  * Dart: `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:263-265`
    ```dart
    static final RegExp _mobilePattern = RegExp(
      r'(?:(?:\+91|0091|91|0)[\s\-]?)?(?:(?:\(0\)\s*))?([6-9]\d{4}[\s\-]?\d{5})\b',
    );
    ```
- **Observed Behavior**:
  * Because the optional prefix group `(?:\+91...)?` is not anchored with a preceding `\b` or negative lookbehind `(?<!\d)`, the mandatory capture `([6-9]...)` matches inside any longer sequence of digits whenever digit 2 or digit 3 falls in `[6, 7, 8, 9]`.
  * Verbatim execution command:
    ```bash
    PYTHONPATH=backend backend/venv/bin/python -c '
    from app import mask_pii
    print(mask_pii("Rx: Amoxicillin 500mg, Batch No: 9876 5432 1096, Exp: 12/2027")[0])
    print(mask_pii("Transaction Ref: 98765432101")[0])
    '
    ```
  * Verbatim execution output:
    ```
    Rx: Amoxicillin 500mg, Batch No: 98[MASKED-PHONE-XXXX], Exp: 12/2027
    Transaction Ref: 9[MASKED-PHONE-XXXX]
    ```
  * In Dart:
    ```
    Dart Batch Cross-Interference: Medication: Paracetamol, Batch: 98XXXXX-XX096 (Phone count: 1)
    Dart 11-digit test: Transaction Ref: 9XXXXX-XX101 (Phone count: 1)
    ```
  * **Blast Radius**: Approximately 40% of all 12-digit pharmaceutical batch numbers (any code where the 3rd digit is 6, 7, 8, or 9) have their trailing 10 digits mutilated as a mobile phone number, destroying batch traceability. In addition, 11-digit order IDs and reference numbers are corrupted with dangling leading digits.

---

#### Defect 2 (HIGH): Non-Standard Spaced Indian Phone Numbers Leaked in Dart
- **Code Location**:
  * Dart: `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:263-265`
    `([6-9]\d{4}[\s\-]?\d{5})\b`
  * Python: `backend/app.py:175-177`
    `([6-9](?:[\-\s]?\d){9})\b`
- **Observed Behavior**:
  * Dart enforces an exact 5+5 digit split (`\d{4}` after `[6-9]`), completely missing common 4+6, 3+3+4, or pairwise grouped phone numbers.
  * Verbatim test output from `aarogyam-flutter/test/unit/adversarial_numerical_stress_test.dart`:
    ```
    4+6 format: "Call 9876 543210 immediately", phone count: 0 (LEAKED)
    3+3+4 format: "Call 987 654 3210 immediately", phone count: 0 (LEAKED)
    Pairwise format: "Call 98-76-54-32-10 immediately", phone count: 0 (LEAKED)
    ```
  * In Python, all three formats are correctly masked.
  * **Blast Radius**: Direct raw PII leakage from the edge client to cloud payloads, violating DPDP Act 2023 Sec 8 and ABDM guidelines.

---

#### Defect 3 (HIGH): Supply Chain Keywords Missing in Python Backend (`SN:`, `Item:`, `Rx#`)
- **Code Location**:
  * Python `backend/app.py:159-161`:
    ```python
    BATCH_LABEL_RE = re.compile(
        r"(?i)\b(?:batch(?:\s*(?:no|num|number))?|b\.?\s*no\.?|lot(?:\s*(?:no|num|number))?|exp(?:\.?|iry)?|mfg|mfd|gtin|barcode|inv(?:oice)?)\b"
    )
    ```
  * Dart `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart:257-260`:
    Contains `sn`, `serial`, `item`, `rx#`.
- **Observed Behavior**:
  * Verbatim execution command:
    ```bash
    PYTHONPATH=backend backend/venv/bin/python -c '
    from app import mask_pii
    for t in ["Medication: SN: 2345 6789 0124", "Prescription: Item: 2345 6789 0124", "Pharmacy: Rx# 2345 6789 0124"]:
        print(t, "->", mask_pii(t)[0])
    '
    ```
  * Verbatim execution output:
    ```
    Medication: SN: 2345 6789 0124 -> Medication: SN: [MASKED-AADHAAR-XXXX]
    Prescription: Item: 2345 6789 0124 -> Prescription: Item: [MASKED-AADHAAR-XXXX]
    Pharmacy: Rx# 2345 6789 0124 -> Pharmacy: Rx# [MASKED-AADHAAR-XXXX]
    ```
  * **Blast Radius**: Cross-platform divergence where Dart protects SN and Item, but Python wipes them as Aadhaar.

---

#### Defect 4 (MEDIUM): Regex Syntax Word-Boundary Defect on `rx#` in Dart
- **Code Location**:
  * Dart `edge_pii_sanitizer.dart:258`:
    `r'\b(batch(?:\s*no\.?|\s*#)?|lot(?:\s*no\.?)?|exp(?:\.|\s*date)?|expiry|mfg(?:\.|\s*date)?|barcode|gtin|invoice|sn|serial(?:\s*no\.?)?|item|rx#)\b'`
- **Observed Behavior**:
  * `#` is a non-word character `\W`. In `rx#)\b`, the trailing `\b` asserts a transition to a word character `\w`. When followed by a space, colon, or newline (all `\W`), `\b` fails.
  * Verbatim execution:
    ```
    Pharmacy: Rx# 2345 6789 0124 -> Pharmacy: Rx# XXXXXXXX0124 (Aadhaar count: 1)
    ```
  * **Blast Radius**: `Rx#` is completely inoperative as a pharmaceutical batch safeguard in Dart.

---

#### Defect 5 (MEDIUM): Missing Vernacular Batch Labels in Hindi and Marathi
- **Code Location**:
  * Neither Python `BATCH_LABEL_RE` nor Dart `_pharmaContextPattern` includes Hindi or Marathi batch terms (`बैच`, `लॉट`, `कालबाह्य`, `घटक`).
- **Observed Behavior**:
  * `दवा: पैरासिटामोल, बैच नं: 2345 6789 0124` -> `दवा: पैरासिटामोल, बैच नं: [MASKED-AADHAAR-XXXX]`
  * `औषध: अमोक्सिसिलिन, लॉट क्र: 2345 6789 0124` -> `औषध: अमोक्सिसिलिन, लॉट क्र: [MASKED-AADHAAR-XXXX]`
  * **Blast Radius**: Any vernacular prescription scan containing a batch number passing Verhoeff is wrongly redacted.

---

#### Defect 6 (MEDIUM): Divergent Default Phone Masking Presentation Breaks Cross-Platform Hash Determinism
- **Code Location**:
  * Python `backend/app.py:353-359`: Phone numbers are always masked to `[MASKED-PHONE-XXXX]`.
  * Dart `edge_pii_sanitizer.dart:322-330`: Default `phoneMaskStyle` is `PhoneMaskStyle.partial` (`+91-XXXXX-XX210`).
- **Observed Behavior**:
  * In Canonical Vector V10:
    Dart sanitized: `+91-XXXXX-XX210`
    Python sanitized: `[MASKED-PHONE-XXXX]`
  * The SHA-256 `sanitized_payload_sha256` generated by the Flutter edge client differs completely from the SHA-256 hash computed on the backend for identical inputs.

---

## 2. Logic Chain

1. **Verhoeff Mathematical Foundation**:
   - Observations 1.1.1 through 1.1.4 prove that both engines faithfully implement the Dihedral Group $D_5$ Cayley tables. The 100% detection rate on adjacent transpositions and ~95% detection rates on twins and jump transpositions conform strictly to cryptographic specifications.
2. **From Observation 1.2 (Defect 1) to Batch Corruption**:
   - The edge sanitizer executes sequentially: Aadhaar masking (Step 4) followed by Phone masking (Step 5).
   - In Step 4, contextual lookback correctly identifies `Batch:` and suppresses Aadhaar masking.
   - However, Step 5's regex lacks a leading boundary anchor `(?<!\d)` or `(?<=\s|^|[^\d])`.
   - When encountering a 12-digit number (e.g. `987654321096`), the engine skips the first 2 digits, identifies a 10-digit substring `7654321096` starting with 7, matches the trailing `\b`, and replaces it with `[MASKED-PHONE-XXXX]` (Python) or `XXXXX-XX096` (Dart).
   - Therefore, the pharmaceutical batch safeguard is completely bypassed by the downstream phone sanitizer.
3. **From Observation 1.2 (Defect 2) to PII Leakage**:
   - Dart's phone regex `([6-9]\d{4}[\s\-]?\d{5})\b` cannot match strings with arbitrary internal delimiters.
   - Indian mobile numbers commonly appear as `9876 543210` or `987 654 3210`.
   - These numbers pass through Dart unmasked, leaking personal mobile numbers into the outbound payload.
4. **From Observations 1.2 (Defects 3-6) to Contract & Parity Failure**:
   - Discrepancies between Python's `BATCH_LABEL_RE` and Dart's `_pharmaContextPattern` cause identical inputs (`SN:`, `Item:`, `Rx#`) to produce conflicting redactions.
   - The regex bug on `rx#)\b` renders the token dead.
   - Differing default phone representations prevent cryptographic manifest verification between edge client and backend.

---

## 3. Caveats

- **WatsonX Granite Vision 3.2 2B**: Cloud vision inference was not tested directly; all tests evaluated the local edge de-identification engine and backend sanitization endpoints as defined in Milestone 1 scope.
- No other caveats.

---

## 4. Conclusion

**Verdict**: **REQUEST_CHANGES**

While the core mathematical tables for Verhoeff $D_5$ are flawlessly implemented and achieve 100% detection on adjacent transpositions, Milestone 1 cannot be approved due to critical operational defects:
1. **Critical Batch Corruption**: Downstream phone regex destroys ~40% of 12-digit pharmaceutical batch numbers and mutates 11-digit identifiers.
2. **Critical Edge PII Leakage**: Dart fails to mask 4+6 and 3+3+4 spaced Indian phone numbers, allowing raw phone numbers to be dispatched to cloud endpoints.
3. **Keyword Parity & Regex Defect**: Python misses `SN:`, `Item:`, and `Rx#`, while Dart's `rx#)\b` regex contains a fatal word boundary bug.
4. **Manifest Divergence**: Divergent default phone masking styles break SHA-256 audit proof equivalence between edge and cloud.

### Concrete Remediation Actions Required for Worker:
1. **Fix Phone Regex Boundary (Python & Dart)**:
   Add a negative lookbehind `(?<!\d)` to ensure mobile numbers do not match suffixes of longer digit strings:
   - Python: `r"(?<!\d)(?:(?:\+91[\-\s]?|0091[\-\s]?|\b91[\-\s]|\b0)?(?:\(0\)\s*)?)([6-9](?:[\-\s]?\d){9})(?!\d)"`
   - Dart: `RegExp(r'(?<!\d)(?:(?:\+91|0091|91|0)[\s\-]?)?(?:(?:\(0\)\s*))?([6-9](?:[\s\-]?\d){9})(?!\d)')`
2. **Support Arbitrary Spacing in Dart Phone Regex**:
   Update Dart's mobile pattern from `([6-9]\d{4}[\s\-]?\d{5})` to `([6-9](?:[\s\-]?\d){9})`, matching Python's flexible delimiter capability.
3. **Synchronize Batch Keywords**:
   - Add `sn`, `serial`, `item`, and `rx` to Python's `BATCH_LABEL_RE`.
   - Fix Dart's `rx#` pattern to avoid `\b` after `#`: `r'\b(?:batch(?:\s*no\.?|\s*#)?|lot(?:\s*no\.?)?|exp(?:\.|\s*date)?|expiry|mfg(?:\.|\s*date)?|barcode|gtin|invoice|sn|serial(?:\s*no\.?)?|item)\b|rx#'`.
   - Add Devanagari keywords (`बैच`, `लॉट`, `कालबाह्य`, `घटक`) to both engines.
4. **Align Default Phone Masking Presentation**:
   Align default phone masking format between Python and Dart (either both tokenized `[MASKED-PHONE-XXXX]` or both partial `+91-XXXXX-XX210`).

---

## 5. Verification Method

To independently reproduce all empirical findings:

1. **Execute Python Adversarial Numerical & Phone Test Suite**:
   ```bash
   cd /Users/rufbook/aarogyam
   backend/venv/bin/pytest backend/tests/test_adversarial_numerical_stress.py -v -s
   ```
   *Expected outcome*: 11/11 tests pass, documenting the empirical presence of phone cross-interference on batch codes, 11-digit suffix capture, and missing Python batch keywords.

2. **Execute Dart Adversarial Numerical & Phone Test Suite**:
   ```bash
   cd /Users/rufbook/aarogyam/aarogyam-flutter
   flutter test test/unit/adversarial_numerical_stress_test.dart
   ```
   *Expected outcome*: 11/11 tests pass, empirically demonstrating Dart's 4+6 phone leakage, Rx# word-boundary failure, 11-digit boundary defect, and batch code phone cross-interference.

3. **Invalidation Conditions**:
   - When phone regexes are anchored with `(?<!\d)` and `(?!\d)`, `Batch: 987654321096` and `Ref: 98765432101` will remain uncorrupted.
   - When Dart supports `(?:[\s\-]?\d){9}`, `Call 9876 543210` will be masked without raw PII leakage.
