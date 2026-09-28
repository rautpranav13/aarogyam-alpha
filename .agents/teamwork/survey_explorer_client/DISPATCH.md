# Task Dispatch: Survey Explorer - Flutter Client Architecture

## Context
You are Survey Explorer 1 investigating the Aarogyam Flutter client for the end-to-end fallback mechanism to IBM Granite Vision / WatsonX.

## Working Directory
/Users/rufbook/aarogyam/.agents/teamwork/survey_explorer_client

## Authoritative Inputs
- /Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md
- Flutter project files under `/Users/rufbook/aarogyam/lib/` and `/Users/rufbook/aarogyam/test/`

## Objective
Map the current on-device ML Kit OCR, camera scanning flows, blister foil verification, fallback trigger conditions, local storage mechanisms, schedule/reminder UI, and safety alert indicators.

## Scope & Instructions
1. Read `/Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md`.
2. Inspect the codebase (e.g. using graphify if available, ripgrep, or file inspection) to identify:
   - Existing ML Kit OCR implementation for doctor prescriptions.
   - Existing blister strip / medicine foil scanning & verification logic.
   - Confidence scoring, failure detection, error handling, and thresholding mechanisms.
   - HTTP networking / backend client services currently used for API calls.
   - Local storage mechanisms (e.g. Hive, SQLite, SharedPreferences, Isar) for medication schedules.
   - UI views for schedule, reminders, blister verification safety indicators, vernacular audio/TTS announcements.
   - Existing Flutter tests and test harness setup (`flutter test`).
3. Identify all architectural gap points required to fulfill R1, R2, R3, R4 on the Flutter client.
4. Output a comprehensive survey report to `/Users/rufbook/aarogyam/.agents/teamwork/survey_explorer_client/survey_report.md` and write `handoff.md`.
5. Send a message to orchestrator upon completion.

## 2026-09-28T00:57:33Z
You are the Client Architecture Explorer.
Working directory: /Users/rufbook/aarogyam/.agents/teamwork/survey_explorer_client
Read your task dispatch at /Users/rufbook/aarogyam/.agents/teamwork/survey_explorer_client/DISPATCH.md and the original user request at /Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md.

Investigate the Flutter codebase (lib/, test/, pubspec.yaml) to map:
1. Current ML Kit OCR for doctor prescriptions and blister strip scanning.
2. Failure detection, confidence thresholds, error handling for OCR and blister verification.
3. Network / HTTP client services for communicating with backend vision APIs.
4. Local storage mechanisms (Hive, SQLite, SharedPreferences) and data models for medication schedules.
5. UI views for medication schedules, reminders, blister verification safety indicators, vernacular audio/TTS announcements.
6. Existing Flutter tests and test harness setup (`flutter test`).

Do NOT modify any code. Output your complete survey report to /Users/rufbook/aarogyam/.agents/teamwork/survey_explorer_client/survey_report.md and write handoff.md in your working directory. Send a message to orchestrator when finished.
