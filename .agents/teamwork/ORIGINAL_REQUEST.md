# Original User Request

## 2026-09-28T00:56:08Z

Implement an end-to-end fallback mechanism across the Aarogyam Flutter client and backend that dispatches images to the cloud Vision Model (IBM Granite Vision / WatsonX) whenever on-device processing fails or yields low confidence, returning structured results back to the device.

Working directory: /Users/rufbook/aarogyam
Integrity mode: development

## Requirements

### R1. On-Device Failure Detection & Cloud Vision Model Dispatch
When on-device text recognition (Google ML Kit) or foil verification fails, encounters errors, or produces low-confidence/incomplete results (for both doctor prescriptions and medicine blister foils), the system must automatically capture and dispatch the image payload to the backend vision endpoint.

### R2. Edge Privacy & PII Sanitization
Before dispatching image or text payloads to the cloud vision model, apply de-identification/masking to sensitive personal identifiers (Aadhaar, phone numbers, patient names) where applicable, maintaining compliance and returning verification proofs.

### R3. Structured Response Processing & Client Synchronization
The backend vision model must parse handwritten prescriptions into structured medication schedules (names, strengths, frequencies, food relations, 24-hr timings) and blister foil verifications into safety verdicts (match status, expiry status, vernacular speech alerts), returning standard JSON payloads that update local app storage and UI immediately.

### R4. Automated Verification & Regression Testing
Provide end-to-end automated test suites in both the Flutter client (`flutter test`) and backend (`pytest`) covering fallback trigger conditions, mock vision API responses, PII redaction, and UI state updates.

## Acceptance Criteria

### Fallback Routing & Execution
- [ ] Prescription scanning automatically triggers backend vision model processing when local OCR returns insufficient, empty, or unreadable text.
- [ ] Blister strip verification automatically escalates to cloud multimodal vision analysis when on-device text/expiry verification is inconclusive.
- [ ] Network failures or backend timeouts gracefully fall back to safe on-device or mock responses without crashing the app.

### Data Integrity & Client Integration
- [ ] Parsed medication schedules from the vision model populate the client-side medication storage and appear in the schedule/reminder view.
- [ ] Blister verification results from the vision model trigger appropriate safety indicators (match/mismatch/expired) and vernacular audio announcements.
- [ ] Sensitive PII is masked or de-identified before cloud transmission and logged with proof.

### Test Automation & Quality
- [ ] All Flutter widget and integration tests pass via `flutter test`.
- [ ] All backend test suites pass via `pytest backend/`.
- [ ] New unit and integration tests specifically validate failure-triggered vision model execution.
