# Task Dispatch: E2E Testing Track Writer

## Context
You are the E2E Test Writer responsible for designing and creating the comprehensive, opaque-box test suite for the Aarogyam IBM Granite Vision / WatsonX fallback mechanism.

## Working Directory
/Users/rufbook/aarogyam/.agents/teamwork/e2e_test_writer

## Authoritative Inputs
- /Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md
- /Users/rufbook/aarogyam/PROJECT.md
- /Users/rufbook/aarogyam/.agents/teamwork/survey_spec_miner_privacy/spec_report.md

## Objective
Design the test architecture, write `TEST_INFRA.md`, implement comprehensive Tier 1-4 test suites in Flutter and Python, and publish `TEST_READY.md`.

## Methodology & Tiers
1. **Tier 1 - Feature Coverage (>=5 per feature)**:
   - F1 & F2: Prescription failure detection & vision model dispatch
   - F3 & F4: Blister foil inconclusive detection & cloud escalation
   - F5: Network timeout / error recovery & offline fallback
   - F6 & F7: Aadhaar (Verhoeff D5) and phone number masking
   - F8 & F9: Patient name de-identification & SHA-256 proof manifest
   - F10 & F11: Structured medication schedule extraction & storage sync
   - F12: Blister safety verdicts & vernacular audio alert generation
2. **Tier 2 - Boundary & Corner Cases (>=5 per feature)**:
   - Edge cases: 0 chars OCR, exactly 14 chars (boundary for <15), 15 chars, invalid Verhoeff checksums, medicine batch numbers formatted like Aadhaar (e.g. `1234-5678-9012`), 9-digit vs 10-digit phones, expired vs unexpired blister dates (e.g. `EXP 01/2020` vs `EXP 12/2030`), network socket timeouts (simulate 0.1s timeout).
3. **Tier 3 - Cross-Feature Combinations (Pairwise)**:
   - OCR failure + PII masking + cloud dispatch
   - Inconclusive blister + network timeout + local fallback
   - Tampered PII manifest + backend verification
   - Expired medication + vernacular TTS alert + schedule block
4. **Tier 4 - Real-World Application Scenarios (>=5 scenarios)**:
   - Scenario 1: Illegible handwritten prescription with patient PII (Ramesh Kumar, Aadhaar 2345-6789-0124) digitized into morning/night schedule.
   - Scenario 2: Torn/blurry blister pack with expired date (EXP 03/2024) blocked with vernacular alert.
   - Scenario 3: Complete offline mode during remote village clinic visit gracefully falling back with visual warning.
   - Scenario 4: Valid prescription + legitimate medicine batch code preserved without false redaction.
   - Scenario 5: Multi-drug prescription with complex 24-hr timings and food relations.

## File Outputs
- Write `/Users/rufbook/aarogyam/TEST_INFRA.md`
- Write tests to:
  - `backend/tests/test_e2e_fallback.py`
  - `aarogyam-flutter/test/unit/fallback_e2e_test.dart`
- Publish `/Users/rufbook/aarogyam/TEST_READY.md`
- Write `handoff.md` and report to orchestrator.

## 2026-09-28T01:05:25Z
You are the E2E Test Writer for Aarogyam Dual Track testing.
Working directory: /Users/rufbook/aarogyam/.agents/teamwork/e2e_test_writer
Read your task dispatch at /Users/rufbook/aarogyam/.agents/teamwork/e2e_test_writer/DISPATCH.md, PROJECT.md, and ORIGINAL_REQUEST.md.

Design and implement comprehensive opaque-box test suites (Tiers 1-4) in:
- backend/tests/test_e2e_fallback.py
- aarogyam-flutter/test/unit/fallback_e2e_test.dart
Create /Users/rufbook/aarogyam/TEST_INFRA.md and publish /Users/rufbook/aarogyam/TEST_READY.md when test infrastructure is ready.
Do NOT modify application implementation source code. Only write tests and documentation.
Write handoff.md and notify orchestrator when done.
