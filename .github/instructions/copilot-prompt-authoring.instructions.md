---
name: "Copilot Prompt Authoring"
description: "Guidelines for creating and validating Copilot custom prompt files"
---

# Writing a Copilot Custom Prompt File

Use this instruction file when you are authoring or maintaining a Copilot custom
prompt file inside the `.github/instructions/` (or compatible) directory. The goal
is to ensure the prompt is structured correctly, documented for both humans and
agents, and can be used by subagents to generate or validate prompts.

## Placement & naming 🚩

- Files usually live in `.github/instructions/` but other recognized locations
  include `.claude/skills/` or `.agents/skills/` if your workflow requires it.
- The filename should be descriptive of the prompt’s purpose (e.g.
  `copilot-custom.prompt-files.instructions.md`).

## Required sections 📄

Each custom prompt instruction file should include the following headings in
Markdown order:

1. **Purpose / When to use** – explain what the prompt is for and when it should
   be applied.
2. **Inputs & arguments** – detail any placeholders, CLI flags, or JSON fields
   that the prompt depends on.
3. **Workflow / Steps** – outline how the agent or developer should produce or
   modify the prompt, including any external resources to fetch.
4. **Examples & validation** – provide sample inputs/outputs or checks that can
   be programmatically validated.

> These sections allow subagents to understand and act on the prompt without
> manual intervention.

### Frontmatter guidelines

```yaml
---
name: "<descriptive-name>"        # required, should match file purpose
description: "Short summary"      # required
# optional fields:
# argument-hint: "..."           # one-line hint for chat UI
# user-invokable: true/false      # whether agents can run it on demand
# disable-model-invocation: true/false
---
```

Include any extra metadata your team needs, but the fields above are the
minimum to be parsed by automation.

## Example structure

```
.github/instructions/copilot-custom.prompt-files.instructions.md
``` 

or if you have companion assets:

```
.github/instructions/custom-prompt-name/
├── copilot-custom.prompt-files.instructions.md
└── examples/
    └── sample-input.json
```

## Validation checklist ✅

1. Filename and frontmatter `name` accurately describe the prompt’s intent.
2. All four sections are present and clearly written.
3. Any placeholders or arguments are unambiguous and documented.
4. Workflow steps are concrete and ordered logically.
5. Examples provide at least one programmatic check or output sample.
6. References to other assets use valid relative paths.

Following this template makes custom prompts discoverable, usable by subagents,
and easy to maintain. Adjust wording to fit project conventions as needed.