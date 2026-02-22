#!/usr/bin/env bash
# read-direct.sh — Block and wait for a direct message on this agent's direct log
# Usage: read-direct.sh <your-agent-name> [--timeout N]
# Pass YOUR OWN agent name so the script reads from your direct log.
# Default: blocks indefinitely until a message arrives.
# --timeout N: wait at most N seconds, then exit with "(no message)".
#
# Messages are CONSUMED (removed from the queue) atomically on read,
# so no two readers can receive the same message.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_lock.sh
source "$SCRIPT_DIR/_lock.sh"

WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SYNC_DIR="$WORKSPACE_ROOT/tmp/agent-sync"
DIRECT_DIR="$SYNC_DIR/direct"

# --- parse args ---
NAME=""
TIMEOUT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    -*)
      echo "Usage: read-direct.sh <your-agent-name> [--timeout N]" >&2
      exit 1
      ;;
    *)
      NAME="$1"
      shift
      ;;
  esac
done

if [[ -z "$NAME" ]]; then
  echo "Usage: read-direct.sh <your-agent-name> [--timeout N]" >&2
  exit 1
fi

DIRECT_LOG="$DIRECT_DIR/${NAME}.log"
LOCKDIR="${DIRECT_LOG}.lock"

# Ensure lock is released on exit / signal
trap 'release_lock "$LOCKDIR"' EXIT INT TERM

# --- validate direct log exists ---
if [[ ! -f "$DIRECT_LOG" ]]; then
  echo "✗ No direct message log for agent '$NAME'. Is the agent registered?" >&2
  exit 1
fi

# --- blocking read: poll, consume atomically ---
POLL_INTERVAL=0.5
ELAPSED=0

while true; do
  # Acquire lock, read content, truncate, release — atomic consume
  acquire_lock "$LOCKDIR"
  CONTENT=$(cat "$DIRECT_LOG")
  if [[ -n "$CONTENT" ]]; then
    : > "$DIRECT_LOG"          # truncate under lock
    release_lock "$LOCKDIR"
    printf '%s\n' "$CONTENT"
    exit 0
  fi
  release_lock "$LOCKDIR"

  # Check timeout
  if [[ -n "$TIMEOUT" ]]; then
    ELAPSED_INT=${ELAPSED%.*}
    if [[ "${ELAPSED_INT:-0}" -ge "$TIMEOUT" ]]; then
      echo "(no message)"
      exit 0
    fi
  fi

  sleep "$POLL_INTERVAL"
  ELAPSED=$(echo "$ELAPSED + $POLL_INTERVAL" | bc)
done
