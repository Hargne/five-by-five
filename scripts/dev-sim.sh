#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SDK_HOME="${CONNECTIQ_SDK_HOME:-}"
KEY_PATH="${CONNECTIQ_KEY_PATH:-$HOME/.ciq/developer_key.der}"
DEVICE_ID="${CONNECTIQ_DEVICE_ID:-fr245}"
OUTPUT_PATH="${ROOT_DIR}/bin/FiveByFive.prg"
INTERVAL_SECONDS="1"

usage() {
  cat <<'EOF'
Watch, rebuild, and redeploy FiveByFive to a running Connect IQ simulator.

Usage:
  scripts/dev-sim.sh [-d device-id] [-s sdk_home] [-k key.der] [-o output.prg] [-i seconds]

Options:
  -d  Simulator device id (default: fr245, or CONNECTIQ_DEVICE_ID)
  -i  Poll interval in seconds (default: 1)
  -k  Path to developer key (.der, default: ~/.ciq/developer_key.der)
  -o  Output .prg path (default: bin/FiveByFive.prg)
  -s  Connect IQ SDK home path (optional if monkeyc/monkeydo are in PATH)
  -h  Show this help

Environment overrides:
  CONNECTIQ_DEVICE_ID
  CONNECTIQ_KEY_PATH
  CONNECTIQ_SDK_HOME

Start the simulator in another terminal before running this script:
  simulator
EOF
}

while getopts ":d:i:k:o:s:h" opt; do
  case "$opt" in
    d) DEVICE_ID="$OPTARG" ;;
    i) INTERVAL_SECONDS="$OPTARG" ;;
    k) KEY_PATH="$OPTARG" ;;
    o) OUTPUT_PATH="$OPTARG" ;;
    s) SDK_HOME="$OPTARG" ;;
    h)
      usage
      exit 0
      ;;
    :)
      echo "Missing value for -$OPTARG" >&2
      usage
      exit 2
      ;;
    \?)
      echo "Unknown option: -$OPTARG" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -n "$SDK_HOME" ]]; then
  MONKEYC="${SDK_HOME}/bin/monkeyc"
  MONKEYDO="${SDK_HOME}/bin/monkeydo"
else
  MONKEYC="$(command -v monkeyc || true)"
  MONKEYDO="$(command -v monkeydo || true)"
fi

if [[ -z "$MONKEYC" || ! -x "$MONKEYC" ]]; then
  echo "monkeyc not found. Add it to PATH, pass -s <sdk_home>, or set CONNECTIQ_SDK_HOME." >&2
  exit 1
fi

if [[ -z "$MONKEYDO" || ! -x "$MONKEYDO" ]]; then
  echo "monkeydo not found. Add it to PATH, pass -s <sdk_home>, or set CONNECTIQ_SDK_HOME." >&2
  exit 1
fi

if [[ ! -f "$KEY_PATH" ]]; then
  echo "Key file not found: $KEY_PATH" >&2
  echo "Set -k <path/to/key.der> or CONNECTIQ_KEY_PATH." >&2
  exit 1
fi

case "$INTERVAL_SECONDS" in
  ''|*[!0-9.]*)
    echo "Poll interval must be a number: $INTERVAL_SECONDS" >&2
    exit 2
    ;;
esac

mkdir -p "$(dirname "$OUTPUT_PATH")"

fingerprint() {
  find \
    "$ROOT_DIR/source" \
    "$ROOT_DIR/resources" \
    "$ROOT_DIR/manifest.xml" \
    "$ROOT_DIR/monkey.jungle" \
    -type f \
    -print0 |
    xargs -0 shasum |
    LC_ALL=C sort |
    shasum |
    awk '{print $1}'
}

build_and_run() {
  echo
  echo "[$(date '+%H:%M:%S')] Building $OUTPUT_PATH"
  "$MONKEYC" \
    -f "$ROOT_DIR/monkey.jungle" \
    -o "$OUTPUT_PATH" \
    -y "$KEY_PATH"

  echo "[$(date '+%H:%M:%S')] Deploying to simulator device: $DEVICE_ID"
  "$MONKEYDO" "$OUTPUT_PATH" "$DEVICE_ID"
}

echo "Watching FiveByFive sources."
echo "  Device:   $DEVICE_ID"
echo "  Key:      $KEY_PATH"
echo "  Output:   $OUTPUT_PATH"
echo "  Interval: ${INTERVAL_SECONDS}s"
echo "Press Ctrl+C to stop."

last_fingerprint=""

while true; do
  current_fingerprint="$(fingerprint)"

  if [[ "$current_fingerprint" != "$last_fingerprint" ]]; then
    if build_and_run; then
      last_fingerprint="$current_fingerprint"
    else
      echo "[$(date '+%H:%M:%S')] Build or deploy failed. Waiting for changes..."
      last_fingerprint="$current_fingerprint"
    fi
  fi

  sleep "$INTERVAL_SECONDS"
done
