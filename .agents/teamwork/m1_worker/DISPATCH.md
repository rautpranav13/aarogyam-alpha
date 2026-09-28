# Task Dispatch: Milestone 1 Worker - Edge Privacy & PII Sanitization Subsystem

## Context
You are the Worker implementing Milestone 1 (M1: Edge Privacy & PII Sanitization Subsystem) for Aarogyam.

## Working Directory
/Users/rufbook/aarogyam/.agents/teamwork/m1_worker

## Authoritative Inputs
- /Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md
- /Users/rufbook/aarogyam/PROJECT.md
- /Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_1/report.md (Flutter Edge PII design & drop-in code)
- /Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_2/report.md (Backend PII design & drop-in code)
- /Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_3/report.md (API integration & cross-platform parity)

## Exclusive File Ownership
You have exclusive write ownership of the following files:
1. `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart`
2. `aarogyam-flutter/lib/backend/api_requests/api_calls.dart` (adding `RedactPiiAPICall`)
3. `aarogyam-flutter/test/unit/edge_pii_sanitizer_test.dart`
4. `backend/app.py` (updating `mask_pii`, Verhoeff D5, batch code protection, name de-identification, SHA-256 manifest, `/api/redact-pii`)
5. `backend/tests/test_pii_sanitizer.py`

## Instructions & Tasks
1. Read the reports from M1 Explorers 1, 2, and 3.
2. Implement `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart` with:
   - Dihedral group D5 Verhoeff algorithm ($d, p, inv$ tables)
   - Aadhaar masking (`XXXXXXXX1234`) with batch code protection
   - Indian mobile & landline phone masking
   - Multilingual patient name de-identification (`[PATIENT-ANON-XXXX]`) preserving doctor/clinic credentials
   - Tamper-evident `SanitizationManifest` with SHA-256 pre/post digests
3. Implement `RedactPiiAPICall` in `aarogyam-flutter/lib/backend/api_requests/api_calls.dart`.
4. Create `aarogyam-flutter/test/unit/edge_pii_sanitizer_test.dart` with comprehensive test groups.
5. Implement backend updates in `backend/app.py` with cross-platform parity to the Dart implementation.
6. Create `backend/tests/test_pii_sanitizer.py` with 16 comprehensive unit tests.
7. Execute build & tests:
   - `cd /Users/rufbook/aarogyam/aarogyam-flutter && flutter test test/unit/edge_pii_sanitizer_test.dart`
   - `cd /Users/rufbook/aarogyam/aarogyam-flutter && flutter test`
   - `backend/venv/bin/pytest backend/tests/test_pii_sanitizer.py -v`
   - `backend/venv/bin/pytest backend/tests/ -v`
8. Document all test outputs, commands, and layout compliance in `handoff.md` and report to orchestrator.

## Mandatory Integrity Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
