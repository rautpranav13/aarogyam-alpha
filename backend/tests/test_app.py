"""
Unit and integration tests for the Project Alpha consolidated backend.
Run with: pytest backend/tests/ -v
"""
import os
import sys
import json
import pytest
import unittest.mock as mock

# Ensure backend root is on sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as test_client:
        yield test_client


def test_health_endpoint(client):
    """Verify health endpoint returns status and correct model info."""
    response = client.get("/api/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"
    assert "granite-vision" in data["vision_model"]


def test_digitize_rx_missing_payload(client):
    """Verify /api/digitize-rx returns 400 when image is missing."""
    response = client.post("/api/digitize-rx", json={})
    assert response.status_code == 400
    data = response.get_json()
    assert data["status"] == "error"


@mock.patch("app._get_watsonx_model")
def test_digitize_rx_success(mock_model_fn, client):
    """Verify /api/digitize-rx successfully parses prescriptions using Granite Vision."""
    mock_model = mock.MagicMock()
    mock_response = {
        "choices": [
            {
                "message": {
                    "content": json.dumps({
                        "medications": [
                            {
                                "id": 1,
                                "name": "Metformin",
                                "strength": "500mg",
                                "frequency": "BD",
                                "timing_24hr": ["08:30", "20:30"],
                                "food_relation": "After Food",
                                "instructions": "Take after meals",
                                "instructions_vernacular": "भोजन के बाद लें"
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
    assert len(data["data"]["medications"]) == 1
    assert data["data"]["medications"][0]["name"] == "Metformin"


def test_verify_strip_missing_payload(client):
    """Verify /api/verify-strip returns 400 when missing required fields."""
    response = client.post("/api/verify-strip", json={"image_base64": "abc"})
    assert response.status_code == 400


@mock.patch("app._get_watsonx_model")
def test_verify_strip_match(mock_model_fn, client):
    """Verify /api/verify-strip detects matching blister strip."""
    mock_model = mock.MagicMock()
    mock_response = {
        "choices": [
            {
                "message": {
                    "content": json.dumps({
                        "verified": True,
                        "detected_text": "METFORMIN 500MG",
                        "confidence": 0.98,
                        "voice_alert_vernacular": "सत्यापित: मेटफॉर्मिन 500mg",
                        "action": "ALLOW_CONSUMPTION"
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
    assert data["verified"] is True
    assert data["action"] == "ALLOW_CONSUMPTION"


def test_vernacular_tts_missing_text(client):
    """Verify /api/vernacular-tts returns 400 when text is empty."""
    response = client.post("/api/vernacular-tts", json={})
    assert response.status_code == 400
