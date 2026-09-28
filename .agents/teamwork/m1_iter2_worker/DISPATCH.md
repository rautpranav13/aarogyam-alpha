# Task Dispatch: Milestone 1 Iteration 2 Worker - Adversarial Remediation

## Context
You are the Milestone 1 Iteration 2 Worker for Aarogyam.

## Working Directory
/Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_worker

## Authoritative Inputs
- /Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md
- /Users/rufbook/aarogyam/PROJECT.md
- /Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_explorer_1/report.md (Dart drop-in remediation)
- /Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_explorer_2/report.md (Backend drop-in remediation)
- /Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_explorer_3/report.md (Test harness parity updates)

## Exclusive File Ownership
1. `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart`
2. `backend/app.py`
3. `aarogyam-flutter/test/unit/adversarial_numerical_stress_test.dart`
4. `backend/tests/test_adversarial_numerical_stress.py`
5. `aarogyam-flutter/test/unit/edge_pii_adversarial_test.dart`
6. `backend/tests/test_adversarial_pii.py`

## Instructions & Tasks
1. Read the reports from M1 Iteration 2 Explorers 1, 2, and 3.
2. Apply the drop-in remediation blocks to `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart` from Explorer 1's report:
   - Semicolon `;` and inline `उम्र`/`आयु` in lookaheads
   - Standalone `नाम -` and `नाव -` headers
   - Leading `(?<![0-9\u0966-\u096F])` and trailing `(?![0-9\u0966-\u096F])` lookarounds on mobile patterns
   - Flexible spacing in 10-digit Indian numbers
   - Fix `rx#\b` syntax to `rx(?:\s*#)?\b` and add vernacular batch keywords
   - Support Devanagari numerals
   - Exact substring index replacement
3. Apply the drop-in remediation blocks to `backend/app.py` from Explorer 2's report:
   - Match all 7 regex updates with complete cross-platform parity.
4. Update the adversarial test assertions per Explorer 3's report in:
   - `aarogyam-flutter/test/unit/adversarial_numerical_stress_test.dart`
   - `backend/tests/test_adversarial_numerical_stress.py`
5. Run tests:
   - `cd /Users/rufbook/aarogyam/aarogyam-flutter && flutter test test/unit/edge_pii_adversarial_test.dart`
   - `cd /Users/rufbook/aarogyam/aarogyam-flutter && flutter test test/unit/adversarial_numerical_stress_test.dart`
   - `cd /Users/rufbook/aarogyam/aarogyam-flutter && flutter test`
   - `backend/venv/bin/pytest backend/tests/test_adversarial_pii.py -v`
   - `backend/venv/bin/pytest backend/tests/test_adversarial_numerical_stress.py -v`
   - `backend/venv/bin/pytest backend/tests/ -v`
6. Write `handoff.md` and report to orchestrator.

## Mandatory Integrity Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
