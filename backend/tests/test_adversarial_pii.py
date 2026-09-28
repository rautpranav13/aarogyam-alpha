"""
Adversarial Stress Test Suite for Aarogyam Backend PII Engine.
Tests:
- Varied punctuation and line-breaks in English, Hindi, and Marathi patient names.
- Standalone Hindi 'नाम - ' and Marathi 'नाव - '.
- Semicolon delimiters and inline clinical headers.
- Doctor credential protection vs patient masking (Dr. A.K. Gupta, MD vs Patient: Ramesh Gupta).
- Cryptographic SHA-256 manifest tamper resistance (1-char mutations at index 0, mid, end, whitespace).
- Empty and whitespace input handling.
- Large input scaling (100KB prescription text).
- Parity with Dart pseudonym tokens.

Run with: backend/venv/bin/pytest backend/tests/test_adversarial_pii.py -v
"""
import os
import sys
import hashlib
import time
import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app import app, mask_pii


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as test_client:
        yield test_client


# =============================================================================
# 1. Multilingual Patient De-Identification & Punctuation Variations
# =============================================================================

def test_english_punctuation_and_line_breaks():
    variations = [
        "Patient: Ramesh Kumar\nRx: Paracetamol 500mg",
        "Patient Name: Ramesh Kumar\r\nAge: 54",
        "Pt. Name: Ramesh Kumar; Age: 54",
        "Pt: Ramesh Kumar, M",
        "Patient - Ramesh Kumar\nRx: Tab",
    ]
    for text in variations:
        sanitized, meta = mask_pii(text)
        assert "Ramesh Kumar" not in sanitized, f"Raw name leaked in: {text!r} -> {sanitized!r}"
        assert "[PATIENT-ANON-F188]" in sanitized, f"Token missing in: {text!r} -> {sanitized!r}"
        assert meta["entities_masked"]["patient_name"] >= 1


def test_hindi_variations_with_semicolon_and_hyphen():
    hindi_cases = [
        "मरीज: सुरेश शर्मा\nदवा: पैरासिटामोल",
        "मरीज का नाम: सुरेश शर्मा; उम्र: ४५",
        "रोगी का नाम: सुरेश शर्मा, उम्र: ४५ वर्ष",
        "रोगी: सुरेश शर्मा\nदवा: मेटफॉर्मिन",
        "मरीज - सुरेश शर्मा\nउम्र: ४५",
    ]
    for text in hindi_cases:
        sanitized, meta = mask_pii(text)
        assert "सुरेश शर्मा" not in sanitized, f"Hindi name leaked in: {text!r} -> {sanitized!r}"
        assert "[PATIENT-ANON-BA83]" in sanitized, f"Token missing in: {text!r} -> {sanitized!r}"
        assert meta["entities_masked"]["patient_name"] >= 1


def test_hindi_standalone_nam_hyphen_dispatch_case():
    """
    Stress-tests the specific case from dispatch: 'नाम - सुरेश शर्मा;'
    """
    text = "नाम - सुरेश शर्मा; उम्र: ४५ वर्ष"
    sanitized, meta = mask_pii(text)
    # Empirically verify whether 'नाम -' is masked
    is_masked = "[PATIENT-ANON-" in sanitized
    print(f"\n[Python] Standalone 'नाम - सुरेश शर्मा;' masked: {is_masked} | Output: {sanitized!r}")
    assert "सुरेश शर्मा" not in sanitized, f"CRITICAL: Raw patient name leaked in standalone 'नाम -' anchor: {sanitized!r}"


def test_marathi_variations_with_semicolon():
    marathi_cases = [
        "रुग्णाचे नाव: आनंदी पाटील\nवय: ४५",
        "रुग्णाचे नाव - आनंदी पाटील; वय: ४५",
        "रुग्णाचे नाव: आनंदी पाटील, वय: ४५ वर्ष",
    ]
    for text in marathi_cases:
        sanitized, meta = mask_pii(text)
        assert "आनंदी पाटील" not in sanitized, f"Marathi name leaked in: {text!r} -> {sanitized!r}"
        assert "[PATIENT-ANON-603B]" in sanitized, f"Token missing in: {text!r} -> {sanitized!r}"
        assert meta["entities_masked"]["patient_name"] >= 1


def test_multi_word_names_and_honorifics():
    multi_cases = [
        ("Patient: Mr. Ramesh Kumar\nAge: 30", "Mr. Ramesh Kumar"),
        ("Patient Name: Ramesh Kumar Gupta\nAge: 45", "Ramesh Kumar Gupta"),
        ("मरीज का नाम: श्री सुरेश कुमार शर्मा\nउम्र: ५०", "श्री सुरेश कुमार शर्मा"),
        ("रुग्णाचे नाव: श्रीमती अनिता विठ्ठल जोशी\nवय: ४०", "श्रीमती अनिता विठ्ठल जोशी"),
    ]
    for input_text, raw_name in multi_cases:
        sanitized, meta = mask_pii(input_text)
        assert raw_name not in sanitized, f"Raw name '{raw_name}' leaked in: {sanitized!r}"
        assert "[PATIENT-ANON-" in sanitized
        assert meta["entities_masked"]["patient_name"] >= 1


def test_cross_platform_token_parity_with_dart():
    parity_pairs = {
        "Ramesh Kumar": "[PATIENT-ANON-F188]",
        "सुरेश कुमार": "[PATIENT-ANON-8E96]",
        "Anita Joshi": "[PATIENT-ANON-093F]",
        "आनंदी पाटील": "[PATIENT-ANON-603B]",
        "Sunita Devi": "[PATIENT-ANON-5211]",
        "सुरेश शर्मा": "[PATIENT-ANON-BA83]",
        "Mr. Ramesh Kumar": "[PATIENT-ANON-C921]",
    }
    for name, expected_token in parity_pairs.items():
        text = f"Patient: {name}\n"
        sanitized, _ = mask_pii(text)
        assert expected_token in sanitized, f"Token mismatch for {name}: expected {expected_token}, got {sanitized}"


def test_devanagari_numerals_aadhaar_and_phone():
    """Verify handling of Devanagari numerals in Aadhaar and Phone numbers."""
    aadhaar_dev = "आधार: २३४५ ६७८९ ०१२४"
    sanitized_a, meta_a = mask_pii(aadhaar_dev)
    assert meta_a["entities_masked"]["aadhaar"] >= 1
    assert "२३४५" not in sanitized_a

    phone_dev = "संपर्क: ९८७६५४३२१०"
    sanitized_p, meta_p = mask_pii(phone_dev)
    print(f"\n[Python] Devanagari phone masked count: {meta_p['entities_masked']['phone']} | Output: {sanitized_p!r}")
    assert "९८७६५४३२१०" not in sanitized_p, f"Devanagari phone leaked in: {sanitized_p!r}"


# =============================================================================
# 2. Doctor and Clinic Credential Preservation
# =============================================================================

def test_doctor_credentials_preserved_against_patient():
    prescription = """
All India Institute of Medical Sciences (AIIMS)
Cardiology OPD
Doctor: Dr. A.K. Gupta, MD (AIIMS), DM (Cardio)
Reg. No: MCI-45678
Patient: Ramesh Gupta
Age: 58 Yrs, Male
Rx: Tab Atorvastatin 20mg
"""
    sanitized, meta = mask_pii(prescription)

    # Doctor and clinic preserved
    assert "Dr. A.K. Gupta, MD (AIIMS), DM (Cardio)" in sanitized
    assert "All India Institute of Medical Sciences (AIIMS)" in sanitized
    assert "Reg. No: MCI-45678" in sanitized

    # Patient masked
    assert "Ramesh Gupta" not in sanitized
    assert "[PATIENT-ANON-C85F]" in sanitized
    assert meta["entities_masked"]["patient_name"] == 1


def test_hindi_doctor_and_patient_preservation():
    prescription = """
प्राथमिक स्वास्थ्य केंद्र (PHC)
डॉ. ए.के. गुप्ता, एम.डी. (एम्स)
मरीज का नाम: रमेश गुप्ता
उम्र: ५८ वर्ष
दवा: एस्पिरिन 75mg
"""
    sanitized, meta = mask_pii(prescription)
    assert "डॉ. ए.के. गुप्ता, एम.डी. (एम्स)" in sanitized
    assert "प्राथमिक स्वास्थ्य केंद्र (PHC)" in sanitized
    assert "रमेश गुप्ता" not in sanitized
    assert "[PATIENT-ANON-2822]" in sanitized


def test_doctor_credentials_in_patient_line_preserved():
    text = "Patient: Dr. Rajesh Verma, MBBS"
    sanitized, meta = mask_pii(text)
    assert "Dr. Rajesh Verma, MBBS" in sanitized
    assert meta["entities_masked"]["patient_name"] == 0


def test_inline_doctor_and_patient_same_line():
    text = "Dr. S. K. Sharma, MD; Patient: Ramesh Kumar"
    sanitized, meta = mask_pii(text)
    assert "Dr. S. K. Sharma, MD" in sanitized
    assert "[PATIENT-ANON-F188]" in sanitized
    assert "Ramesh Kumar" not in sanitized


# =============================================================================
# 3. Cryptographic SHA-256 Manifest Tamper Resistance
# =============================================================================

def test_tamper_simulation_single_character_mutations():
    raw_text = "Patient Name: Ramesh Kumar\nAadhaar: 2345 6789 0124\nPhone: +91 98765 43210"
    sanitized, meta = mask_pii(raw_text, mask_format="uidai")
    proof = meta["proof"]
    expected_post_sha = proof["post_hash_sha256"]

    # Verify authentic payload matches post_hash_sha256
    authentic_hash = hashlib.sha256(sanitized.encode("utf-8")).hexdigest()
    assert authentic_hash == expected_post_sha

    # Mutation 1: Flip first char
    c0 = "Y" if sanitized[0] != "Y" else "X"
    mutated_start = c0 + sanitized[1:]
    assert hashlib.sha256(mutated_start.encode("utf-8")).hexdigest() != expected_post_sha

    # Mutation 2: Mutate middle char
    mid = len(sanitized) // 2
    c_mid = "Z" if sanitized[mid] != "Z" else "A"
    mutated_mid = sanitized[:mid] + c_mid + sanitized[mid + 1:]
    assert hashlib.sha256(mutated_mid.encode("utf-8")).hexdigest() != expected_post_sha

    # Mutation 3: Mutate last char
    c_last = "1" if sanitized[-1] != "1" else "0"
    mutated_end = sanitized[:-1] + c_last
    assert hashlib.sha256(mutated_end.encode("utf-8")).hexdigest() != expected_post_sha

    # Mutation 4: Append trailing space
    mutated_ws = sanitized + " "
    assert hashlib.sha256(mutated_ws.encode("utf-8")).hexdigest() != expected_post_sha


def test_empty_and_whitespace_input_handling():
    # Empty string
    s_empty, meta_empty = mask_pii("")
    assert s_empty == ""
    assert meta_empty.total_redactions == 0
    empty_sha = hashlib.sha256(b"").hexdigest()
    assert meta_empty["proof"]["pre_hash_sha256"] == empty_sha
    assert meta_empty["proof"]["post_hash_sha256"] == empty_sha

    # Whitespace-only string
    ws_text = "   \n\t   "
    s_ws, meta_ws = mask_pii(ws_text)
    assert meta_ws.total_redactions == 0
    ws_sha = hashlib.sha256(ws_text.encode("utf-8")).hexdigest()
    assert meta_ws["proof"]["pre_hash_sha256"] == ws_sha
    assert meta_ws["proof"]["post_hash_sha256"] == ws_sha


# =============================================================================
# 4. Large Input Scaling (100KB Prescription Texts)
# =============================================================================

def test_large_input_scaling_100kb():
    single_block = """
District Hospital Pune | AIIMS Outreach Clinic
Dr. S. K. Sharma, MD, MBBS, Reg: MMC-12345
Patient Name: Ramesh Kumar, Age: 54 Yrs, Gender: Male, UHID: UHID-98124
Aadhaar: 2345 6789 0124
Contact: +91 98765 43210
Batch No: 1234-5678-9012, Exp: 12/2028
Rx: Metformin 500mg BD after food, Atorvastatin 20mg HS
मरीज का नाम: सुरेश कुमार, उम्र: ५४ वर्ष, लिंग: पुरुष
दवा: पैरासिटामोल 650mg TDS
रुग्णाचे नाव: आनंदी पाटील, वय: ४८, संपर्क: 020-25678901
औषध: अमोक्सिसिलिन 500mg BD
---
"""
    repeated_blocks = []
    total_bytes = 0
    block_bytes = len(single_block.encode("utf-8"))
    while total_bytes < 102400:
        repeated_blocks.append(single_block)
        total_bytes += block_bytes

    large_text = "".join(repeated_blocks)
    actual_kb = len(large_text.encode("utf-8")) / 1024
    assert actual_kb >= 100

    start_time = time.perf_counter()
    sanitized, meta = mask_pii(large_text, mask_format="uidai")
    elapsed = time.perf_counter() - start_time

    print(f"\n[Python] Processed {actual_kb:.2f} KB in {elapsed*1000:.2f} ms")

    # Scaling threshold: Must complete within 2.0s
    assert elapsed < 2.0, f"Scaling failed: took {elapsed:.2f}s for 100KB"

    # Verify no raw PII leaked
    assert "Ramesh Kumar" not in sanitized
    assert "सुरेश कुमार" not in sanitized
    assert "आनंदी पाटील" not in sanitized
    assert "2345 6789 0124" not in sanitized
    assert "+91 98765 43210" not in sanitized

    # Verify batch protection persisted across all 230+ blocks
    assert "Batch No: 1234-5678-9012" in sanitized

    # Verify SHA-256 matches actual sanitized output
    expected_post = hashlib.sha256(sanitized.encode("utf-8")).hexdigest()
    assert meta["proof"]["post_hash_sha256"] == expected_post
    assert meta.total_redactions > 500
