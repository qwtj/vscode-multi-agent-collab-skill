---
name: "Copilot Skill Authoring"
description: "Guidelines for creating and validating Copilot skills"
applyTo: "**/.github/skills/**"
---

# Creating a Copilot Skill

Use this instruction file when you are authoring or maintaining a Copilot skill in the
`.github/skills` (or compatible) folder. It provides a concise template and checklist to
ensure your skill works end-to-end.

## Required skill layout 🔧

Each skill lives in its own folder named after the skill:  
```
.github/skills/<skill-name>/
    SKILL.md
    [optional resources...]
```

- The `SKILL.md` file is mandatory.
- The frontmatter `name` field in `SKILL.md` **must exactly match** the `<skill-name>` folder.

### Optional locations & companion assets

- Other recognized folders: `.claude/skills/` and `.agents/skills/`.
- You may include supporting examples, scripts, templates, or assets within the skill
  folder; reference them with relative links from `SKILL.md`.

## SKILL.md sections 📄

A minimal `SKILL.md` should include the following headings in Markdown order:

1. **Purpose / When to use** – describe the skill’s intent and scenarios.
2. **Inputs & arguments** – list CLI flags, JSON fields, or other parameters.
3. **Step-by-step workflow** – describe the sequence of steps the agent will perform.
4. **Outputs & validation checks** – explain expected results and how to verify success.

> The agent reads this file to know how to execute the skill; write it for both
> humans and machines.

### Frontmatter guidance

```yaml
---
name: "<skill-name>"          # required, exact match to folder name
description: "Short summary"   # required
# optional fields:
# argument-hint: "..."        # one-line hint for chat UI
# user-invokable: true/false   # allow manual invocation
# disable-model-invocation: true/false
---
```

Include any additional metadata your team needs, but the above fields are the
minimum to pass validation.

## Example tree

```
.github/skills/translate-text/
├── SKILL.md
└── examples/
    └── sample-input.json
```

## Validation checklist ✅

1. Folder name and `SKILL.md` frontmatter `name` match exactly.
2. `SKILL.md` contains all four required sections.
3. Arguments listed are clearly described and parsable.
4. Workflow steps are concrete and ordered.
5. Outputs include at least one check or sample that can be programmatically
   validated.
6. (Optional) Companion resources referenced with working relative links.

Following this template will ensure your Copilot skill is discoverable, usable,
and easy to maintain. Adjust wording as needed for your team’s conventions.