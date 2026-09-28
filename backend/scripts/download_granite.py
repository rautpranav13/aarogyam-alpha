"""
Utility to download and cache IBM Granite Vision 3.2 2B weights locally from Hugging Face.
Usage:
    python backend/scripts/download_granite.py
"""
import os
import sys

def download_model(model_id: str = "ibm-granite/granite-vision-3.2-2b"):
    print(f"[*] Checking local environment for IBM Granite Vision: {model_id}")
    try:
        from huggingface_hub import snapshot_download
        print(f"[*] Downloading snapshot for {model_id}...")
        path = snapshot_download(
            repo_id=model_id,
            ignore_patterns=["*.msgpack", "*.h5", "*.ot"]
        )
        print(f"[✓] IBM Granite Vision 3.2 2B successfully downloaded to: {path}")
        return path
    except ImportError:
        print("[!] huggingface_hub not installed in current environment.")
        print("[*] Install with: pip install huggingface-hub")
        print("[*] Note: In Project Alpha, WatsonX Cloud ModelInference can also be used directly without local weight storage.")
        return None
    except Exception as e:
        print(f"[!] Download error: {e}")
        return None

if __name__ == "__main__":
    model = sys.argv[1] if len(sys.argv) > 1 else "ibm-granite/granite-vision-3.2-2b"
    download_model(model)
