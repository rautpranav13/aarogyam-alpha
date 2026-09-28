# Milestone 1 Iteration 2 Explorer 3 Handoff Report: Adversarial Parity & Test Harness

**Author**: Explorer 3 (`m1_iter2_explorer_3`)  
**Role**: Adversarial Parity & Test Harness Specialist  
**Working Directory**: `/Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_explorer_3`  
**Parent Orchestrator Conversation ID**: `debcb2f8-6c27-4400-9b21-9904a1a71bab`  
**Date**: 2026-09-28T01:43:00Z  

---

## 1. Observation

### 1.1 Direct Test Suite Execution Results
1. **Backend Adversarial Suites**:
   - Command: `backend/venv/bin/pytest backend/tests/test_adversarial_pii.py backend/tests/test_adversarial_numerical_stress.py -v`
   - Result: `2 failed, 23 passed in 0.24s`.
   - Verbatim Failures:
     * Failure 1:
       ```
       FAILED backend/tests/test_adversarial_pii.py::test_hindi_standalone_nam_hyphen_dispatch_case - AssertionError: CRITICAL: Raw patient name leaked in standalone 'नाम -' anchor: 'नाम - सुरेश शर्मा; उम्र: ४५ वर्ष'
       assert 'सुरेश शर्मा' not in 'नाम - सुरेश शर्मा; उम्र: ४५ वर्ष'
       ```
     * Failure 2:
       ```
       FAILED backend/tests/test_adversarial_pii.py::test_devanagari_numerals_aadhaar_and_phone - AssertionError: Devanagari phone leaked in: 'संपर्क: ९८७६५४३२१०'
       assert '९८७६५४३२१०' not in 'संपर्क: ९८७६५४३२१०'
       ```
   - Notice: `test_adversarial_numerical_stress.py` showed 11 PASSED, but inspection of lines 182-207, 209-228, and 257-271 revealed that 3 of these tests explicitly assert defective behavior:
     * Line 205: `assert phone_masked == 1, "Demonstrated phone cross-interference on batch code"`
     * Line 225-227: `assert m_sn["entities_masked"]["aadhaar"] == 1`
     * Line 269: `assert meta["entities_masked"]["phone"] == 1`

2. **Flutter Dart Adversarial Suites**:
   - Command: `flutter test test/unit/edge_pii_adversarial_test.dart test/unit/adversarial_numerical_stress_test.dart`
   - Result: `6 failed, 21 passed`.
   - Verbatim Failures in `edge_pii_adversarial_test.dart`:
     * Failure 1: `English variations` -> `'Pt. Name: Ramesh Kumar; Age: 54'` leaked `'Ramesh Kumar'` (missing `;` in lookahead).
     * Failure 2: `Hindi variations` -> `'मरीज का नाम: सुरेश शर्मा; उम्र: ४५'` leaked `'सुरेश शर्मा'` (missing `;` and `उम्र` in lookahead).
     * Failure 3: `Hindi standalone` -> `'नाम - सुरेश शर्मा; उम्र: ४५ वर्ष'` leaked `'सुरेश शर्मा'` (missing `नाम -` in anchor).
     * Failure 4: `Hindi age boundary` -> `'मरीज का नाम: सुरेश शर्मा उम्र: ४५ वर्ष'` failed exact token match (swallowed `उम्र` into name).
     * Failure 5: `Devanagari numerals` -> `'आधार: २३४५ ६७८९ ०१२४'` and `'संपर्क: ९८७६५४३२१०'` leaked unmasked.
     * Failure 6: `Marathi variations` -> `'रुग्णाचे नाव - आनंदी पाटील; वय: ४५'` leaked `'आनंदी पाटील'` (missing `;` in lookahead).
   - Notice: `adversarial_numerical_stress_test.dart` showed 11 PASSED, but inspection of lines 144-159, 161-171, 188-197, and 199-211 revealed that 4 of these tests assert defective behavior:
     * Line 157: `expect(result.entityCounts[PiiType.phone], equals(1));`
     * Line 169: `expect(result.entityCounts[PiiType.aadhaar], equals(1));`
     * Line 195: `expect(result.entityCounts[PiiType.phone], equals(1));`
     * Lines 203, 209: `expect(res4_6.entityCounts[PiiType.phone], equals(0));` (asserting 4+6 and 3+3+4 phone formats leak).

3. **Baseline Regression Suites**:
   - `backend/venv/bin/pytest backend/tests/test_pii_sanitizer.py backend/tests/test_app.py -v`: `34 passed in 0.17s`.
   - `flutter test test/unit/edge_pii_sanitizer_test.dart test/unit/fallback_e2e_test.dart`: `91 passed`.

---

## 2. Logic Chain

1. **Root Cause Analysis of Failing Security Contract Tests**:
   - In Observation 1.1 and 1.2, `test_adversarial_pii.py` and `edge_pii_adversarial_test.dart` fail because the regex patterns omit:
     * Semicolon `;` and inline `उम्र`/`आयु` in lookahead assertions.
     * Standalone `नाम -` and `नाव -` in anchor group prefixes.
     * Devanagari numerals `[०-९]` in phone and Aadhaar character sets.
   - When Explorer 1 and Explorer 2 apply their remediation code, these exact missing items are added to `edge_pii_sanitizer.dart` and `backend/app.py`. Therefore, these 8 failing tests will immediately turn GREEN.

2. **The Inversion Hazard in Numerical Stress Tests**:
   - As observed in Observation 1.1 and 1.2, Challenger 1 intentionally constructed tests in `test_adversarial_numerical_stress.py` and `adversarial_numerical_stress_test.dart` that assert the presence of bugs (asserting `phone == 1` on 12-digit batch numbers, asserting `aadhaar == 1` on `SN:`, asserting `phone == 0` on 4+6 spaced phones).
   - If only the source code files (`edge_pii_sanitizer.dart` and `backend/app.py`) are patched, the vulnerabilities are eliminated. Consequently:
     * Batch numbers will NOT be phone-masked (`phone == 0`), causing `assert phone_masked == 1` to FAIL.
     * `SN:`, `Item:`, and `Rx#` will NOT be Aadhaar-masked (`aadhaar == 0`), causing `assert m_sn["entities_masked"]["aadhaar"] == 1` to FAIL.
     * 11-digit numbers will NOT be suffix-masked (`phone == 0`), causing `assert meta["entities_masked"]["phone"] == 1` to FAIL.
     * 4+6 spaced phones will be masked (`phone == 1`), causing `expect(res4_6.entityCounts[PiiType.phone], equals(0))` to FAIL.
   - Therefore, to achieve 100% test pass rate, the test assertions in `test_adversarial_numerical_stress.py` and `adversarial_numerical_stress_test.dart` MUST be transitioned from "vulnerability demonstrator" mode to "hardened verification guard" mode.

3. **Cross-Platform Parity Assurance**:
   - By ensuring that both Dart and Python use the exact same tokenization format (`[PATIENT-ANON-XXXX]`), identical lookahead delimiters (`[;,|/\n\r]`, `उम्र`, `आयु`, `वय`), identical leading boundary lookbehind (`(?<!\d)`), identical keyword coverage (`SN:`, `Item:`, `Rx#`, `बैच`, `लॉट`), and Devanagari digit normalization, all 20 canonical parity test vectors produce identical de-identification outcomes.

---

## 3. Caveats

- **Read-Only Constraint Adhered To**: In accordance with the Explorer role specification, no production source code files (`edge_pii_sanitizer.dart`, `backend/app.py`) or test files were directly modified during this investigation.
- **Phone Mask Presentation**: Dart's default phone mask presentation is `PhoneMaskStyle.partial` (`+91-XXXXX-XX210` / `XXXXX-XX210`), whereas Python defaults to `[MASKED-PHONE-XXXX]`. Existing baseline tests in both languages explicitly rely on these defaults. This difference does not compromise privacy (both completely eliminate plaintext phone numbers) and should remain aligned with existing unit tests.

---

## 4. Conclusion

Milestone 1 Iteration 2 can achieve a **100% test pass rate across all 8 test suites** (59 backend tests and 118+ Flutter tests) with zero cross-platform divergence by executing two coordinated actions:
1. **Apply Source Fixes**: Implement the 7 remediation pillars in `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart` and `backend/app.py` as detailed in `report.md §3`.
2. **Transition Inverted Test Assertions**: Update the 3 tests in `backend/tests/test_adversarial_numerical_stress.py` and 4 tests in `aarogyam-flutter/test/unit/adversarial_numerical_stress_test.dart` to assert secure behavior instead of bug presence as detailed in `report.md §4`.

---

## 5. Verification Method

To independently verify the test integration and cross-platform plan once implemented:

### 1. Run Flutter Test Suites
```bash
cd /Users/rufbook/aarogyam/aarogyam-flutter
# 1. Adversarial suites (27 tests total)
flutter test test/unit/edge_pii_adversarial_test.dart test/unit/adversarial_numerical_stress_test.dart

# 2. Baseline regression suites (91 tests total)
flutter test test/unit/edge_pii_sanitizer_test.dart test/unit/fallback_e2e_test.dart

# 3. Full flutter regression
flutter test
```
*Expected Result*: All 27 adversarial tests pass; all 91 baseline tests pass; full suite passes (+216 tests).

### 2. Run Backend Python Test Suites
```bash
cd /Users/rufbook/aarogyam
# 1. Adversarial suites (25 tests total)
backend/venv/bin/pytest backend/tests/test_adversarial_pii.py backend/tests/test_adversarial_numerical_stress.py -v

# 2. Baseline regression suites (34 tests total)
backend/venv/bin/pytest backend/tests/test_pii_sanitizer.py backend/tests/test_app.py -v

# 3. Full backend regression
backend/venv/bin/pytest backend/tests/ -v
```
*Expected Result*: All 25 adversarial tests pass; all 34 baseline tests pass; full suite passes (124+ tests).

### 3. Invalidation Conditions
- Any test failure in `edge_pii_adversarial_test.dart` or `test_adversarial_pii.py`.
- Any test failure in `adversarial_numerical_stress_test.dart` or `test_adversarial_numerical_stress.py` due to stale bug assertions.
- Any regression in baseline test suites (`edge_pii_sanitizer_test.dart`, `fallback_e2e_test.dart`, `test_pii_sanitizer.py`).
- Raw patient name leaking under semicolon delimiter (`Pt. Name: Ramesh Kumar; Age: 54`).
- Raw patient name leaking under standalone header (`नाम - सुरेश शर्मा;`).
- 12-digit batch code (`9876 5432 1096`) or 11-digit identifier (`98765432101`) mutilated by phone regex.
