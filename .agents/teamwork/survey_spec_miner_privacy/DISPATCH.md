# Task Dispatch: Spec Miner - Edge Privacy & PII Sanitization Specifications

## Context
You are the Spec Miner investigating specifications and requirements for Edge Privacy, PII Sanitization, and Compliance proofs for Aarogyam.

## Working Directory
/Users/rufbook/aarogyam/.agents/teamwork/survey_spec_miner_privacy

## Authoritative Inputs
- /Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md
- Entire Aarogyam codebase (Flutter client & backend)

## Objective
Extract authoritative requirements, patterns, and specifications for R2: Edge Privacy & PII Sanitization (Aadhaar, phone numbers, patient names masking/de-identification with verifiable proof).

## Scope & Instructions
1. Read `/Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md`.
2. Inspect the codebase for:
   - Any existing privacy filters, PII sanitization modules, or regex/NER pipelines in Flutter or Python.
   - Specifications for Aadhaar format (12-digit Indian national ID, Verhoeff algorithm, masking patterns e.g. `XXXXXXXX1234` or redacting bounding boxes).
   - Specifications for phone numbers (Indian mobile prefixes e.g. `+91`, 10 digits).
   - Specifications for patient names (de-identification, synthetic tokens, bounding box redaction on image if required, or text payload masking).
   - Verification proofs requirement: cryptographic hash, audit logs, sanitization manifest, or proof tokens confirming sensitive identifiers were masked prior to cloud transmission.
   - Any compliance constraints (DPDP Act, HIPAA, FHIR, etc.) or project-specific standards.
3. Formulate clear, unambiguous specifications and data contracts for the PII sanitization subsystem on both edge/client and backend.
4. Output a comprehensive specification report to `/Users/rufbook/aarogyam/.agents/teamwork/survey_spec_miner_privacy/spec_report.md` and write `handoff.md`.
5. Send a message to orchestrator upon completion.

## 2026-09-28T00:57:33Z
You are the Privacy Spec Miner.
Working directory: /Users/rufbook/aarogyam/.agents/teamwork/survey_spec_miner_privacy
Read your task dispatch at /Users/rufbook/aarogyam/.agents/teamwork/survey_spec_miner_privacy/DISPATCH.md and the original user request at /Users/rufbook/aarogyam/.agents/teamwork/ORIGINAL_REQUEST.md.

Investigate specifications and requirements for R2: Edge Privacy & PII Sanitization:
1. Examine existing privacy filters, PII sanitization modules, or regex/NER pipelines across Flutter and Python.
2. Formalize specifications for Aadhaar (12 digits, Verhoeff algorithm validation, masking e.g. XXXXXXXX1234 or image redaction).
3. Formalize specifications for Phone Numbers (Indian mobile formats e.g. +91, 10 digits, masking).
4. Formalize specifications for Patient Names (de-identification, synthetic tokens, bounding box redaction).
5. Formalize specifications for Verification Proofs (cryptographic hash, audit log, sanitization manifest, proof tokens).
6. Formulate clear data contracts and JSON schemas for PII sanitization across edge client and backend.

Do NOT modify any code. Output your complete specification report to /Users/rufbook/aarogyam/.agents/teamwork/survey_spec_miner_privacy/spec_report.md and write handoff.md in your working directory. Send a message to orchestrator when finished.

