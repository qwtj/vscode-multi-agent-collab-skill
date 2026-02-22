#!/usr/bin/env bash
# list-agents.sh — List all registered agents as JSON
# Usage: list-agents.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SYNC_DIR="$WORKSPACE_ROOT/tmp/agent-sync"
REGISTRY="$SYNC_DIR/registry.jsonl"

# --- init ---
mkdir -p "$SYNC_DIR"
touch "$REGISTRY" 2>/dev/null || true

# --- build JSON array from JSONL ---
if [[ ! -s "$REGISTRY" ]]; then
  echo "[]"
  exit 0
fi

# Use awk to build a JSON array from JSONL lines
echo "["
FIRST=true
while IFS= read -r line; do
  if [[ -z "$line" ]]; then
    continue
  fi
  if $FIRST; then
    FIRST=false
  else
    echo ","
  fi
  printf "  %s" "$line"
done < "$REGISTRY"
echo ""
echo "]"
