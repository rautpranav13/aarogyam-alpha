# Forensic Audit Report: Milestone 1 (Edge Privacy & PII Sanitization)

**Date**: 2026-09-28T01:34:00Z  
**Auditor**: Milestone 1 Forensic Auditor (`m1_auditor`)  
**Target Subsystem**: Milestone 1 (M1: Edge Privacy & PII Sanitization Subsystem)  
**Profile**: General Project  
**Integrity Mode**: Development (Investigated across Development, Demo, and Benchmark)  
**Final Binary Verdict**: **CLEAN**

---

## 1. Executive Summary

A comprehensive forensic audit and adversarial review was conducted on all Milestone 1 deliverables:
1. `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart`
2. `aarogyam-flutter/lib/backend/api_requests/api_calls.dart`
3. `aarogyam-flutter/test/unit/edge_pii_sanitizer_test.dart`
4. `backend/app.py`
5. `backend/tests/test_pii_sanitizer.py`

Every empirical check was executed independently. The implementation is authentic, employs genuine mathematical group theory tables for the Verhoeff algorithm ($D_5$ dihedral group), performs real-time dynamic SHA-256 cryptographic hashing, enforces strict negative lookback filters for pharmaceutical batch codes and doctor credentials, exhibits zero test circumvention, zero pre-populated artifacts, and 100% layout compliance.

---

## 2. Phase 1 — Mode-Agnostic Investigation (Observations)

| Forensic Check | Observation & Raw Evidence | Status |
|----------------|----------------------------|--------|
| **1. Hardcoded Output Detection** | Searched codebase for hardcoded test names (`Ramesh`), test tokens (`F188`, `8E96`), test Aadhaar numbers (`2345 6789 0124`), batch codes (`1234-5678-9012`). None found in source files (`edge_pii_sanitizer.dart`, `app.py`). All tokens and hashes are generated dynamically via `sha256(utf8.encode(input))` and regex transforms. | **CLEAN** |
| **2. Facade / Dummy Logic Detection** | Examined all classes and functions. `VerhoeffAlgorithm` implements full multiplication ($10 \times 10$), permutation ($8 \times 10$), and inverse tables. `mask_pii` and `EdgePiiSanitizer.sanitize` perform multi-stage regex replacements, context-distance calculations, and return populated model entities. No `return <constant>`, no empty functions, no placeholder stubs. | **CLEAN** |
| **3. Pre-populated Artifacts** | Scanned workspace with `find . -maxdepth 3 -name '*.log' -o -name '*result*' -o -name '*output*'`. Zero stale or pre-populated log or attestation files found. | **CLEAN** |
| **4. Test Circumvention** | Grepped test files for `assert True`, `skip`, `@pytest.mark.skip`, or trivial `expect(true, isTrue)`. Zero occurrences found. All 53 unit tests perform substantive string, integer, boolean, and cryptographic hash assertions. | **CLEAN** |
| **5. Layout Compliance** | Scanned `.agents/teamwork/` for non-markdown files (`find .agents/teamwork -type f ! -name '*.md'`). Found 0 files. Only markdown agent metadata is present. No source code, tests, or binary files were placed in `.agents/teamwork/`. | **CLEAN** |
| **6. Core Logic Delegation** | Verhoeff D5 algorithm, batch code protection, and multilingual de-identification rules are implemented natively in Dart and Python. Only standard cryptography packages (`crypto` in Dart, `hashlib` in Python) are used for SHA-256 hashing. Core PII sanitization is built from scratch without delegating to 3rd-party PII services. | **CLEAN** |

---

## 3. Phase 2 — Mode-Specific Flagging

Under **Development Mode** (as specified in `ORIGINAL_REQUEST.md`), the strictness rules require catching hardcoded test results, facade implementations, and fabricated outputs. Under all three modes (Development, Demo, Benchmark), all checks evaluated to **CLEAN**.

| Rule / Prohibited Pattern | Evaluation Under Development Mode | Result |
|---------------------------|-----------------------------------|--------|
| Hardcoded test results | No hardcoded outputs in implementation files | PASS |
| Facade / Dummy logic | Full algorithmic implementation present | PASS |
| Fabricated verification output | Tests run live; proofs generated dynamically | PASS |
| Test circumvention | Strict behavioral assertions throughout test suites | PASS |
| Layout violation | `.agents/teamwork/` strictly metadata only | PASS |

---

## 4. Independent Test Execution & Verification

### 4.1 Flutter Test Suite Execution
- **Command**: `flutter test test/unit/edge_pii_sanitizer_test.dart`
- **Result**: `00:01 +32: All tests passed!` (32/32 tests passed in 1 second)
- **Command**: `flutter test` (Full repository regression)
- **Result**: `00:10 +216: All tests passed!` (216/216 tests passed, 0 failures, 0 regressions)

### 4.2 Python Pytest Suite Execution
- **Command**: `backend/venv/bin/pytest backend/tests/test_pii_sanitizer.py -v`
- **Result**: `21 passed in 0.11s` (21/21 tests passed)
- **Command**: `backend/venv/bin/pytest backend/tests/ -v` (Full backend regression)
- **Result**: `111 passed in 0.19s` (111/111 tests passed, 0 failures across all 4 backend test suites)

---

## 5. Adversarial Stress-Testing & Attack Surface

An adversarial script was executed independently to stress-test corner cases:

1. **Dihedral Group D5 Leading Digits ($0..9$)**:
   - Tested 10 synthetic 12-digit numbers with generated Verhoeff check digits.
   - Result: Numbers starting with 0 or 1 were strictly rejected per UIDAI specification; numbers starting with 2..9 were correctly accepted. (PASS)
2. **Dual Context Collision (Batch Number + Aadhaar in same payload)**:
   - Input: `"Batch Number: 2345 6789 0124. Also Patient Aadhaar: 2345 6789 0124."`
   - Result: Batch number `2345 6789 0124` remained untouched while the patient Aadhaar was masked to `XXXXXXXX0124`. Entity count = 1. (PASS)
3. **Doctor Safeguard in Patient Field**:
   - Input: `"Patient Name: Dr. S. K. Gupta, MD"`
   - Result: Doctor credentials preserved untouched, entity count = 0. (PASS)
4. **Cryptographic SHA-256 Invariant**:
   - Pre-sanitization and post-sanitization digests matched independent `hashlib.sha256` computations. Zero PII present in proof metadata. (PASS)
5. **Cross-Platform Token Parity (V1-V10)**:
   - Verified that UTF-8 multilingual inputs produce byte-identical tokens in both Dart and Python:
     * English: `"Ramesh Kumar"` $\to$ `"[PATIENT-ANON-F188]"`
     * Hindi: `"सुरेश कुमार"` $\to$ `"[PATIENT-ANON-8E96]"`
     * Spaced Aadhaar: `"2345 6789 0124"` $\to$ `"XXXXXXXX0124"`
     * Mobile: `"+91 98765 43210"` $\to$ `"+91-XXXXX-XX210"`

---

## 6. Final Verdict

**VERDICT**: **CLEAN**

The Milestone 1 work product satisfies all integrity standards, architectural requirements, and interface contracts without defects or shortcuts. Milestone 1 is verified for sign-off.
