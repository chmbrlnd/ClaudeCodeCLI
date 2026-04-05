---
title: "Key Concepts"
date: 2026-04-05
owner: JFC
---

# Orientation

Before the concepts, four framing questions.

**What is Claude Code CLI?**
A terminal-based coding assistant from Anthropic that reads your files,
runs commands, and edits code directly on your machine.  It is not a
chat window with copy-paste; it is a process with access to your shell
and your filesystem, governed by a permission model you control.

**Why should I care?**
Because the tasks that used to eat time — writing code, tests, and documentation,perform literature surveys, check equations — become
conversations instead of chores.  The leverage is real, but only if
one understands the tool well enough to trust it and bound it.

**How do I use it?**
Install it, point it at a project, and talk to it.  The workshop walks
through the setup, the three permission modes, the instruction
layers, and the day-to-day
rhythm of commit-as-you-go sessions.  By the end, you'll have run
Claude on real code and shaped its behavior to your own preferences.

**What else should I know?**
Claude Code is not magic and it is not a toy.  It makes mistakes,
especially on unfamiliar codebases or vague prompts.  The antidote is
not to distrust it, but to give it a sandbox — a bounded place to
work, a version control safety net, and instructions specific enough
to be useful.  Everything downstream in this workshop is about
building that envelope.

---

# Goals

This workshop is built around three goals, with one more for the people
watching from the sidelines.

1. **Lower the barrier to entry.** Give people who are curious about
   Claude Code CLI everything they need to install it, authenticate,
   and run their first useful session — without first having to piece
   the setup together from scattered documentation.

2. **Make the case for sandboxes.** Help existing users understand why
   running Claude inside a well-defined sandbox — whether a dedicated
   machine, a scoped directory, or the built-in bash sandbox — changes
   what's safe to attempt and therefore what's worth trying.

3. **Go deeper for experienced users.** Share the more advanced
   notions — hooks, sub-agents, headless mode, MCP servers — that
   turn Claude Code from a faster editor into a programmable
   collaborator.

And, for curious observers who haven't yet decided whether to try:
show enough of what the tool actually does, in realistic contexts,
that the decision becomes easier to make.

---

# Key Concepts

The core ideas to take away from this workshop, in the order they build on
each other.

## Foundations

- **The Modes** — Normal, Auto-Accept, and Plan.  How much latitude you
  grant Claude, switched with `Shift+Tab`.

- **Concept 6 — CLI Tools: Read / Write / Bash** — the three primitives
  Claude uses to interact with your machine.  Everything else is built
  on these.

- **Concept 7 — CLAUDE.md: The Road Map** — standing instructions that
  travel with a project (or with you, globally).  Tells Claude what it
  needs to know before it starts reading code.

- **Concept 9 — Sessions: Compartmentalize Your Work** — each named
  session is its own conversation and context window.  Start fresh when
  the task changes.

## Controlling Claude

- **Concept 11 — Flags** — modify Claude's behavior at launch
  (`--add-dir`, `--permission-mode`, `--append-system-prompt`, etc.).

- **Concept 12 — Slash Commands** — control the session itself
  (`/compact`, `/config`, `/rename`), as opposed to asking Claude in
  prose.

## Extending Claude

- **Concept 13 — Skills** — reusable, named bundles of instructions for
  specific tasks.  Write once, invoke many times.

- **Concept 14 — Hooks** — custom scripts that run at specific points
  in Claude's lifecycle (pre-tool-use, post-tool-use, stop, etc.).

- **Concept 15 — MCP Servers** — extend Claude's capabilities beyond
  the local filesystem: databases, APIs, external services.

## Scaling Up

- **Concept 16 — Sub-Agents** — isolate the prompt and context of a
  sub-task so it doesn't pollute the main conversation.

- **Concept 17 — Agent Teams** — coordinate multiple agents to tackle
  large, intertwined tasks in parallel.

- **Concept 20 — Headless Mode** — let Claude work unsupervised,
  scripted, or on a schedule.
