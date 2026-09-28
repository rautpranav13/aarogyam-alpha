# Milestone 1: Backend PII Sanitizer & Cryptographic Manifest Technical Specification

**Author**: Milestone 1 Explorer 2 (Backend PII Sanitizer)  
**Date**: 2026-09-28  
**Scope**: `backend/app.py` (`mask_pii`, `POST /api/redact-pii`, `POST /api/digitize-rx`), `backend/tests/test_pii_sanitizer.py`  
**Target Milestone**: Milestone 1 (M1: Edge Privacy & PII Sanitization Subsystem)  
**Authoritative References**: `PROJECT.md`, `survey_spec_miner_privacy/spec_report.md`, UIDAI Aadhaar Act 2016, DoT National Numbering Plan, DPDP Act 2023 §8.

---

## 1. Executive Summary

This specification establishes the exact engineering design and ready-to-implement code for upgrading the backend privacy engine in `backend/app.py` and creating its dedicated automated test suite in `backend/tests/test_pii_sanitizer.py`.

### Key Enhancements Designed:
1. **Dihedral Group $D_5$ Verhoeff Algorithm**: Replaces naive 12-digit regex with mathematical checksum validation and UIDAI-compliant first-digit constraints ($s_0 \in [2, 9]$).
2. **Pharmaceutical Batch Code Protection**: Prevents false positive masking of medicine batch numbers (e.g. `1234-5678-9012`, `Batch No: 2345 6789 0124`, `Lot: ...`, `Exp: ...`) using contextual keyword analysis and UIDAI lead-digit gating.
3. **Comprehensive Indian Phone Number Sanitization**: Handles contiguous 10-digit, $5+5$, $4+6$, and $3+3+4$ groupings with `+91`, `0`, `0091`, and `91` prefixes for DoT-allocated mobile ranges ($6, 7, 8, 9$) and STD clinic landlines while rejecting non-phone serial numbers.
4. **Multilingual Patient Name De-Identification**: Uses demographic header anchors across English, Hindi, and Marathi (`Patient Name:`, `रोगी का नाम:`, `रुग्णाचे नाव:`) with strict negative filters protecting doctor names (`Dr.`, `MD`, `MBBS`, `डॉ.`) and medical centers (`AIIMS`, `PHC`, `रुग्णालय`). Generates deterministic pseudo-tokens (`[PATIENT-ANON-XXXX]`).
5. **Cryptographic SHA-256 Proof Manifest**: Produces a tamper-evident audit record containing `pre_hash_sha256`, `post_hash_sha256`, UUIDv4 `manifest_id`, ISO-8601 UTC timestamp, and `verhoeff-d5-regex-ner-v1` algorithm tag per `PROJECT.md § Interface Contracts`.
6. **Interface Alignment**: Upgrades `POST /api/redact-pii` to return `sanitized_text`, `entities_masked` counts, and the `proof` object while retaining full backward compatibility.
7. **Defense-in-Depth Cloud Dispatch**: Updates `POST /api/digitize-rx` to automatically cleanse `raw_ocr_text` using `mask_pii()` before injecting it into the Granite Vision 3.2 2B prompt.

---

## 2. Baseline Architecture & Problem Analysis

### 2.1 Existing State in `backend/app.py`
In `backend/app.py:90-120`:
```python
def mask_pii(text: str) -> Tuple[str, List[Dict[str, str]]]:
    redactions = []
    aadhaar_pattern = r'\b(\d{4}[\s-]?\d{4}[\s-]?\d{4})\b'
    ...
    masked_text = re.sub(aadhaar_pattern, "[MASKED-AADHAAR-XXXX]", text)
    abha_pattern = r'\b(\d{2}-\d{4}-\d{4}-\d{4})\b'
    ...
    mobile_pattern = r'(?:\+91[\-\s]?|0)?([6-9]\d{9})\b'
    ...
    return masked_text, redactions
```

### 2.2 Vulnerabilities & Architectural Gaps
| Issue | Current Behavior | Clinical / Compliance Risk |
|---|---|---|
| **False Positive Batch Masking** | Any 12-digit string (`1234-5678-9012` or `Batch: 2345 6789 0124`) is masked as Aadhaar. | Blister strip and prescription batch numbers are erased, breaking medication verification (`/api/verify-strip`). |
| **Aadhaar Transposition Vulnerability** | Typo or swapped digits (e.g. `2346 5789 0124` vs valid `2345 6789 0124`) treated as genuine Aadhaar without checksum check. | False confidence in data sanitization audit logs. |
| **Zero Patient Name Redaction** | `mask_pii` does not detect patient names. | Direct violation of DPDP Act 2023 §8 and HIPAA Safe Harbor: patient names are forwarded in plaintext. |
| **Phone Format Gaps** | Spaces inside numbers (`+91 98765 43210` or `98765 43210`) fail the naive contiguous `\d{9}` regex. | Patient phone numbers leak into cloud AI logs. |
| **No Cryptographic Proof** | Static string template returned; no SHA-256 pre/post digests. | Fails `PROJECT.md § Interface Contracts` for `/api/redact-pii`. |
| **Missing Cloud Ingress Defense** | `/api/digitize-rx` forwarded `raw_ocr_text` directly to WatsonX without deterministic edge/gateway sanitization. | Relies solely on LLM prompt instructions for privacy redaction. |

---

## 3. Mathematical & Algorithmic Design

### 3.1 Dihedral Group $D_5$ (Verhoeff Algorithm)

The Verhoeff algorithm operates on the dihedral group $D_5$ of order 10 (symmetries of a regular pentagon: 5 rotations and 5 reflections). It detects 100% of single-digit errors and 100% of adjacent transposition errors, plus over 94% of other transposition/twin errors.

#### Constant Tables:
```python
# Multiplication table d[10][10] for Dihedral Group D_5
VERHOEFF_D = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
    [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
    [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
    [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
    [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
    [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
    [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
    [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
]

# Permutation table p[8][10]
VERHOEFF_P = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
]

# Inversion table inv[10]
VERHOEFF_INV = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9]
```

#### Validation & Generation Algorithms:
```python
def validate_verhoeff(num_str: str) -> bool:
    """
    Validates a 12-digit Aadhaar candidate using the Verhoeff D5 algorithm.
    Enforces UIDAI constraints: exactly 12 digits, first digit in range [2, 9].
    """
    clean = "".join(ch for ch in str(num_str) if ch.isdigit())
    if len(clean) != 12:
        return False
    if clean[0] in ("0", "1"):
        return False  # UIDAI standard: Aadhaar never starts with 0 or 1

    c = 0
    for i, digit in enumerate(reversed(clean)):
        c = VERHOEFF_D[c][VERHOEFF_P[i % 8][int(digit)]]
    return c == 0


def generate_verhoeff_checksum(num_str: str) -> str:
    """
    Generates the Verhoeff checksum digit for an 11-digit Aadhaar prefix.
    """
    clean = "".join(ch for ch in str(num_str) if ch.isdigit())
    c = 0
    for i, digit in enumerate(reversed(clean)):
        c = VERHOEFF_D[c][VERHOEFF_P[(i + 1) % 8][int(digit)]]
    return str(VERHOEFF_INV[c])
```

### 3.2 Aadhaar vs. Batch Code Disambiguation Logic
To protect legitimate medicine batch numbers, GTINs, and lot codes:
1. **Keyword Context Window**: Look up to 40 characters backward from the match start.
2. **Batch Filter**: If preceded by `batch`, `b.no`, `lot`, `exp`, `expiry`, `mfg`, `mfd`, `gtin`, `barcode`, or `inv`, DO NOT REDACT.
3. **Explicit Aadhaar Label**: If preceded by `aadhaar`, `aadhar`, `uidai`, `uid`, `आधार`, or `adhar`, REDACT unconditionally (protects against minor OCR errors in explicitly declared Aadhaar fields).
4. **Unlabeled Numbers**: Must satisfy:
   - Leading digit $s_0 \in [2, 9]$
   - `validate_verhoeff(digits) is True`
5. **Masking Format**:
   - UIDAI compliant standard: `f"XXXXXXXX{digits[-4:]}"` (e.g. `XXXXXXXX0124`)
   - Optional token mode: `"[MASKED-AADHAAR-XXXX]"`

### 3.3 Indian Phone Number Recognition
- **Mobile Pattern**:
  `r"(?:\+91[\-\s]?|0091[\-\s]?|\b91[\-\s]|\b0)?(?:\(0\)\s*)?([6-9](?:[\-\s]?\d){9})\b"`
  Captures:
  - Contiguous: `9876543210`, `+919876543210`, `09876543210`
  - 5+5: `98765 43210`, `+91 98765 43210`, `+91-98765-43210`
  - 4+6 & 3+3+4: `7654-321098`, `+91 987 654 3210`
  Rejects non-phone serial numbers (`SN: 5432109876`, `Ref: 1234567890`) and 6-digit pincodes (`411001`).
- **Landline Pattern**:
  `r"(?i)\b(?:tel|phone|ph|contact|call|फोन|संपर्क|दूरध्वनी)\s*[:\-\s]\s*(?:\+91[\-\s]?)?(0\d{2,4}[\-\s]?\d{6,8})\b"`
- **Masking Format**: `"[MASKED-PHONE-XXXX]"`

### 3.4 Multilingual Patient Name De-Identification
- **Demographic Anchors**:
  `r"((?:patient(?:\s+name)?|pt\.?\s*name|pt\b|मरीज(?:\s+का\s+नाम)?|रोगी(?:\s+का\s+नाम)?|रुग्णाचे\s+नाव)\s*[:\-\s]\s*)"`
- **Name Extraction**:
  `r"((?:(?:Mr|Mrs|Ms|Miss|Master|Shri|Smt|Kumari|श्री|श्रीमती|कु)\.?\s+)?[A-Za-z\u0900-\u097F]+(?:[ \t]+[A-Za-z\u0900-\u097F]+){0,3})"`
- **Doctor / Institution Negative Safeguard**:
  `r"\b(?:Dr\.?|Doctor|डॉ\.?|वैद्य|MBBS|MD|MS|BAMS|BHMS|BDS|FRCS|DM|MCh|PHC|CHC|AIIMS|Hospital|Clinic|Centre|Center|Dispensary|आरोग्य\s*केंद्र|रुग्णालय|अस्पताल)\b"`
  If the extracted candidate matches any medical credential or facility keyword, redaction is aborted and the original text is preserved.
- **Deterministic Pseudonymization**:
  Generates `f"[PATIENT-ANON-{hashlib.sha256(name.encode()).hexdigest()[:4].upper()}]"`, producing repeatable tokens like `[PATIENT-ANON-F188]` without storing raw names.

### 3.5 Cryptographic Proof Manifest
Computes:
- `pre_hash_sha256`: SHA-256 digest of original input text.
- `post_hash_sha256`: SHA-256 digest of sanitized text.
- `manifest_id`: UUIDv4 string.
- `timestamp`: Current UTC timestamp in ISO-8601 (`YYYY-MM-DDTHH:MM:SS.mmmmmm+00:00`).
- `algorithm`: Literal `"verhoeff-d5-regex-ner-v1"`.
- `proof_token`: `f"PRV-{manifest_id[:8]}-{post_hash_sha256[:8]}"`.
- **Security Invariant**: The manifest strictly contains entity counts, hash digests, and validation metadata. No raw PII strings are stored or leaked.

---

## 4. Exact Implementation for `backend/app.py`

Below is the complete, drop-in Python code for `backend/app.py`.

```python
# =============================================================================
# Milestone 1: Edge Privacy & PII Sanitization Engine (Verhoeff D5 + DPDP Proof)
# =============================================================================
import uuid
import hashlib
from datetime import datetime, timezone

# Dihedral group D5 multiplication table (10x10)
VERHOEFF_D = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
    [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
    [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
    [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
    [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
    [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
    [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
    [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
]

# Dihedral group D5 permutation table (8x10)
VERHOEFF_P = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
]

# Dihedral group D5 inverse table
VERHOEFF_INV = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9]


def validate_verhoeff(num_str: str) -> bool:
    """
    Validates a 12-digit Aadhaar candidate using the Verhoeff D5 algorithm.
    Enforces UIDAI constraints: exactly 12 digits, first digit in range [2, 9].
    """
    clean = "".join(ch for ch in str(num_str) if ch.isdigit())
    if len(clean) != 12:
        return False
    if clean[0] in ("0", "1"):
        return False  # UIDAI standard: Aadhaar never starts with 0 or 1

    c = 0
    for i, digit in enumerate(reversed(clean)):
        c = VERHOEFF_D[c][VERHOEFF_P[i % 8][int(digit)]]
    return c == 0


def generate_verhoeff_checksum(num_str: str) -> str:
    """
    Generates the Verhoeff checksum digit for an 11-digit Aadhaar prefix.
    """
    clean = "".join(ch for ch in str(num_str) if ch.isdigit())
    c = 0
    for i, digit in enumerate(reversed(clean)):
        c = VERHOEFF_D[c][VERHOEFF_P[(i + 1) % 8][int(digit)]]
    return str(VERHOEFF_INV[c])


# Compiled patterns for PII detection and negative filters
AADHAAR_LABEL_RE = re.compile(
    r"(?i)\b(?:aadhaar|aadhar|uidai|uid|आधार(?:\s*क्र\.?)?|adhar)\b"
)
BATCH_LABEL_RE = re.compile(
    r"(?i)\b(?:batch(?:\s*(?:no|num|number))?|b\.?\s*no\.?|lot(?:\s*(?:no|num|number))?|exp(?:\.?|iry)?|mfg|mfd|gtin|barcode|inv(?:oice)?)\b"
)
AADHAAR_CANDIDATE_RE = re.compile(r"\b(\d{4}[\s-]?\d{4}[\s-]?\d{4})\b")

DOCTOR_FILTER_RE = re.compile(
    r"\b(?:Dr\.?|Doctor|डॉ\.?|वैद्य|MBBS|MD|MS|BAMS|BHMS|BDS|FRCS|DM|MCh|PHC|CHC|AIIMS|Hospital|Clinic|Centre|Center|Dispensary|आरोग्य\s*केंद्र|रुग्णालय|अस्पताल)\b",
    re.IGNORECASE,
)
PATIENT_HEADER_RE = re.compile(
    r"((?:patient(?:\s+name)?|pt\.?\s*name|pt\b|मरीज(?:\s+का\s+नाम)?|रोगी(?:\s+का\s+नाम)?|रुग्णाचे\s+नाव)\s*[:\-\s]\s*)"
    r"((?:(?:Mr|Mrs|Ms|Miss|Master|Shri|Smt|Kumari|श्री|श्रीमती|कु)\.?\s+)?"
    r"[A-Za-z\u0900-\u097F]+(?:[ \t]+[A-Za-z\u0900-\u097F]+){0,3})",
    re.IGNORECASE,
)

MOBILE_PATTERN_RE = re.compile(
    r"(?:\+91[\-\s]?|0091[\-\s]?|\b91[\-\s]|\b0)?(?:\(0\)\s*)?([6-9](?:[\-\s]?\d){9})\b"
)
LANDLINE_PATTERN_RE = re.compile(
    r"(?i)\b(?:tel|phone|ph|contact|call|फोन|संपर्क|दूरध्वनी)\s*[:\-\s]\s*(?:\+91[\-\s]?)?(0\d{2,4}[\-\s]?\d{6,8})\b"
)
ABHA_PATTERN_RE = re.compile(r"\b(\d{2}-\d{4}-\d{4}-\d{4})\b")


def mask_pii(
    text: str,
    mask_format: str = "uidai",
    generate_proof: bool = True
) -> Tuple[str, Dict[str, Any]]:
    """
    On-Device & Gateway PII De-Identification Engine.
    Redacts Indian Personal Identifiable Information:
    - 12-digit Aadhaar with Verhoeff D5 validation & Batch Code protection
    - Indian Mobile (+91, 0, 5+5, 4+6) & Landline numbers
    - Multilingual Patient Names (English, Hindi, Marathi) with Doctor exclusion
    - 14-digit ABHA (Ayushman Bharat Health Account) IDs
    
    Returns:
        sanitized_text (str): De-identified text string.
        metadata (dict): Structured manifest, entity counts, and SHA-256 proofs.
    """
    if not text:
        manifest_id = str(uuid.uuid4())
        empty_proof = {
            "manifest_id": manifest_id,
            "pre_hash_sha256": hashlib.sha256(b"").hexdigest(),
            "post_hash_sha256": hashlib.sha256(b"").hexdigest(),
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "algorithm": "verhoeff-d5-regex-ner-v1",
            "proof_token": f"PRV-{manifest_id[:8]}-{hashlib.sha256(b'').hexdigest()[:8]}",
        }
        return "", {
            "entities_masked": {"aadhaar": 0, "phone": 0, "patient_name": 0, "abha_id": 0},
            "total_redactions": 0,
            "redactions": [],
            "proof": empty_proof,
        }

    pre_hash = hashlib.sha256(text.encode("utf-8")).hexdigest()
    redactions: List[Dict[str, Any]] = []
    entities_count = {"aadhaar": 0, "phone": 0, "patient_name": 0, "abha_id": 0}

    # Step 1: Patient Name De-Identification with Doctor Safeguard
    def replace_patient_name(match: re.Match) -> str:
        prefix = match.group(1)
        name = match.group(2).strip()
        if DOCTOR_FILTER_RE.search(name):
            return match.group(0)  # Preserve doctor or facility entity
        short_hash = hashlib.sha256(name.encode("utf-8")).hexdigest()[:4].upper()
        token = f"[PATIENT-ANON-{short_hash}]"
        entities_count["patient_name"] += 1
        redactions.append({
            "type": "PATIENT_NAME",
            "masked": token,
            "char_offset": match.start()
        })
        return f"{prefix}{token}"

    sanitized = PATIENT_HEADER_RE.sub(replace_patient_name, text)

    # Step 2: Aadhaar Number Masking with Verhoeff D5 & Batch Protection
    def replace_aadhaar(match: re.Match) -> str:
        start = match.start()
        ctx = sanitized[max(0, start - 40):start]
        # Check pharmaceutical batch context
        if BATCH_LABEL_RE.search(ctx):
            return match.group(0)  # Preserve medicine batch / lot code
        raw_match = match.group(0)
        digits = re.sub(r"[\s-]", "", raw_match)
        is_labeled = bool(AADHAAR_LABEL_RE.search(ctx))
        is_valid = validate_verhoeff(digits)
        if is_labeled or is_valid:
            entities_count["aadhaar"] += 1
            masked_val = (
                f"XXXXXXXX{digits[-4:]}"
                if mask_format == "uidai"
                else "[MASKED-AADHAAR-XXXX]"
            )
            redactions.append({
                "type": "AADHAAR",
                "masked": masked_val,
                "verhoeff_valid": is_valid,
                "labeled": is_labeled,
                "char_offset": start
            })
            return masked_val
        return raw_match

    sanitized = AADHAAR_CANDIDATE_RE.sub(replace_aadhaar, sanitized)

    # Step 3: ABHA ID Masking (14 digits)
    def replace_abha(match: re.Match) -> str:
        entities_count["abha_id"] += 1
        redactions.append({
            "type": "ABHA_ID",
            "masked": "[MASKED-ABHA-XXXX]",
            "char_offset": match.start()
        })
        return "[MASKED-ABHA-XXXX]"

    sanitized = ABHA_PATTERN_RE.sub(replace_abha, sanitized)

    # Step 4: Indian Mobile & Landline Phone Numbers
    def replace_mobile(match: re.Match) -> str:
        entities_count["phone"] += 1
        redactions.append({
            "type": "PHONE",
            "masked": "[MASKED-PHONE-XXXX]",
            "char_offset": match.start()
        })
        return "[MASKED-PHONE-XXXX]"

    sanitized = MOBILE_PATTERN_RE.sub(replace_mobile, sanitized)

    def replace_landline(match: re.Match) -> str:
        entities_count["phone"] += 1
        redactions.append({
            "type": "PHONE",
            "masked": "[MASKED-PHONE-XXXX]",
            "char_offset": match.start()
        })
        return "[MASKED-PHONE-XXXX]"

    sanitized = LANDLINE_PATTERN_RE.sub(replace_landline, sanitized)

    # Step 5: Cryptographic Audit Proof Construction
    post_hash = hashlib.sha256(sanitized.encode("utf-8")).hexdigest()
    manifest_id = str(uuid.uuid4())
    timestamp = datetime.now(timezone.utc).isoformat()
    proof = {
        "manifest_id": manifest_id,
        "pre_hash_sha256": pre_hash,
        "post_hash_sha256": post_hash,
        "timestamp": timestamp,
        "algorithm": "verhoeff-d5-regex-ner-v1",
        "proof_token": f"PRV-{manifest_id[:8]}-{post_hash[:8]}",
    }

    metadata = {
        "sanitized_text": sanitized,
        "entities_masked": entities_count,
        "total_redactions": len(redactions),
        "redactions": redactions,
        "proof": proof,
    }
    return sanitized, metadata


@app.route("/api/redact-pii", methods=["POST"])
def redact_pii_endpoint():
    """
    De-identification endpoint adhering to PROJECT.md § Interface Contracts.
    Accepts raw OCR text and returns sanitized text, entity counts, and cryptographic proof.
    """
    data = request.get_json(silent=True) or {}
    text = data.get("text", "")
    if not text:
        return jsonify({"status": "error", "message": "Missing 'text' parameter"}), 400

    mask_level = data.get("mask_level", "uidai")
    generate_proof = data.get("generate_proof", True)

    sanitized_text, metadata = mask_pii(
        text,
        mask_format="uidai" if mask_level != "full_token" else "token",
        generate_proof=generate_proof
    )

    return jsonify({
        "status": "success",
        "sanitized_text": sanitized_text,
        "masked_text": sanitized_text,  # Backward compatibility
        "entities_masked": metadata["entities_masked"],
        "redactions_count": metadata["total_redactions"],  # Backward compatibility
        "redactions": metadata["redactions"],  # Backward compatibility
        "privacy_verified": True,  # Backward compatibility
        "proof": metadata["proof"],
    }), 200
```

### 4.1 Integration into `/api/digitize-rx`
In `digitize_rx()`:
```python
        raw_text_ocr = data.get("raw_ocr_text", "")
        # Apply deterministic defense-in-depth sanitization to OCR text
        sanitized_ocr = ""
        sanitization_meta = None
        if raw_text_ocr:
            sanitized_ocr, sanitization_meta = mask_pii(raw_text_ocr)
```
When assembling prompt messages for WatsonX or returning demo fallback:
Use `sanitized_ocr` instead of `raw_text_ocr`.
In response:
```python
        proof_str = (
            f"DPDP-VERIFIED: [{sanitization_meta['entities_masked']['aadhaar']} Aadhaar, "
            f"{sanitization_meta['entities_masked']['phone']} Phone, "
            f"{sanitization_meta['entities_masked']['patient_name']} Name Redacted] | "
            f"Proof ID: {sanitization_meta['proof']['manifest_id'][:8]}"
            if sanitization_meta and sanitization_meta["total_redactions"] > 0
            else "DPDP-VERIFIED: Clean Payload"
        )
```

---

## 5. Exact Specification for `backend/tests/test_pii_sanitizer.py`

Below is the complete, runnable pytest file `backend/tests/test_pii_sanitizer.py` designed to provide 100% test coverage for M1 backend privacy requirements.

```python
"""
Unit and integration tests for Aarogyam Edge Privacy & PII Sanitization Engine.
Validates:
- Dihedral Group D5 Verhoeff algorithm validation and checksum generation
- Batch code false positive rejection (preserving medicine batch/lot numbers)
- Indian phone number format sanitization (mobile +91, 0, 5+5, landline)
- Multilingual patient name de-identification (English, Hindi, Marathi)
- Doctor credentials and clinic entity preservation
- Cryptographic SHA-256 pre/post manifest generation & proof verification
- Flask POST /api/redact-pii endpoint contract compliance

Run with: backend/venv/bin/pytest backend/tests/test_pii_sanitizer.py -v
"""
import os
import sys
import re
import json
import hashlib
import pytest

# Ensure backend directory is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app import (
    app,
    validate_verhoeff,
    generate_verhoeff_checksum,
    mask_pii,
)


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as test_client:
        yield test_client


# =============================================================================
# 1. Verhoeff D5 Algorithm Mathematical Integrity Tests
# =============================================================================

def test_verhoeff_checksum_generation_and_validation():
    """Verify Verhoeff D5 generates correct check digit and validates full 12-digit Aadhaar."""
    # Prefix: 23456789012 -> Check digit: 4 -> Full: 234567890124
    prefix1 = "23456789012"
    check1 = generate_verhoeff_checksum(prefix1)
    assert check1 == "4"
    assert validate_verhoeff(prefix1 + check1) is True

    # Prefix: 34567890123 -> Check digit: 8 -> Full: 345678901238
    prefix2 = "34567890123"
    check2 = generate_verhoeff_checksum(prefix2)
    assert check2 == "8"
    assert validate_verhoeff(prefix2 + check2) is True

    # Prefix: 98765432109 -> Check digit: 6 -> Full: 987654321096
    prefix3 = "98765432109"
    check3 = generate_verhoeff_checksum(prefix3)
    assert check3 == "6"
    assert validate_verhoeff(prefix3 + check3) is True


def test_verhoeff_transposition_error_detection():
    """Verify adjacent digit swaps are detected and invalidated."""
    valid_aadhaar = "234567890124"
    assert validate_verhoeff(valid_aadhaar) is True

    # Swap adjacent digits 5 and 6: 23456... -> 23465...
    transposed = "234657890124"
    assert validate_verhoeff(transposed) is False

    # Swap adjacent digits 9 and 0: ...890124 -> ...809124
    transposed2 = "234567809124"
    assert validate_verhoeff(transposed2) is False


def test_verhoeff_single_digit_substitution_detection():
    """Verify single digit modifications are detected and invalidated."""
    valid_aadhaar = "234567890124"
    for i in range(12):
        original_digit = int(valid_aadhaar[i])
        for delta in [1, 2, 5]:
            tampered = list(valid_aadhaar)
            tampered[i] = str((original_digit + delta) % 10)
            tampered_str = "".join(tampered)
            # Leading digit 0/1 are automatically invalid, otherwise checksum fails
            assert validate_verhoeff(tampered_str) is False


def test_verhoeff_uidai_leading_digit_rules():
    """Verify UIDAI rules: Aadhaar cannot start with 0 or 1."""
    # Starts with 0
    assert validate_verhoeff("012345678901") is False
    # Starts with 1 (common medicine batch prefix)
    assert validate_verhoeff("123456789012") is False


def test_verhoeff_invalid_length_and_characters():
    """Verify non-12-digit strings and non-numeric inputs return False."""
    assert validate_verhoeff("23456789012") is False  # 11 digits
    assert validate_verhoeff("2345678901245") is False  # 13 digits
    assert validate_verhoeff("23456789ABCD") is False  # Letters
    assert validate_verhoeff("") is False


# =============================================================================
# 2. Medicine Batch Code False Positive Protection Tests
# =============================================================================

def test_batch_code_false_positive_prevention():
    """Verify pharmaceutical batch numbers are preserved and NOT masked."""
    # 1. Leading with 1
    text1 = "Medicine: Paracetamol 500mg (Batch No: 1234-5678-9012)"
    sanitized1, meta1 = mask_pii(text1)
    assert "1234-5678-9012" in sanitized1
    assert meta1["entities_masked"]["aadhaar"] == 0

    # 2. Valid Verhoeff digits preceded by 'Batch No:'
    text2 = "Rx: Metformin 500mg, Batch No: 2345 6789 0124, Exp: 12/2028"
    sanitized2, meta2 = mask_pii(text2)
    assert "2345 6789 0124" in sanitized2
    assert meta2["entities_masked"]["aadhaar"] == 0

    # 3. Preceded by 'Lot:'
    text3 = "Lot number: 2345-6789-0124, Tab Amoxicillin"
    sanitized3, meta3 = mask_pii(text3)
    assert "2345-6789-0124" in sanitized3
    assert meta3["entities_masked"]["aadhaar"] == 0

    # 4. Preceded by 'GTIN:' or 'Barcode:'
    text4 = "GTIN: 234567890124 Barcode verified"
    sanitized4, meta4 = mask_pii(text4)
    assert "234567890124" in sanitized4
    assert meta4["entities_masked"]["aadhaar"] == 0


def test_genuine_aadhaar_masking_with_uidai_format():
    """Verify valid Aadhaar is masked to UIDAI format XXXXXXXX1234."""
    # Valid Aadhaar without explicit label
    text = "Patient Identification: 2345 6789 0124, Resident of Pune"
    sanitized, meta = mask_pii(text)
    assert "XXXXXXXX0124" in sanitized
    assert "2345" not in sanitized
    assert meta["entities_masked"]["aadhaar"] == 1


def test_labeled_aadhaar_masking_even_with_ocr_typo():
    """Verify labeled Aadhaar (Aadhaar, आधार) is redacted even with minor checksum mismatch."""
    text1 = "Aadhaar: 2346 5789 0124 (OCR typo in checksum)"
    sanitized1, meta1 = mask_pii(text1)
    assert "XXXXXXXX0124" in sanitized1
    assert meta1["entities_masked"]["aadhaar"] == 1

    text2 = "आधार क्र: 3456 7890 1238"
    sanitized2, meta2 = mask_pii(text2)
    assert "XXXXXXXX1238" in sanitized2
    assert meta2["entities_masked"]["aadhaar"] == 1


# =============================================================================
# 3. Indian Phone Number Sanitization Tests
# =============================================================================

def test_indian_mobile_numbers_various_formats():
    """Verify contiguous, 5+5, 4+6, and prefixed mobile numbers are masked."""
    formats = [
        "Contact: 9876543210",
        "Phone: +91 98765 43210",
        "Mobile: +91-98765-43210",
        "Emergency: 09876543210",
        "Alt: 0091 98765 43210",
        "Call: 87654 32109",
        "SMS: 7654-321098",
        "Dial: 6543210987",
        "Doctor's nurse: +91 987 654 3210",
    ]
    for fmt in formats:
        sanitized, meta = mask_pii(fmt)
        assert "[MASKED-PHONE-XXXX]" in sanitized, f"Failed on: {fmt}"
        assert meta["entities_masked"]["phone"] == 1


def test_clinic_landline_masking():
    """Verify STD landline numbers with phone keyword context are masked."""
    landlines = [
        "Tel: 020-25678901",
        "Phone: 011 26588500",
        "संपर्क: 022-26543210",
    ]
    for line in landlines:
        sanitized, meta = mask_pii(line)
        assert "[MASKED-PHONE-XXXX]" in sanitized
        assert meta["entities_masked"]["phone"] == 1


def test_phone_number_negative_filters():
    """Verify non-phone serial numbers and pincodes starting with 1-5 are NOT masked."""
    assert mask_pii("SN: 5432109876")[1]["entities_masked"]["phone"] == 0
    assert mask_pii("Order ID: 1234567890")[1]["entities_masked"]["phone"] == 0
    assert mask_pii("Pincode: 411001, Pune")[1]["entities_masked"]["phone"] == 0


# =============================================================================
# 4. Multilingual Patient Name De-Identification & Doctor Preservation Tests
# =============================================================================

def test_patient_name_deidentification_english():
    """Verify English patient names are masked with synthetic anonymous tokens."""
    text = "Patient Name: Ramesh Kumar, Age: 54, Male"
    sanitized, meta = mask_pii(text)
    assert "Ramesh Kumar" not in sanitized
    assert "[PATIENT-ANON-" in sanitized
    assert meta["entities_masked"]["patient_name"] == 1

    text2 = "Pt. Name: Mrs. Sunita Devi\nAge: 42"
    sanitized2, meta2 = mask_pii(text2)
    assert "Sunita Devi" not in sanitized2
    assert "[PATIENT-ANON-" in sanitized2


def test_patient_name_deidentification_hindi_marathi():
    """Verify Hindi and Marathi patient names are masked."""
    # Hindi
    text_hi = "रोगी का नाम: सुरेश पाटील, उम्र: ५४ वर्ष"
    sanitized_hi, meta_hi = mask_pii(text_hi)
    assert "सुरेश पाटील" not in sanitized_hi
    assert "[PATIENT-ANON-" in sanitized_hi
    assert meta_hi["entities_masked"]["patient_name"] == 1

    # Marathi
    text_mr = "रुग्णाचे नाव: अनिता जोशी, वय: ४८"
    sanitized_mr, meta_mr = mask_pii(text_mr)
    assert "अनिता जोशी" not in sanitized_mr
    assert "[PATIENT-ANON-" in sanitized_mr
    assert meta_mr["entities_masked"]["patient_name"] == 1


def test_doctor_and_clinic_name_preservation():
    """Verify doctor names and healthcare facilities are NEVER masked."""
    prescription = """
    Community Health Centre (CHC)
    Doctor: Dr. S. K. Sharma, MD (Medicine)
    Registration: MCI-12345
    Patient Name: Ramesh Kumar
    Age: 54, Male
    Rx: Metformin 500mg
    """
    sanitized, meta = mask_pii(prescription)
    # Doctor and CHC preserved
    assert "Dr. S. K. Sharma, MD (Medicine)" in sanitized
    assert "Community Health Centre (CHC)" in sanitized
    assert "MCI-12345" in sanitized
    # Patient name masked
    assert "Ramesh Kumar" not in sanitized
    assert "[PATIENT-ANON-" in sanitized
    assert meta["entities_masked"]["patient_name"] == 1


def test_doctor_safeguard_corner_case():
    """Verify candidate matching doctor credentials in patient field is protected."""
    text = "Patient: Dr. John Doe, MBBS"
    sanitized, meta = mask_pii(text)
    assert "Dr. John Doe, MBBS" in sanitized
    assert meta["entities_masked"]["patient_name"] == 0


# =============================================================================
# 5. Cryptographic Proof Manifest Integrity Tests
# =============================================================================

def test_cryptographic_manifest_proof_structure():
    """Verify SHA-256 pre/post digests, manifest ID, and algorithm tag."""
    raw_text = "Patient Name: Ramesh Kumar\nAadhaar: 2345 6789 0124\nPhone: +91 98765 43210"
    sanitized, meta = mask_pii(raw_text)

    proof = meta["proof"]
    assert "manifest_id" in proof
    assert len(proof["manifest_id"]) == 36  # UUID length
    assert proof["algorithm"] == "verhoeff-d5-regex-ner-v1"
    assert "PRV-" in proof["proof_token"]

    # Pre-hash verification
    expected_pre = hashlib.sha256(raw_text.encode("utf-8")).hexdigest()
    assert proof["pre_hash_sha256"] == expected_pre

    # Post-hash verification
    expected_post = hashlib.sha256(sanitized.encode("utf-8")).hexdigest()
    assert proof["post_hash_sha256"] == expected_post
    assert proof["pre_hash_sha256"] != proof["post_hash_sha256"]


def test_cryptographic_manifest_zero_pii_leakage():
    """Verify security invariant: proof manifest never contains raw PII."""
    raw_text = "Patient Name: Ramesh Kumar\nAadhaar: 2345 6789 0124\nPhone: 9876543210"
    _, meta = mask_pii(raw_text)

    proof_json = json.dumps(meta["proof"])
    assert "Ramesh Kumar" not in proof_json
    assert "2345 6789 0124" not in proof_json
    assert "9876543210" not in proof_json


# =============================================================================
# 6. REST API Endpoint Integration Tests
# =============================================================================

def test_redact_pii_endpoint_contract(client):
    """Verify POST /api/redact-pii complies with PROJECT.md Interface Contract."""
    payload = {
        "text": "Patient Name: Ramesh Kumar\nAadhaar: 2345 6789 0124\nPhone: +91 98765 43210",
        "generate_proof": True,
    }
    response = client.post("/api/redact-pii", json=payload)
    assert response.status_code == 200

    data = response.get_json()
    assert data["status"] == "success"
    assert "sanitized_text" in data
    assert "Ramesh Kumar" not in data["sanitized_text"]
    assert "XXXXXXXX0124" in data["sanitized_text"]
    assert "[MASKED-PHONE-XXXX]" in data["sanitized_text"]

    # Entities masked counts
    entities = data["entities_masked"]
    assert entities["aadhaar"] == 1
    assert entities["phone"] == 1
    assert entities["patient_name"] == 1

    # Proof object verification
    proof = data["proof"]
    assert proof["algorithm"] == "verhoeff-d5-regex-ner-v1"
    assert len(proof["pre_hash_sha256"]) == 64
    assert len(proof["post_hash_sha256"]) == 64


def test_redact_pii_endpoint_empty_text_error(client):
    """Verify POST /api/redact-pii returns 400 when text is missing."""
    response = client.post("/api/redact-pii", json={})
    assert response.status_code == 400
    data = response.get_json()
    assert data["status"] == "error"
```

---

## 6. Implementation Plan & Actionable Steps for Builder Agent

1. **Step 1: Update `backend/app.py`**
   - Add constants: `VERHOEFF_D`, `VERHOEFF_P`, `VERHOEFF_INV`.
   - Add helper functions: `validate_verhoeff()`, `generate_verhoeff_checksum()`.
   - Add compiled regular expressions: `AADHAAR_LABEL_RE`, `BATCH_LABEL_RE`, `AADHAAR_CANDIDATE_RE`, `DOCTOR_FILTER_RE`, `PATIENT_HEADER_RE`, `MOBILE_PATTERN_RE`, `LANDLINE_PATTERN_RE`, `ABHA_PATTERN_RE`.
   - Replace lines 90-120 in `backend/app.py` with the upgraded `mask_pii()` implementation.
   - Update `redact_pii_endpoint()` in `backend/app.py:149-165` to return `sanitized_text`, `entities_masked`, and `proof`.
   - Update `digitize_rx()` in `backend/app.py:175-200` to call `mask_pii()` on `raw_text_ocr` before prompt dispatch.

2. **Step 2: Create `backend/tests/test_pii_sanitizer.py`**
   - Write the complete test suite code provided in Section 5 into `backend/tests/test_pii_sanitizer.py`.

3. **Step 3: Verification**
   - Execute:
     ```bash
     backend/venv/bin/pytest backend/tests/test_pii_sanitizer.py -v
     backend/venv/bin/pytest backend/tests/ -v
     ```
   - All tests in `test_pii_sanitizer.py` plus existing 21 tests in `test_app.py` and `test_dadi_ma.py` must pass with zero regressions.
