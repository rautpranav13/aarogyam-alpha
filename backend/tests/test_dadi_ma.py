"""
Tests for Dadi-Ma AI Companion Endpoints & Services
"""
import pytest
from app import app
from dadi_ma_service import (
    check_emergency_red_flags,
    format_dadi_ma_response,
    get_dadi_ma_greeting,
    REMEDY_CATALOG,
    search_remedies
)


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_emergency_red_flags_detection():
    # Hindi emergency
    is_em, warn = check_emergency_red_flags("मुझे सीने में दर्द हो रहा है बहुत तेज", "hi")
    assert is_em is True
    assert "१०८" in warn or "आपातकालीन" in warn

    # Marathi emergency
    is_em, warn = check_emergency_red_flags("मला छातीत दुखणे जाणवत आहे आणि श्वास घेण्यास त्रास होतोय", "mr")
    assert is_em is True
    assert "१०८" in warn or "तातडीची" in warn

    # English emergency
    is_em, warn = check_emergency_red_flags("Patient has severe chest pain and fainting", "en")
    assert is_em is True
    assert "108" in warn or "Emergency" in warn

    # Normal non-emergency query
    is_em, warn = check_emergency_red_flags("मुझे हल्की खांसी है, क्या उपाय करूं?", "hi")
    assert is_em is False
    assert warn is None


def test_remedy_catalog_integrity():
    assert len(REMEDY_CATALOG) >= 5
    for r in REMEDY_CATALOG:
        assert "id" in r
        assert "title" in r
        assert "hi" in r["title"] and "mr" in r["title"] and "en" in r["title"]
        assert "ingredients" in r
        assert "preparation" in r
        assert "precaution" in r


def test_dadi_ma_greeting_generator():
    morning = get_dadi_ma_greeting(hour=8, lang="hi")
    assert morning["period"] == "morning"
    assert "प्रभात" in morning["title"]

    night_mr = get_dadi_ma_greeting(hour=22, lang="mr")
    assert night_mr["period"] == "night"
    assert "रात्री" in night_mr["title"]


def test_dadi_ma_chat_endpoint_fallback_hindi(client):
    res = client.post("/api/dadi-ma/chat", json={
        "query": "मुझे रात में खांसी हो रही है",
        "language": "hi",
        "medications": [{"name": "Paracetamol", "frequency": "1-0-1"}]
    })
    assert res.status_code == 200
    data = res.get_json()
    assert data["status"] == "success"
    assert data["is_emergency"] is False
    assert len(data["response_text"]) > 10
    assert len(data["remedies"]) > 0
    assert "तुलसी" in data["remedies"][0]["title"] or "काढ़ा" in data["remedies"][0]["title"]


def test_dadi_ma_chat_endpoint_emergency_trigger(client):
    res = client.post("/api/dadi-ma/chat", json={
        "query": "सीने में बहुत तेज दर्द है और सांस रुक रही है",
        "language": "hi"
    })
    assert res.status_code == 200
    data = res.get_json()
    assert data["status"] == "emergency"
    assert data["is_emergency"] is True
    assert data["action_required"] == "CALL_108_OR_VISIT_DOCTOR"


def test_dadi_ma_remedies_endpoint(client):
    res = client.get("/api/dadi-ma/remedies?language=mr")
    assert res.status_code == 200
    data = res.get_json()
    assert data["status"] == "success"
    assert data["count"] > 0
    assert "काढा" in data["remedies"][0]["title"] or "पाणी" in data["remedies"][0]["title"] or "दूध" in data["remedies"][0]["title"]


def test_dadi_ma_daily_greeting_endpoint(client):
    res = client.post("/api/dadi-ma/daily-greeting", json={
        "hour": 9,
        "language": "hi"
    })
    assert res.status_code == 200
    data = res.get_json()
    assert data["status"] == "success"
    assert data["data"]["period"] == "morning"


def test_dadi_ma_explain_prescription_endpoint(client):
    payload = {
        "doctor_name": "डॉ. एस. के. शर्मा",
        "diagnosis": "उच्च रक्तचाप और मधुमेह",
        "language": "hi",
        "medications": [
            {
                "name": "Metformin Hydrochloride 500mg",
                "frequency": "1-0-1",
                "instructions_vernacular": "भोजन के बाद 1 गोली पानी के साथ लें।"
            },
            {
                "name": "Telmisartan 40mg",
                "frequency": "1-0-0",
                "instructions_vernacular": "सुबह नाश्ते के बाद 1 गोली लें।"
            }
        ]
    }
    res = client.post("/api/dadi-ma/explain-prescription", json=payload)
    assert res.status_code == 200
    data = res.get_json()
    assert data["status"] == "success"
    assert "डॉ. एस. के. शर्मा" in data["explanation_text"]
    assert "Metformin" in data["explanation_text"]
    assert len(data["medications_breakdown"]) == 2
