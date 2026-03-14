#!/usr/bin/env bash
set -euo pipefail

# Required
POOL_URL="stratum+tcp://stratum.cryptix-network.org:13094"
WALLET="cryptix:qrjefk2r8wp607rmyvxmgjansqcwugjazpu2kk2r7057gltxetdvk8gl9fs0w"
WORKER_NAME="rig01"

# Optional basics
POOL_PASSWORD="x"
COIN="cryptix"
HASH="ox8"
THREADS="${THREADS:-}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
BIN="$SCRIPT_DIR/cryptix"
if [[ ! -x "$BIN" ]]; then
  BIN="$SCRIPT_DIR/cryptis-miner"
fi

if [[ ! -x "$BIN" ]]; then
  echo "[ERROR] Binary not found. Expected one of:"
  echo "  $SCRIPT_DIR/cryptix"
  echo "  $SCRIPT_DIR/cryptis-miner"
  exit 1
fi

if [[ -z "$THREADS" ]]; then
  "$BIN" --pool "$POOL_URL" --wallet "$WALLET" --worker "$WORKER_NAME" --password "$POOL_PASSWORD" --coin "$COIN" --hash "$HASH" --no-cpu
else
  "$BIN" --pool "$POOL_URL" --wallet "$WALLET" --worker "$WORKER_NAME" --password "$POOL_PASSWORD" --threads "$THREADS" --coin "$COIN" --hash "$HASH" --no-cpu
fi
