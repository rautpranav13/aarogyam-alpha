# Task Dispatch: Milestone 1 Challenger 1 (Numerical & Verhoeff Adversarial Testing)

## Context
You are Challenger 1 for Milestone 1 (M1: Edge Privacy & PII Sanitization Subsystem).

## Working Directory
/Users/rufbook/aarogyam/.agents/teamwork/m1_challenger_1

## Authoritative Inputs
- /Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md
- /Users/rufbook/aarogyam/PROJECT.md
- /Users/rufbook/aarogyam/.agents/teamwork/m1_worker/handoff.md
- Files to stress-test:
  * `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart`
  * `backend/app.py`

## Challenger Tasks
1. Empirically verify correctness and robustness through adversarial test generation.
2. Stress test the Verhoeff algorithm in both Dart and Python:
   - Adjacent transposition attacks (e.g. `ab` -> `ba`).
   - Twin errors (e.g. `aa` -> `bb`).
   - Jump transposition attacks (e.g. `abc` -> `cba`).
   - Boundary tests (000000000000, 111111111111, leading 0/1).
3. Stress test pharmaceutical batch collisions:
   - Construct adversarial texts with medicine batch numbers that happen to satisfy the Verhoeff checksum. Verify they are NOT masked due to contextual lookbacks (`Batch:`, `Lot:`, etc.).
4. Stress test phone number patterns:
   - 9-digit numbers, 11-digit numbers, fake mobile prefixes (1-5), spaced formats, international dialing codes.
5. Execute stress test scripts in `backend/venv/bin/python` and Dart.
6. Issue a clear verdict: **APPROVE** or **REQUEST_CHANGES** with full empirical evidence in your `handoff.md`.

## 2026-09-28T01:30:34Z
You are Challenger 1 for Milestone 1 (Numerical, Verhoeff & Phone Adversarial Testing).
Working directory: /Users/rufbook/aarogyam/.agents/teamwork/m1_challenger_1
Read DISPATCH.md at /Users/rufbook/aarogyam/.agents/teamwork/m1_challenger_1/DISPATCH.md, PROJECT.md, and the M1 Worker handoff at /Users/rufbook/aarogyam/.agents/teamwork/m1_worker/handoff.md.

Adversarially stress-test edge_pii_sanitizer.dart and backend/app.py:
- Verhoeff algorithm transposition, twin, jump transposition, and leading 0/1 attacks.
- Pharmaceutical batch collision attacks (synthesize 12-digit batch codes that pass Verhoeff and ensure they are preserved).
- Indian phone number edge cases.
Execute test scripts with python and dart.
Issue a clear verdict (APPROVE or REQUEST_CHANGES) with empirical evidence in handoff.md and notify orchestrator.
