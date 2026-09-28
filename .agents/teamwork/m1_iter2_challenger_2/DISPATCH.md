# Task Dispatch: Milestone 1 Iteration 2 Challenger 2 (Multilingual Name Verification)

## Context
You are Challenger 2 for Milestone 1 Iteration 2 Gate Verification.

## Working Directory
/Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_challenger_2

## Authoritative Inputs
- /Users/rufbook/aarogyam/PROJECT.md
- /Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_worker/handoff.md
- Files to stress-test:
  * `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart`
  * `backend/app.py`

## Challenger Tasks
1. Verify that semicolon delimiters (`;`) and inline `उम्र`/`आयु` do NOT cause patient names to leak.
2. Verify that standalone `नाम -` and `नाव -` headers are properly recognized and de-identified.
3. Verify that Devanagari numerals in Aadhaar and phone numbers are normalized and masked properly.
4. Execute empirical verification scripts in Dart and Python.
5. Issue a clear verdict: **APPROVE** or **REQUEST_CHANGES** in `handoff.md`.
