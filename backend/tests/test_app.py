"""
Unit and integration tests for the Project Alpha production backend.
Run with: backend/venv/bin/pytest backend/tests/ -v
"""
import os
import sys
import json
import pytest
import unittest.mock as mock

# Ensure backend root is on sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app import app, _clean_base64, _sanitize_json_markdown


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as test_client:
        yield test_client


def test_clean_base64_helper():
    """Verify base64 data URL stripping."""
    assert _clean_base64("data:image/jpeg;base64,ABCDEF") == "ABCDEF"
    assert _clean_base64("ABCDEF") == "ABCDEF"
    assert _clean_base64("") == ""


def test_sanitize_json_markdown_helper():
    """Verify markdown code fence stripping."""
    raw = '```json\n{"test": true}\n```'
    assert _sanitize_json_markdown(raw) == '{"test": true}'
    raw2 = '```\n{"test": true}\n```'
    assert _sanitize_json_markdown(raw2) == '{"test": true}'


def test_home_endpoint(client):
    """Verify root documentation endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "online"
    assert "endpoints" in data


def test_health_endpoint(client):
    """Verify health endpoint returns status and correct model info."""
    response = client.get("/api/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"
    assert "granite-vision" in data["vision_model"]
    assert "hi" in data["supported_languages"]
    assert "mr" in data["supported_languages"]


def test_digitize_rx_missing_payload(client):
    """Verify /api/digitize-rx returns 400 when image is missing."""
    response = client.post("/api/digitize-rx", json={})
    assert response.status_code == 400
    data = response.get_json()
    assert data["status"] == "error"


def test_digitize_rx_demo_fallback_hindi(client):
    """Verify /api/digitize-rx fallback returns valid Hindi clinical structure."""
    payload = {
        "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
        "language": "hi"
    }
    response = client.post("/api/digitize-rx", json=payload)
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "success"
    meds = data["data"]["medications"]
    assert len(meds) >= 1
    assert "Metformin" in meds[0]["name"]
    assert "instructions_vernacular" in meds[0]


def test_digitize_rx_demo_fallback_marathi(client):
    """Verify /api/digitize-rx fallback returns valid Marathi clinical structure."""
    payload = {
        "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
        "language": "mr"
    }
    response = client.post("/api/digitize-rx", json=payload)
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "success"
    meds = data["data"]["medications"]
    assert len(meds) >= 1
    assert "घ्या" in meds[0]["instructions_vernacular"]


@mock.patch("app.WATSONX_API_KEY", "mock_key")
@mock.patch("app.WATSONX_PROJECT_ID", "mock_proj")
@mock.patch("app._get_watsonx_model")
def test_digitize_rx_watsonx_success(mock_model_fn, client):
    """Verify /api/digitize-rx successfully parses prescriptions when WatsonX is configured."""
    mock_model = mock.MagicMock()
    mock_response = {
        "choices": [
            {
                "message": {
                    "content": json.dumps({
                        "medications": [
                            {
                                "id": 1,
                                "name": "Pantoprazole",
                                "strength": "40mg",
                                "frequency": "OD",
                                "timing_24hr": ["07:30"],
                                "food_relation": "Before Food",
                                "instructions": "Take 1 tablet before breakfast",
                                "instructions_vernacular": "सुबह नाश्ते से पहले लें"
                            }
                        ]
                    })
                }
            }
        ]
    }
    mock_model.chat.return_value = mock_response
    mock_model_fn.return_value = mock_model

    payload = {
        "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
        "language": "hi"
    }

    response = client.post("/api/digitize-rx", json=payload)
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "success"
    assert data["data"]["medications"][0]["name"] == "Pantoprazole"


def test_verify_strip_missing_payload(client):
    """Verify /api/verify-strip returns 400 when missing required fields."""
    response = client.post("/api/verify-strip", json={"image_base64": "abc"})
    assert response.status_code == 400


def test_verify_strip_demo_fallback(client):
    """Verify /api/verify-strip returns structured verification when WatsonX is unconfigured."""
    payload = {
        "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
        "expected_drug": "Metformin",
        "expected_strength": "500mg",
        "language": "hi"
    }
    response = client.post("/api/verify-strip", json=payload)
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "success"
    assert data["verified"] is True
    assert "METFORMIN" in data["detected_text"]
    assert data["action"] == "ALLOW_CONSUMPTION"


@mock.patch("app.WATSONX_API_KEY", "mock_key")
@mock.patch("app.WATSONX_PROJECT_ID", "mock_proj")
@mock.patch("app._get_watsonx_model")
def test_verify_strip_mismatch_alert(mock_model_fn, client):
    """Verify /api/verify-strip triggers BLOCK_CONSUMPTION when packaging does not match."""
    mock_model = mock.MagicMock()
    mock_response = {
        "choices": [
            {
                "message": {
                    "content": json.dumps({
                        "verified": False,
                        "detected_text": "AMLODIPINE 5MG",
                        "confidence": 0.99,
                        "voice_alert_vernacular": "चेतावनी: यह गलत दवा है! इसे न लें।",
                        "action": "BLOCK_CONSUMPTION"
                    })
                }
            }
        ]
    }
    mock_model.chat.return_value = mock_response
    mock_model_fn.return_value = mock_model

    payload = {
        "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
        "expected_drug": "Metformin",
        "expected_strength": "500mg",
        "language": "hi"
    }

    response = client.post("/api/verify-strip", json=payload)
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "success"
    assert data["verified"] is False
    assert data["action"] == "BLOCK_CONSUMPTION"


def test_vernacular_tts_missing_text(client):
    """Verify /api/vernacular-tts returns 400 when text is empty."""
    response = client.post("/api/vernacular-tts", json={})
    assert response.status_code == 400


def test_vernacular_tts_mock_delivery(client):
    """Verify /api/vernacular-tts delivers text for native speech engine when credentials are unconfigured."""
    response = client.post("/api/vernacular-tts", json={"text": "दवा का समय हो गया है", "language": "hi"})
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "mock"
    assert data["text"] == "दवा का समय हो गया है"
