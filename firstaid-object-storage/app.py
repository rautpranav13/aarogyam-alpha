
import os
from dotenv import load_dotenv
load_dotenv()

import ibm_boto3
from ibm_botocore.client import Config, ClientError
from flask import Flask, request, jsonify
from flask_cors import CORS

# Flask app
app = Flask(__name__)
CORS(app, origins=os.getenv("CORS_ORIGINS", "*"))

COS_API_KEY_ID = os.getenv('COS_API_KEY_ID')
COS_INSTANCE_CRN = os.getenv('COS_INSTANCE_CRN')
COS_ENDPOINT = os.getenv('COS_ENDPOINT', 'https://s3.ap.cloud-object-storage.appdomain.cloud')
BUCKET_NAME = os.getenv('BUCKET_NAME', 'aarogyamfirstaid')

def create_cos_client():
    """Create an IBM COS client."""
    return ibm_boto3.client(
        's3',
        ibm_api_key_id=COS_API_KEY_ID,
        ibm_service_instance_id=COS_INSTANCE_CRN,
        config=Config(signature_version='oauth'),
        endpoint_url=COS_ENDPOINT
    )

def get_public_url(bucket_name, object_key):
    """Generate the public URL for an object in the bucket."""
    return f"{COS_ENDPOINT}/{bucket_name}/{object_key}"

def list_objects_in_folder(cos_client, bucket_name, folder_name):
    """List objects in the specified folder of the bucket."""
    try:
        response = cos_client.list_objects_v2(Bucket=bucket_name, Prefix=folder_name)
        object_urls = []
        for obj in response.get('Contents', []):
            object_key = obj['Key']
            if object_key.endswith('/'):
                continue  # Skip folder entries
            public_url = get_public_url(bucket_name, object_key)
            object_urls.append(public_url)
        return object_urls
    except ClientError as e:
        print(f"Unable to list objects. Error: {e}")
        return []

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"})


@app.route('/list_objects', methods=['GET'])
def list_objects():
    """API Endpoint to list objects in a folder."""
    folder_name = request.args.get('folder_name')
    if not folder_name:
        return jsonify({"error": "folder_name query parameter is required"}), 400

    cos_client = create_cos_client()
    object_urls = list_objects_in_folder(cos_client, BUCKET_NAME, folder_name)
    return jsonify({"folder": folder_name, "objects": object_urls})


@app.route('/')
def home():
    return "Hello, Welcome to Aarogyam!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
