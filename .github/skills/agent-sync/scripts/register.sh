#!/usr/bin/env bash
# register.sh — Register a Copilot agent with a name and role.
# Usage: register.sh <agent-name> <role>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SYNC_DIR="$WORKSPACE_ROOT/tmp/agent-sync"
REGISTRY="$SYNC_DIR/registry.jsonl"
DIRECT_DIR="$SYNC_DIR/direct"

# --- args ---
if [[ $# -lt 2 ]]; then
  echo "Usage: register.sh <agent-name> <role>" >&2
  exit 1
fi

NAME="$1"
shift
ROLE="$*"

# --- init dirs ---
mkdir -p "$SYNC_DIR" "$DIRECT_DIR"
touch "$REGISTRY" "$SYNC_DIR/message.log"

# --- check for duplicate ---
if grep -q "\"name\":\"${NAME}\"" "$REGISTRY" 2>/dev/null; then
  echo "⚠  Agent '$NAME' is already registered. Updating role." >&2
  # Remove old entry
  TMPFILE=$(mktemp)
  grep -v "\"name\":\"${NAME}\"" "$REGISTRY" > "$TMPFILE" || true
  mv "$TMPFILE" "$REGISTRY"
fi

# --- timestamp ---
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z")

# --- write registry entry ---
echo "{\"name\":\"${NAME}\",\"role\":\"${ROLE}\",\"registered_at\":\"${TIMESTAMP}\"}" >> "$REGISTRY"

# --- create direct message log for this agent ---
DIRECT_LOG="$DIRECT_DIR/${NAME}.log"
touch "$DIRECT_LOG"

# --- announce in message.log ---
echo "${TIMESTAMP} | SYSTEM | Agent '${NAME}' registered as '${ROLE}'." >> "$SYNC_DIR/message.log"

echo "✓ ${NAME} registered as ${ROLE}"
