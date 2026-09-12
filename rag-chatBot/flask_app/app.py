# Import necessary libraries
import os
from dotenv import load_dotenv
load_dotenv()

from flask import Flask, request, jsonify
from flask_cors import CORS  # To handle cross-origin requests
from ibm_watsonx_ai import Credentials, APIClient
from pypdf import PdfReader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.docstore.document import Document
from langchain_ibm import WatsonxEmbeddings, WatsonxLLM
from langchain.chains import RetrievalQA
from langchain_chroma import Chroma
from ibm_watsonx_ai.metanames import GenTextParamsMetaNames as GenParams
from ibm_watsonx_ai.foundation_models.utils.enums import DecodingMethods

# Flask app setup
app = Flask(__name__)
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "*")
CORS(app, origins=CORS_ORIGINS)

# Watsonx AI credentials setup
credentials = Credentials(
    url=os.getenv("WATSONX_URL", "https://eu-gb.ml.cloud.ibm.com"),
    api_key=os.getenv("WATSONX_API_KEY")
)
project_id = os.getenv("WATSONX_PROJECT_ID")

# Env-driven chunk config
CHUNK_SIZE = int(os.getenv("CHUNK_SIZE", "512"))
CHUNK_OVERLAP = int(os.getenv("CHUNK_OVERLAP", "50"))
CHROMA_DIR = os.getenv("CHROMA_DIR", "./chroma_db")

# Initialize Watsonx Granite model
model_id = "ibm/granite-13b-instruct-v2"
parameters = {
    GenParams.DECODING_METHOD: DecodingMethods.GREEDY,
    GenParams.MIN_NEW_TOKENS: 1,
    GenParams.MAX_NEW_TOKENS: 100,
    GenParams.STOP_SEQUENCES: ["<|endoftext|>"]
}

# Initialize the LLM
watsonx_granite = WatsonxLLM(
    model_id=model_id,
    url=credentials.get("url"),
    apikey=credentials.get("apikey"),
    project_id=project_id,
    params=parameters
)

# Process the PDF file for context documents
pdf_file_path = "AarogyamDataset.pdf"  # PDF path
pdf_text = ""
try:
    with open(pdf_file_path, "rb") as f:
        pdf_reader = PdfReader(f)
        for page in pdf_reader.pages:
            pdf_text += page.extract_text() or ""
    print("info\nPDF successfully processed.")
except Exception as e:
    print(f"error\nFailed to process PDF: {e}")
    pdf_text = ""

# Split PDF text into chunks
try:
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=CHUNK_SIZE,
        chunk_overlap=CHUNK_OVERLAP,
        length_function=len
    )
    chunks = text_splitter.split_text(pdf_text)
    documents = [Document(page_content=chunk) for chunk in chunks]
    print(f"info\nTotal document chunks created: {len(documents)}")
except Exception as e:
    print(f"error\nFailed to split PDF text: {e}")
    documents = []

# Create or load vector store for document retrieval
try:
    embeddings = WatsonxEmbeddings(
        model_id="ibm/slate-30m-english-rtrvr",
        url=credentials["url"],
        apikey=credentials["apikey"],
        project_id=project_id
    )

    if os.path.exists(CHROMA_DIR) and len(os.listdir(CHROMA_DIR)) > 0:
        # Load existing vector store from disk
        docsearch = Chroma(persist_directory=CHROMA_DIR, embedding_function=embeddings)
        print("Loaded existing vector store from disk")
    else:
        # Build from PDF and persist to disk
        docsearch = Chroma.from_documents(documents, embeddings, persist_directory=CHROMA_DIR)
        print("Built and persisted new vector store")

except Exception as e:
    print(f"error\nFailed to create/load vector store: {e}")
    docsearch = None

# In-process query cache
_query_cache: dict = {}


@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok", "vectorstore": "ready" if docsearch else "unavailable"})


@app.route('/watsonchat', methods=['POST'])
def watsonchat():
    try:
        # Parse the query from the request
        data = request.get_json()
        user_query = data.get('query')

        if not user_query:
            print("error\nNo query provided in the request.")
            return jsonify({"error": "No query provided"}), 400

        print(f"info\nUser Query: {user_query}")

        # Check in-process cache first
        cache_key = user_query.strip().lower()
        if cache_key in _query_cache:
            return jsonify({"response": _query_cache[cache_key]})

        # Format the query with additional instructions
        formatted_query = (
            f"Bullet points with short descriptions are preferred. Return the response as minimal HTML <body> content, structured with headings, bullet points, and bolded critical information."
            f"Ensure the output is plain text, concise, and suitable for mobile app display. Provide Ayurvedic remedies, dietary norms, yoga/exercise, and lifestyle precautions, avoiding allopathic medicines for the query: {user_query}"
        )

        print(f"critical\nFormatted Query: {formatted_query}")

        # Ensure the vector store is initialized
        if not docsearch:
            print("error\nVector store is not initialized.")
            return jsonify({"error": "Vector store is not initialized"}), 500

        # Build RetrievalQA
        qa = RetrievalQA.from_chain_type(llm=watsonx_granite, chain_type="stuff", retriever=docsearch.as_retriever())

        # Get the response from Watson AI
        try:
            aiResponse = qa.invoke(formatted_query)
        except Exception as e:
            print(f"error\nModel invocation failed: {e}")
            return jsonify({"error": "Model invocation failed", "detail": str(e)}), 500

        print(f"critical\nAI Response: {aiResponse}")

        ai_response_result = aiResponse.get("result")
        if not ai_response_result:
            print("error\nAI did not return a valid result.")
            return jsonify({"error": "AI did not return a valid result."}), 500

        # Cache the result
        _query_cache[cache_key] = ai_response_result

        return jsonify({"response": ai_response_result})
    except Exception as e:
        print(f"error\nException: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/')
def index():
    return "Watson Chat API is running!"

if __name__ == "__main__":
    app.run(debug=True)
