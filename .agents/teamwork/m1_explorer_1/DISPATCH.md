# Task Dispatch: Milestone 1 Explorer 1 - Flutter Edge PII Sanitizer Design

## Context
You are Explorer 1 for Milestone 1 (M1: Edge Privacy & PII Sanitization Subsystem).

## Working Directory
/Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_1

## Authoritative Inputs
- /Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md
- /Users/rufbook/aarogyam/PROJECT.md
- /Users/rufbook/aarogyam/.agents/teamwork/survey_spec_miner_privacy/spec_report.md
- Flutter codebase in `/Users/rufbook/aarogyam/aarogyam-flutter/`

## Objective
Analyze and formulate the exact implementation plan for the Dart edge PII sanitizer (`aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart`).

## Scope
1. Plan the exact Dart implementation of:
   - Verhoeff algorithm matrices ($d_{10\times10}, p_{8\times10}, inv_{10}$) for validating 12-digit Aadhaar numbers and partial masking to `XXXXXXXX1234`.
   - Indian mobile & landline phone number detection and masking.
   - Multilingual heuristic patient name de-identification (`[PATIENT-ANON-XXXX]`) with doctor/hospital exclusion filters.
   - SHA-256 pre/post cryptographic digest generation using `crypto` package (check if `crypto` is in `pubspec.yaml` or if pure Dart SHA-256 / SHA-1 can be used).
2. Recommend the exact class structure, method signatures, and unit tests in `test/unit/edge_pii_sanitizer_test.dart`.
3. Output your report to `/Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_1/report.md` and write `handoff.md`.

## 2026-09-28T01:05:25Z
You are Milestone 1 Explorer 1 (Flutter Edge PII Sanitizer).
Working directory: /Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_1
Read /Users/rufbook/aarogyam/.agents/teamwork/m1_explorer_1/DISPATCH.md, PROJECT.md, and /Users/rufbook/aarogyam/.agents/teamwork/survey_spec_miner_privacy/spec_report.md.
Investigate Flutter codebase and design the exact implementation for aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart and its unit test test/unit/edge_pii_sanitizer_test.dart.
Do NOT modify code. Output report.md and handoff.md, then notify orchestrator.
