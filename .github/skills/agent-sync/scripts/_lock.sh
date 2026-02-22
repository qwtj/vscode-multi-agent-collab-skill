#!/usr/bin/env bash
# _lock.sh — Portable atomic lock helpers using mkdir (POSIX-safe).
# Source this file, then call:
#   acquire_lock  <lockdir-path>
#   release_lock  <lockdir-path>
#
# mkdir is atomic on every POSIX filesystem, so two processes racing to create
# the same directory will have exactly one succeed — no flock/shlock needed.

acquire_lock() {
  local lockdir="$1"
  local max_attempts=200        # 200 × 0.05 s = 10 s max wait
  local attempt=0
  while ! mkdir "$lockdir" 2>/dev/null; do
    attempt=$((attempt + 1))
    if [[ $attempt -ge $max_attempts ]]; then
      echo "✗ Failed to acquire lock ($lockdir) after ${max_attempts} attempts" >&2
      exit 1
    fi
    sleep 0.05
  done
}

release_lock() {
  rmdir "$1" 2>/dev/null || true
}
