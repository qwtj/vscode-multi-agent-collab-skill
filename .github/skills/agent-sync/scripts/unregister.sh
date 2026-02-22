#!/usr/bin/env bash
# unregister.sh — Remove an agent from the registry and clean up its pipe
# Usage: unregister.sh <agent-name>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SYNC_DIR="$WORKSPACE_ROOT/tmp/agent-sync"
REGISTRY="$SYNC_DIR/registry.jsonl"
DIRECT_DIR="$SYNC_DIR/direct"

# --- args ---
if [[ $# -lt 1 ]]; then
  echo "Usage: unregister.sh <agent-name>" >&2
  exit 1
fi

NAME="$1"

# --- check existence ---
if ! grep -q "\"name\":\"${NAME}\"" "$REGISTRY" 2>/dev/null; then
  echo "⚠  Agent '$NAME' is not registered." >&2
  exit 1
fi

# --- remove from registry ---
TMPFILE=$(mktemp)
grep -v "\"name\":\"${NAME}\"" "$REGISTRY" > "$TMPFILE" || true
mv "$TMPFILE" "$REGISTRY"

# --- remove direct message log ---
DIRECT_LOG="$DIRECT_DIR/${NAME}.log"
if [[ -f "$DIRECT_LOG" ]]; then
  rm -f "$DIRECT_LOG"
fi

# --- announce ---
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z")
echo "${TIMESTAMP} | SYSTEM | Agent '${NAME}' has been unregistered." >> "$SYNC_DIR/message.log"

echo "✓ ${NAME} unregistered"
