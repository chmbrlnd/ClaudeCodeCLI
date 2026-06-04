---
title: "Power Features"
subtitle: "Concepts 9--14: Models, Access, Flags, Commands, Skills, Hooks"
---

# Concept 9: Models

## Switching Models

Toggle with `/model` or the `--model` flag.

- **Opus** --- complex reasoning, architecture, multi-file changes
- **Sonnet** --- fast iteration, simple edits, quick questions
- **Haiku** --- lightweight queries, cost-sensitive workflows

## When to Use Each Model

- Prompt quality matters more than model choice
- Start with Sonnet for speed; escalate to Opus when stuck
- Use `/fast` to toggle fast mode (same model, faster output)

# Concept 10: Denying Access

## .claudeignore

Works like `.gitignore` --- files Claude won't read.

```
node_modules/
.env
secrets/
*.key
```

## Deny Lists in settings.json

```json
{
  "permissions": {
    "deny": ["Read(secrets/*)", "Bash(curl*)"]
  }
}
```

More granular than `.claudeignore` --- controls specific tools and patterns.

# Concept 11: Flags

## Key Flags

- `-p "..."` --- headless mode, single prompt, no interaction
- `--model` --- choose model
- `--allowedTools` --- restrict available tools
- `--output-format` --- control output (text, json, stream-json)
- `--max-turns` --- limit conversation turns
- `--resume` --- resume a previous session

## Combining Flags

```bash
claude -p "Run tests and fix failures" \
  --model opus \
  --allowedTools Read,Write,Bash \
  --max-turns 20
```

Flags compose naturally for scripted workflows.

# Concept 12: Slash Commands

## Command Reference

- `/help` --- show available commands
- `/model` --- switch model
- `/compact` --- compress conversation
- `/rename` --- name the current session
- `/context` --- show context-window usage
- `/cost` --- show token usage and cost
- `/clear` --- reset the conversation

## Special Prefixes

- `!command` --- run a shell command without leaving Claude
- `@file` --- add a file to context

# Concept 13: Skills

## How Skills Work

Skills are reusable prompt templates registered in settings.

- Invoked with `/skill-name`
- Can accept arguments
- Defined in `~/.claude/skills/` or `.claude/skills/`

## Creating a Skill

```markdown
---
name: review-pr
description: Review a pull request
---
Review PR #$ARGS for correctness, style, and test coverage.
Focus on security implications and breaking changes.
```

# Concept 14: Hooks

## Hook Types

- `PreToolUse` --- fires before a tool runs
- `PostToolUse` --- fires after a tool runs
- `Notification` --- fires when Claude sends a notification

## Example: Auto-lint After Writes

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "command": "eslint --fix $FILE_PATH"
    }]
  }
}
```

## When to Use Hooks

- Enforce formatting (lint, prettier) after every write
- Audit logging for compliance
- Custom notifications (Slack, email)
- Guard rails: block writes to protected files
