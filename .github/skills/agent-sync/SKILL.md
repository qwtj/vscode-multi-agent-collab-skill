---
name: "agent-sync"
description: "Synchronize and communicate between multiple VS Code Copilot agents"
user-invokable: true
argument-hint: "<command> [args] — e.g. register Alice Researcher"
---

# Purpose / When to use

Make up your own agent name, but always ask the user for the role before registering.

Use this skill whenever **multiple VS Code Copilot agents** need to:

- **Know each other's names and roles** in a shared workspace.
- **Send and receive messages** through a shared `message.log` file.
- **Coordinate work** by reading who is registered and what they are doing.

Each agent **must ask the user** for its role before registering. The role is a
free-form string describing what the agent is responsible for (e.g. "backend
developer", "code reviewer", "test writer").

All runtime state lives under `tmp/agent-sync/` in the workspace root.

## Autonomous operation

> **Agents MUST NOT ask the user what to do next.** After completing a task or
> sending a message, agents should **immediately listen for incoming messages**
> by calling `read.sh --wait` or `read-direct.sh` with an appropriate timeout
> and then act on whatever instruction or information arrives.
>
> **Default wait time:** Always use a timeout of **at least 120 seconds** (or
> longer) when waiting for messages, unless the user has **explicitly requested
> a shorter wait**. This ensures agents stay available long enough for other
> agents to respond. Example:
> ```bash
> .github/skills/agent-sync/scripts/read.sh --wait --timeout 120
> .github/skills/agent-sync/scripts/read-direct.sh "<your-agent-name>" --timeout 120
> ```
>
> If the timeout expires with no message, the agent should retry or proceed
> with its next planned action — **never prompt the user for guidance**.

# Inputs & arguments

| Command       | Arguments             | Description                                      |
|---------------|-----------------------|--------------------------------------------------|
| `register`    | `<agent-name> <role>`        | Register this agent with a chosen name and role (ask the user for the role first). |
| `unregister`  | `<agent-name>`               | Remove an agent from the registry.               |
| `list`        | *(none)*              | List all currently registered agents.            |
| `send`        | `<sender-name> <message>`    | Broadcast a message to `message.log`. First arg is **your own** agent name (the sender).       |
| `read`        | `[--since N] [--wait] [--timeout N]` | Read messages from the log. `--wait` blocks until a new message arrives. `--timeout N` limits the wait. `--since N` shows last N lines (instant mode). |
| `send-direct` | `<sender-name> <receiver-name> <msg>`   | Send a private message via named pipe to a specific agent. |
| `read-direct` | `<your-agent-name> [--timeout N]` | **Blocks** until a direct message arrives on **your own** pipe. Pass your agent name so the script knows which pipe to read. `--timeout N` limits the wait (exits with "(no message)" on timeout). |

# Step-by-step workflow

## First-time setup (automatic)

All scripts auto-create the `tmp/agent-sync/` directory, `registry.jsonl`,
and `message.log` if they don't exist.

## Registering an agent

1. **Ask the user** what role this agent should have.
2. Run the register script:
   ```bash
   .github/skills/agent-sync/scripts/register.sh "<agent-name>" "<role>"
   ```
3. The script appends a JSON line to `tmp/agent-sync/registry.jsonl` and
   creates a direct message log at `tmp/agent-sync/direct/<agent-name>.log`
   for direct messaging.

## Discovering other agents

```bash
.github/skills/agent-sync/scripts/list-agents.sh
```

Returns a JSON array of all registered agents with their names, roles, and
registration timestamps.

## Sending a broadcast message

```bash
.github/skills/agent-sync/scripts/send.sh "<sender-name>" "Your message here"
```

The first argument is **your own** agent name (the sender). Appends a
timestamped, structured log line to `tmp/agent-sync/message.log`.

## Reading broadcast messages

```bash
.github/skills/agent-sync/scripts/read.sh                # all messages (instant)
.github/skills/agent-sync/scripts/read.sh --since 10     # last 10 messages (instant)
.github/skills/agent-sync/scripts/read.sh --wait           # BLOCK until a new message arrives
.github/skills/agent-sync/scripts/read.sh --wait --timeout 120 # block up to 120s (default minimum)
```

> **Important:** Use `--wait` when the agent should pause and listen for
> incoming broadcast messages. The script polls `message.log` every 0.5s and
> prints only the **new** lines that appeared after the wait began.
>
> **Default timeout rule:** Use `--timeout 120` (or higher) unless the user
> explicitly asks for a shorter wait. Never use a timeout below 30 seconds
> without explicit user instruction.

## Direct messaging

Send to a specific agent's direct log:
```bash
.github/skills/agent-sync/scripts/send-direct.sh "<sender-name>" "<receiver-name>" "Message"
```

The target agent reads its own direct log (polls for new messages):
```bash
.github/skills/agent-sync/scripts/read-direct.sh "<your-agent-name>"            # block forever
.github/skills/agent-sync/scripts/read-direct.sh "<your-agent-name>" --timeout 120 # block up to 120s (default minimum)
```

> **Important:** By default `read-direct.sh` **polls indefinitely** until
> another agent writes a message. Use `--timeout N` if the agent should
> give up after N seconds (minimum 120s unless the user says otherwise).
> Run the read command in a **background terminal** when the agent needs to
> continue other work while listening.
>
> **Do not ask the user for next steps.** After a timeout expires, retry the
> wait or proceed autonomously with your next planned action.

## Unregistering

```bash
.github/skills/agent-sync/scripts/unregister.sh "<agent-name>"
```

Removes the agent from the registry and cleans up its direct message log.

# Outputs & validation checks

- **register** → prints `✓ <name> registered as <role>` and exits 0.
- **unregister** → prints `✓ <name> unregistered` and exits 0.
- **list** → prints a JSON array to stdout; exits 0 even if empty (`[]`).
- **send** → prints `✓ message sent` and exits 0.
- **read** → prints log lines to stdout; exits 0.
- **send-direct** → prints `✓ direct message sent to <receiver-name>` and exits 0.
- **read-direct** → **blocks** until a message arrives and prints it; with `--timeout`, prints `(no message)` if the timeout expires. Exits 0.

### Validation

1. After `register`, run `list` and verify the agent appears.
2. After `send`, run `read --since 1` and verify the message appears.
3. Timestamps in `message.log` should be valid ISO 8601 and within ±5s of
   the current system time.

### Sample `message.log` entry

```
2026-02-20T14:30:05-08:00 | Alice | Hello team, starting code review now.
```

### Sample `registry.jsonl` entry

```json
{"name":"Alice","role":"Code Reviewer","registered_at":"2026-02-20T14:29:50-08:00"}
```

