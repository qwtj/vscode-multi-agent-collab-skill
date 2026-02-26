#!/usr/bin/env bash
# read.sh — Read broadcast messages from message.log
# Usage: read.sh [--since N] [--wait] [--timeout N] [--agent <name>]
#
# --wait:         Block until at least one NEW message arrives, print it, then exit.
# --timeout N:    With --wait, give up after N seconds (default: block forever).
# --since N:      Without --wait, show the last N lines (non-destructive peek).
# --agent <name>: RECOMMENDED for group chat. Non-destructive cursor-based read:
#                 each agent tracks its own position so ALL agents see ALL messages.
#                 Without --agent, messages are CONSUMED (log truncated) on read —
#                 only safe for single-consumer work queues.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_lock.sh
source "$SCRIPT_DIR/_lock.sh"

WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SYNC_DIR="$WORKSPACE_ROOT/tmp/agent-sync"
LOG="$SYNC_DIR/message.log"
LOCKDIR="${LOG}.lock"
CURSOR_DIR="$SYNC_DIR/cursors"

# --- init ---
mkdir -p "$SYNC_DIR" "$CURSOR_DIR"
touch "$LOG"

# Ensure lock is released on exit / signal
trap 'release_lock "$LOCKDIR"' EXIT INT TERM

# --- parse args ---
SINCE=""
WAIT=false
TIMEOUT=""
AGENT_NAME=""
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
    --agent)
      AGENT_NAME="$2"
      shift 2
      ;;
    *)
      echo "Usage: read.sh [--since N] [--wait] [--timeout N] [--agent <name>]" >&2
      exit 1
      ;;
  esac
done

if $WAIT; then
  POLL_INTERVAL=1
  START_TIME=$(date +%s)

  if [[ -n "$AGENT_NAME" ]]; then
    # --- per-agent cursor mode (group chat safe) ---
    # Non-destructive: log is never truncated. Each agent independently
    # tracks the last line it read via a cursor file.
    CURSOR_FILE="$CURSOR_DIR/${AGENT_NAME}.pos"
    [[ -f "$CURSOR_FILE" ]] || echo "0" > "$CURSOR_FILE"

    while true; do
      # Acquire lock so that the cursor read + print + advance is atomic.
      # This prevents two concurrent sessions for the same agent from both
      # seeing the same unread messages and sending duplicate replies.
      acquire_lock "$LOCKDIR"
      CURSOR=$(cat "$CURSOR_FILE")
      TOTAL=$(wc -l < "$LOG" | tr -d ' ')
      if [[ "$TOTAL" -gt "$CURSOR" ]]; then
        # New lines available — print them and advance cursor
        tail -n +"$((CURSOR + 1))" "$LOG"
        echo "$TOTAL" > "$CURSOR_FILE"
        release_lock "$LOCKDIR"
        exit 0
      fi
      release_lock "$LOCKDIR"

      # Check timeout
      if [[ -n "$TIMEOUT" ]]; then
        NOW=$(date +%s)
        ELAPSED=$(( NOW - START_TIME ))
        if [[ "$ELAPSED" -ge "$TIMEOUT" ]]; then
          echo "(no new messages after ${TIMEOUT}s)"
          exit 0
        fi
      fi

      sleep "$POLL_INTERVAL"
    done

  else
    # --- legacy consume mode (single-consumer work queue only) ---
    # WARNING: truncates the log — do NOT use with multiple concurrent readers.
    while true; do
      acquire_lock "$LOCKDIR"
      CONTENT=$(cat "$LOG")
      if [[ -n "$CONTENT" ]]; then
        : > "$LOG"               # truncate under lock
        release_lock "$LOCKDIR"
        printf '%s\n' "$CONTENT"
        exit 0
      fi
      release_lock "$LOCKDIR"

      # Check timeout
      if [[ -n "$TIMEOUT" ]]; then
        NOW=$(date +%s)
        ELAPSED=$(( NOW - START_TIME ))
        if [[ "$ELAPSED" -ge "$TIMEOUT" ]]; then
          echo "(no new messages after ${TIMEOUT}s)"
          exit 0
        fi
      fi

      sleep "$POLL_INTERVAL"
    done
  fi

else
  # --- instant mode: non-destructive peek at existing messages ---
  if [[ -n "$SINCE" ]]; then
    tail -n "$SINCE" "$LOG"
  else
    cat "$LOG"
  fi
fi
