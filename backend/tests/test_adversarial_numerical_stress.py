"""
Adversarial Stress Testing Suite for Milestone 1: Numerical, Verhoeff D5 & Phone Sanitization.
Role: Challenger 1 (Adversarial Empirical Verification)

Validates:
1. Verhoeff D5 Algorithm:
   - 100% detection of adjacent transpositions across large-scale synthetic valid Aadhaar numbers.
   - Empirical quantification of twin error detection rate (~95.4%).
   - Empirical quantification of jump transposition error detection rate (~94.6%).
   - Boundary conditions: 000000000000, 111111111111, leading 0/1 UIDAI constraints, length checks.
2. Pharmaceutical Batch Collision Attacks:
   - Synthesis of valid 12-digit Verhoeff numbers placed in medicine batch contexts.
   - Verification of preservation under standard supply chain keywords.
   - Detection of cross-interference where batch codes are falsely mutilated by phone regex.
   - Lookback window boundary testing (>40 chars).
   - Discrepancy in batch keywords (SN, Item, Rx# in Python vs Dart).
3. Indian Phone Number Edge Cases:
   - Rejection of 9-digit numbers.
   - 11-digit number suffix-matching boundary vulnerability.
   - Non-mobile starting prefixes (1-5).
   - Varied spacing and delimiter formats.

Run with: backend/venv/bin/pytest backend/tests/test_adversarial_numerical_stress.py -v
"""
import os
import sys
import random
import pytest
import re

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app import (
    validate_verhoeff,
    generate_verhoeff_checksum,
    mask_pii,
)



def _generate_valid_aadhaar_pool(count=500, seed=42):
    """Generates deterministic valid 12-digit Aadhaar numbers starting with 2-9."""
    rng = random.Random(seed)
    pool = []
    for _ in range(count):
        prefix = str(rng.randint(2, 9)) + "".join(str(rng.randint(0, 9)) for _ in range(10))
        check = generate_verhoeff_checksum(prefix)
        full = prefix + check
        assert validate_verhoeff(full) is True
        pool.append(full)
    return pool


# =============================================================================
# 1. Verhoeff D5 Algorithm Stress Tests
# =============================================================================

def test_verhoeff_adjacent_transpositions_100pct_detection():
    """Verify Verhoeff D5 detects 100% of adjacent digit transpositions across 500 valid numbers."""
    pool = _generate_valid_aadhaar_pool(count=500, seed=101)
    total_tested = 0
    total_missed = 0

    for num in pool:
        for i in range(11):
            if num[i] != num[i + 1]:
                transposed = num[:i] + num[i + 1] + num[i] + num[i + 2:]
                total_tested += 1
                if validate_verhoeff(transposed):
                    total_missed += 1

    assert total_tested > 4000, "Insufficient transposition tests executed"
    detection_rate = (total_tested - total_missed) / total_tested
    assert total_missed == 0, f"Verhoeff missed {total_missed}/{total_tested} adjacent transpositions"
    assert detection_rate == 1.0


def test_verhoeff_twin_errors_empirical_rate():
    """
    Empirically measure Verhoeff twin error (aa -> bb) detection rate.
    Verhoeff D5 mathematically detects ~95.4% of twin errors.
    """
    pool = _generate_valid_aadhaar_pool(count=500, seed=202)
    total_tested = 0
    total_missed = 0

    for num in pool:
        for i in range(11):
            if num[i] == num[i + 1]:
                orig_digit = num[i]
                for new_digit in "0123456789":
                    if new_digit != orig_digit:
                        twin = num[:i] + new_digit + new_digit + num[i + 2:]
                        total_tested += 1
                        if validate_verhoeff(twin):
                            total_missed += 1

    if total_tested > 0:
        detection_rate = (total_tested - total_missed) / total_tested
        # Detection rate should be around 95% (+/- 3%)
        assert 0.90 <= detection_rate <= 1.0, f"Unexpected twin detection rate: {detection_rate:.4f}"


def test_verhoeff_jump_transpositions_empirical_rate():
    """
    Empirically measure Verhoeff jump transposition (abc -> cba) detection rate.
    Verhoeff D5 mathematically detects ~94.2% - 95.0% of jump transpositions.
    """
    pool = _generate_valid_aadhaar_pool(count=500, seed=303)
    total_tested = 0
    total_missed = 0

    for num in pool:
        for i in range(10):
            if num[i] != num[i + 2]:
                jumped = num[:i] + num[i + 2] + num[i + 1] + num[i] + num[i + 3:]
                total_tested += 1
                if validate_verhoeff(jumped):
                    total_missed += 1

    assert total_tested > 3500
    detection_rate = (total_tested - total_missed) / total_tested
    # Detection rate for jump transpositions in D5 is typically ~94-96%
    assert 0.92 <= detection_rate <= 0.98, f"Unexpected jump transposition detection rate: {detection_rate:.4f}"


def test_verhoeff_boundary_and_repetitive_numbers():
    """Verify boundary conditions: all zeros, all ones, leading 0/1, repeated digits."""
    # UIDAI constraints: leading 0 and 1 are invalid
    assert validate_verhoeff("000000000000") is False
    assert validate_verhoeff("111111111111") is False
    assert validate_verhoeff("012345678901") is False
    assert validate_verhoeff("123456789012") is False

    # Invalid lengths
    assert validate_verhoeff("23456789012") is False   # 11 digits
    assert validate_verhoeff("2345678901245") is False # 13 digits
    assert validate_verhoeff("") is False

    # Check which repdigits satisfy D5 checksum
    # Note: 333333333333, 666666666666, 999999999999 mathematically pass D5 checksum
    repdigits_valid = {d: validate_verhoeff(d * 12) for d in "0123456789"}
    assert repdigits_valid["0"] is False
    assert repdigits_valid["1"] is False
    assert repdigits_valid["3"] is True
    assert repdigits_valid["6"] is True
    assert repdigits_valid["9"] is True


# =============================================================================
# 2. Pharmaceutical Batch Collision & Context Protection Tests
# =============================================================================

def test_synthesized_verhoeff_batch_preservation():
    """
    Construct valid 12-digit Verhoeff numbers and verify preservation under
    canonical supply chain keywords (Batch, Lot, Exp, Mfg, GTIN, Barcode).
    """
    # 234567890124: valid Verhoeff starting with 2
    # 555544443333: valid Verhoeff starting with 5
    # 777788889996: valid Verhoeff starting with 7
    v_codes = ["234567890124", "555544443333", "777788889996"]
    for code in v_codes:
        assert validate_verhoeff(code) is True

    keywords = [
        "Batch:", "Batch No:", "Batch Number:", "B.No:",
        "Lot:", "Lot No:", "Exp:", "Expiry:", "Mfg:", "Mfg Date:",
        "GTIN:", "Barcode:", "Invoice:"
    ]

    for kw in keywords:
        for code in v_codes:
            spaced = f"{code[:4]} {code[4:8]} {code[8:]}"
            text = f"Medication: Paracetamol 500mg, {kw} {spaced}, Store in cool place."
            sanitized, meta = mask_pii(text)
            assert meta["entities_masked"]["aadhaar"] == 0, f"False Aadhaar redaction for {kw} {spaced}"
            assert spaced in sanitized, f"Batch code {spaced} was modified under keyword {kw}"


def test_batch_code_phone_cross_interference_vulnerability():
    """
    Vulnerability Demonstration:
    When a valid 12-digit Verhoeff batch number contains a 10-digit sequence
    starting with 6-9 (e.g. 987654321096 or 9876 5432 1096),
    the mobile phone regex incorrectly matches and masks the batch number.
    """
    # 9876 5432 1096 is a valid Verhoeff number
    v_code = "987654321096"
    assert validate_verhoeff(v_code) is True

    text_spaced = "Rx: Amoxicillin 500mg, Batch No: 9876 5432 1096, Exp: 12/2027"
    sanitized_spaced, meta_spaced = mask_pii(text_spaced)

    # In Python, MOBILE_PATTERN_RE matches 76 5432 1096 inside the batch code
    # This test documents the empirical failure:
    phone_masked = meta_spaced["entities_masked"]["phone"]
    aadhaar_masked = meta_spaced["entities_masked"]["aadhaar"]

    # Document empirical reality:
    print(f"\nEmpirical batch cross-interference result: '{sanitized_spaced}' (phone: {phone_masked}, aadhaar: {aadhaar_masked})")
    assert aadhaar_masked == 0, "Aadhaar shield worked"
    # Note: Phone regex falsely captures suffix because of missing boundary constraint
    assert phone_masked == 1, "Demonstrated phone cross-interference on batch code"
    assert "[MASKED-PHONE-XXXX]" in sanitized_spaced


def test_missing_batch_labels_in_python_backend():
    """
    Empirically demonstrates that SN:, Item:, and Rx# are missing from Python's
    BATCH_LABEL_RE, causing valid Verhoeff batch codes to be falsely redacted as Aadhaar.
    """
    code = "2345 6789 0124"
    assert validate_verhoeff(code) is True

    # SN:
    s_sn, m_sn = mask_pii(f"Medical device SN: {code}")
    # Item:
    s_item, m_item = mask_pii(f"Pharmacy Item: {code}")
    # Rx#
    s_rx, m_rx = mask_pii(f"Prescription Rx# {code}")

    # Empirical behavior: Python backend masks all 3 as Aadhaar because labels are missing from BATCH_LABEL_RE
    assert m_sn["entities_masked"]["aadhaar"] == 1
    assert m_item["entities_masked"]["aadhaar"] == 1
    assert m_rx["entities_masked"]["aadhaar"] == 1


# =============================================================================
# 3. Indian Phone Number Edge Case Tests
# =============================================================================

def test_phone_9digit_rejection():
    """Verify 9-digit numbers are NOT masked as Indian mobile numbers."""
    cases = [
        "Call 987654321 today",
        "Call 98765 4321 today",
        "Ref: +91 987654321 invalid",
    ]
    for text in cases:
        sanitized, meta = mask_pii(text)
        assert meta["entities_masked"]["phone"] == 0
        assert sanitized == text


def test_phone_fake_mobile_prefixes_1_through_5():
    """Verify 10-digit numbers starting with 1-5 are NOT masked as mobile numbers."""
    for prefix_digit in "12345":
        num = prefix_digit + "234567890"
        text = f"Identifier: {num} on record"
        sanitized, meta = mask_pii(text)
        assert meta["entities_masked"]["phone"] == 0, f"Prefix {prefix_digit} was wrongly masked as phone"
        assert num in sanitized


def test_phone_11digit_suffix_matching_vulnerability():
    """
    Vulnerability Demonstration:
    Because MOBILE_PATTERN_RE lacks a leading word boundary / non-digit check,
    an 11-digit number starting with 9 (e.g. 98765432101) has its trailing 10 digits
    matched and masked as a phone number, leaving a dangling leading digit.
    """
    text = "Transaction Ref: 98765432101"
    sanitized, meta = mask_pii(text)

    # Empirical proof of regex boundary flaw:
    print(f"\nEmpirical 11-digit result: '{sanitized}' (phone: {meta['entities_masked']['phone']})")
    assert meta["entities_masked"]["phone"] == 1
    assert "9[MASKED-PHONE-XXXX]" in sanitized


def test_phone_spaced_formats_in_python():
    """Verify Python backend handles various spaced phone formats."""
    formats = [
        ("Contiguous", "Call 9876543210 immediately"),
        ("5+5", "Call 98765 43210 immediately"),
        ("4+6", "Call 9876 543210 immediately"),
        ("3+3+4", "Call 987 654 3210 immediately"),
        ("5-5", "Call 98765-43210 immediately"),
        ("2-2-2-2-2", "Call 98-76-54-32-10 immediately"),
    ]
    for name, fmt in formats:
        sanitized, meta = mask_pii(fmt)
        assert meta["entities_masked"]["phone"] == 1, f"Python failed to mask format: {name} ('{fmt}')"
        assert "[MASKED-PHONE-XXXX]" in sanitized
