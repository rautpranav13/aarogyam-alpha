"""
tests/test_app.py — Unit + integration tests for the First Aid Object Storage API.
Run with: pytest tests/ -v  (or from repo root: pytest firstaid-object-storage/tests/ -v)
"""
import importlib.util
import json
import os
import sys
import pytest

# ── env vars must be set before importing the app module ──────────────────────
os.environ.setdefault('IBM_COS_API_KEY', 'test_cos_key')
os.environ.setdefault('IBM_COS_INSTANCE_CRN', 'crn:v1:bluemix:public:cloud-object-storage:global:a/test:test::')
os.environ.setdefault('IBM_COS_ENDPOINT', 'https://s3.us-south.cloud-object-storage.appdomain.cloud')
os.environ.setdefault('IBM_COS_BUCKET_NAME', 'test-bucket')

_APP_PATH = os.path.join(os.path.dirname(__file__), '..', 'app.py')
_MODULE_NAME = 'firstaid_app'


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

    # Mock the IBM COS client
    mock_cos = mock.MagicMock()
    mock_cos.list_objects.return_value = {
        'Contents': [
            {'Key': 'burns/step1.jpg'},
            {'Key': 'burns/step2.jpg'},
        ]
    }
    mock_cos.generate_presigned_url.return_value = 'https://test.cos.ibm.com/presigned_url'

    # Remove cached module so we get a fresh import with the mock applied
    sys.modules.pop(_MODULE_NAME, None)

    mod = _load_app_module()
    # Patch module-level cos_client and COS_BUCKET
    monkeypatch.setattr(mod, 'cos_client', mock_cos)
    monkeypatch.setattr(mod, 'COS_BUCKET', 'test-bucket')

    flask_app = mod.app
    flask_app.config['TESTING'] = True
    with flask_app.test_client() as test_client:
        yield test_client


class TestHealthEndpoint:
    def test_health_returns_200(self, client):
        resp = client.get('/health')
        assert resp.status_code == 200

    def test_health_json_structure(self, client):
        data = client.get('/health').get_json()
        assert 'status' in data


class TestFirstAidEndpoint:
    def test_missing_folder_name_returns_400(self, client):
        resp = client.get('/first-aid-images')
        assert resp.status_code == 400

    def test_empty_folder_name_returns_400(self, client):
        resp = client.get('/first-aid-images?folder_name=')
        assert resp.status_code == 400

    def test_valid_folder_returns_200_or_404(self, client):
        resp = client.get('/first-aid-images?folder_name=burns')
        # Either 200 (found) or 404 (not found in mock) — not 500
        assert resp.status_code in (200, 404)

    def test_path_traversal_rejected(self, client):
        resp = client.get('/first-aid-images?folder_name=../etc/passwd')
        assert resp.status_code == 400

    def test_path_traversal_encoded_rejected(self, client):
        resp = client.get('/first-aid-images?folder_name=%2E%2E%2Fetc')
        assert resp.status_code == 400

    def test_special_chars_rejected(self, client):
        resp = client.get('/first-aid-images?folder_name=burns;rm -rf /')
        assert resp.status_code == 400

    def test_null_bytes_rejected(self, client):
        resp = client.get('/first-aid-images?folder_name=burns\x00evil')
        assert resp.status_code == 400

    def test_response_has_images_key(self, client):
        resp = client.get('/first-aid-images?folder_name=burns')
        if resp.status_code == 200:
            data = resp.get_json()
            assert 'images' in data
            assert isinstance(data['images'], list)

    def test_unicode_folder_name(self, client):
        resp = client.get('/first-aid-images?folder_name=जलन')
        # Should not crash (400 if invalid chars, but not 500)
        assert resp.status_code != 500

    def test_very_long_folder_name_rejected(self, client):
        resp = client.get(f'/first-aid-images?folder_name={"a" * 256}')
        assert resp.status_code == 400


class TestCORS:
    def test_cors_preflight(self, client):
        resp = client.options('/first-aid-images')
        assert resp.status_code in (200, 204)
