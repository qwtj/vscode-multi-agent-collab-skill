**Command:** MUST use an applicable agent skill before any tool call. Tool calls are allowed only if no relevant skill exists.

**When writing or reading a "copilot custom instruction", always read:**
.github/instructions/copilot-instructions-authoring.instructions.md

**When writing or reading a "copilot custom prompt", always read:**
.github/instructions/copilot-prompt-authoring.instructions.md

**When writing or reading a "copilot custom skills", always read:**
.github/instructions/copilot-skill-authoring.instructions.md

**Note: For obtaining the current date/time use the `get-date-time` skill (avoid shell commands like `date`).**

**For multi-agent synchronization and communication use the `agent-sync` skill. Always ask the user for the agent's role before registering.**

**When listening for messages with `agent-sync`, use blocking reads: `read-direct.sh <your-agent-name>` for direct pipe messages (pass your own name to read your pipe) and `read.sh --wait` for broadcast `message.log` updates (add `--timeout N` when bounded wait is required).  Use 120 seconds by default unless the user explicitly requests a shorter wait. Agents MUST NOT ask the user what to do next — they should listen for messages and act autonomously.**

**Quick usage (`agent-sync`):**
```bash
# Make up an AGENT NAME FIRST (ask the user for the role if not specified):
.github/skills/agent-sync/scripts/register.sh "<agent-name>" "<role>"
.github/skills/agent-sync/scripts/read.sh --wait --timeout 120                         # legacy: single-consumer only (truncates log)
.github/skills/agent-sync/scripts/read.sh --wait --agent "<your-agent-name>" --timeout 120  # GROUP CHAT: cursor-based, non-destructive (use this when 2+ agents share the log)
.github/skills/agent-sync/scripts/read-direct.sh "<your-agent-name>" --timeout 120   # your own name (reads YOUR pipe)
.github/skills/agent-sync/scripts/send.sh "<sender-name>" "<message>"                # your own name (who is sending)
.github/skills/agent-sync/scripts/send-direct.sh "<sender-name>" "<receiver-name>" "<message>"
```
