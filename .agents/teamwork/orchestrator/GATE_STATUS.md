# Gate Status Tracking

## Gate — Milestone 1 (Edge Privacy & PII Sanitization Subsystem) - Iteration 1
| Agent | Role | Verdict | Source |
|-------|------|---------|--------|
| m1_worker | teamwork_preview_worker | DONE | handoff.md |
| m1_reviewer_1 | teamwork_preview_reviewer | REQUEST_CHANGES | handoff.md |
| m1_reviewer_2 | teamwork_preview_reviewer | APPROVE | handoff.md |
| m1_challenger_1 | teamwork_preview_challenger | REQUEST_CHANGES | handoff.md |
| m1_challenger_2 | teamwork_preview_challenger | REQUEST_CHANGES | handoff.md |
| m1_auditor | teamwork_preview_auditor | CLEAN | handoff.md |

Gate Result: **FAIL** (REQUEST_CHANGES on adversarial edge cases)

### Failure Feedback & Required Fixes:
1. **Adversarial Semicolon & Inline Delimiters**: In `_patientAnchorPattern` (Dart) and `PATIENT_HEADER_RE` (Python), add `;` and inline `उम्र`/`आयु` to lookaheads so demographics like `मरीज का नाम: सुरेश शर्मा; उम्र: ४५ वर्ष` do not leak patient names.
2. **Standalone Name Headers**: Support standalone `नाम -` and `नाव -` (and `नाम:` / `नाव:`) in both Dart and Python.
3. **Leading Boundary Anchor on Mobile Patterns**: Add negative lookbehind `(?<!\d)` in both Dart and Python to prevent trailing 10 digits of 11/12-digit batch codes or IDs starting with [6-9] from being falsely masked as phone numbers.
4. **Flexible Spaced Phone Matching in Dart**: Support 4+6, 3+3+4, and arbitrary spacing in 10-digit Indian numbers rather than strictly 5+5.
5. **Batch Keywords Parity**: Ensure `SN:`, `Item:`, `Rx#`, and vernacular `बैच`/`लॉट` are in both Dart and Python lookback patterns. Fix `rx#\b` word-boundary regex syntax.
6. **Devanagari Numerals**: Support Devanagari numerals in Aadhaar and phone patterns (or normalize Devanagari numerals `[०-९]` to `[0-9]` during preprocessing).
7. **Patient Name Substring Collision**: In Dart, avoid `fullMatch.replaceFirst(rawName, ...)` which replaces prefix words matching the name; use exact substring replacement.
