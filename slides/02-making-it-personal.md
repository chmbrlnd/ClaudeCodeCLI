---
title: "Making Claude Personal"
subtitle: "Concepts 3--8: Terminal, Prompts, Permissions, Tools, CLAUDE.md, Context"
---

# Concept 3: The Terminal

## Shell Environment Inheritance

Claude inherits your shell environment.

- `$PATH`, environment variables, aliases
- Working directory, git state, installed tools
- If *you* can run it in your terminal, Claude can too

## Keeping Your Mac Awake

Long-running Claude sessions need your machine awake.

- `caffeinate -dims` prevents sleep
- Or: System Settings > Energy > Prevent sleeping when display is off

## Session Hygiene

- One task per session keeps context focused
- Name sessions for easy recall: `/rename refactor-auth`
- Resume with `claude -r <name>`, `claude -c` (most recent), or the picker

# Concept 4: Prompts (Deeper Dive)

## Three Instruction Layers

- **Global** (all projects) --- `~/.claude/CLAUDE.md`
- **Project** (this repo) --- `./CLAUDE.md`
- **Subdirectory** (module) --- `src/api/CLAUDE.md`

Claude merges all layers, with more specific layers taking precedence.
CLI flags (`--append-system-prompt`) override all three.

## Working With External Directories

Claude can read outside the project root if you tell it where to look.

- "Read the API spec from `../shared-contracts/openapi.yaml`"
- Useful for monorepo setups or shared schemas

## Example Workflows

Feed Claude structured task files:

- `TASK.md` --- what to build
- `INFO.md` --- reference material
- Pipe files in: `cat TASK.md | claude`

# Concept 5: Permissions (Deeper Dive)

## settings.json

```json
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep"],
    "deny": ["Bash(rm*)"]
  }
}
```

Persists across sessions. Lives at `~/.claude/settings.json` or `.claude/settings.json`.

## Auto-Accept Mode

`Shift+Tab` once enables Auto-Accept: file edits apply without prompting.

- Bash still follows your `settings.json` (the `ask` list is respected)
- The sweet spot once you trust Claude's direction
- For scripts, `--allowedTools` pre-approves *specific* tools instead

# Concept 6: CLI Tools

## Read / Write / Bash

Claude's core tools:

- **Read** --- view file contents
- **Write** / **Edit** --- create or modify files
- **Bash** --- run shell commands
- **Glob** / **Grep** --- find files and search content

## The Verification Oracle

Claude can verify its own work:

1. Write code
2. Run tests
3. Check results
4. Fix and repeat

This loop is what makes Claude effective --- it's not just generating code, it's *validating* it.

# Concept 7: CLAUDE.md

## What to Include

- Project structure and conventions
- Build and test commands
- What to avoid (anti-patterns, deprecated APIs)
- Style preferences

## The Compressed Index

CLAUDE.md doesn't need to contain everything --- just enough for Claude to *find* everything.

- Point to docs: "API types are in `src/types/`"
- Point to patterns: "Follow the style in `src/routes/users.ts`"
- Point to tests: "Run `just test` before committing"

## Generating a Starter CLAUDE.md

```bash
claude -p "Read this project and generate a CLAUDE.md"
```

Then edit the result --- Claude gives you a draft, you make it yours.

# Concept 8: Context Window

## Why a Bigger Window Isn't Enough

Even with 200K tokens, you can't fit a large project.

- Context is working memory, not long-term storage
- More context = slower reasoning, higher cost
- Quality of context matters more than quantity

## Strategies for Managing Context

- Start new sessions for new tasks
- Use CLAUDE.md to reduce repeated explanations
- Structure code so Claude can read one file at a time
- Use `/compact` to compress the conversation
