# Use custom instructions in VS Code

Custom instructions enable you to define common guidelines and rules that automatically influence how AI generates code and handles other development tasks. Instead of manually including context in every chat prompt, specify custom instructions in a Markdown file to ensure consistent AI responses that align with your coding practices and project requirements.

You can configure custom instructions to apply automatically to all chat requests or to specific files only. Alternatively, you can manually attach custom instructions to a specific chat prompt.

> **Note**  
> Custom instructions are not taken into account for [inline suggestions](https://code.visualstudio.com/docs/copilot/ai-powered-suggestions) as you type in the editor.

## Types of instruction files

VS Code supports two categories of custom instructions. If you have multiple instruction files in your project, VS Code combines and adds them to the chat context; no specific order is guaranteed.

### Always-on instructions

Always-on instructions are automatically included in every chat request. Use them for project-wide coding standards, architecture decisions, and conventions that apply to all code.

- **A single `.github/copilot-instructions.md` file**
  - Automatically applies to all chat requests in the workspace
  - Stored within the workspace
- **One or more `AGENTS.md` files**
  - Useful if you work with multiple AI agents in your workspace
  - Automatically applies to all chat requests in the workspace or to specific subfolders (experimental)
  - Stored in the root of the workspace or in subfolders (experimental)
- **Organization-level instructions**
  - Share instructions across multiple workspaces and repositories within a GitHub organization
  - Defined at the GitHub organization level
- **`CLAUDE.md` file**
  - For compatibility with Claude Code and other Claude-based tools
  - Stored in the workspace root, `.claude` folder, or user home directory

### File-based instructions

File-based instructions are applied when files that the agent is working on match a specified pattern or if the description matches the current task. Use file-based instructions for language-specific conventions, framework patterns, or rules that only apply to certain parts of your codebase.

- **One or more `.instructions.md` files**
  - Conditionally apply instructions based on file type or location by using glob patterns
  - Stored in the workspace or user profile

To reference specific context in your instructions, such as files or URLs, you can use Markdown links.

> **Tip**  
> Which approach should you use? Start with a single `.github/copilot-instructions.md` file for project-wide coding standards. Add `.instructions.md` files when you need different rules for different file types or frameworks. Use `AGENTS.md` if you work with multiple AI agents in your workspace.

---

## Use a `.github/copilot-instructions.md` file

VS Code automatically detects a `.github/copilot-instructions.md` Markdown file in the root of your workspace and applies the instructions in this file to all chat requests within this workspace.

Use `copilot-instructions.md` for:

- Coding style and naming conventions that apply across the project
- Technology stack declarations and preferred libraries
- Architectural patterns to follow or avoid
- Security requirements and error handling approaches
- Documentation standards

Follow these steps to create a `.github/copilot-instructions.md` file in your workspace:

1. Create a `.github/copilot-instructions.md` file at the root of your workspace. If needed, create a `.github` directory first.
2. Describe your instructions in Markdown format. Keep them concise and focused for optimal results.

> **Note**  
> VS Code also supports the use of an `AGENTS.md` file for always-on instructions.

#### Example: General coding guidelines

```markdown
# General coding guidelines
- Use 2 spaces for indentation.
- Prefer async/await over callbacks.
...
```

---

## Use `.instructions.md` files

You can create file-based instructions with `*.instructions.md` Markdown files that are applied dynamically based on the files or tasks the agent is working on.

The agent determines which instructions files to apply based on the file patterns specified in the `applyTo` property in the instructions file header or semantic matching of the instruction description to the current task.

Use `.instructions.md` files for:

- Different conventions for frontend vs. backend code
- Language-specific guidelines in a monorepo
- Framework-specific patterns for specific modules
- Specialized rules for test files or documentation

### Instructions file locations

You can define instructions for a specific workspace or at the user level, where they are applied across all your workspaces.

|              | Location                               |
|--------------|----------------------------------------|
| Workspace    | `.github/instructions` folder          |
| User profile | `prompts` folder of the current VS Code profile |

For compatibility with Claude Code and other Claude-based tools, VS Code also detects instructions files in the `.claude/rules` workspace folder and the `~/.claude/rules` user folder.

You can configure additional file locations for workspace instructions files with the `chat.instructionsFilesLocations` setting. This is useful if you want to keep instructions files in a different folder or have multiple folders for better organization.

### Instructions file format

Instructions files are Markdown files with the `.instructions.md` extension. The semi-optional YAML frontmatter header controls when the instructions are applied:

| Property     | Required | Description                                                                                                                                      |
|--------------|----------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| name         | No       | Display name shown in the UI. Defaults to the file name.                                                                                        |
| description  | No       | Short description shown on hover in the Chat view.                                                                                              |
| applyTo      | No       | Glob pattern that defines which files the instructions apply to automatically, relative to the workspace root. Use `**` to apply to all files. If not specified, the instructions are not applied automatically — you can still add them manually to a chat request. |

The body contains the instructions in Markdown format. To reference agent tools, use the `#tool:<tool-name>` syntax (for example, `#tool:githubRepo`).

```markdown
---
name: 'Python Standards'
description: 'Coding conventions for Python files'
applyTo: '**/*.py'
---
# Python coding standards
- Follow the PEP 8 style guide.
- Use type hints for all function signatures.
- Write docstrings for public functions.
- Use 4 spaces for indentation.
```

### Create an instructions file

When you create an instructions file, choose whether to store it in your workspace or user profile. Workspace instructions files apply only to that workspace, while user instructions files are available across multiple workspaces.

> **Tip**  
> Type `/instructions` in the chat input to quickly open the Configure Instructions and Rules menu.

1. In the Chat view, select **Configure Chat** (gear icon) > **Chat Instructions**, and then select *New instruction file*.  
   ![Screenshot showing the Chat view, and Configure Chat menu, highlighting the Configure Chat button.](https://code.visualstudio.com/assets/docs/copilot/customization/configure-chat-instructions.png)
2. Choose the location where to create the instructions file.
   - **Workspace**: create the instructions file in the `.github/instructions` folder of your workspace to only use it within that workspace. Add more instruction folders for your workspace with the `chat.instructionsFilesLocations` setting.
   - **User profile**: create the instructions files in the [current profile folder](https://code.visualstudio.com/docs/configure/profiles) to use it across all your workspaces.
3. Enter a file name for your instructions file. This is the default name that is used in the UI.
4. Author the custom instructions by using Markdown formatting.
   - Fill in the YAML frontmatter at the top of the file to configure the instructions' description, name, and when they apply.
   - Add instructions in the body of the file.

To modify an existing instructions file, in the Chat view, select **Configure Chat** (gear icon) > **Chat Instructions**, and then select an instructions file from the list. Alternatively, use the **Chat: Configure Instructions** command from the Command Palette (⇧⌘P) and select the instructions file from the Quick Pick.

#### Example: Language-specific coding guidelines

```markdown
---
name: 'JavaScript Standards'
description: 'Conventions for JS/TS files'
applyTo: '**/*.js'
---
# JavaScript coding standards
- Use camelCase for identifiers.
- Avoid `var`; use `let` or `const`.
```

#### Example: Documentation writing guidelines

```markdown
---
name: 'Docs Guidelines'
description: 'Rules for writing documentation'
applyTo: '**/docs/**/*.md'
---
# Documentation rules
- Write in second person.
- Keep sentences short.
```

For more community-contributed examples, see the [Awesome Copilot repository](https://github.com/github/awesome-copilot/tree/main).

---

## Use an `AGENTS.md` file

VS Code automatically detects an `AGENTS.md` Markdown file in the root of your workspace and applies the instructions in this file to all chat requests within this workspace. This is useful if you work with multiple AI agents in your workspace and want a single set of instructions recognized by all of them, or if you want subfolder-level instructions that apply to specific parts of a monorepo.

Use `AGENTS.md` when:

- You work with multiple AI coding agents and want a single set of instructions recognized by all of them
- You want subfolder-level instructions that apply to specific parts of a monorepo

To enable or disable support for `AGENTS.md` files, configure the `chat.useAgentsMdFile` setting.

### Use multiple AGENTS.md files (experimental)

Using multiple `AGENTS.md` files in subfolders is useful if you want to apply different instructions to different parts of your project. For example, you can have one `AGENTS.md` file for the frontend code and another for the backend code.

Use the experimental `chat.useNestedAgentsMdFiles` setting to enable or disable support for nested `AGENTS.md` files in your workspace. When enabled, VS Code searches recursively in all subfolders of your workspace for `AGENTS.md` files and adds their relative path to the chat context. The agent can then decide which instructions to use based on the files being edited.

> **Tip**  
> For folder-specific instructions, you can also use multiple `.instructions.md` files with different `applyTo` patterns that match the folder structure.

---

## Use a `CLAUDE.md` file

VS Code automatically detects a `CLAUDE.md` file and applies it as always-on instructions, similar to `AGENTS.md`. This is useful if you use Claude Code or other Claude-based tools alongside VS Code and want a single set of instructions recognized by all of them.

VS Code searches for `CLAUDE.md` files in these locations:

| Location        | Path                                        |
|-----------------|---------------------------------------------|
| Workspace root  | `CLAUDE.md` in the root of your workspace   |
| `.claude` folder | `.claude/CLAUDE.md` in your workspace       |
| User home       | `~/.claude/CLAUDE.md` for personal instructions across all projects |
| Local variant   | `CLAUDE.local.md` for local-only instructions (not committed to version control) |

To enable or verbose... (truncated for brevity)