---
title: "Foundations"
date: 2026-04-05
version: 0.1
status: draft
owner: JFC
review-due: 2026-10-05
---

# Foundations

## The Core Thesis

Claude Code and the claude.ai chat interface use the same underlying model.
The performance gap users experience on development tasks is not a model
quality difference — it is an *architectural* difference in how context is
stored, retrieved, and verified.

The chat interface presents the model with a flat, sequential context tape.
Claude Code gives it a tree-structured, randomly addressable external memory
(the filesystem) coupled with a ground-truth verification oracle (the
compiler, interpreter, or test runner).  That architectural distinction
dominates for any task with complex, distributed state.

This thesis is the thread that connects every concept in this workshop:
prompts, permissions, CLAUDE.md, context management, and autonomous operation
are all mechanisms that exploit or manage that architectural advantage.

### Architecture Comparison

| Capability | Chat Interface | Claude Code |
|---|---|---|
| Context structure | Flat sequential tape | Tree-structured, randomly addressable |
| Context loading | All-at-once, linear | Demand-paged, selective |
| Project index | User memories (sparse) | CLAUDE.md (dense codebook) |
| Verification | Prediction only | Ground-truth oracle (compiler/interpreter) |
| Cross-step memory | Conversation history | Filesystem as persistent scratchpad |
| Feedback loop | Open-loop generation | Closed-loop control with error signals |

### Where the Chat Interface Excels

Where the chat interface excels — and this is important to teach honestly —
is tasks where context is naturally sequential and self-contained: conceptual
Q&A, standalone document drafting, brainstorming, research via web search.
There is no tree to navigate, no external state to manage, no oracle to
consult.  The bottleneck is generation quality, and the model is identical.

### Demand Paging

Claude Code's filesystem enables **demand paging**: loading exactly the needed
information at the top of the current attention window, where it receives
maximal weight.  The model doesn't hold the entire codebase in context; it
holds a *map* and dereferences pointers on demand — analogous to a Turing
machine's finite-state controller (the context window) operating on an
unbounded tape (the filesystem).

---

## Concept 1: The Prompt

Claude Code is a terminal-native interface.  You launch it with `claude` and
type natural-language prompts directly.  Unlike a chat UI, the prompt lives
inside your shell — alongside your files, your Git history, and your running
processes.  This changes the interaction model fundamentally: the context is
your project, not a blank conversation.

The key architectural insight: in the chat interface, context is a linear
transcript — user turn, assistant turn, user turn.  Even with a 200k-token
window, this is a *flat* structure where information in the interior receives
diminished attention (the "lost in the middle" effect).  In Claude Code, the
filesystem is a tree-structured, randomly addressable store.

### Plan Mode: Think Before Acting

Plan Mode is read-only.  Claude can explore your codebase and reason about it,
but cannot edit files or run commands.  This is how you prevent Claude from
charging ahead in the wrong direction.

**Entering Plan Mode:**

- Start from the terminal: `claude --permission-mode plan`
- Switch mid-session: press `Shift+Tab` twice (Normal → Auto-Accept → Plan)
- Set as default in settings.json:

```json
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

**What Claude can and cannot do in Plan Mode:**

| Can do | Cannot do |
|--------|-----------|
| Read and analyze files | Edit or create files |
| Trace through code paths | Run bash commands |
| Ask you clarifying questions | Make any changes |
| Propose a detailed plan | Execute anything |

**The Plan Mode workflow:**

1. **Enter Plan Mode** (`Shift+Tab` twice, or `--permission-mode plan`)
2. **Describe what you want** — "I need to refactor the auth system to use
   OAuth2"
3. **Claude explores and proposes a plan** — it reads files, traces
   dependencies, identifies what needs to change
4. **Refine the plan** — ask follow-up questions: "What about backward
   compatibility?" or "Can you break this into smaller steps?"
5. **Edit the plan** — press `Ctrl+G` to open the plan in your editor
6. **Switch to Normal Mode** — press `Shift+Tab` to cycle back
7. **Claude executes the plan** — it already knows what to do from the
   planning phase

Use Plan Mode for anything that touches more than a couple of files, involves
architectural decisions, or where you'd want a human developer to explain
their plan before coding.

---

## Concept 2: Permissions

When you ask a chatbot for advice, there is no risk — it can only produce
text.  Claude Code can take action: it can read files, write files, and
execute shell commands.  This is why the permission model matters.

### Permission Categories

- **Accept** — Claude proposes a tool use (e.g., edit a file) and you
  approve it interactively.  This is the default for destructive operations.
- **Permission file** — `.claude/settings.json` lets you pre-approve
  categories of actions (e.g., allow all reads, allow writes in `src/`).
  This is how you configure trust boundaries per-project.
- **Read tools** — `cat`, `ls`, `find`, `grep`.  Low risk.  Typically
  auto-approved.
- **Write tools** — Creating or modifying files.  Medium risk.  Requires
  approval unless allow-listed.
- **Bash** — Arbitrary shell commands.  Highest risk.  Guarded most tightly.

### The Core Distinction

| | Chatbot | Claude Code |
|---|---|---|
| Output | Advice (text) | Action (file changes, commands) |
| Risk | Misunderstanding | Unintended side effects |
| Guard | Your judgment | Permission system + your judgment |

A chatbot gives advice.  Claude Code takes action.  The permission model
exists because actions have consequences that text does not.

### Instruction Layers (Preview)

There are three ways to give Claude standing instructions, and they stack:

1. **Global** — `~/.claude/CLAUDE.md` applies to every project
2. **Project** — `./CLAUDE.md` is per-repo, shared with collaborators
3. **CLI flags** — `--append-system-prompt` for one-off overrides

More specific wins.  These layers are covered in depth in Concept 4.

---

## Exercises

1. **Launch and explore:** Run `claude` in a project directory.  Ask it to
   describe the project structure.  Notice that it reads files on demand
   rather than loading everything at once.

2. **Plan Mode practice:** Start Claude in Plan Mode
   (`claude --permission-mode plan`).  Ask it to analyze a codebase and
   propose a refactoring plan.  Switch to Normal Mode and have it execute
   one step.

3. **Permission awareness:** During an interactive session, pay attention to
   when Claude asks for permission versus when it acts automatically.  Which
   actions are auto-approved?  Which require confirmation?

4. **Chat vs. Code comparison:** Take a coding question you've asked in the
   chat interface.  Ask the same question in Claude Code from within the
   relevant project directory.  Compare the specificity and accuracy of the
   responses.
