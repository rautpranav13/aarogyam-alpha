import os
import re
import logging
from dotenv import load_dotenv
load_dotenv()

import ibm_boto3
from ibm_botocore.client import Config, ClientError
from flask import Flask, request, jsonify
from flask_cors import CORS

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Flask app
app = Flask(__name__)
CORS(app, origins=os.getenv("CORS_ORIGINS", "*"))

COS_API_KEY_ID = os.getenv('COS_API_KEY_ID') or os.getenv('IBM_COS_API_KEY')
COS_INSTANCE_CRN = os.getenv('COS_INSTANCE_CRN') or os.getenv('IBM_COS_INSTANCE_CRN')
COS_ENDPOINT = (
    os.getenv('COS_ENDPOINT')
    or os.getenv('IBM_COS_ENDPOINT', 'https://s3.ap.cloud-object-storage.appdomain.cloud')
)
COS_BUCKET = (
    os.getenv('BUCKET_NAME')
    or os.getenv('IBM_COS_BUCKET_NAME', 'aarogyamfirstaid')
)

# Maximum allowed folder name length
_MAX_FOLDER_NAME_LEN = 128
# Only allow alphanumeric, hyphens, underscores, forward slashes and dots
_SAFE_FOLDER_RE = re.compile(r'^[\w\-./]+$', re.UNICODE)
# Characters that indicate path traversal or injection attempts
_DANGEROUS_RE = re.compile(r'(\.\.|;|`|\$|\||\x00)', re.UNICODE)


def create_cos_client():
    """Create and return an IBM COS client."""
    return ibm_boto3.client(
        's3',
        ibm_api_key_id=COS_API_KEY_ID,
        ibm_service_instance_id=COS_INSTANCE_CRN,
        config=Config(signature_version='oauth'),
        endpoint_url=COS_ENDPOINT
    )


# Module-level client — mocked in tests via `mock.patch('app.cos_client', ...)`
cos_client = None  # Lazily initialised so tests can inject a mock before first use


def _get_cos_client():
    """Return the module-level cos_client, creating it if needed."""
    global cos_client
    if cos_client is None:
        cos_client = create_cos_client()
    return cos_client


def get_public_url(bucket_name, object_key):
    """Generate the public URL for an object in the bucket."""
    return f"{COS_ENDPOINT}/{bucket_name}/{object_key}"


def list_objects_in_folder(client, bucket_name, folder_name):
    """List objects in the specified folder of the bucket.

    Returns a list of public URLs, or raises ClientError on failure.
    """
    response = client.list_objects(Bucket=bucket_name, Prefix=folder_name)
    contents = response.get('Contents') if isinstance(response, dict) else None
    urls = []
    for obj in (contents or []):
        key = obj['Key']
        if key.endswith('/'):
            continue  # skip folder-prefix entries
        urls.append(get_public_url(bucket_name, key))
    return urls


def _validate_folder_name(folder_name: str):
    """Validate folder_name; return an error message string or None if valid."""
    if not folder_name:
        return "folder_name query parameter is required"

    # Null-byte check
    if '\x00' in folder_name:
        return "folder_name contains invalid characters"

    if len(folder_name) > _MAX_FOLDER_NAME_LEN:
        return f"folder_name exceeds maximum length of {_MAX_FOLDER_NAME_LEN} characters"

    # Path traversal / injection
    if _DANGEROUS_RE.search(folder_name):
        return "folder_name contains invalid or unsafe characters"

    return None


@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"})


@app.route('/first-aid-images', methods=['GET'])
def first_aid_images():
    """API endpoint to list first-aid images in a COS folder."""
    folder_name = request.args.get('folder_name', '')

    error = _validate_folder_name(folder_name)
    if error:
        return jsonify({"error": error}), 400

    try:
        client = _get_cos_client()
        urls = list_objects_in_folder(client, COS_BUCKET, folder_name)
        if not urls:
            return jsonify({"folder": folder_name, "images": []}), 404
        return jsonify({"folder": folder_name, "images": urls}), 200
    except ClientError as e:
        logger.error("COS ClientError: %s", e)
        return jsonify({"error": "Failed to list objects", "detail": str(e)}), 500
    except Exception as e:
        logger.exception("Unexpected error in /first-aid-images")
        return jsonify({"error": str(e)}), 500


# Keep legacy endpoint for backwards compatibility
@app.route('/list_objects', methods=['GET'])
def list_objects():
    """Legacy endpoint — delegates to /first-aid-images logic."""
    folder_name = request.args.get('folder_name', '')
    if not folder_name:
        return jsonify({"error": "folder_name query parameter is required"}), 400

    try:
        client = _get_cos_client()
        object_urls = list_objects_in_folder(client, COS_BUCKET, folder_name)
        return jsonify({"folder": folder_name, "objects": object_urls})
    except Exception as e:
        logger.exception("Unexpected error in /list_objects")
        return jsonify({"error": str(e)}), 500


@app.route('/')
def home():
    return "Hello, Welcome to Aarogyam!"


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
