---
title: "Using Claude Autonomously"
subtitle: "Concepts 15--21: MCP, Sub-Agents, Teams, Checkpoints, Git, Headless, Worktrees"
---

# The Compounding Effect

## Why Autonomy Compounds

Each layer of structure makes the next level of autonomy safer.

- Tests let Claude verify its own work
- CLAUDE.md lets Claude follow your conventions
- Git lets Claude checkpoint and recover
- Together: Claude can work independently on real tasks

# Concept 15: MCP Servers

## How MCP Works

Model Context Protocol connects Claude to external services.

- Claude calls MCP tools just like built-in tools
- Servers run locally or remotely
- Examples: databases, APIs, monitoring dashboards

## When to Use MCP

- Your workflow needs data Claude can't get from the filesystem
- You want Claude to interact with external services (Slack, Linear, GitHub)
- Pure-filesystem projects often don't need MCP at all

# Concept 16: Sub-Agents

## How Sub-Agents Work

Claude can spawn sub-agents for parallel or specialized work.

- Each sub-agent gets its own context window
- Results flow back to the parent agent
- Useful for: parallel file analysis, independent research, code review

## Sub-Agent Scoping

- Sub-agents inherit permissions but not conversation history
- Keep sub-agent tasks focused and self-contained
- The parent agent synthesizes results

# Concept 17: Agent Teams

## Orchestration Patterns

- **Fan-out**: one task split across multiple agents
- **Pipeline**: output of one agent feeds the next
- **Specialist**: different agents for different domains

## When to Use Agent Teams

- Large refactors spanning many files
- Tasks requiring different expertise (frontend + backend)
- When context window limits would slow a single agent

# Concept 18: Checkpoints and Undo

## How Checkpoints Work

Claude creates git checkpoints as it works.

- Every significant change is a checkpoint
- You can review and revert at any point
- `Esc + Esc` undoes the last action

## Best Practices

- Commit before starting a complex task
- Review checkpoints periodically during long sessions
- Use branches for experimental work

# Concept 19: Git Integration

## What Claude Can Do With Git

- Create commits with meaningful messages
- Create and manage branches
- Open pull requests (with `gh`)
- Resolve merge conflicts

## Git as Safety Infrastructure

Git isn't just version control --- it's your undo button.

- Every Claude session starts from a known state
- Checkpoints let you roll back bad changes
- Branches isolate experimental work
- `git diff` shows exactly what Claude changed

# Concept 20: Headless Mode

## The `-p` Flag

```bash
claude -p "Run all tests and report failures"
```

- Single prompt, no interactive session
- Output goes to stdout
- Exit code reflects success/failure

## CI/CD Integration

```bash
# In a GitHub Action
claude -p "Review this PR for security issues" \
  --output-format json \
  --max-turns 10
```

Headless mode makes Claude a building block in automated pipelines.

# Concept 21: Worktrees

## How Worktrees Work

Git worktrees let you check out multiple branches simultaneously.

- Each worktree is a separate directory
- They share the same `.git` database
- Changes in one worktree don't affect others

## Worktrees + Claude Code

- `git worktree add ../proj-feature feature-branch`
- Launch a separate Claude session in each worktree
- No context switching --- each worktree is independent, then merge back

## Why Worktrees Instead of Branches

- Branches require `git stash` / `git checkout` juggling
- Worktrees give you parallel, isolated working directories
- Perfect for: reviewing a PR while working on a feature
