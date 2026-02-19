---
name: 'Task monitor rules'
description: 'Append-only, atomic-append rules for tmp/task-monitor.md'
applyTo: 'tmp/task-monitor.md'
---

# File-based instructions for ./tmp/task-monitor.md

Purpose
- Maintain a chronological, append-only task log used by agents and humans. These rules are file-specific and are enforced for `task-monitor.md`.

Primary rule (enforced)
- ALWAYS append new lines only. Do NOT edit, reorder, or delete existing lines in `./tmp/task-monitor.md`.

Required line format (single-line event entries)
- Exact format: <owner|agent id> | <task name> | <task status> [started|paused|active|complete|failed], <high-level overview>
- Validate new lines against the regex: ^[^|]+ \| [^|]+ \| (started|paused|active|complete|failed), .+$

Safe append behaviour
- Appends must be atomic. Prefer O_APPEND or write-to-temp-file + rename.
- After append, immediately re-read the file tail to confirm the line is present.
- If the identical line already exists, do not append (idempotency).
- To change a task's status, append a new line with the same <owner|agent id> and <task name> and the new status; never modify earlier entries.

Concurrency and deadlock prevention
- Prefer optimistic append; avoid locks when possible.
- If locking is required, use a short-lived advisory lock (e.g. `./tmp/task-monitor.lock`) with non-blocking acquire + exponential backoff (50ms → 500ms), up to 5 attempts.
- Keep lock hold-time < 500ms. Never wait more than 5s to acquire a lock.
- If lock acquisition repeatedly fails, append a `paused` or `failed` event for the task and abort.
- Do not hold locks while performing external I/O or network calls.

Race-condition mitigation
- After writing, re-read the last N lines to confirm the write succeeded and no interleaving occurred.
- Producers must check the task's last recorded status and avoid appending duplicate status lines.

Failure & recovery
- On write failure, push the event into a local retry queue and append a `paused` or `failed` event describing the failure.
- On restart, reconcile the retry queue with the `task-monitor.md` file; do not retroactively edit previous lines.

Copilot and human-edit policy
- Any PR that modifies `./tmp/task-monitor.md` must only add new lines; changes to existing lines will be rejected.
- When generating code that writes to `task-monitor.md`, implement the lock/retry/verify pattern described above.

Task pickup & lifecycle (directory rules)
- Task source directory: agents MUST only pick up task files from `./tmp/task` unless explicitly configured otherwise.
- Skip rule: before picking a task, check `task-monitor.md` for the task's most recent entry; do NOT pick a task whose last recorded status is `active` or `failed`. Also check that the task file is not present in any `./tmp/task - <status>` folder (for example `./tmp/task - active`, `./tmp/task - paused`, `./tmp/task - failed`); if present, skip pickup.
- Task identity: treat the task file's basename (filename without extension) as the `<task name>` used in `task-monitor.md` entries.
- Start sequence: when beginning work on a picked task, append a `started` event for the task (owner/agent id | <task name> | started, short reason) and then append `active` when processing begins. After appending `active`, atomically move the task file from `./tmp/task` to `./tmp/task - active` (create the directory if missing) and re-read `task-monitor.md` tail to verify the `active` entry and the file presence in `./tmp/task - active`. If the file is already in `./tmp/task - active`, do not re-move or duplicate the `active` event.
- Failures: if processing fails, append a `failed` event with an informative message (include error context). Then atomically move the task file to `./tmp/task - failed` (create the directory if missing). Do not delete historical entries; to change a task's status append a new `failed` line — never edit previous lines.
- Pause for user: if the task requires user input, append `paused` and atomically move the task file to `./tmp/task - paused`; halt processing until an explicit resume event is appended to `task-monitor.md`.
- Completion and move: on successful completion, append a `complete` event and then atomically move the task file from its current location (`./tmp/task` or any `./tmp/task - <status>` folder) to `./tmp/task - complete` (use rename/move to preserve atomicity). After the move, re-read `task-monitor.md` tail and verify the `complete` entry and that the file exists in `./tmp/task - complete`.
- Idempotency & safety: if the file already exists in the target `./tmp/task - <status>` folder or the corresponding status line already exists in `task-monitor.md`, do not append duplicate status events or re-move the file. Always append new status lines for transitions; never edit earlier entries.
- Directory existence: ensure any `./tmp/task - <status>` directories you will use (`active`, `paused`, `failed`, `complete`) exist (create if missing) before attempting moves; directory creation should be non-blocking and retry-on-failure.
- Auditability: always append status transitions to `task-monitor.md` (never edit previous lines) so that the full lifecycle (started → active → paused/failed → complete) is recorded and traceable.


Examples
- agent-1 | data-sync | started, Scheduling sync for bucket A
- agent-1 | data-sync | active, Processing batch #7
- agent-1 | data-sync | complete, Synced 7 items in 32s
- scheduler | nightly-backup | paused, Waiting for resource quota
