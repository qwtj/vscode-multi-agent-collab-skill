#!/usr/bin/env bash
# read.sh — Read broadcast messages from message.log
# Usage: read.sh [--since N] [--wait] [--timeout N]
#
# --wait:      Block until at least one NEW message arrives, consume & print it, then exit.
# --timeout N: With --wait, give up after N seconds (default: block forever).
# --since N:   Without --wait, show the last N lines (non-destructive peek).
#
# In --wait mode messages are CONSUMED (removed from the queue) atomically,
# so no two readers can receive the same message.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_lock.sh
source "$SCRIPT_DIR/_lock.sh"

WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SYNC_DIR="$WORKSPACE_ROOT/tmp/agent-sync"
LOG="$SYNC_DIR/message.log"
LOCKDIR="${LOG}.lock"

# --- init ---
mkdir -p "$SYNC_DIR"
touch "$LOG"

# Ensure lock is released on exit / signal
trap 'release_lock "$LOCKDIR"' EXIT INT TERM

# --- parse args ---
SINCE=""
WAIT=false
TIMEOUT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --since)
      SINCE="$2"
      shift 2
      ;;
    --wait)
      WAIT=true
      shift
      ;;
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    *)
      echo "Usage: read.sh [--since N] [--wait] [--timeout N]" >&2
      exit 1
      ;;
  esac
done

if $WAIT; then
  # --- blocking mode: wait for NEW messages, consume atomically ---
  POLL_INTERVAL=0.5
  ELAPSED=0

  while true; do
    acquire_lock "$LOCKDIR"
    CONTENT=$(cat "$LOG")
    if [[ -n "$CONTENT" ]]; then
      : > "$LOG"                 # truncate under lock
      release_lock "$LOCKDIR"
      printf '%s\n' "$CONTENT"
      exit 0
    fi
    release_lock "$LOCKDIR"

    # Check timeout
    if [[ -n "$TIMEOUT" ]]; then
      ELAPSED_INT=${ELAPSED%.*}
      if [[ "${ELAPSED_INT:-0}" -ge "$TIMEOUT" ]]; then
        echo "(no new messages after ${TIMEOUT}s)"
        exit 0
      fi
    fi

    sleep "$POLL_INTERVAL"
    ELAPSED=$(echo "$ELAPSED + $POLL_INTERVAL" | bc)
  done
else
  # --- instant mode: non-destructive peek at existing messages ---
  if [[ -n "$SINCE" ]]; then
    tail -n "$SINCE" "$LOG"
  else
    cat "$LOG"
  fi
fi
