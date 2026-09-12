#API service
import os
from dotenv import load_dotenv
load_dotenv()

from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import base64
from ibm_watsonx_ai import Credentials
from ibm_watsonx_ai.foundation_models import ModelInference

app = Flask(__name__)
CORS(app, origins=os.getenv("CORS_ORIGINS", "*"))

def augment_api_request_body(user_query, image):
    """
    Prepares the message payload for the WatsonX API request.
    """
    return [
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": (
                        "You are a highly advanced AI assistant designed to process and analyze medical images. "
                        "Bullet points with short descriptions are preferred. Return the response as minimal "
                        "HTML <body> content, structured with headings, bullet points, and bolded critical information. "
                        "Ensure the output is plain text, concise, and suitable for mobile app display. "
                        f"{user_query}"
                    )
                },
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{image}"}
                }
            ]
        }
    ]

def validate_html(html_content):
    """
    Validates if the HTML content starts with <body> and ends with </body>.
    If invalid, returns fallback HTML content.
    """
    #if not html_content.startswith("<body>") or not html_content.endswith("</body>"):
        #return "<body><h3>Error</h3><p>Invalid HTML content generated.</p></body>"
    return html_content

def process_image_with_query(image_url, user_query):
    """
    Processes an image with a custom user query and returns the response.
    """
    try:
        # Encode the image to base64
        timeout = int(os.getenv("IMAGE_FETCH_TIMEOUT", "10"))
        img_response = requests.get(image_url, timeout=timeout)
        img_response.raise_for_status()
        encoded_image = base64.b64encode(img_response.content).decode("utf-8")
    except Exception as e:
        return {"status": "error", "message": f"Failed to process image: {str(e)}"}

    # WatsonX AI credentials and model initialization
    credentials = Credentials(
        url=os.getenv("WATSONX_URL", "https://eu-de.ml.cloud.ibm.com"),
        api_key=os.getenv("WATSONX_API_KEY")
    )

    model = ModelInference(
        model_id="mistralai/pixtral-12b",
        credentials=credentials,
        project_id=os.getenv("WATSONX_PROJECT_ID"),
        params={"max_tokens": 500}
    )

    try:
        # Prepare the request payload
        messages = augment_api_request_body(user_query, encoded_image)

        # Call WatsonX AI with the custom query
        response = model.chat(messages=messages)
        content = response.get('choices', [{}])[0].get('message', {}).get('content', '').strip()

        # Validate and return the response
        return {"status": "success", "response": validate_html(content)}

    except Exception as e:
        print(f"error\nModel call failed: {e}")
        return {"status": "error", "message": f"Model call failed: {str(e)}"}

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"})


@app.route('/process-image', methods=['POST'])
def process_image():
    """
    API endpoint to process an image with a custom user query.
    """
    try:
        # Parse the JSON body
        data = request.get_json()
        if not data or not data.get('image_url') or not data.get('user_query'):
            return jsonify({"error": "image_url and user_query are required"}), 400

        image_url = data.get('image_url')
        user_query = data.get('user_query')

        # Validate input types
        if not isinstance(image_url, str):
            return jsonify({"status": "error", "message": "Invalid input: 'image_url' must be a string."}), 400

        if not isinstance(user_query, str):
            return jsonify({"status": "error", "message": "Invalid input: 'user_query' must be a string."}), 400

        # Process the image and query
        result = process_image_with_query(image_url, user_query)
        status_code = 500 if result.get("status") == "error" else 200
        return jsonify(result), status_code

    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/')
def home():
    return "Welcome to the Flask app!"

if __name__ == "__main__":
    app.run(debug=True)
