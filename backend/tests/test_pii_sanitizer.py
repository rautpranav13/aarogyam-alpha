"""
Unit and integration tests for Aarogyam Edge Privacy & PII Sanitization Engine.
Validates:
- Dihedral Group D5 Verhoeff algorithm validation and checksum generation
- Batch code false positive rejection (preserving medicine batch/lot numbers)
- Indian phone number format sanitization (mobile +91, 0, 5+5, landline)
- Multilingual patient name de-identification (English, Hindi, Marathi)
- Doctor credentials and clinic entity preservation
- Cryptographic SHA-256 pre/post manifest generation & proof verification
- Canonical cross-platform parity test vectors (V1-V10)
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
    sanitized1, meta1 = mask_pii(text1, mask_format="uidai")
    assert "1234-5678-9012" in sanitized1
    assert meta1["entities_masked"]["aadhaar"] == 0

    # 2. Valid Verhoeff digits preceded by 'Batch No:'
    text2 = "Rx: Metformin 500mg, Batch No: 2345 6789 0124, Exp: 12/2028"
    sanitized2, meta2 = mask_pii(text2, mask_format="uidai")
    assert "2345 6789 0124" in sanitized2
    assert meta2["entities_masked"]["aadhaar"] == 0

    # 3. Preceded by 'Lot:'
    text3 = "Lot number: 2345-6789-0124, Tab Amoxicillin"
    sanitized3, meta3 = mask_pii(text3, mask_format="uidai")
    assert "2345-6789-0124" in sanitized3
    assert meta3["entities_masked"]["aadhaar"] == 0

    # 4. Preceded by 'GTIN:' or 'Barcode:'
    text4 = "GTIN: 234567890124 Barcode verified"
    sanitized4, meta4 = mask_pii(text4, mask_format="uidai")
    assert "234567890124" in sanitized4
    assert meta4["entities_masked"]["aadhaar"] == 0


def test_genuine_aadhaar_masking_with_uidai_format():
    """Verify valid Aadhaar is masked to UIDAI format XXXXXXXX1234."""
    text = "Patient Identification: 2345 6789 0124, Resident of Pune"
    sanitized, meta = mask_pii(text, mask_format="uidai")
    assert "XXXXXXXX0124" in sanitized
    assert "2345" not in sanitized
    assert meta["entities_masked"]["aadhaar"] == 1


def test_genuine_aadhaar_masking_with_token_format():
    """Verify valid Aadhaar can be masked with token format."""
    text = "Patient Identification: 2345 6789 0124, Resident of Pune"
    sanitized, meta = mask_pii(text, mask_format="token")
    assert "[MASKED-AADHAAR-XXXX]" in sanitized
    assert "2345" not in sanitized
    assert meta["entities_masked"]["aadhaar"] == 1


def test_labeled_aadhaar_masking_even_with_ocr_typo():
    """Verify labeled Aadhaar (Aadhaar, आधार) is redacted even with minor checksum mismatch."""
    text1 = "Aadhaar: 2346 5789 0124 (OCR typo in checksum)"
    sanitized1, meta1 = mask_pii(text1, mask_format="uidai")
    assert "XXXXXXXX0124" in sanitized1
    assert meta1["entities_masked"]["aadhaar"] == 1

    text2 = "आधार क्र: 3456 7890 1238"
    sanitized2, meta2 = mask_pii(text2, mask_format="uidai")
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
    sanitized, meta = mask_pii(raw_text, mask_format="uidai")

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
    _, meta = mask_pii(raw_text, mask_format="uidai")

    proof_json = json.dumps(meta["proof"])
    assert "Ramesh Kumar" not in proof_json
    assert "2345 6789 0124" not in proof_json
    assert "9876543210" not in proof_json


# =============================================================================
# 6. Canonical Cross-Platform Test Vectors (V1-V10)
# =============================================================================

def test_canonical_parity_vectors_v1_through_v10():
    """Verify 10 canonical benchmark test vectors matching Dart EdgePiiSanitizer."""
    # V1: Valid Aadhaar (spaced)
    s1, m1 = mask_pii("Patient Aadhaar: 2345 6789 0124", mask_format="uidai")
    assert "XXXXXXXX0124" in s1
    assert m1["entities_masked"]["aadhaar"] == 1

    # V2: Valid Aadhaar (hyphenated)
    s2, m2 = mask_pii("UID: 2345-6789-0124", mask_format="uidai")
    assert "XXXXXXXX0124" in s2
    assert m2["entities_masked"]["aadhaar"] == 1

    # V3: Batch Number Protection
    s3, m3 = mask_pii("Batch Number: 1234-5678-9012 Exp: 12/2026", mask_format="uidai")
    assert "1234-5678-9012" in s3
    assert m3["entities_masked"]["aadhaar"] == 0

    # V4: Aadhaar Transposition Error rejection
    s4, m4 = mask_pii("Ref: 2346 5789 0124", mask_format="uidai")
    assert "2346 5789 0124" in s4
    assert m4["entities_masked"]["aadhaar"] == 0

    # V5: Indian Mobile (+91 format)
    s5, m5 = mask_pii("Contact: +91 98765 43210", mask_format="uidai")
    assert "[MASKED-PHONE-XXXX]" in s5
    assert m5["entities_masked"]["phone"] == 1

    # V6: Serial Number Rejection
    s6, m6 = mask_pii("Device SN: 5432109876, Lot: 4567", mask_format="uidai")
    assert "5432109876" in s6
    assert m6["entities_masked"]["phone"] == 0

    # V7: English Patient Name
    s7, m7 = mask_pii("Patient Name: Ramesh Kumar, Age: 54", mask_format="uidai")
    assert "[PATIENT-ANON-F188]" in s7
    assert "Ramesh Kumar" not in s7
    assert m7["entities_masked"]["patient_name"] == 1

    # V8: Hindi Patient Name
    s8, m8 = mask_pii("मरीज का नाम: सुरेश कुमार, उम्र: ४५ वर्ष", mask_format="uidai")
    assert "[PATIENT-ANON-8E96]" in s8
    assert "सुरेश कुमार" not in s8
    assert m8["entities_masked"]["patient_name"] == 1

    # V9: Doctor & Clinic Safeguard
    input_v9 = "Dr. S. K. Sharma, MD, Community Health Centre, AIIMS"
    s9, m9 = mask_pii(input_v9, mask_format="uidai")
    assert s9 == input_v9
    assert m9["entities_masked"]["patient_name"] == 0

    # V10: Composite Full Prescription
    input_v10 = (
        "Dr. Rajesh Verma, MBBS\n"
        "Apex Clinic\n"
        "Patient: Ramesh Kumar\n"
        "Ph: +91 98765 43210\n"
        "Aadhaar: 2345 6789 0124\n"
        "Batch: 1234-5678-9012\n"
        "Rx: Paracetamol 500mg"
    )
    s10, m10 = mask_pii(input_v10, mask_format="uidai")
    assert "Dr. Rajesh Verma, MBBS" in s10
    assert "Apex Clinic" in s10
    assert "[PATIENT-ANON-F188]" in s10
    assert "[MASKED-PHONE-XXXX]" in s10
    assert "XXXXXXXX0124" in s10
    assert "Batch: 1234-5678-9012" in s10
    assert "Rx: Paracetamol 500mg" in s10
    assert m10["entities_masked"]["aadhaar"] == 1
    assert m10["entities_masked"]["phone"] == 1
    assert m10["entities_masked"]["patient_name"] == 1


# =============================================================================
# 7. REST API Endpoint Integration Tests
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
