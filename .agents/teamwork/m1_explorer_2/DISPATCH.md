# Task Dispatch: Milestone 1 Explorer 2 - Backend PII Sanitizer & Manifest Verification Design

## Context
You are Explorer 2 for Milestone 1 (M1: Edge Privacy & PII Sanitization Subsystem).

## Working Directory
/Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_2

## Authoritative Inputs
- /Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md
- /Users/rufbook/aarogyam/PROJECT.md
- /Users/rufbook/aarogyam/.agents/teamwork/survey_spec_miner_privacy/spec_report.md
- Backend codebase in `/Users/rufbook/aarogyam/backend/`

## Objective
Analyze and formulate the exact implementation plan for upgrading `backend/app.py` PII sanitization.

## Scope
1. Plan the exact Python implementation in `backend/app.py`:
   - Upgrade `mask_pii(text: str)`:
     * Add Verhoeff D5 algorithm validation so only genuine 12-digit Aadhaar numbers are masked (preserving medicine batch codes like `1234-5678-9012`).
     * Mask Aadhaar to `XXXXXXXX1234` or `[MASKED-AADHAAR-XXXX]`.
     * Add phone number masking for Indian formats.
     * Add patient name de-identification heuristics with doctor/hospital exclusion filters (`[PATIENT-ANON-XXXX]`).
     * Return sanitization metadata & cryptographic SHA-256 proof manifest.
   - Update `POST /api/redact-pii` route to return the structured manifest and entity counts per `PROJECT.md § Interface Contracts`.
2. Recommend unit tests in `backend/tests/test_pii_sanitizer.py`.
3. Output your report to `/Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_2/report.md` and write `handoff.md`.

## 2026-09-28T01:05:25Z
You are Milestone 1 Explorer 2 (Backend PII Sanitizer).
Working directory: /Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_2
Read /Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_2/DISPATCH.md, PROJECT.md, and /Users/rufbook/aarogyam/.agents/teamwork/survey_spec_miner_privacy/spec_report.md.
Investigate backend codebase and design the exact implementation for backend/app.py (mask_pii, Verhoeff D5, batch code protection, patient names, SHA-256 manifest) and backend/tests/test_pii_sanitizer.py.
Do NOT modify code. Output report.md and handoff.md, then notify orchestrator.
