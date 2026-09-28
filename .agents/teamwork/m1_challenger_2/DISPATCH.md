# Task Dispatch: Milestone 1 Challenger 2 (Multilingual Name & Manifest Tamper Testing)

## Context
You are Challenger 2 for Milestone 1 (M1: Edge Privacy & PII Sanitization Subsystem).

## Working Directory
/Users/rufbook/aarogyam/.agents/teamwork/m1_challenger_2

## Authoritative Inputs
- /Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md
- /Users/rufbook/aarogyam/PROJECT.md
- /Users/rufbook/aarogyam/.agents/teamwork/m1_worker/handoff.md
- Files to stress-test:
  * `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart`
  * `backend/app.py`

## Challenger Tasks
1. Empirically verify correctness and robustness through adversarial test generation.
2. Stress test multilingual patient de-identification across English, Hindi, and Marathi:
   - Varied punctuation and line-breaks (`Patient: Ramesh Kumar\n`, `नाम - सुरेश शर्मा;`).
   - Doctor credentials protection (`Dr. A. K. Gupta, MD (AIIMS)` vs `Patient: Ramesh Gupta`). Verify Dr. is never masked.
   - Devanagari numerals and script variations.
   - Deterministic pseudonym calculation across Dart and Python.
3. Stress test cryptographic proof manifests:
   - Tamper simulation: mutate a single character in sanitized text and recalculate SHA-256 to ensure mismatch is detected.
   - Empty input handling, massive input handling (100KB prescription text).
4. Execute stress test scripts in `backend/venv/bin/python` and Dart.
5. Issue a clear verdict: **APPROVE** or **REQUEST_CHANGES** with full empirical evidence in your `handoff.md`.
