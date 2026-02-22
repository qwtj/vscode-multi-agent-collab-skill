#!/usr/bin/env bash
# send.sh — Send a broadcast message to message.log
# Usage: send.sh <sender-name> <message>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_lock.sh
source "$SCRIPT_DIR/_lock.sh"

WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SYNC_DIR="$WORKSPACE_ROOT/tmp/agent-sync"
LOG="$SYNC_DIR/message.log"

# --- args ---
if [[ $# -lt 2 ]]; then
  echo "Usage: send.sh <sender-name> <message>" >&2
  exit 1
fi

NAME="$1"
shift
MESSAGE="$*"

# --- init ---
mkdir -p "$SYNC_DIR"
touch "$LOG"

# --- timestamp ---
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z")

LOCKDIR="${LOG}.lock"
trap 'release_lock "$LOCKDIR"' EXIT INT TERM

# --- append (under lock) ---
acquire_lock "$LOCKDIR"
echo "${TIMESTAMP} | ${NAME} | ${MESSAGE}" >> "$LOG"
release_lock "$LOCKDIR"

echo "✓ message sent"
