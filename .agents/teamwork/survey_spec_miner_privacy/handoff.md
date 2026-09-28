# Handoff Report: Privacy Spec Miner (R2)

## 1. Observation
1. **Backend PII Engine (`backend/app.py:84-114`)**:
   `mask_pii(text: str)` uses regex `r'\b(\d{4}[\s-]?\d{4}[\s-]?\d{4})\b'` to match Aadhaar numbers and `r'(?:\+91[\-\s]?|0)?([6-9]\d{9})\b'` for phone numbers.
   When tested with `Batch Number: 1234-5678-9012`, the batch number was falsely replaced with `[MASKED-AADHAAR-XXXX]`. Furthermore, patient names (e.g. `Prescription for Ramesh Kumar, Age 54, Male`) were completely untouched.
2. **Backend Digitize Endpoint (`backend/app.py:161-200`)**:
   `/api/digitize-rx` accepts `image_base64` and `raw_ocr_text`. It forwards raw image data and unredacted OCR text directly to IBM WatsonX Granite Vision, relying merely on prompt instruction `1. Redact all patient PII (Names, Phone numbers, Aadhaar)` and generating a static string `'pii_redacted_proof': 'Patient Identity Redacted: [MASKED-AADHAAR-XXXX] [MASKED-PHONE-XXXX]'`.
3. **Flutter Report Scanner (`lib/main_pages/report_sanner/report_sanner_widget.dart:84-135`)**:
   The Flutter client extracts text using `MLKitOcrService.extractText(path)` and immediately dispatches `_model.imageBase64` and `_model.rawOcrText` to `DigitizeRxAPICall.call(...)`. No edge image masking or regex de-identification is executed prior to cloud transmission.
4. **Dead State (`lib/main_pages/report_sanner/report_sanner_model.dart:12`)**:
   `bool piiMaskingEnabled = true;` is declared in `ReportSannerModel` but is never referenced or used in `report_sanner_widget.dart`.
5. **Baseline Test Status**:
   `backend/venv/bin/pytest backend/tests/ -v` passed all 21 tests in 0.30s. No existing unit tests cover `mask_pii()` or `/api/redact-pii`.

## 2. Logic Chain
1. Based on Observation 1, without Verhoeff algorithm validation ($D_5$ dihedral group), naive 12-digit regex matching causes high-risk false positives on clinical metadata (e.g., medicine batch codes, UPC/GTIN barcodes, NDC numbers) while failing to catch single-digit typos or transposition errors.
2. Based on Observation 1 and 2, patient names are currently unredacted in text and raw prescription photos are sent to the cloud, representing a direct violation of India's Digital Personal Data Protection Act (DPDP Act 2023) and HIPAA Safe Harbor standards.
3. Based on Observation 3 and 4, the Flutter edge client contains UI scaffolding for privacy (`_buildPrivacyBadge`) and a dead flag (`piiMaskingEnabled`), but lacks an active edge sanitization pipeline that blackens bounding boxes on image bytes and tokenizes OCR text before API invocation.
4. Based on Observation 2, 3, and 5, returning a static proof string does not provide tamper-evident cryptographic assurance. A verifiable `SanitizationManifest` with SHA-256 pre/post digests and zero-knowledge entity counts must be generated on the device and validated by the backend.

## 3. Caveats
1. Handwriting OCR limitations: On poorly lit or illegible handwritten prescriptions, Google ML Kit on-device OCR may fail to detect all text characters in a patient name. In such cases, the fallback architecture must apply defensive header masking (e.g., top 15% bounding area of the prescription slip where demographics typically reside) before sending the image to the cloud vision model.
2. Read-only constraint: As a Specification Miner, no application code was modified. The detailed specifications, algorithms, and data contracts have been synthesized into `spec_report.md` for the implementation phase.

## 4. Conclusion
Authoritative specifications and contracts for **R2: Edge Privacy & PII Sanitization** have been formalized and saved to `/Users/rufbook/aarogyam/.agents/teamwork/survey_spec_miner_privacy/spec_report.md`.
The specification provides:
- Exact Verhoeff algorithm tables ($d_{10\times 10}, p_{8\times 10}, inv_{10}$) and validation routines for Aadhaar with defensive context filtering and partial masking (`XXXXXXXX1234`).
- Comprehensive Indian mobile and landline regex patterns accommodating contiguous, $5+5$, and $3+3+4$ groupings with $+91$ and $0$ prefixes.
- Multilingual heuristic NER rules for patient names in English, Hindi, and Marathi, with strict doctor/hospital exclusion filters and synthetic token replacement (`[PATIENT-ANON-XXXX]`).
- Cryptographic verification proof specification using SHA-256 pre/post digests, tamper-evident `SanitizationManifest`, and proof tokens conforming to DPDP Act 2023.
- Complete JSON schemas and data contracts for `POST /api/redact-pii`, augmented `POST /api/digitize-rx`, and client-side models.

## 5. Verification Method
1. Inspect the complete specification report:
   ```bash
   cat /Users/rufbook/aarogyam/.agents/teamwork/survey_spec_miner_privacy/spec_report.md
   ```
2. Verify backend test baseline:
   ```bash
   backend/venv/bin/pytest backend/tests/ -v
   ```
3. Test Verhoeff validation and phone pattern behavior in Python:
   ```bash
   backend/venv/bin/python -c "
   import re, sys; sys.path.insert(0, 'backend')
   # Run Verhoeff validation test on valid Aadhaar:
   d = [[0,1,2,3,4,5,6,7,8,9],[1,2,3,4,0,6,7,8,9,5],[2,3,4,0,1,7,8,9,5,6],[3,4,0,1,2,8,9,5,6,7],[4,0,1,2,3,9,5,6,7,8],[5,9,8,7,6,0,4,3,2,1],[6,5,9,8,7,1,0,4,3,2],[7,6,5,9,8,2,1,0,4,3],[8,7,6,5,9,3,2,1,0,4],[9,8,7,6,5,4,3,2,1,0]]
   p = [[0,1,2,3,4,5,6,7,8,9],[1,5,7,6,2,8,3,0,9,4],[5,8,0,3,7,9,6,1,4,2],[8,9,1,6,0,4,3,5,2,7],[9,4,5,3,1,2,6,8,7,0],[4,2,8,6,5,7,3,9,0,1],[2,7,9,3,8,0,6,4,1,5],[7,0,4,6,9,1,3,2,5,8]]
   def verhoeff(s):
       s = re.sub(r'[\s-]', '', str(s))
       if not s.isdigit() or len(s) != 12 or s[0] in '01': return False
       c = 0
       for i, item in enumerate(reversed(s)): c = d[c][p[i % 8][int(item)]]
       return c == 0
   assert verhoeff('234567890124') == True
   assert verhoeff('234657890124') == False
   print('Verhoeff algorithm verification PASSED')
   "
   ```
