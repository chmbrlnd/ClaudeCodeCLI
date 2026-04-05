---
title: "Making Claude Personal"
date: 2026-04-05
version: 0.1
status: draft
owner: JF
review-due: 2026-10-05
---

# Making Claude Personal

## Concept 3: The Terminal

Claude Code runs in your terminal emulator, inheriting your shell
environment — `$PATH`, environment variables, project directory.  It is not
a separate IDE or a browser tab; it is a process in your terminal session.
This means it has the same access you do, subject to the permission model.

### Shell Environment Inheritance

When Claude Code launches, it sees everything your shell sees:

- Your `$PATH` (which tools are available)
- Your environment variables
- Your current working directory
- Your Git configuration

This is why running Claude from the right directory matters — the project
directory *is* the context.

### Keeping Your Mac Awake

Claude Code sessions can run for a while.  Use the built-in `caffeinate`
command to prevent sleep:

```bash
# Wrap your Claude command — sleep is prevented until Claude exits
caffeinate -dims claude -p "your long task here"

# Or if Claude is already running in another tab, open a second tab:
caffeinate -dims -t 14400    # stay awake for 4 hours
```

Flags: `-d` display, `-i` idle, `-m` disk, `-s` system (even on battery).
When the command or timer ends, normal sleep resumes.

### Session Hygiene

Sessions are tied to the starting directory, not the files Claude creates.
If you `cd ~/Sandbox/VScode/my-project` and run Claude there, the session is
filed under `my-project` — even if Claude created files elsewhere.

You don't need to clean up after completing a session.  Just `Ctrl+D` to
exit.  The named session is saved automatically and can be resumed anytime.

---

## Concept 4: Prompts (Deeper Dive)

Effective prompting in Claude Code differs from chat-style prompting.  Because
the tool has access to your filesystem, you can be concrete: "refactor the
error handling in `src/parser.rs` to use `thiserror`" rather than "how should
I handle errors in Rust?"  The more specific and scoped the prompt, the better
the result.  Multi-step prompts work well — ask Claude to read a file first,
then propose changes, then apply them.

### Three Instruction Layers

There are three ways to give Claude standing instructions, and they stack.

**Layer 1: `~/.claude/CLAUDE.md` (global, all projects)**

Create this file for preferences that apply everywhere — your coding style,
preferred languages, formatting opinions.

```markdown
# Global preferences
- Prefer Python 3.11+ syntax
- Use type hints always
- Write docstrings in Google style
- When writing tests, use pytest
```

**Layer 2: Project `CLAUDE.md` (per-repo)**

Lives at `./CLAUDE.md` or `./.claude/CLAUDE.md` in your project root.
Checked into git, shared with collaborators.  Contains project-specific
conventions.

```markdown
# Project: my-api
- Run tests with: pytest tests/ -v
- Linter: ruff check .
- This project uses SQLAlchemy 2.0 async syntax
- Always run tests after making changes
```

**Layer 3: CLI flags (one-off overrides)**

For ad-hoc tasks where you want to inject instructions without editing files:

```bash
# Append extra rules to the default prompt
claude --append-system-prompt "Focus only on security vulnerabilities."

# Load rules from a file
claude --append-system-prompt-file ./audit-rules.txt

# Replace the entire system prompt (advanced, rarely needed)
claude --system-prompt "You are a code auditor. Only report issues."
```

**How the layers combine:** More specific wins.  Claude sees all of them, but
project-level overrides global, and CLI flags override both.  A
`CLAUDE.local.md` in the project root is like project-level but personal
(auto-added to `.gitignore`).

**Subdirectory CLAUDE.md files:** You can place a `CLAUDE.md` inside any
subfolder (e.g., `src/api/CLAUDE.md`).  These load on-demand — only when
Claude reads files in that directory.  Useful for module-specific rules in
larger projects.

### Working With External Directories

You don't have to `cd` into a project to work on it.  Use `--add-dir`:

```bash
# Audit a project from anywhere
claude --add-dir ~/Sandbox/VScode/my-project \
  -p "Do a professional code audit."

# Work with multiple directories at once
claude --add-dir ~/Sandbox/VScode/frontend ~/Sandbox/VScode/backend \
  -p "Check for API contract mismatches between frontend and backend"
```

**Note:** CLAUDE.md files inside `--add-dir` directories are *not* loaded by
default.  To load them, set the environment variable:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ~/project
```

### Example Workflows

**Workflow A: Focused coding session**

```bash
cd ~/Sandbox/VScode/my-project
claude
```
```
/rename feature-user-profiles
```
→ `Shift+Tab` twice → Plan Mode
→ "I need to add user profile pages with avatar upload"
→ Claude proposes plan
→ `Shift+Tab` → back to Normal (or Auto-Accept for speed)
→ Claude implements
→ "Run the tests"
→ `/compact` if the conversation gets long
→ Done for now?  Just exit.  Resume later with `claude -r feature-user-profiles`

**Workflow B: Quick external audit**

```bash
claude --add-dir ~/Sandbox/VScode/my-project \
  --append-system-prompt "You are a senior code reviewer." \
  -p "Review this codebase for security issues and test coverage gaps."
```

One-shot.  Results print to terminal.  Pipe to a file to keep them.

**Workflow C: Multi-step refactor with safety**

```bash
cd ~/Sandbox/VScode/my-project
claude --permission-mode plan
```
```
/rename refactor-database-layer
```
→ "Analyze the database layer.  I want to migrate from raw SQL to SQLAlchemy."
→ Claude reads everything, proposes a migration plan
→ Review the plan, ask questions
→ `Shift+Tab` → Normal Mode
→ "Start with step 1 of your plan"
→ After each step: "Run tests to make sure nothing broke"
→ Repeat until done

---

## Concept 5: Permissions (Deeper Dive)

The `.claude/settings.json` file is where you codify trust.  You can
allow-list specific tools, restrict write access to certain directories, and
block bash commands that match patterns.  This file is part of your project
and can be version-controlled, meaning your team shares a common trust
configuration.

### Example settings.json

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(python *)",
      "Bash(pip install *)"
    ],
    "deny": []
  }
}
```

This avoids repeated permission prompts for common commands.  Commit
`.claude/settings.json` to the repo so the whole team shares the same
trust boundaries.

### Auto-Accept Mode

`Shift+Tab` cycles through three permission modes:

```
Normal Mode  →  Auto-Accept Mode  →  Plan Mode  →  (back to Normal)
```

**Normal Mode (default):** Claude asks permission before editing files or
running commands.  You approve each action.

**Auto-Accept Mode (`⏵⏵ accept edits on`):** Claude automatically applies
file edits without asking.  Bash commands still follow your settings.json
rules.  This is the sweet spot for productive coding sessions where you trust
Claude's direction but want destructive commands gated.

**Plan Mode (`⏸ plan mode on`):** Read-only, no changes possible.

### How Auto-Accept Interacts With settings.json

| Action | Normal Mode | Auto-Accept Mode |
|--------|------------|-----------------|
| File edits | Prompts you | **Auto-approved** |
| Sandboxed bash (in allow list) | Auto-approved | Auto-approved |
| `git push`, `rm`, etc. (in ask list) | Prompts you | **Still prompts you** |
| Reading denied paths | Blocked | Blocked |

The `ask` list is respected regardless of mode.  Auto-Accept only removes
the prompt for file edits — it doesn't override your safety gates.

### The `--allowedTools` Flag

For scripted/CI use, you can pre-approve specific tools from the CLI:

```bash
claude --allowedTools "Edit" "Read" "Bash(npm run test)" \
  -p "fix lint errors and run tests"
```

This is more surgical than Auto-Accept — you're saying "these exact tools
are fine, prompt for everything else."

---

## Concept 6: CLI Tools — Read / Write / Bash

Claude Code's tool use falls into three tiers:

- **Read** — Inspect files, list directories, search codebases.  Safe,
  idempotent, no side effects.
- **Write** — Create or modify files.  Side effects are contained to the
  filesystem and are reversible via Git.
- **Bash** — Run arbitrary commands.  Side effects can be irreversible (e.g.,
  `rm -rf`, network calls, database mutations).  This is why bash is the most
  restricted tier.

### The Verification Oracle

The bash tier is where the **verification oracle** lives.  The Python
interpreter, the LaTeX compiler, `pytest`, `cargo check` — these tools
provide something unavailable in the chat interface: a binary correctness
signal plus a rich, structured error signal (line numbers, type mismatches,
stack traces).

In the chat interface, "this code compiles" is a *prediction*.  In Claude
Code, it is a *verified fact*.

### The Feedback Loop

In reinforcement-learning terms, the compiler acts as an immediate reward
signal.  Each read → edit → run → read-error → fix cycle is a dense,
grounded feedback loop — far more informative per token than any
specification you could write in a prompt.

This is why Claude Code can converge on working code through iteration even
when its first attempt has bugs: the error messages tell it exactly which
assumptions were violated.

---

## Concept 7: CLAUDE.md

The `CLAUDE.md` file is a project-level instruction file that Claude Code
reads automatically when it starts in a directory.  It is where you tell
Claude about your project's conventions, architecture, preferred libraries,
testing strategy, and anything else a new contributor would need to know.
Think of it as onboarding documentation — but the reader is an AI agent.

### What to Include

A good `CLAUDE.md` includes: project overview, directory layout, build and
test commands, coding conventions, and things to avoid.

```markdown
# Project: Faculty Report Generator

## Build & Run
- Install deps: pip install -r requirements.txt
- Run server: uvicorn main:app --reload
- Run tests: pytest tests/

## Conventions
- Python 3.11+, type hints required
- Use ReportLab for PDF generation
- All API routes in routes/ directory
```

Keep `CLAUDE.md` up to date as the project evolves — it directly impacts how
well Claude understands your codebase.  Commit it to the repo so the whole
team benefits.

### Three Instruction Layers Revisited

| Layer | Location | Scope | Shared? |
|-------|----------|-------|---------|
| Global | `~/.claude/CLAUDE.md` | All projects | No (personal) |
| Project | `./CLAUDE.md` | This repo | Yes (committed) |
| Local | `./CLAUDE.local.md` | This repo | No (gitignored) |
| Subdirectory | `src/api/CLAUDE.md` | Module-level | Yes (committed) |

### The Compressed Index

At a deeper level, `CLAUDE.md` functions as a *compressed index* — a
sufficient statistic for the project.  It compresses the enormous state space
of all files, conventions, and architectural decisions into a small,
high-entropy-per-token summary that tells the model *where to look* and
*what patterns to expect*.

It acts like a learned codebook: the model reads the index, then navigates
the filesystem tree to retrieve precisely the information needed.  The ratio
of useful decisions per token of context consumed is dramatically higher than
ingesting raw source files.

### Generating a Starter CLAUDE.md

Use the `/init` slash command inside a Claude Code session.  Claude will
analyze your project and generate an initial `CLAUDE.md` that you can edit
and refine.

---

## Concept 8: Context Window and Compaction

Claude Code operates within a finite context window.  As a conversation grows,
older content may be compacted or summarized to make room for new information.
Understanding this is important for long sessions: if you've been working for
a while, Claude may lose track of details from earlier in the conversation.

### Why a Bigger Window Isn't Enough

A natural assumption is that simply expanding the context window should
eliminate the need for careful context management.  It doesn't, for two
reasons:

- **Attention degradation.** Transformer attention over very long sequences
  is not uniform.  Loading every file into a 200k-token window can actually
  *degrade* performance relative to selectively reading three relevant files,
  because the signal-to-noise ratio decreases.
- **Wrong axis of improvement.** Context length is a capacity parameter.  The
  filesystem provides a structural capability: random access, hierarchical
  organization, and persistence across reasoning steps.  Doubling the context
  window is an improvement along one axis; random addressability is an
  improvement along an orthogonal axis.  They are not substitutes.

### Demand Paging

Claude Code's filesystem enables **demand paging**: loading exactly the needed
information at the top of the current attention window, where it receives
maximal weight.

The filesystem also acts as a **persistent scratchpad** — when the model
writes to a file in step 3 and reads it back in step 7, it has external
working memory that survives between reasoning steps.  This enables problem
decomposition strategies that would be impossible with purely internal state.

### Strategies for Managing Context

- Keep prompts focused — one task at a time.
- Use `CLAUDE.md` to offload persistent knowledge so it doesn't need to live
  in the conversation.
- Start a fresh session when switching to a fundamentally different task.
- Use the `/compact` command to manually trigger compaction when the context
  is getting full.
- Use `/context` to see how much of the context window is used.

---

## Sessions

### Naming and Resuming

Name your session early so you can come back later:

```
/rename auth-refactor
```

Resume a named session:

```bash
claude -r auth-refactor       # resume by name
claude -c                     # resume most recent (same project directory)
claude -r                     # open the interactive picker
```

### The Session Picker

The interactive picker lets you search, preview, rename, and filter sessions.
Key shortcuts:

- `P` — preview session
- `R` — rename session
- `/` — search
- `A` — toggle between current project and all projects

### What "Resume" Means

When you resume, the full conversation history is restored — messages, tool
results, everything.  Claude picks up where you left off.  However, context
window space is still consumed by the old messages, so long sessions may need
a `/compact` before continuing.

### Sessions Are Per-Project

Sessions are tied to the git repo (or directory) you started them from.  If
you `cd` somewhere else and run `claude -r`, you won't see sessions from the
other project.  Use the `A` key in the picker to toggle and see all projects.

---

## Exercises

1. **Instruction layers:** Create a `~/.claude/CLAUDE.md` with your personal
   coding preferences.  Then create a project-level `CLAUDE.md`.  Start a
   Claude session and verify that both are loaded.

2. **Session management:** Start a Claude session, name it with `/rename`,
   exit, and resume it with `claude -r`.  Try the session picker.

3. **Auto-Accept workflow:** Start in Plan Mode, agree on a plan, then
   switch to Auto-Accept and let Claude execute.  Notice which actions still
   prompt for permission.

4. **External audit:** Use `--add-dir` to audit a project from a different
   directory.  Combine with `--append-system-prompt` to inject auditing
   rules.

5. **Context management:** In a long session, use `/context` to check usage.
   Try `/compact` and notice how Claude summarizes the conversation.
