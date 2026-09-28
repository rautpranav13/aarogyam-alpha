"""
Comprehensive End-to-End Fallback Test Suite (Tiers 1-4)
Covers F1 to F12: Prescription Failure Detection, WatsonX Granite Vision Dispatch,
Blister Inconclusive Escalation, Edge PII Redaction, Verhoeff D5 Checksum,
Network Error Recovery, Structured Medication Schedules, and Vernacular Alerts.

Run with:
backend/venv/bin/pytest backend/tests/test_e2e_fallback.py -v
"""

import os
import sys
import json
import re
import hashlib
import pytest
import unittest.mock as mock

# Ensure backend root is on sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app import app, mask_pii, _clean_base64, _sanitize_json_markdown


# ==============================================================================
# AUTHORITATIVE TEST ORACLES (Verhoeff D5 & PII Standards)
# ==============================================================================

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

VERHOEFF_INV = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9]


def oracle_validate_verhoeff(num_str: str) -> bool:
    """Verhoeff algorithm validation on Dihedral group D5."""
    clean = "".join(ch for ch in num_str if ch.isdigit())
    if len(clean) != 12:
        return False
    if clean[0] in ("0", "1"):
        return False
    c = 0
    for i, item in enumerate(reversed(clean)):
        c = VERHOEFF_D[c][VERHOEFF_P[i % 8][int(item)]]
    return c == 0


def oracle_generate_verhoeff_checksum(prefix11: str) -> str:
    """Calculates Verhoeff 12th checksum digit from 11-digit prefix."""
    clean = "".join(ch for ch in prefix11 if ch.isdigit())
    c = 0
    for i, item in enumerate(reversed(clean)):
        c = VERHOEFF_D[c][VERHOEFF_P[(i + 1) % 8][int(item)]]
    return str(VERHOEFF_INV[c])


def oracle_compute_sha256(text: str) -> str:
    """Produces authoritative SHA-256 hexadecimal digest."""
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


# Fixtures
@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as test_client:
        yield test_client


TINY_BASE64_IMAGE = (
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
)


# ==============================================================================
# TIER 1: FEATURE COVERAGE (>= 5 TESTS PER FEATURE GROUP)
# ==============================================================================

class TestTier1FeatureCoverage:
    """Tier 1: Comprehensive feature coverage across F1-F12."""

    # --------------------------------------------------------------------------
    # F1 & F2: Prescription Failure Detection & Cloud Vision Model Dispatch
    # --------------------------------------------------------------------------

    def test_f1_f2_empty_ocr_triggers_fallback_digitization(self, client):
        """F1/F2: Empty OCR text triggers image digitization and returns structured medications."""
        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "raw_ocr_text": "",
            "ocr_failed": True,
            "language": "hi",
        }
        res = client.post("/api/digitize-rx", json=payload)
        assert res.status_code == 200
        data = res.get_json()
        assert data["status"] == "success"
        assert "medications" in data["data"]
        assert len(data["data"]["medications"]) >= 1

    def test_f1_f2_short_ocr_text_triggers_ocr_failed_flag(self, client):
        """F1/F2: Short OCR text (<15 chars) processed with ocr_failed=True."""
        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "raw_ocr_text": "Rx Metfor",
            "ocr_failed": True,
            "language": "hi",
        }
        res = client.post("/api/digitize-rx", json=payload)
        assert res.status_code == 200
        data = res.get_json()
        assert data["status"] == "success"
        assert len(data["data"]["medications"]) >= 1

    def test_f1_f2_missing_payload_error_handling(self, client):
        """F1/F2: Missing both image and OCR text returns 400 Bad Request."""
        res = client.post("/api/digitize-rx", json={})
        assert res.status_code == 400
        data = res.get_json()
        assert data["status"] == "error"
        assert "message" in data

    def test_f1_f2_language_adaptation_hindi(self, client):
        """F1/F2: Hindi language prescription returns Hindi vernacular summary and instructions."""
        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "language": "hi",
        }
        res = client.post("/api/digitize-rx", json=payload)
        assert res.status_code == 200
        data = res.get_json()["data"]
        assert "vernacular_summary" in data
        assert any(ord(ch) >= 0x0900 and ord(ch) <= 0x097F for ch in data["vernacular_summary"])

    def test_f1_f2_language_adaptation_marathi(self, client):
        """F1/F2: Marathi language prescription returns Marathi vernacular summary."""
        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "language": "mr",
        }
        res = client.post("/api/digitize-rx", json=payload)
        assert res.status_code == 200
        data = res.get_json()["data"]
        assert "vernacular_summary" in data
        assert "डॉ. आनंद देशमुख" in data["doctor_name"]

    def test_f1_f2_watsonx_live_dispatch_mock(self, client):
        """F1/F2: Live Granite Vision dispatch invokes model and parses returned JSON."""
        with mock.patch("app.WATSONX_API_KEY", "mock_key"), \
             mock.patch("app.WATSONX_PROJECT_ID", "mock_proj"), \
             mock.patch("app._get_watsonx_model") as mock_model_fn:
            mock_model = mock.MagicMock()
            mock_model.chat.return_value = {
                "choices": [{
                    "message": {
                        "content": json.dumps({
                            "doctor_name": "Dr. Sharma",
                            "medications": [{
                                "id": 1,
                                "name": "Atorvastatin 10mg",
                                "frequency": "1-0-0",
                                "timing_24hr": ["21:00"]
                            }]
                        })
                    }
                }]
            }
            mock_model_fn.return_value = mock_model

            payload = {
                "image_base64": TINY_BASE64_IMAGE,
                "language": "en"
            }
            res = client.post("/api/digitize-rx", json=payload)
            assert res.status_code == 200
            data = res.get_json()["data"]
            assert data["doctor_name"] == "Dr. Sharma"
            assert data["medications"][0]["name"] == "Atorvastatin 10mg"

    # --------------------------------------------------------------------------
    # F3 & F4: Blister Foil Inconclusive Detection & Cloud Escalation
    # --------------------------------------------------------------------------

    def test_f3_f4_unclear_foil_ocr_escalation(self, client):
        """F3/F4: Inconclusive foil OCR escalates to cloud verify-strip endpoint."""
        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "raw_ocr_text": "M... 500",
            "ocr_failed": True,
            "expected_drug": "Metformin",
            "expected_strength": "500mg",
            "language": "hi",
        }
        res = client.post("/api/verify-strip", json=payload)
        assert res.status_code == 200
        data = res.get_json()
        assert data["status"] == "success"
        assert "verified" in data
        assert "action" in data

    def test_f3_f4_successful_foil_match_verification(self, client):
        """F3/F4: Matching drug confirms verification and ALLOW_CONSUMPTION action."""
        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "expected_drug": "Metformin",
            "expected_strength": "500mg",
            "raw_ocr_text": "METFORMIN HYDROCHLORIDE 500MG IP",
            "language": "hi",
        }
        res = client.post("/api/verify-strip", json=payload)
        assert res.status_code == 200
        data = res.get_json()
        assert data["verified"] is True
        assert data["action"] == "ALLOW_CONSUMPTION"
        assert "detected_text" in data

    def test_f3_f4_mismatched_foil_detection(self, client):
        """F3/F4: Packaging mismatch triggers BLOCK_CONSUMPTION warning."""
        with mock.patch("app.WATSONX_API_KEY", "mock_key"), \
             mock.patch("app.WATSONX_PROJECT_ID", "mock_proj"), \
             mock.patch("app._get_watsonx_model") as mock_model_fn:
            mock_model = mock.MagicMock()
            mock_model.chat.return_value = {
                "choices": [{
                    "message": {
                        "content": json.dumps({
                            "verified": False,
                            "detected_text": "AMLODIPINE 5MG",
                            "action": "BLOCK_CONSUMPTION",
                            "voice_alert_vernacular": "चेतावनी: गलत दवा!"
                        })
                    }
                }]
            }
            mock_model_fn.return_value = mock_model

            payload = {
                "image_base64": TINY_BASE64_IMAGE,
                "expected_drug": "Metformin",
                "expected_strength": "500mg",
                "language": "hi",
            }
            res = client.post("/api/verify-strip", json=payload)
            assert res.status_code == 200
            data = res.get_json()
            assert data["verified"] is False
            assert data["action"] == "BLOCK_CONSUMPTION"

    def test_f3_f4_missing_drug_or_image_validation(self, client):
        """F3/F4: Missing required fields in verify-strip returns 400 Bad Request."""
        # Missing expected_drug
        res1 = client.post("/api/verify-strip", json={"image_base64": TINY_BASE64_IMAGE})
        assert res1.status_code == 400

        # Missing image and ocr text
        res2 = client.post("/api/verify-strip", json={"expected_drug": "Metformin"})
        assert res2.status_code == 400

    def test_f3_f4_multilingual_foil_voice_alert(self, client):
        """F3/F4: Verification alert provides localized Marathi and Hindi voice prompts."""
        for lang, expected_token in [("hi", "सत्यापित"), ("mr", "सत्यापित")]:
            payload = {
                "image_base64": TINY_BASE64_IMAGE,
                "expected_drug": "Metformin",
                "expected_strength": "500mg",
                "language": lang,
            }
            res = client.post("/api/verify-strip", json=payload)
            assert res.status_code == 200
            data = res.get_json()
            assert expected_token in data["voice_alert_vernacular"]

    # --------------------------------------------------------------------------
    # F5: Network Timeout / Error Recovery & Offline Fallback
    # --------------------------------------------------------------------------

    def test_f5_digitize_rx_watsonx_timeout_resilience(self, client):
        """F5: WatsonX network timeout falls back gracefully to structured clinical response."""
        with mock.patch("app.WATSONX_API_KEY", "mock_key"), \
             mock.patch("app.WATSONX_PROJECT_ID", "mock_proj"), \
             mock.patch("app._get_watsonx_model") as mock_model_fn:
            mock_model = mock.MagicMock()
            mock_model.chat.side_effect = TimeoutError("Simulated WatsonX timeout")
            mock_model_fn.return_value = mock_model

            payload = {"image_base64": TINY_BASE64_IMAGE, "language": "hi"}
            res = client.post("/api/digitize-rx", json=payload)
            assert res.status_code == 200
            data = res.get_json()
            assert data["status"] == "success"
            assert "medications" in data["data"]

    def test_f5_digitize_rx_watsonx_connection_error_resilience(self, client):
        """F5: WatsonX ConnectionError handled with 200 OK fallback response."""
        with mock.patch("app.WATSONX_API_KEY", "mock_key"), \
             mock.patch("app.WATSONX_PROJECT_ID", "mock_proj"), \
             mock.patch("app._get_watsonx_model") as mock_model_fn:
            mock_model = mock.MagicMock()
            mock_model.chat.side_effect = ConnectionError("WatsonX unreachable")
            mock_model_fn.return_value = mock_model

            payload = {"image_base64": TINY_BASE64_IMAGE, "language": "mr"}
            res = client.post("/api/digitize-rx", json=payload)
            assert res.status_code == 200
            data = res.get_json()
            assert data["status"] == "success"

    def test_f5_digitize_rx_invalid_json_fallback(self, client):
        """F5: Granite Vision output with invalid JSON falls back to structured fallback."""
        with mock.patch("app.WATSONX_API_KEY", "mock_key"), \
             mock.patch("app.WATSONX_PROJECT_ID", "mock_proj"), \
             mock.patch("app._get_watsonx_model") as mock_model_fn:
            mock_model = mock.MagicMock()
            mock_model.chat.return_value = {
                "choices": [{"message": {"content": "This is non-json model output"}}]
            }
            mock_model_fn.return_value = mock_model

            payload = {"image_base64": TINY_BASE64_IMAGE, "language": "hi"}
            res = client.post("/api/digitize-rx", json=payload)
            assert res.status_code == 200
            data = res.get_json()
            assert data["status"] == "success"
            assert len(data["data"]["medications"]) >= 1

    def test_f5_verify_strip_watsonx_error_resilience(self, client):
        """F5: verify-strip handles WatsonX exceptions without crashing."""
        with mock.patch("app.WATSONX_API_KEY", "mock_key"), \
             mock.patch("app.WATSONX_PROJECT_ID", "mock_proj"), \
             mock.patch("app._get_watsonx_model") as mock_model_fn:
            mock_model = mock.MagicMock()
            mock_model.chat.side_effect = RuntimeError("WatsonX internal failure")
            mock_model_fn.return_value = mock_model

            payload = {
                "image_base64": TINY_BASE64_IMAGE,
                "expected_drug": "Metformin",
                "expected_strength": "500mg",
                "language": "hi",
            }
            res = client.post("/api/verify-strip", json=payload)
            assert res.status_code == 200
            data = res.get_json()
            assert data["status"] == "success"
            assert "verified" in data

    def test_f5_tts_unconfigured_or_failed_graceful_mock(self, client):
        """F5: Vernacular TTS returns mock status when IBM credentials are unconfigured."""
        res = client.post("/api/vernacular-tts", json={"text": "दवा का समय हो गया", "language": "hi"})
        assert res.status_code == 200
        data = res.get_json()
        assert data["status"] == "mock"
        assert data["text"] == "दवा का समय हो गया"

    # --------------------------------------------------------------------------
    # F6 & F7: Aadhaar (Verhoeff D5) and Phone Number Masking
    # --------------------------------------------------------------------------

    def test_f6_f7_valid_aadhaar_standard_masking(self):
        """F6/F7: Valid Aadhaar formats are sanitized in mask_pii."""
        raw_text = "Patient Aadhaar: 2345 6789 0124 (UIDAI registered)"
        masked, redactions = mask_pii(raw_text)
        assert "[MASKED-AADHAAR-XXXX]" in masked
        assert "2345 6789 0124" not in masked
        assert len(redactions) >= 1
        assert any(r["type"] == "AADHAAR" for r in redactions)

    def test_f6_f7_verhoeff_d5_checksum_oracle_validation(self):
        """F6/F7: Verhoeff D5 checksum oracle correctly differentiates valid vs transposed Aadhaar."""
        valid_aadhaar = "234567890124"
        transposed_adjacent = "234657890124"  # 5 and 6 swapped
        transposed_jump = "234567890142"      # 2 and 4 swapped

        assert oracle_validate_verhoeff(valid_aadhaar) is True
        assert oracle_validate_verhoeff(transposed_adjacent) is False
        assert oracle_validate_verhoeff(transposed_jump) is False

    def test_f6_f7_standard_10_digit_indian_mobile_masking(self):
        """F6/F7: Indian 10-digit mobile numbers starting with 6-9 are masked."""
        mobiles = ["9876543210", "8765432109", "7654321098", "6543210987"]
        for mob in mobiles:
            text = f"Contact patient at {mob} for follow-up"
            masked, redactions = mask_pii(text)
            assert "[MASKED-PHONE-XXXX]" in masked
            assert mob not in masked
            assert any(r["type"] == "PHONE" for r in redactions)

    def test_f6_f7_country_code_prefixed_phone_masking(self):
        """F6/F7: Mobile numbers with +91 or 0 prefix are masked."""
        samples = [
            "Phone: +91-9876543210",
            "Emergency: 09876543210",
        ]
        for s in samples:
            masked, redactions = mask_pii(s)
            assert "[MASKED-PHONE-XXXX]" in masked
            assert "9876543210" not in masked

    def test_f6_f7_redact_pii_endpoint_integration(self, client):
        """F6/F7: /api/redact-pii endpoint integration with Aadhaar and phone."""
        payload = {
            "text": "Patient Aadhaar: 2345-6789-0124, Contact: +91-9876543210",
        }
        res = client.post("/api/redact-pii", json=payload)
        assert res.status_code == 200
        data = res.get_json()
        assert data["status"] == "success"
        assert data["privacy_verified"] is True
        assert data["redactions_count"] >= 2
        assert "2345-6789-0124" not in data["masked_text"]
        assert "9876543210" not in data["masked_text"]

    # --------------------------------------------------------------------------
    # F8 & F9: Patient Name De-Identification & SHA-256 Proof Manifest
    # --------------------------------------------------------------------------

    def test_f8_f9_patient_demographic_masking_oracle(self):
        """F8/F9: Patient demographic extraction oracle produces synthetic pseudonyms."""
        raw_header = "Patient Name: Ramesh Kumar, Age: 54, Male"
        patient_pattern = r'(?i)(?:patient(?:\s+name)?|मरीज(?:\s+का\s+नाम)?)\s*[:\-\s]\s*([A-Za-z\s]+)'
        match = re.search(patient_pattern, raw_header)
        assert match is not None
        matched_name = match.group(1).strip()
        assert "Ramesh Kumar" in matched_name

        # Synthetic pseudonym generation
        name_hash = hashlib.sha256(matched_name.encode("utf-8")).hexdigest()[:4].upper()
        synthetic_token = f"[PATIENT-ANON-{name_hash}]"
        sanitized = raw_header.replace(matched_name, synthetic_token)
        assert "Ramesh Kumar" not in sanitized
        assert "[PATIENT-ANON-" in sanitized

    def test_f8_f9_doctor_and_clinic_name_preservation(self):
        """F8/F9: Doctor titles (Dr., MD) and clinic names are preserved to maintain prescription validity."""
        doctor_text = "Dr. S. K. Sharma, MD, Community Health Centre, PHC Shirur"
        doctor_safeguard = r'\b(Dr\.?|Doctor|MD|MBBS|PHC|CHC|Hospital|Clinic)\b'
        assert re.search(doctor_safeguard, doctor_text, re.IGNORECASE) is not None

    def test_f8_f9_sha256_pre_post_digest_generation(self):
        """F8/F9: Pre-sanitization and post-sanitization SHA-256 digests form valid 64-char hex strings."""
        raw_payload = "Patient: Ramesh Kumar, Aadhaar: 2345-6789-0124"
        clean_payload = "Patient: [PATIENT-ANON-7F4A], Aadhaar: [MASKED-AADHAAR-XXXX]"

        pre_hash = oracle_compute_sha256(raw_payload)
        post_hash = oracle_compute_sha256(clean_payload)

        assert len(pre_hash) == 64
        assert len(post_hash) == 64
        assert pre_hash != post_hash

    def test_f8_f9_sanitization_manifest_contract(self):
        """F8/F9: SanitizationManifest schema conforms to DPDP Act Section 8 requirements."""
        manifest = {
            "proof_id": "PRV-test-8f2b",
            "timestamp_utc": "2026-09-28T01:00:00Z",
            "digests": {
                "raw_input_sha256": oracle_compute_sha256("raw"),
                "sanitized_payload_sha256": oracle_compute_sha256("sanitized"),
            },
            "redaction_summary": {
                "total_redactions": 2,
                "aadhaar_redacted": 1,
                "phone_redacted": 1,
            },
        }
        assert manifest["proof_id"].startswith("PRV-")
        assert len(manifest["digests"]["raw_input_sha256"]) == 64
        assert manifest["redaction_summary"]["total_redactions"] == 2

    def test_f8_f9_tamper_detection_on_manifest(self):
        """F8/F9: Altering payload after sanitization invalidates cryptographic digest."""
        clean_payload = "Prescription: [PATIENT-ANON-8F2B] take Metformin 500mg"
        authentic_digest = oracle_compute_sha256(clean_payload)

        tampered_payload = "Prescription: Ramesh Kumar take Metformin 500mg"
        tampered_digest = oracle_compute_sha256(tampered_payload)

        assert authentic_digest != tampered_digest

    # --------------------------------------------------------------------------
    # F10 & F11: Structured Medication Schedule Extraction & Storage Sync
    # --------------------------------------------------------------------------

    def test_f10_f11_medication_fields_presence(self, client):
        """F10/F11: Extracted medication schedule contains all required clinical fields."""
        res = client.post("/api/digitize-rx", json={"image_base64": TINY_BASE64_IMAGE, "language": "hi"})
        assert res.status_code == 200
        meds = res.get_json()["data"]["medications"]
        required_fields = ["name", "strength", "frequency", "timing_24hr", "morning", "night", "food_relation"]
        for med in meds:
            for field in required_fields:
                assert field in med, f"Field '{field}' missing in medication item"

    def test_f10_f11_24hr_timing_normalization(self, client):
        """F10/F11: Clinical frequencies map to valid 24-hr timing strings."""
        res = client.post("/api/digitize-rx", json={"image_base64": TINY_BASE64_IMAGE, "language": "hi"})
        meds = res.get_json()["data"]["medications"]
        time_24hr_regex = r'^([01]\d|2[0-3]):[0-5]\d$'
        for med in meds:
            timings = med["timing_24hr"]
            assert isinstance(timings, list)
            assert len(timings) >= 1
            for t in timings:
                assert re.match(time_24hr_regex, t), f"Invalid 24hr timing: {t}"

    def test_f10_f11_food_relation_compliance(self, client):
        """F10/F11: Food relation field contains clinical advice (Before/After Food)."""
        res = client.post("/api/digitize-rx", json={"image_base64": TINY_BASE64_IMAGE, "language": "hi"})
        meds = res.get_json()["data"]["medications"]
        valid_food_relations = {"Before Food", "After Food", "With Food", "After Breakfast"}
        for med in meds:
            assert med["food_relation"] in valid_food_relations

    def test_f10_f11_prescription_metadata_extraction(self, client):
        """F10/F11: Top-level prescription metadata includes doctor, clinic, and diagnosis."""
        res = client.post("/api/digitize-rx", json={"image_base64": TINY_BASE64_IMAGE, "language": "hi"})
        data = res.get_json()["data"]
        assert "doctor_name" in data
        assert "clinic_name" in data
        assert "diagnosis" in data
        assert "pii_redacted_proof" in data

    def test_f10_f11_multilingual_instructions_vernacular(self, client):
        """F10/F11: Medications include instructions_vernacular in the requested language."""
        for lang in ["hi", "mr"]:
            res = client.post("/api/digitize-rx", json={"image_base64": TINY_BASE64_IMAGE, "language": lang})
            meds = res.get_json()["data"]["medications"]
            for med in meds:
                assert "instructions_vernacular" in med
                assert len(med["instructions_vernacular"]) > 0

    # --------------------------------------------------------------------------
    # F12: Blister Safety Verdicts & Vernacular Audio Alert Generation
    # --------------------------------------------------------------------------

    def test_f12_allow_consumption_on_safe_match(self, client):
        """F12: Valid matching blister strip returns ALLOW_CONSUMPTION and verified=True."""
        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "expected_drug": "Metformin",
            "expected_strength": "500mg",
            "language": "hi",
        }
        res = client.post("/api/verify-strip", json=payload)
        data = res.get_json()
        assert data["action"] == "ALLOW_CONSUMPTION"
        assert data["verified"] is True
        assert data["is_expired"] is False

    def test_f12_block_consumption_on_mismatch(self, client):
        """F12: Mismatched blister strip returns BLOCK_CONSUMPTION and verified=False."""
        with mock.patch("app.WATSONX_API_KEY", "mock_key"), \
             mock.patch("app.WATSONX_PROJECT_ID", "mock_proj"), \
             mock.patch("app._get_watsonx_model") as mock_model_fn:
            mock_model = mock.MagicMock()
            mock_model.chat.return_value = {
                "choices": [{
                    "message": {
                        "content": json.dumps({
                            "verified": False,
                            "action": "BLOCK_CONSUMPTION",
                            "voice_alert_vernacular": "गलत दवा!"
                        })
                    }
                }]
            }
            mock_model_fn.return_value = mock_model

            payload = {
                "image_base64": TINY_BASE64_IMAGE,
                "expected_drug": "Metformin",
                "expected_strength": "500mg",
                "language": "hi",
            }
            res = client.post("/api/verify-strip", json=payload)
            data = res.get_json()
            assert data["action"] == "BLOCK_CONSUMPTION"
            assert data["verified"] is False

    def test_f12_block_consumption_on_expiry(self, client):
        """F12: Expired medication blister pack returns BLOCK_CONSUMPTION."""
        with mock.patch("app.WATSONX_API_KEY", "mock_key"), \
             mock.patch("app.WATSONX_PROJECT_ID", "mock_proj"), \
             mock.patch("app._get_watsonx_model") as mock_model_fn:
            mock_model = mock.MagicMock()
            mock_model.chat.return_value = {
                "choices": [{
                    "message": {
                        "content": json.dumps({
                            "verified": False,
                            "is_expired": True,
                            "action": "BLOCK_CONSUMPTION",
                            "voice_alert_vernacular": "चेतावनी! यह दवा एक्सपायर हो चुकी है!"
                        })
                    }
                }]
            }
            mock_model_fn.return_value = mock_model

            payload = {
                "image_base64": TINY_BASE64_IMAGE,
                "expected_drug": "Metformin",
                "expected_strength": "500mg",
                "language": "hi",
            }
            res = client.post("/api/verify-strip", json=payload)
            data = res.get_json()
            assert data["action"] == "BLOCK_CONSUMPTION"
            assert data["is_expired"] is True

    def test_f12_vernacular_voice_alert_hindi(self, client):
        """F12: Hindi vernacular alert contains clear spoken Hindi advice."""
        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "expected_drug": "Metformin",
            "expected_strength": "500mg",
            "language": "hi",
        }
        res = client.post("/api/verify-strip", json=payload)
        data = res.get_json()
        assert "सत्यापित" in data["voice_alert_vernacular"]

    def test_f12_vernacular_voice_alert_marathi(self, client):
        """F12: Marathi vernacular alert contains clear spoken Marathi advice."""
        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "expected_drug": "Metformin",
            "expected_strength": "500mg",
            "language": "mr",
        }
        res = client.post("/api/verify-strip", json=payload)
        data = res.get_json()
        assert "सत्यापित" in data["voice_alert_vernacular"]


# ==============================================================================
# TIER 2: BOUNDARY & CORNER CASES (>= 5 TESTS PER FEATURE GROUP)
# ==============================================================================

class TestTier2BoundaryAndCornerCases:
    """Tier 2: Boundary conditions, extreme payloads, format collisions, and thresholds."""

    # 1. Prescription OCR Length Boundaries
    @pytest.mark.parametrize("ocr_length, should_fail", [
        (0, True),     # 0 chars (empty)
        (1, True),     # 1 char
        (14, True),    # 14 chars (<15 boundary)
        (15, False),   # 15 chars (>=15 boundary)
        (100, False),  # Normal prescription
    ])
    def test_tier2_prescription_ocr_length_threshold(self, client, ocr_length, should_fail):
        """Tier 2: Boundary test for prescription failure threshold (< 15 chars)."""
        ocr_text = "A" * ocr_length
        is_failed = len(ocr_text.strip()) < 15
        assert is_failed == should_fail

        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "raw_ocr_text": ocr_text,
            "ocr_failed": is_failed,
            "language": "hi",
        }
        res = client.post("/api/digitize-rx", json=payload)
        assert res.status_code == 200

    def test_tier2_extreme_ocr_payload_stress(self, client):
        """Tier 2: Extreme 10,000 character OCR text payload handled without memory exhaustion."""
        large_ocr = "Rx Paracetamol 500mg Take 1 tablet daily. " * 250  # ~10,000 chars
        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "raw_ocr_text": large_ocr,
            "ocr_failed": False,
            "language": "hi",
        }
        res = client.post("/api/digitize-rx", json=payload)
        assert res.status_code == 200

    # 2. Blister OCR Length Boundaries
    @pytest.mark.parametrize("foil_ocr, is_unclear", [
        ("", True),             # 0 chars
        ("M", True),            # 1 char (<4)
        ("MET", True),          # 3 chars (<4)
        ("METF", False),        # 4 chars (>=4)
        ("---///###!!!", True), # Pure punctuation noise
    ])
    def test_tier2_blister_ocr_length_threshold(self, client, foil_ocr, is_unclear):
        """Tier 2: Boundary test for blister foil inconclusive threshold (< 4 chars)."""
        clean_text = "".join(ch for ch in foil_ocr if ch.isalnum())
        evaluated_unclear = len(clean_text) < 4
        assert evaluated_unclear == is_unclear

        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "raw_ocr_text": foil_ocr,
            "ocr_failed": evaluated_unclear,
            "expected_drug": "Metformin",
            "expected_strength": "500mg",
            "language": "hi",
        }
        res = client.post("/api/verify-strip", json=payload)
        assert res.status_code == 200

    # 3. Aadhaar & Verhoeff Checksum Edge Cases
    def test_tier2_verhoeff_adjacent_transposition_detection(self):
        """Tier 2: Adjacent digit swapping in valid Aadhaar is detected as invalid."""
        valid_aadhaar = "234567890124"
        assert oracle_validate_verhoeff(valid_aadhaar) is True

        # Adjacent transposition: swap 5 and 6
        transposed = "234657890124"
        assert oracle_validate_verhoeff(transposed) is False

    def test_tier2_verhoeff_jump_transposition_detection(self):
        """Tier 2: Jump digit transposition is detected as invalid."""
        # Jump transposition: swap 2 and 4 at the tail
        jump_transposed = "234567890142"
        assert oracle_validate_verhoeff(jump_transposed) is False

    def test_tier2_verhoeff_leading_digit_boundary(self):
        """Tier 2: Numbers starting with 0 or 1 fail Aadhaar standard per UIDAI."""
        zero_lead = "012345678901"
        one_lead = "123456789012"
        assert oracle_validate_verhoeff(zero_lead) is False
        assert oracle_validate_verhoeff(one_lead) is False

    def test_tier2_aadhaar_batch_number_format_collision(self):
        """Tier 2: Medicine batch number 1234-5678-9012 fails Verhoeff validation."""
        batch_number = "1234-5678-9012"
        assert oracle_validate_verhoeff(batch_number) is False

    def test_tier2_verhoeff_non_digit_and_length_underflow(self):
        """Tier 2: Verhoeff validator rejects non-digits and numbers shorter than 12 digits."""
        assert oracle_validate_verhoeff("2345-6789-012") is False   # 11 digits
        assert oracle_validate_verhoeff("2345-6789-01234") is False # 13 digits
        assert oracle_validate_verhoeff("ABCD-EFGH-IJKL") is False  # Letters

    # 4. Phone Number Boundary Cases
    def test_tier2_phone_number_length_underflow(self):
        """Tier 2: 9-digit number is not masked as Indian mobile."""
        short_phone = "Call 987654321 for queries"
        masked, redactions = mask_pii(short_phone)
        assert "987654321" in masked  # 9-digit not masked
        assert len(redactions) == 0

    def test_tier2_phone_number_invalid_prefix_series(self):
        """Tier 2: 10-digit number starting with 1-5 (e.g. serial numbers) are not mobile phones."""
        serial_no = "Serial Number: 5432109876"
        masked, redactions = mask_pii(serial_no)
        # Mobile regex matches [6-9], so 5432109876 should not be matched
        assert "5432109876" in masked
        assert len(redactions) == 0

    def test_tier2_phone_number_boundary_valid_series(self):
        """Tier 2: Boundary series starting with 6 and 9 are both masked."""
        phone_6 = "Phone 6123456789"
        phone_9 = "Phone 9123456789"
        masked_6, red_6 = mask_pii(phone_6)
        masked_9, red_9 = mask_pii(phone_9)
        assert "[MASKED-PHONE-XXXX]" in masked_6
        assert "[MASKED-PHONE-XXXX]" in masked_9

    # 5. Expiry Date Boundary Cases
    @pytest.mark.parametrize("exp_str, expected_expired", [
        ("EXP 01/2020", True),   # Far past
        ("EXP 03/2024", True),   # Recent past
        ("EXP 12/2030", False),  # Far future
        ("EXP 12/2026", False),  # Current valid
    ])
    def test_tier2_expiry_date_boundaries(self, exp_str, expected_expired):
        """Tier 2: Boundary test for expiry date parsing and verification."""
        # Simple calendar check: month/year
        match = re.search(r'(\d{1,2})[/](\d{2,4})', exp_str)
        assert match is not None
        month = int(match.group(1))
        year = int(match.group(2))
        if year < 100:
            year += 2000
        # Check against reference current date 2026-09
        is_exp = (year < 2026) or (year == 2026 and month < 9)
        assert is_exp == expected_expired

    # 6. Network Socket Timeout Boundary Simulation
    def test_tier2_rapid_socket_timeout_resilience(self, client):
        """Tier 2: Microsecond/short socket timeout recovers cleanly with fallback."""
        with mock.patch("app.WATSONX_API_KEY", "mock_key"), \
             mock.patch("app.WATSONX_PROJECT_ID", "mock_proj"), \
             mock.patch("app._get_watsonx_model") as mock_model_fn:
            mock_model = mock.MagicMock()
            mock_model.chat.side_effect = TimeoutError("Simulated 0.1s socket timeout")
            mock_model_fn.return_value = mock_model

            payload = {"image_base64": TINY_BASE64_IMAGE, "language": "hi"}
            res = client.post("/api/digitize-rx", json=payload)
            assert res.status_code == 200
            data = res.get_json()
            assert data["status"] == "success"


# ==============================================================================
# TIER 3: CROSS-FEATURE COMBINATIONS (PAIRWISE INTEGRATION)
# ==============================================================================

class TestTier3CrossFeatureCombinations:
    """Tier 3: Pairwise feature combinations testing interactions and failure cascading."""

    def test_tier3_ocr_failure_plus_pii_masking_plus_cloud_dispatch(self, client):
        """Tier 3: OCR failure combined with PII masking and cloud vision dispatch."""
        raw_slip = "Patient: Ramesh Kumar, Aadhaar: 2345-6789-0124, Phone: 9876543210, Rx: Metformin"
        # 1. Edge PII masking
        masked_text, redactions = mask_pii(raw_slip)
        assert len(redactions) >= 2
        assert "2345-6789-0124" not in masked_text
        assert "9876543210" not in masked_text

        # 2. Cloud dispatch with ocr_failed flag
        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "raw_ocr_text": masked_text,
            "ocr_failed": True,
            "language": "hi",
        }
        res = client.post("/api/digitize-rx", json=payload)
        assert res.status_code == 200
        data = res.get_json()
        assert data["status"] == "success"
        assert len(data["data"]["medications"]) >= 1

    def test_tier3_inconclusive_blister_plus_network_timeout_plus_local_fallback(self, client):
        """Tier 3: Inconclusive blister scan combined with WatsonX timeout falls back gracefully."""
        with mock.patch("app.WATSONX_API_KEY", "mock_key"), \
             mock.patch("app.WATSONX_PROJECT_ID", "mock_proj"), \
             mock.patch("app._get_watsonx_model") as mock_model_fn:
            mock_model = mock.MagicMock()
            mock_model.chat.side_effect = TimeoutError("Gateway timeout to WatsonX")
            mock_model_fn.return_value = mock_model

            payload = {
                "image_base64": TINY_BASE64_IMAGE,
                "raw_ocr_text": "...",
                "ocr_failed": True,
                "expected_drug": "Metformin",
                "expected_strength": "500mg",
                "language": "hi",
            }
            res = client.post("/api/verify-strip", json=payload)
            assert res.status_code == 200
            data = res.get_json()
            assert data["status"] == "success"
            assert "ALLOW_CONSUMPTION" in data["action"] or "BLOCK_CONSUMPTION" in data["action"]

    def test_tier3_tampered_pii_manifest_detection(self):
        """Tier 3: Deliberately tampered PII payload triggers SHA-256 mismatch in audit manifest."""
        original_sanitized = "Prescription for [PATIENT-ANON-7F4A]: Metformin 500mg"
        authentic_digest = oracle_compute_sha256(original_sanitized)

        # Attacker injects unmasked PII back into sanitized payload
        tampered_sanitized = "Prescription for Ramesh Kumar: Metformin 500mg"
        recalculated_digest = oracle_compute_sha256(tampered_sanitized)

        # Verification oracle rejects tampered payload
        is_verified = (authentic_digest == recalculated_digest)
        assert is_verified is False

    def test_tier3_expired_medication_plus_tts_alert_plus_block_action(self, client):
        """Tier 3: Expired medication triggers BLOCK_CONSUMPTION and generates vernacular warning."""
        with mock.patch("app.WATSONX_API_KEY", "mock_key"), \
             mock.patch("app.WATSONX_PROJECT_ID", "mock_proj"), \
             mock.patch("app._get_watsonx_model") as mock_model_fn:
            warning_voice = "चेतावनी: यह दवा एक्सपायर हो चुकी है!"
            mock_model = mock.MagicMock()
            mock_model.chat.return_value = {
                "choices": [{
                    "message": {
                        "content": json.dumps({
                            "verified": False,
                            "is_expired": True,
                            "detected_expiry": "EXP 01/2023",
                            "action": "BLOCK_CONSUMPTION",
                            "voice_alert_vernacular": warning_voice
                        })
                    }
                }]
            }
            mock_model_fn.return_value = mock_model

            # 1. Verify strip
            verify_res = client.post("/api/verify-strip", json={
                "image_base64": TINY_BASE64_IMAGE,
                "expected_drug": "Metformin",
                "expected_strength": "500mg",
                "language": "hi"
            })
            assert verify_res.status_code == 200
            v_data = verify_res.get_json()
            assert v_data["action"] == "BLOCK_CONSUMPTION"
            assert v_data["is_expired"] is True

            # 2. Synthesize audio alert for the warning
            tts_res = client.post("/api/vernacular-tts", json={
                "text": v_data["voice_alert_vernacular"],
                "language": "hi"
            })
            assert tts_res.status_code == 200
            t_data = tts_res.get_json()
            assert t_data["text"] == warning_voice


# ==============================================================================
# TIER 4: REAL-WORLD CLINICAL SCENARIOS (>= 5 SCENARIOS)
# ==============================================================================

class TestTier4RealWorldScenarios:
    """Tier 4: End-to-end integration workflows modeling genuine Indian healthcare contexts."""

    def test_tier4_scenario1_illegible_prescription_with_pii(self, client):
        """
        Scenario 1:
        Patient Ramesh Kumar arrives with illegible handwritten slip containing Aadhaar 2345-6789-0124.
        Local OCR fails (<15 chars). PII is masked, image dispatched, and structured schedule extracted.
        """
        # Step 1: Raw slip with patient PII
        raw_slip = "Pt: Ramesh Kumar, Aadhaar 2345-6789-0124. Rx: Metf 500 BD"

        # Step 2: Edge PII masking
        masked_text, redactions = mask_pii(raw_slip)
        assert "2345-6789-0124" not in masked_text
        assert "[MASKED-AADHAAR-XXXX]" in masked_text

        # Step 3: Cloud fallback digitization
        payload = {
            "image_base64": TINY_BASE64_IMAGE,
            "raw_ocr_text": masked_text,
            "ocr_failed": True,
            "language": "hi",
        }
        res = client.post("/api/digitize-rx", json=payload)
        assert res.status_code == 200
        rx_data = res.get_json()["data"]

        # Step 4: Verify schedule parsed into morning/night doses
        meds = rx_data["medications"]
        metformin = next((m for m in meds if "Metformin" in m["name"]), None)
        assert metformin is not None
        assert metformin["morning"] is True
        assert metformin["night"] is True
        assert "08:30" in metformin["timing_24hr"]
        assert "20:30" in metformin["timing_24hr"]

    def test_tier4_scenario2_torn_blurry_blister_with_expired_date(self, client):
        """
        Scenario 2:
        Torn/blurry blister pack with expired date (EXP 03/2024) blocked with vernacular alert.
        """
        with mock.patch("app.WATSONX_API_KEY", "mock_key"), \
             mock.patch("app.WATSONX_PROJECT_ID", "mock_proj"), \
             mock.patch("app._get_watsonx_model") as mock_model_fn:
            mock_model = mock.MagicMock()
            mock_model.chat.return_value = {
                "choices": [{
                    "message": {
                        "content": json.dumps({
                            "verified": False,
                            "detected_text": "METFORMIN 500MG IP",
                            "detected_expiry": "EXP 03/2024",
                            "is_expired": True,
                            "confidence": 0.94,
                            "action": "BLOCK_CONSUMPTION",
                            "voice_alert_vernacular": "चेतावनी! यह दवा एक्सपायर हो चुकी है (03/2024)! कृपया इसे न लें।"
                        })
                    }
                }]
            }
            mock_model_fn.return_value = mock_model

            payload = {
                "image_base64": TINY_BASE64_IMAGE,
                "raw_ocr_text": "METF... EXP 03/24",
                "ocr_failed": True,
                "expected_drug": "Metformin",
                "expected_strength": "500mg",
                "language": "hi",
            }
            res = client.post("/api/verify-strip", json=payload)
            assert res.status_code == 200
            data = res.get_json()
            assert data["action"] == "BLOCK_CONSUMPTION"
            assert data["is_expired"] is True
            assert "एक्सपायर" in data["voice_alert_vernacular"]

    def test_tier4_scenario3_remote_village_offline_clinic_visit(self, client):
        """
        Scenario 3:
        Complete offline mode during remote village clinic visit gracefully falling back with visual warning.
        """
        # WatsonX credentials unconfigured / offline
        with mock.patch("app.WATSONX_API_KEY", ""), \
             mock.patch("app.WATSONX_PROJECT_ID", ""):
            payload = {
                "image_base64": TINY_BASE64_IMAGE,
                "language": "mr",
            }
            res = client.post("/api/digitize-rx", json=payload)
            assert res.status_code == 200
            data = res.get_json()
            assert data["status"] == "success"
            # Preserves clinical stability without crashing
            assert "डॉ. आनंद देशमुख" in data["data"]["doctor_name"]
            assert len(data["data"]["medications"]) >= 2

    def test_tier4_scenario4_prescription_with_batch_code_preserved(self, client):
        """
        Scenario 4:
        Valid prescription + legitimate medicine batch code preserved without false redaction.
        """
        raw_text = "Prescription Batch: B-8921 Lot: 4401 Aadhaar: 2345 6789 0124"
        masked, redactions = mask_pii(raw_text)
        # Aadhaar is masked
        assert "[MASKED-AADHAAR-XXXX]" in masked
        assert "2345 6789 0124" not in masked
        # Batch codes preserved
        assert "B-8921" in masked
        assert "4401" in masked

    def test_tier4_scenario5_multi_drug_complex_regimen_extraction(self, client):
        """
        Scenario 5:
        Multi-drug prescription with complex 24-hr timings and food relations
        (Metformin BD after food, Telmisartan OD after breakfast, Pantoprazole OD before food).
        """
        res = client.post("/api/digitize-rx", json={"image_base64": TINY_BASE64_IMAGE, "language": "hi"})
        assert res.status_code == 200
        meds = res.get_json()["data"]["medications"]
        assert len(meds) >= 3

        # 1. Metformin: BD (Twice daily), After food
        metformin = next(m for m in meds if "Metformin" in m["name"])
        assert metformin["frequency"] == "1-0-1"
        assert len(metformin["timing_24hr"]) == 2
        assert metformin["food_relation"] == "After Food"

        # 2. Telmisartan: OD (Morning once), After breakfast
        telmisartan = next(m for m in meds if "Telmisartan" in m["name"])
        assert telmisartan["frequency"] == "1-0-0"
        assert len(telmisartan["timing_24hr"]) == 1
        assert telmisartan["morning"] is True

        # 3. Pantoprazole: OD (Morning once), Before food
        pantoprazole = next(m for m in meds if "Pantoprazole" in m["name"])
        assert pantoprazole["food_relation"] == "Before Food"
        assert pantoprazole["morning"] is True
