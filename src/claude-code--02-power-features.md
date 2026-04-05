---
title: "Power Features"
date: 2026-04-05
version: 0.1
status: draft
owner: JF
review-due: 2026-10-05
---

# Power Features

## Concept 9: Models

Claude Code can use different models for different tasks:

- **Opus** — Highest capability.  Best for complex reasoning, architecture
  decisions, and multi-file refactors.  Slower and more expensive.
- **Sonnet** — The default workhorse.  Good balance of speed, cost, and
  capability for everyday coding tasks.
- **Haiku** — Fastest and cheapest.  Good for simple lookups, formatting,
  and quick questions where deep reasoning isn't needed.

You can switch models mid-session or set a default in configuration.  A
common pattern: use Sonnet for most work, escalate to Opus for hard problems,
drop to Haiku for boilerplate.

### Switching Models

**Mid-session:** Use the `/model` slash command to switch models without
leaving your session.

**At launch:** Use the `--model` flag:

```bash
claude --model opus
claude --model haiku
```

### When to Use Each Model

| Task | Recommended Model |
|------|-------------------|
| Complex multi-file refactor | Opus |
| Architecture planning | Opus |
| Everyday coding, bug fixes | Sonnet |
| Writing tests | Sonnet |
| Simple formatting, boilerplate | Haiku |
| Quick lookups, explanations | Haiku |

---

## Concept 10: Denying Access to Files

You can use `.claude/settings.json` or `.claudeignore` to prevent Claude from
reading or modifying specific files or directories.

### Use Cases

- Secrets files (`.env`, credentials)
- Large vendored dependencies
- Generated code that shouldn't be manually edited
- Sensitive data files

### .claudeignore

Works like `.gitignore` — create a `.claudeignore` file in your project root:

```
# Secrets
.env
.env.*
secrets/

# Generated files
dist/
node_modules/
*.generated.ts

# Large vendored code
vendor/
```

### Deny Lists in settings.json

You can also use the `deny` list in `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": ["Bash(git *)"],
    "deny": ["Read(~/.ssh/*)", "Read(.env)"]
  }
}
```

---

## Concept 11: Flags

Claude Code accepts command-line flags that modify its behavior at launch.
Flags are especially useful for scripting and CI/CD integration, where you
want deterministic, non-interactive behavior.

### Key Flags

| Flag | Purpose | Example |
|------|---------|---------|
| `--model` | Choose the model | `claude --model opus` |
| `--allowedTools` | Restrict available tools | `claude --allowedTools "Read" "Edit"` |
| `--print` / `-p` | Non-interactive mode | `claude -p "explain this code"` |
| `--output-format` | Output format | `claude -p "..." --output-format json` |
| `--max-turns` | Limit autonomous iteration | `claude -p "..." --max-turns 5` |
| `--add-dir` | Add external directories | `claude --add-dir ~/other-project` |
| `--append-system-prompt` | Inject instructions | `claude --append-system-prompt "Be terse"` |
| `--append-system-prompt-file` | Load instructions from file | `claude --append-system-prompt-file rules.txt` |
| `--system-prompt` | Replace system prompt | `claude --system-prompt "You are an auditor"` |
| `--permission-mode` | Set permission mode | `claude --permission-mode plan` |

### Combining Flags

Flags compose naturally.  A common pattern for scripted audits:

```bash
claude --add-dir ~/project \
  --append-system-prompt-file ./audit-rules.txt \
  -p "Audit this codebase" \
  --output-format json \
  --max-turns 10
```

---

## Concept 12: Slash Commands

Inside a Claude Code session, slash commands give you meta-control.  They
operate outside the normal prompt flow — they control the session itself
rather than asking Claude to do something.

### Command Reference

| Command | What it does |
|---------|-------------|
| `/compact` | Compress conversation context |
| `/clear` | Reset conversation completely |
| `/model` | Switch models mid-session |
| `/cost` | Show token usage and cost |
| `/help` | List available commands |
| `/init` | Generate a CLAUDE.md for the current project |
| `/rename name` | Name or rename the current session |
| `/context` | See how much context window is used |

### Special Prefixes

**`!` — Run bash directly:**

```
! npm test
! git status
```

The `!` prefix sends the command straight to your shell without Claude
interpreting it.  Useful for quick checks without leaving the session.

**`@` — Reference a file:**

```
@src/main.py what does this file do?
@tests/test_parser.py add a test for edge cases
```

The `@` prefix tells Claude to focus on a specific file.  It's a shorthand
for "read this file and then answer my question about it."

---

## Concept 13: Skills

Skills are reusable instruction sets that teach Claude Code how to perform
specific tasks.  They are Markdown files that contain best practices, tool
usage patterns, and step-by-step procedures for a domain.  Claude reads a
skill file before starting a task, much like a technician reading a manual
before a repair.

### How Skills Work

Skills can be project-specific, shared across an organization, or
community-maintained.  They live as Markdown files (often named with a
`.md` extension) and are loaded via slash commands or configuration.

### Creating a Skill

A skill file is structured Markdown with clear instructions:

```markdown
# Skill: Database Migration

## When to use
When creating or modifying database schema.

## Steps
1. Create a new migration file in `migrations/`
2. Write the upgrade and downgrade functions
3. Test with `alembic upgrade head`
4. Test rollback with `alembic downgrade -1`
5. Verify the migration is reversible

## Rules
- Never modify an existing migration that has been deployed
- Always include a downgrade path
- Test both upgrade and downgrade locally
```

### Using Skills

Skills are invoked as slash commands.  When Claude encounters a skill
command, it reads the skill file and follows the instructions within.

---

## Concept 14: Hooks

Hooks let you run custom scripts at specific points in Claude Code's
lifecycle — before a tool call, after a tool call, or on specific events.
This lets you enforce project-specific policies, inject context, or log
actions for audit.

### Hook Types

- **Pre-tool hooks** — Run before Claude executes a tool.  Can modify or
  block the action.
- **Post-tool hooks** — Run after a tool completes.  Can process results
  or trigger follow-up actions.
- **Event hooks** — Run on session events like start, end, or error.

### Example: Auto-lint After Writes

A common hook: automatically run the linter after Claude writes a file.

```json
{
  "hooks": {
    "afterWrite": {
      "command": "ruff check --fix ${file}",
      "description": "Auto-fix lint issues after file writes"
    }
  }
}
```

### Example: Audit Logging

Log every bash command Claude runs:

```json
{
  "hooks": {
    "beforeBash": {
      "command": "echo \"$(date): ${command}\" >> .claude-audit.log",
      "description": "Log bash commands for audit"
    }
  }
}
```

### When to Use Hooks

- Enforce coding standards automatically
- Maintain audit trails
- Inject project-specific context at key moments
- Chain tools together (e.g., format after edit, test after write)

---

## Cheat Sheet

| I want to... | Do this |
|--------------|---------|
| Name my session | `/rename my-task-name` |
| Resume a session | `claude -r my-task-name` |
| Resume most recent | `claude -c` |
| Browse all sessions | `claude -r` then use picker |
| Enter Plan Mode | `Shift+Tab` twice, or `--permission-mode plan` |
| Enter Auto-Accept | `Shift+Tab` once |
| Go back to Normal | `Shift+Tab` again |
| Switch models | `/model` in session, or `--model` at launch |
| Audit external code | `claude --add-dir /path -p "audit this"` |
| Add one-off instructions | `--append-system-prompt "your rules"` |
| Load instructions from file | `--append-system-prompt-file ./rules.txt` |
| Compress long conversations | `/compact` |
| Undo Claude's changes | `Esc + Esc` |
| See context usage | `/context` |
| Run bash directly | `! npm test` (prefix with `!`) |
| Reference a file | `@src/main.py` (prefix with `@`) |

---

## Exercises

1. **Model switching:** Start a session with Sonnet.  Ask a complex
   architecture question, then switch to Opus with `/model` and ask the same
   question.  Compare the depth of reasoning.

2. **File access control:** Create a `.claudeignore` file that excludes your
   secrets directory.  Verify that Claude cannot read those files.

3. **Flags practice:** Run a non-interactive audit using `-p`, `--add-dir`,
   and `--output-format json`.  Pipe the output to a file and examine it.

4. **Slash commands:** In a session, try each slash command: `/cost`,
   `/context`, `/compact`, `/model`.  Get comfortable with the meta-controls.

5. **Skills creation:** Write a simple skill file for a common task in your
   project (e.g., "how to add a new API endpoint").  Test it in a session.
