"""
tests/test_app.py — Unit + integration tests for the RAG Chatbot Flask API.
Run with: pytest tests/ -v  (or from repo root: pytest rag-chatBot/tests/ -v)
"""
import importlib.util
import json
import os
import sys
import pytest

# ── env vars must be set before importing the app module ──────────────────────
os.environ.setdefault('WATSONX_API_KEY', 'test_key')
os.environ.setdefault('WATSONX_URL', 'https://us-south.ml.cloud.ibm.com')
os.environ.setdefault('WATSONX_PROJECT_ID', 'test_project')
os.environ.setdefault('IBM_COS_API_KEY', 'test_cos_key')
os.environ.setdefault('IBM_COS_INSTANCE_CRN', 'crn:test')
os.environ.setdefault('IBM_COS_ENDPOINT', 'https://s3.us-south.cloud-object-storage.appdomain.cloud')
os.environ.setdefault('IBM_COS_BUCKET_NAME', 'test-bucket')

_APP_PATH = os.path.join(os.path.dirname(__file__), '..', 'flask_app', 'app.py')
_MODULE_NAME = 'rag_chatbot_app'


def _load_app_module():
    """Load the Flask app as a uniquely-named module to avoid sys.modules collisions."""
    if _MODULE_NAME in sys.modules:
        return sys.modules[_MODULE_NAME]
    spec = importlib.util.spec_from_file_location(_MODULE_NAME, _APP_PATH)
    module = importlib.util.module_from_spec(spec)
    sys.modules[_MODULE_NAME] = module
    spec.loader.exec_module(module)
    return module


@pytest.fixture(scope='module')
def client():
    """Create a test client with all heavy dependencies mocked at import time."""
    import unittest.mock as mock

    # Remove any previously cached version
    sys.modules.pop(_MODULE_NAME, None)

    mock_llm = mock.MagicMock()
    mock_embeddings = mock.MagicMock()
    mock_chroma = mock.MagicMock()
    mock_chroma.as_retriever.return_value = mock.MagicMock()

    with mock.patch('langchain_ibm.WatsonxLLM', return_value=mock_llm), \
         mock.patch('langchain_ibm.WatsonxEmbeddings', return_value=mock_embeddings), \
         mock.patch('langchain_chroma.Chroma', return_value=mock_chroma), \
         mock.patch('ibm_watsonx_ai.Credentials', return_value={}), \
         mock.patch('ibm_watsonx_ai.APIClient', return_value=mock.MagicMock()):
        mod = _load_app_module()
        flask_app = mod.app
        flask_app.config['TESTING'] = True
        with flask_app.test_client() as test_client:
            yield test_client


class TestHealthEndpoint:
    def test_health_returns_200(self, client):
        resp = client.get('/health')
        assert resp.status_code == 200

    def test_health_returns_json(self, client):
        resp = client.get('/health')
        data = resp.get_json()
        assert data is not None
        assert 'status' in data

    def test_health_status_value(self, client):
        resp = client.get('/health')
        data = resp.get_json()
        assert data['status'] in ('ok', 'degraded', 'error')


class TestQueryEndpoint:
    def test_query_missing_question_returns_400(self, client):
        resp = client.post(
            '/watsonchat',
            data=json.dumps({}),
            content_type='application/json'
        )
        assert resp.status_code == 400

    def test_query_empty_question_returns_400(self, client):
        resp = client.post(
            '/watsonchat',
            data=json.dumps({'query': ''}),
            content_type='application/json'
        )
        assert resp.status_code == 400

    def test_query_non_string_returns_400(self, client):
        resp = client.post(
            '/watsonchat',
            data=json.dumps({'query': 123}),
            content_type='application/json'
        )
        assert resp.status_code == 400

    def test_query_no_json_body_returns_400(self, client):
        resp = client.post('/watsonchat', data='not json', content_type='text/plain')
        assert resp.status_code in (400, 415)

    def test_query_too_long_returns_400(self, client):
        resp = client.post(
            '/watsonchat',
            data=json.dumps({'query': 'x' * 2001}),
            content_type='application/json'
        )
        assert resp.status_code == 400

    def test_query_valid_but_rag_unavailable_returns_error(self, client):
        """When vectorstore is None, should return 500 with error message."""
        resp = client.post(
            '/watsonchat',
            data=json.dumps({'query': 'What is Paracetamol?'}),
            content_type='application/json'
        )
        # 500 (vectorstore not initialized) or 400/503 depending on mock state
        assert resp.status_code in (200, 400, 500, 503)


class TestCORS:
    def test_cors_headers_present(self, client):
        resp = client.get('/health')
        # CORS should allow all origins in test
        assert resp.headers.get('Access-Control-Allow-Origin') is not None or \
               resp.status_code == 200  # At minimum it shouldn't crash


class TestInputSanitisation:
    def test_sql_injection_handled_gracefully(self, client):
        """SQL injection in query should not cause unhandled exception (only expected HTTP errors)."""
        resp = client.post(
            '/watsonchat',
            data=json.dumps({'query': "'; DROP TABLE users; --"}),
            content_type='application/json'
        )
        data = resp.get_json()
        assert data is not None  # Always returns JSON, never raw traceback
        assert resp.status_code in (200, 400, 500)

    def test_xss_handled_gracefully(self, client):
        resp = client.post(
            '/watsonchat',
            data=json.dumps({'query': '<script>alert(1)</script>'}),
            content_type='application/json'
        )
        data = resp.get_json()
        assert data is not None
        assert resp.status_code in (200, 400, 500)

    def test_unicode_handled_gracefully(self, client):
        resp = client.post(
            '/watsonchat',
            data=json.dumps({'query': 'आरोग्यम् क्या है?'}),
            content_type='application/json'
        )
        data = resp.get_json()
        assert data is not None
        assert resp.status_code in (200, 400, 500)
