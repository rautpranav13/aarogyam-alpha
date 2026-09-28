# Task Dispatch: M1 Iteration 2 Explorer 2 - Backend Python Remediation

## Context
You are Explorer 2 for Milestone 1 Iteration 2 remediation.

## Working Directory
/Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_explorer_2

## Authoritative Inputs
- /Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md
- /Users/rufbook/aarogyam/PROJECT.md
- /Users/rufbook/aarogyam/.agents/teamwork/orchestrator/GATE_STATUS.md
- Feedback reports:
  * `/Users/rufbook/aarogyam/.agents/teamwork/m1_reviewer_1/handoff.md`
  * `/Users/rufbook/aarogyam/.agents/teamwork/m1_challenger_1/handoff.md`
  * `/Users/rufbook/aarogyam/.agents/teamwork/m1_challenger_2/handoff.md`
- Target file: `backend/app.py`

## Objective
Design the exact drop-in remediation code for `backend/app.py` addressing:
1. Adding `;` and inline `उम्र`/`आयु` to lookaheads in `PATIENT_HEADER_RE`.
2. Supporting standalone `नाम` and `नाव` anchors.
3. Adding `(?<!\d)` leading lookbehind to `MOBILE_PATTERN_RE`.
4. Adding `SN:`, `Item:`, `Rx#`, and vernacular `बैच`/`लॉट` to `BATCH_LABEL_RE`.
5. Supporting Devanagari numerals.

Output your report to `report.md` and write `handoff.md`.

## 2026-09-28T01:42:00Z
You are M1 Iteration 2 Explorer 2 (Backend Python Remediation).
Working directory: /Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_explorer_2
Read /Users/rufbook/aarogyam/.agents/teamwork/m1_iter2_explorer_2/DISPATCH.md, PROJECT.md, and the feedback handoff reports at:
- /Users/rufbook/aarogyam/.agents/teamwork/m1_reviewer_1/handoff.md
- /Users/rufbook/aarogyam/.agents/teamwork/m1_challenger_1/handoff.md
- /Users/rufbook/aarogyam/.agents/teamwork/m1_challenger_2/handoff.md

Design the exact remediation code for backend/app.py to resolve:
1. Semicolon and inline age in PATIENT_HEADER_RE.
2. Standalone नाम and नाव anchors.
3. Leading lookbehind (?<!\d) on MOBILE_PATTERN_RE.
4. Add SN:, Item:, Rx#, and vernacular batch keywords to BATCH_LABEL_RE.
5. Devanagari numerals support.

Write report.md and handoff.md, then notify orchestrator. Do not edit source files directly.
