---
name: "4-Agent Discussion"
description: "Spawns 4 parallel sub-agents to discuss a topic and reach a consensus solution using agent-sync."
user-invokable: true
argument-hint: "<topic> [roles] — e.g. 'How to implement auth in a SPA'"
---

# Purpose / When to use

Use this prompt when the user asks to simulate a discussion, brainstorm, or solve a complex problem using multiple perspectives. It leverages the `runSubagent` tool concurrently to spawn 4 independent agents, assigning each a unique role based on the topic. The agents will use the `agent-sync` skill to communicate, debate, and eventually agree on a solution.

# Inputs & arguments

- `topic`: The subject or problem to be discussed.
- `roles` (optional): Specific roles the user wants the agents to take. If not provided, the main agent must deduce 4 appropriate roles based on the topic.

# Workflow / Steps

1. **Role Assignment**: Analyze the `topic` and define 4 distinct, highly relevant roles (e.g., "Security Expert", "Performance Guru", "UX Designer", "Software Architect"). Assign each role a unique name (e.g., Alice, Bob, Carol, Dave).
2. **Workspace Preparation**: Ensure the `agent-sync` environment is ready (the scripts will auto-create the necessary directories).
3. **Sub-agent Prompt Generation**: Create a detailed prompt for each of the 4 sub-agents. The prompt MUST instruct the sub-agent to:
   - Register itself using `.github/skills/agent-sync/scripts/register.sh "<Name>" "<Role>"`.
   - Introduce itself to the group using `.github/skills/agent-sync/scripts/send.sh "<Name>" "<Introduction and initial thoughts on the topic>"`.
   - Enter a loop of reading messages (`.github/skills/agent-sync/scripts/read.sh --wait --agent "<Name>" --timeout 120`) and responding (`.github/skills/agent-sync/scripts/send.sh "<Name>" "<Message>"`) to debate the topic. **Always pass `--agent "<Name>"` — without it the log is truncated on read and other agents lose their messages.**
   - **Filter out its own messages**: after reading, skip any lines where the sender field matches its own name.
   - Look for a consensus. Once a solution is agreed upon by the group, the agent should unregister and exit, returning its summary of the solution.
4. **Concurrent Execution**: Call the `runSubagent` tool 4 times **concurrently** (in a single tool call batch), passing the respective prompt to each.
5. **Synthesis**: Once all 4 sub-agents return their final results, read the `tmp/agent-sync/message.log` to summarize the discussion history and present the final agreed-upon solution to the user.

# Examples & validation

**Example Sub-agent Prompt:**
"You are 'Alice', acting as the 'Security Expert'. The topic is 'Implementing authentication for a new SPA'. 
1. Register yourself: `.github/skills/agent-sync/scripts/register.sh "Alice" "Security Expert"`
2. Send your initial thoughts: `.github/skills/agent-sync/scripts/send.sh "Alice" "I believe we should use OAuth 2.0 with PKCE..."`
3. Listen for others: `.github/skills/agent-sync/scripts/read.sh --wait --agent Alice --timeout 120`  ← **always pass `--agent <your-name>` in group chat**
4. Skip any messages where the sender is yourself ('Alice') to avoid reacting to your own sends.
5. Reply to others using `send.sh`.
6. Continue discussing until the group reaches a consensus. Then return your final summary."

**Validation Checklist:**
- Did the main agent spawn exactly 4 sub-agents concurrently?
- Did each sub-agent receive a distinct role?
- Did the sub-agents use `agent-sync` to communicate?
- Did the main agent provide a final summary of the discussion to the user?
