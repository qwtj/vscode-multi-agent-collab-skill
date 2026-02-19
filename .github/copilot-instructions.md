# Repository Copilot instructions (always-on)

Purpose
- Provide repository-wide guidelines and defaults that apply to every Copilot / agent session.

Key rules (short)
- Follow project conventions and safety rules in file-based instructions when present.
- Prefer immutable, append-only records for audit logs (see `./tmp/task-monitor.instructions.md`).
- When writing files programmatically, use atomic operations, idempotency checks, and verify writes.

How to use
- Put broad, always-applicable policies here (coding standards, CI rules, security notes).
- Use `*.instructions.md` files for file-specific guidance (the agent will apply them when the file matches).

If you maintain a file-based instruction (recommended)
- Add a `*.instructions.md` adjacent to the file (for example: `./tmp/task-monitor.instructions.md`).
- Reference it from the target file's frontmatter if needed.

Contact
- Keep instruction files concise and focused on behavior agents must follow. See `./tmp/task-monitor.instructions.md` for the task-log policy.