---
title: "Foundations"
subtitle: "Concepts 1--2: The Prompt and Permissions"
---

# The Core Thesis

## CLI vs. Chat

Claude Code is not a chat window with file access.

- **Chat interface**: you paste context in, copy results out
- **CLI agent**: Claude reads your filesystem, runs your tools, writes code directly
- The terminal *is* the interface --- your shell environment is Claude's environment

## Demand Paging

Claude doesn't load your entire codebase at once.

- Reads files on demand as it reasons about your request
- Context window = working memory, not storage
- Implication: structure your project so Claude can *find* what it needs

# Concept 1: The Prompt

## The Prompt Is Everything

Your first message sets the trajectory for the entire session.

- A vague prompt produces vague results
- A specific prompt with constraints produces focused work
- Include: what you want, where it lives, what success looks like

## Plan Mode: Think Before Acting

Use plan mode (`Shift+Tab`) to get Claude's plan before it acts.

- Claude outlines its approach without making changes
- You review, adjust, then let it execute
- Essential for complex or unfamiliar tasks

## Gate Clauses

Tell Claude what *not* to do.

- "Do not modify files outside `src/`"
- "Do not install new dependencies"
- "Ask before deleting anything"

Gate clauses prevent expensive mistakes.

# Concept 2: Permissions

## Permission Categories

Claude asks permission before taking action.

- **Read** --- reading files, listing directories
- **Write** --- creating or editing files
- **Bash** --- running shell commands

## The Core Distinction

- **Allow once**: approve this specific action
- **Allow always**: approve this tool for the session
- Permissions reset each session by default

## Instruction Layers (Preview)

Three layers control Claude's behavior:

1. **System prompt** --- built into Claude Code
2. **CLAUDE.md** --- your project-level instructions
3. **settings.json** --- persistent permission rules

We'll revisit each in later lessons.
