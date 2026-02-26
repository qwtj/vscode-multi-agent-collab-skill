# Agent-Sync Skill

The `agent-sync` skill enables synchronization and communication between multiple VS Code Copilot agents in a shared workspace. It allows agents to register themselves, discover other agents, send broadcast messages, and exchange direct messages, facilitating collaborative workflows.

## Purpose

Use this skill when multiple VS Code Copilot agents need to:
- Know each other's names and roles.
- Send and receive messages through a shared log.
- Coordinate work autonomously.

Each agent must ask the user for its role before registering. All state is stored under `tmp/agent-sync/` in the workspace root.

## Key Features

- **Agent Registration**: Register agents with names and roles.
- **Broadcast Messaging**: Send messages to all agents via `message.log`.
- **Direct Messaging**: Send private messages to specific agents.
- **Message Reading**: Read messages with options for waiting, timeouts, and cursors for group chats.
- **Autonomous Operation**: Agents listen for messages and act without user prompts.

## How to Use

### 1. Register an Agent

First, ask the user for the agent's role. Then run:

```bash
.github/skills/agent-sync/scripts/register.sh "<agent-name>" "<role>"
```

Example:
```bash
.github/skills/agent-sync/scripts/register.sh "Alice" "Security Expert"
```

### 2. List Registered Agents

```bash
.github/skills/agent-sync/scripts/list-agents.sh
```

### 3. Send a Broadcast Message

```bash
.github/skills/agent-sync/scripts/send.sh "<sender-name>" "Your message here"
```

### 4. Read Broadcast Messages

For group chats (multiple agents), use:

```bash
.github/skills/agent-sync/scripts/read.sh --wait --agent "<your-name>" --timeout 120
```

### 5. Send Direct Messages

```bash
.github/skills/agent-sync/scripts/send-direct.sh "<sender-name>" "<receiver-name>" "Message"
```

### 6. Read Direct Messages

```bash
.github/skills/agent-sync/scripts/read-direct.sh "<your-name>" --timeout 120
```

### 7. Unregister an Agent

```bash
.github/skills/agent-sync/scripts/unregister.sh "<agent-name>"
```

## Autonomous Operation Guidelines

- Agents must not ask the user what to do next.
- After sending a message, immediately listen for responses.
- Use timeouts of at least 120 seconds when waiting.
- In group chats, always use `--agent <your-name>` to avoid consuming the log.

## 4-Agents Prompt Example

This example demonstrates a collaborative session with 4 agents: Alice (Security Expert), Bob (Technical Architect), Carol (DevOps Engineer), and Dave (QA and Testing Specialist). They are tasked with planning a secure, scalable microservice architecture.

### Initial Prompt for Each Agent

Each agent is given the following prompt:

"You are [Agent Name], a [Role]. You are part of a team of 4 agents collaborating on planning a microservice architecture for a new project. The team consists of:
- Alice: Security Expert
- Bob: Technical Architect
- Carol: DevOps Engineer
- Dave: QA and Testing Specialist

Your goal is to contribute your expertise to create a comprehensive plan covering architecture, security, DevOps, and testing. Start by registering yourself, then send an initial message with your key recommendations. Listen for messages from others and respond collaboratively. Coordinate to reach consensus on the final plan.

Use the agent-sync skill for communication."

### Sample Workflow

1. Each agent registers:
   ```bash
   .github/skills/agent-sync/scripts/register.sh "Alice" "Security Expert"
   .github/skills/agent-sync/scripts/register.sh "Bob" "Technical Architect"
   .github/skills/agent-sync/scripts/register.sh "Carol" "DevOps Engineer"
   .github/skills/agent-sync/scripts/register.sh "Dave" "QA and Testing Specialist"
   ```

2. Agents send initial messages and discuss.

3. They read messages and respond until consensus is reached.

### Example Conversation (from message.log)

```
2026-02-25T10:00:00-08:00 | Alice | For security, we should use Spring Security with OAuth2/OIDC, TLS 1.3, and encrypt data at rest.
2026-02-25T10:01:00-08:00 | Bob | Architecturally, Spring Boot 3, Java 21, stateless services, Kafka for messaging.
2026-02-25T10:02:00-08:00 | Carol | DevOps: Kubernetes, Terraform, CI/CD with security scanning.
2026-02-25T10:03:00-08:00 | Dave | Testing: JUnit, Testcontainers, Gatling, SAST/DAST.
2026-02-25T10:04:00-08:00 | Bob | Synthesized plan: [comprehensive plan details]
2026-02-25T10:05:00-08:00 | Alice | Agree with the plan.
2026-02-25T10:06:00-08:00 | Carol | Consensus reached.
2026-02-25T10:07:00-08:00 | Dave | Yes, proceed.
```

This setup allows agents to autonomously collaborate and produce a well-rounded plan leveraging each member's expertise.