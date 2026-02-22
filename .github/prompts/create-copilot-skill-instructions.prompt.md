---
name: Create Copilot Skill Instructions
description: Create a custom .instructions.md file that standardizes how to build Copilot skills.
agent: agent
model: Raptor mini (Preview) (copilot)
---

# Goal

Create a workspace custom instruction file at:

`.github/instructions/${input:instructionFileName}.instructions.md`

If no argument is provided, use `copilot-skill-authoring` as the file name.

# Requirements

Use this guidance source:

- https://code.visualstudio.com/docs/copilot/customization/agent-skills

Generate a practical instruction file for creating Copilot skills with these rules:

1. Explain required skill layout:
   - `.github/skills/<skill-name>/SKILL.md`
   - `SKILL.md` frontmatter `name` must match `<skill-name>` exactly.
2. Include optional locations and notes:
   - `.claude/skills/` and `.agents/skills/`
   - Optional companion resources (`examples/`, scripts, templates) referenced with relative links.
3. Include required `SKILL.md` sections:
   - Purpose and when to use
   - Inputs and arguments
   - Step-by-step workflow
   - Output expectations and validation checks
4. Include frontmatter guidance for `SKILL.md`:
   - Required: `name`, `description`
   - Optional: `argument-hint`, `user-invokable`, `disable-model-invocation`
5. Include a short checklist for validating a skill end-to-end.

# Output format for the created instruction file

The created `.instructions.md` must:

- Be concise and action-oriented.
- Contain a YAML frontmatter block with:
  - `name`
  - `description`
  - `applyTo: "**/.github/skills/**"`
- Include a reusable `SKILL.md` template block.
- Include a minimal example folder tree for one skill.

# Success criteria

- The file is created in `.github/instructions/`.
- Instructions are focused on creating and maintaining Copilot skills.
- Content is aligned with the official agent-skills documentation.