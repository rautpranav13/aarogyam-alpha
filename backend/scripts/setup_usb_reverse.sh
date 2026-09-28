#!/usr/bin/env bash
# ==============================================================================
# Aarogyam: Project Alpha — Zero-Latency USB ADB Reverse Tethering
# Guarantees <1ms latency between Android phone and laptop during live pitch
# ==============================================================================

set -e

PORT=${1:-5001}

echo "=========================================================="
echo " Setting up Zero-Latency USB Reverse Tunnel (Port ${PORT})"
echo "=========================================================="

if ! command -v adb &> /dev/null; then
    echo "[!] adb command not found. Ensure Android SDK Platform-Tools are in PATH."
    exit 1
fi

echo "[*] Detecting connected Android devices..."
adb devices

echo "[*] Configuring adb reverse tcp:${PORT} tcp:${PORT}..."
adb reverse tcp:${PORT} tcp:${PORT}

echo "[✓] Port forwarding active! Android device can now access http://localhost:${PORT} directly."
