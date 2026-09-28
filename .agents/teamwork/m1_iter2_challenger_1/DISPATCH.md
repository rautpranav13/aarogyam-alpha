# Task Dispatch: Milestone 1 Iteration 2 Challenger 1 (Numerical & Batch Verification)

## Context
You are Challenger 1 for Milestone 1 Iteration 2 Gate Verification.

## Working Directory
/Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_challenger_1

## Authoritative Inputs
- /Users/rufbook/aarogyam/PROJECT.md
- /Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_worker/handoff.md
- Files to stress-test:
  * `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart`
  * `backend/app.py`

## Challenger Tasks
1. Verify that 11-digit IDs (`Ref: 98765432101`) and 12-digit batch codes (`987654321096`) starting with [6-9] are NO LONGER mutilated as mobile phones.
2. Verify that `Rx# 2345 6789 0124` is preserved and NOT masked as Aadhaar.
3. Verify that non-standard spaced mobile numbers (4+6, 3+3+4) are properly masked.
4. Execute empirical verification scripts in Dart and Python.
5. Issue a clear verdict: **APPROVE** or **REQUEST_CHANGES** in `handoff.md`.
