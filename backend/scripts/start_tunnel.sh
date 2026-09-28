#!/usr/bin/env bash
# ==============================================================================
# Aarogyam: Project Alpha — Cloudflare Tunnel Persistent Runner
# Boots the backend gateway and exposes it via a secure HTTPS Cloudflare tunnel
# ==============================================================================

set -e

PORT=${PORT:-5001}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
FLUTTER_ENV="${BACKEND_DIR}/../aarogyam-flutter/.env"

echo "=========================================================="
echo " Starting Aarogyam Project Alpha Backend & Cloudflare Tunnel"
echo "=========================================================="

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo "[!] cloudflared is not installed."
    echo "[*] Install with: brew install cloudflared"
    echo "[*] Alternatively, use USB reverse tethering: ./setup_usb_reverse.sh"
fi

echo "[*] Launching Flask Gateway on port ${PORT}..."
cd "${BACKEND_DIR}"
"${BACKEND_DIR}/venv/bin/python" app.py &
BACKEND_PID=$!

sleep 2

if command -v cloudflared &> /dev/null; then
    echo "[*] Starting Cloudflare Tunnel for http://localhost:${PORT}..."
    cloudflared tunnel --url "http://localhost:${PORT}"
else
    echo "[*] Backend running locally on PID ${BACKEND_PID} (http://localhost:${PORT})"
    wait $BACKEND_PID
fi
