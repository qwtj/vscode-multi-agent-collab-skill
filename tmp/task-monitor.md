# Task monitor

This file is an **append-only** chronological log of tasks run by agents.

Format
- Each entry MUST be a single line in this exact format:

  `<owner|agent id> | <task name> | <task status> [started|paused|active|complete|failed], <high-level overview>`

Guidelines
- Append only. Do **not** edit or remove existing lines — add a new line for every status change.
- To update a task's status, append a new line with the same `owner|agent id` and `task name` and the new status.
- Keep descriptions short (one brief sentence). If needed, append follow-up lines for details.

Sample entries
- agent-1 | data-sync | started, Scheduling sync for bucket A
- agent-1 | data-sync | active, Processing batch #7
- agent-1 | data-sync | complete, Synced 7 items in 32s
- scheduler | nightly-backup | paused, Waiting for resource quota

Append-only rules are enforced by the workspace instructions file: `.github/instructions/task-monitor.instructions.md`.

agent-1 | task 1 | started, Picked up `task 1.md` to summarize Copilot customization
agent-1 | task 1 | active, Generating summary and bullet list for Copilot customization docs
agent-1 | task 1 | complete, Created `copilot-customization-task-1.md` and moved original file to `tmp/task-complete/`

---TASK LIST---
