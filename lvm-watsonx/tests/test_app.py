"""
tests/test_app.py — Unit + integration tests for the LVM Watsonx Flask API.
Run with: pytest tests/ -v  (or from repo root: pytest lvm-watsonx/tests/ -v)
"""
import importlib.util
import json
import os
import sys
import types
import pytest

# ── env vars must be set before importing the app module ──────────────────────
os.environ.setdefault('WATSONX_API_KEY', 'test_key')
os.environ.setdefault('WATSONX_URL', 'https://us-south.ml.cloud.ibm.com')
os.environ.setdefault('WATSONX_PROJECT_ID', 'test_project')

_APP_PATH = os.path.join(os.path.dirname(__file__), '..', 'flask_app', 'app.py')
_MODULE_NAME = 'lvm_watsonx_app'


def _load_app_module():
    """Load the Flask app as a uniquely-named module to avoid sys.modules collisions."""
    if _MODULE_NAME in sys.modules:
        return sys.modules[_MODULE_NAME]
    spec = importlib.util.spec_from_file_location(_MODULE_NAME, _APP_PATH)
    module = importlib.util.module_from_spec(spec)
    sys.modules[_MODULE_NAME] = module
    spec.loader.exec_module(module)
    return module


@pytest.fixture
def client(monkeypatch):
    import unittest.mock as mock
    # Remove cached module so we get a fresh import with the mock applied
    sys.modules.pop(_MODULE_NAME, None)
    with mock.patch('ibm_watsonx_ai.foundation_models.ModelInference') as mock_model:
        mock_model.return_value.chat.return_value = {
            'choices': [{'message': {'content': 'Mock AI response about the image.'}}]
        }
        mod = _load_app_module()
        flask_app = mod.app
        flask_app.config['TESTING'] = True
        with flask_app.test_client() as c:
            yield c


class TestHealthEndpoint:
    def test_health_returns_200(self, client):
        resp = client.get('/health')
        assert resp.status_code == 200

    def test_health_has_status_key(self, client):
        data = client.get('/health').get_json()
        assert 'status' in data


class TestProcessImageEndpoint:
    def test_missing_image_url_returns_400(self, client):
        resp = client.post(
            '/process-image',
            data=json.dumps({'user_query': 'Describe this'}),
            content_type='application/json'
        )
        assert resp.status_code == 400

    def test_missing_user_query_returns_400(self, client):
        resp = client.post(
            '/process-image',
            data=json.dumps({'image_url': 'https://example.com/img.jpg'}),
            content_type='application/json'
        )
        assert resp.status_code == 400

    def test_invalid_url_scheme_returns_400(self, client):
        resp = client.post(
            '/process-image',
            data=json.dumps({
                'image_url': 'ftp://evil.com/image.jpg',
                'user_query': 'What is this?'
            }),
            content_type='application/json'
        )
        assert resp.status_code == 400

    def test_empty_payload_returns_400(self, client):
        resp = client.post(
            '/process-image',
            data=json.dumps({}),
            content_type='application/json'
        )
        assert resp.status_code == 400

    def test_prompt_too_long_returns_400(self, client):
        resp = client.post(
            '/process-image',
            data=json.dumps({
                'image_url': 'https://example.com/img.jpg',
                'user_query': 'x' * 5001
            }),
            content_type='application/json'
        )
        assert resp.status_code == 400

    def test_non_http_url_rejected(self, client):
        resp = client.post(
            '/process-image',
            data=json.dumps({
                'image_url': 'javascript:alert(1)',
                'user_query': 'test'
            }),
            content_type='application/json'
        )
        assert resp.status_code == 400


class TestSecurity:
    def test_options_request_returns_200(self, client):
        resp = client.options('/process-image')
        assert resp.status_code in (200, 204)

    def test_large_payload_rejected(self, client):
        resp = client.post(
            '/process-image',
            data=json.dumps({
                'image_url': 'https://example.com/img.jpg',
                'user_query': 'a' * 10000
            }),
            content_type='application/json'
        )
        assert resp.status_code in (400, 413)
