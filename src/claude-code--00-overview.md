---
title: "Overview"
date: 2026-04-05
version: 0.1
status: draft
owner: JFC
review-due: 2026-10-05
---

# Overview

## What Is Claude Code?

A terminal-based coding assistant from Anthropic that reads your files, runs
commands, and edits code directly on your machine.  It is not a chat window
with copy-paste; it is a process with access to your shell and filesystem,
governed by a permission model you control.

**Why care?**  Tasks that used to eat time — writing code, tests, and docs;
running literature surveys; checking equations — become conversations instead
of chores.  The leverage is real, but only if you understand the tool well
enough to trust it *and* bound it.

**How you use it.**  Install it, point it at a project, and talk to it.  This
workshop walks through setup, the three permission modes, the instruction
layers, and the day-to-day rhythm of commit-as-you-go sessions.

**What to keep in mind.**  Claude Code is neither magic nor a toy.  It makes
mistakes — especially on unfamiliar codebases or vague prompts.  The antidote
is not distrust but a sandbox: a bounded place to work, a version-control
safety net, and instructions specific enough to be useful.  Everything
downstream is about building that envelope.

---

## Goals

1. **Lower the barrier to entry.** Give the curious everything they need to
   install, authenticate, and run their first useful session — without
   piecing setup together from scattered docs.

2. **Make the case for sandboxes.** Show why running Claude inside a
   well-defined sandbox — a dedicated machine, a scoped directory, or the
   built-in bash sandbox — changes what's safe to attempt, and therefore
   what's worth trying.

3. **Go deeper for experienced users.** Cover the advanced machinery — hooks,
   sub-agents, headless mode, MCP servers — that turns Claude Code from a
   faster editor into a programmable collaborator.

And for observers still deciding whether to try: show enough of what the tool
actually does, in realistic contexts, to make the decision easier.

---

## How the Workshop Is Organized

Four lessons build on each other, followed by three reference appendices.
The arc runs from supervised first prompts to autonomous, multi-agent work.

| Lesson | Concepts | Theme |
|--------|----------|-------|
| 01 — Foundations | 1–2 | The prompt; permissions; why the CLI beats chat |
| 02 — Making Claude Personal | 3–8 | Terminal, instruction layers, tools, CLAUDE.md, context, sessions |
| 03 — Power Features | 9–14 | Models, file access, flags, slash commands, skills, hooks |
| 04 — Using Claude Autonomously | 15–21 | MCP, sub-agents, teams, checkpoints, git, headless, worktrees |
| Appendix A | — | Software setup and settings reference |
| Appendix B | — | Git primer |
| Appendix C | — | `just` primer |

### Threads That Run Through Everything

- **The filesystem is the advantage.** Claude Code's edge over chat is
  architectural: a tree-structured, randomly addressable memory plus a
  ground-truth verification oracle (the compiler or test runner).  Lesson 01
  develops this thesis; every later concept exploits it.

- **CLAUDE.md is the index.** Standing instructions that travel with a project
  (or with you, globally) tell Claude what it needs to know before reading any
  code (Concept 7).

- **Sessions compartmentalize work.** Each named session is its own
  conversation and context window — start fresh when the task changes
  (Lesson 02, *Sessions*).

- **Structure earns autonomy.** Tests, conventions, and git checkpoints are
  what make it safe to let Claude run unsupervised (Lesson 04).
