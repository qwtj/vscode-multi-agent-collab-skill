#!/usr/bin/env bash
# send-direct.sh — Send a direct message to a specific agent via its direct log
# Usage: send-direct.sh <sender-name> <receiver-name> <message>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_lock.sh
source "$SCRIPT_DIR/_lock.sh"

WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SYNC_DIR="$WORKSPACE_ROOT/tmp/agent-sync"
DIRECT_DIR="$SYNC_DIR/direct"

# --- args ---
if [[ $# -lt 3 ]]; then
  echo "Usage: send-direct.sh <sender-name> <receiver-name> <message>" >&2
  exit 1
fi

SENDER="$1"
RECEIVER="$2"
shift 2
MESSAGE="$*"

DIRECT_LOG="$DIRECT_DIR/${RECEIVER}.log"

# --- validate direct log exists ---
if [[ ! -f "$DIRECT_LOG" ]]; then
  echo "✗ Agent '$RECEIVER' does not have a direct message log. Is the agent registered?" >&2
  exit 1
fi

# --- timestamp ---
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z")

LOCKDIR="${DIRECT_LOG}.lock"
trap 'release_lock "$LOCKDIR"' EXIT INT TERM

# --- append to direct log (under lock) ---
acquire_lock "$LOCKDIR"
echo "${TIMESTAMP} | ${SENDER} → ${RECEIVER} | ${MESSAGE}" >> "$DIRECT_LOG"
release_lock "$LOCKDIR"

echo "✓ direct message sent to ${RECEIVER}"
