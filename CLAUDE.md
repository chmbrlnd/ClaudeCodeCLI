# Claude Code CLI — Lesson Plan & Repository Strategy

## About This Document

This file is both the lesson plan for a Claude Code CLI workshop and the
operational blueprint for how the materials are managed. The repository that
holds this file follows a "Markdown is source code" philosophy: every document
is authored in Pandoc Markdown, built into distributable formats with `just`
(a modern alternative to `make`), version-controlled with Git, and archived as
PDF when published.

---

## Repository Structure

```
claude-code-lessons/
  justfile                    # build recipes (see Build System below)
  pandoc/
    reference.docx            # shared styling template for docx output
    defaults.yaml             # pandoc defaults (filters, metadata, fonts)
  src/
    INDEX.md                  # manifest — one line per document, with status
    claude-code--prompts.md
    claude-code--permissions.md
    claude-code--making-it-personal.md
    claude-code--power-features.md
    claude-code--autonomous-use.md
  build/                      # gitignored — ephemeral build artifacts
    *.docx
    *.pdf
    claude-code-master.pdf
  archive/                    # committed — PDFs of record, frozen on distribution
    2026-04-04--claude-code--prompts--v1.0.pdf
```

### Key Principles

Markdown is the canonical source of truth.  Every other format — `.docx`,
`.pdf`, slides — is a derived build artifact.  If a document needs
collaborative editing (e.g., in Google Docs), the round-trip is:
`md → pandoc → docx → Google Doc → export docx → pandoc → md → commit`.
The Google Doc is a transient workspace, never the record of truth.

Each source file carries YAML front matter:

```yaml
---
title: "Prompts"
date: 2026-04-04
version: 1.0
status: draft | active | superseded
owner: JF
review-due: 2026-10-01
---
```

The `archive/` directory holds the exact PDF that was distributed.  A
matching Git tag (e.g., `prompts/v1.0`) ties the archive artifact back to the
source commit.

---

## Build System — `just`

[`just`](https://github.com/casey/just) is a command runner similar to `make`
but designed for project-specific recipes rather than file-dependency graphs.
It uses a file called `justfile` (no extension) with a clean, readable syntax.

### Why `just` Instead of `make`

`make` is built around file-timestamp dependency resolution, which is powerful
for compiling C but overkill for "run pandoc on some Markdown files."  `just`
is simpler: recipes are named commands with arguments, no tabs-vs-spaces
traps, built-in help via `just --list`, and cross-platform support without
worrying about GNU vs. BSD `make` differences.

### Installing `just`

```bash
# macOS
brew install just

# Ubuntu / Debian
sudo apt install just

# cargo (any platform with Rust)
cargo install just

# prebuilt binary
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash
```

### Sample `justfile`

```just
# Default recipe: list available commands
default:
    @just --list

# Build a single source file to docx
docx file:
    pandoc src/{{file}}.md \
      --defaults pandoc/defaults.yaml \
      --reference-doc pandoc/reference.docx \
      -o build/{{file}}.docx

# Build all source files to docx
docx-all:
    #!/usr/bin/env bash
    mkdir -p build
    for f in src/claude-code--*.md; do
      base=$(basename "$f" .md)
      pandoc "$f" \
        --defaults pandoc/defaults.yaml \
        --reference-doc pandoc/reference.docx \
        -o "build/${base}.docx"
    done

# Build a single PDF
pdf file:
    pandoc src/{{file}}.md \
      --defaults pandoc/defaults.yaml \
      -o build/{{file}}.pdf

# Build master PDF — all lessons concatenated with a table of contents
book:
    pandoc src/claude-code--*.md \
      --defaults pandoc/defaults.yaml \
      --toc --toc-depth=2 \
      -o build/claude-code-master.pdf

# Publish: copy a built PDF to the archive with today's date and a version tag
publish file version:
    cp build/{{file}}.pdf archive/$(date +%Y-%m-%d)--{{file}}--{{version}}.pdf
    git add archive/
    git commit -m "Publish {{file}} {{version}}"
    git tag "{{file}}/{{version}}"

# Validate front matter and check for stale documents
check:
    #!/usr/bin/env bash
    echo "--- Front matter check ---"
    for f in src/claude-code--*.md; do
      if ! head -5 "$f" | grep -q "^status:"; then
        echo "MISSING status: $f"
      fi
    done
    echo "--- Stale document check ---"
    for f in src/claude-code--*.md; do
      due=$(grep "^review-due:" "$f" | awk '{print $2}')
      if [[ -n "$due" && "$due" < "$(date +%Y-%m-%d)" ]]; then
        echo "OVERDUE: $f (due $due)"
      fi
    done
    echo "--- INDEX sync check ---"
    for f in src/claude-code--*.md; do
      base=$(basename "$f")
      if ! grep -q "$base" src/INDEX.md; then
        echo "NOT IN INDEX: $base"
      fi
    done

# Clean build artifacts
clean:
    rm -rf build/*
```

### Common Usage

```bash
just                     # show available recipes
just docx-all            # build all lessons as docx
just pdf prompts         # build a single PDF
just book                # build the master PDF
just publish prompts v1.0  # archive and tag
just check               # validate front matter and staleness
```

---

## Lesson Plan — Claude Code CLI

The lesson is organized into four sections, moving from foundations to
autonomous agent workflows.

### The Core Thesis

Claude Code and the claude.ai chat interface use the same underlying model.
The performance gap users experience on development tasks is not a model
quality difference — it is an *architectural* difference in how context is
stored, retrieved, and verified.

The chat interface presents the model with a flat, sequential context tape.
Claude Code gives it a tree-structured, randomly addressable external memory
(the filesystem) coupled with a ground-truth verification oracle (the
compiler, interpreter, or test runner).  That architectural distinction
dominates for any task with complex, distributed state.

This thesis is the thread that connects every concept below: prompts,
permissions, CLAUDE.md, context management, and autonomous operation are all
mechanisms that exploit or manage that architectural advantage.

| Capability | Chat Interface | Claude Code |
|---|---|---|
| Context structure | Flat sequential tape | Tree-structured, randomly addressable |
| Context loading | All-at-once, linear | Demand-paged, selective |
| Project index | User memories (sparse) | CLAUDE.md (dense codebook) |
| Verification | Prediction only | Ground-truth oracle (compiler/interpreter) |
| Cross-step memory | Conversation history | Filesystem as persistent scratchpad |
| Feedback loop | Open-loop generation | Closed-loop control with error signals |

Where the chat interface excels — and this is important to teach honestly —
is tasks where context is naturally sequential and self-contained: conceptual
Q&A, standalone document drafting, brainstorming, research via web search.
There is no tree to navigate, no external state to manage, no oracle to
consult.  The bottleneck is generation quality, and the model is identical.

---

### SECTION 0 — Environment Setup

Before any concepts, participants need a working environment. This section
is a hands-on prerequisite — everyone should complete it before the workshop.

#### Prerequisites

**Homebrew** (macOS package manager). If not already installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Git** via Xcode Command Line Tools:

```bash
xcode-select --install
git --version
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

**Python & pip** — use a Homebrew-managed version rather than the system
Python:

```bash
brew install python
python3 --version && pip3 --version
```

#### VS Code

Install via Homebrew (recommended — keeps it in your `brew upgrade` flow):

```bash
brew install --cask visual-studio-code
```

Recommended extensions:

- **Python** (`ms-python.python`) — IntelliSense, linting, debugging
- **Claude Code** (`anthropic.claude-code`) — Claude AI in the editor sidebar
- **LaTeX Workshop** (`james-yu.latex-workshop`) — if you work with LaTeX

For each project, create a virtual environment and tell VS Code about it:

```bash
cd your-project
python3 -m venv .venv
```

VS Code should auto-detect the `.venv`. If not, open the Command Palette
(⌘+Shift+P), select "Python: Select Interpreter," and choose the one inside
`.venv`. To make this sticky per-project, add `.vscode/settings.json`:

```json
{ "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python" }
```

Add `.venv/` to your `.gitignore` so virtual environments are not tracked.

#### Installing Claude Code

Claude Code comes in two forms — a CLI tool and a VS Code extension. You
want both.

**CLI — Homebrew (recommended):**

```bash
brew install --cask claude-code
claude --version
```

The Homebrew install requires no Node.js and integrates with your system PATH.
It does not auto-update; run `brew upgrade claude-code` periodically.

**CLI — npm (alternative):**

```bash
npm install -g @anthropic-ai/claude-code
```

**VS Code extension:** Open Extensions (⌘+Shift+X), search "Claude Code,"
click Install. Authentication is shared between the CLI and the extension —
sign in once.

**Authenticate:** Run `claude` in your terminal. The first time, it opens a
browser tab. Sign in with your Claude Pro or Max plan, or paste an Anthropic
Console API key.

**Diagnose:** Run `claude doctor` to check your installation type, version,
and common configuration issues.

#### Useful CLI Commands (Quick Reference)

```bash
claude                # start an interactive session in the current directory
claude doctor         # diagnose installation issues
claude --version      # check installed version
claude --help         # see all available flags
```

#### Typical Day-to-Day Workflow

1. Clone or create a repo and open it in VS Code.
2. Create a `.venv` (`python3 -m venv .venv`) and select it as the
   interpreter.
3. Add a `CLAUDE.md` summarizing the project for Claude (see Concept 7).
4. Use the Claude Code sidebar in VS Code for inline questions, code
   generation, and diffs.
5. Use the CLI (`claude`) in your terminal for larger tasks: refactoring,
   writing tests, git operations.
6. Commit regularly. Claude can help with commit messages and branch
   management.

---

### SECTION 1 — Foundations

#### Concept 1: The Prompt

Claude Code is a terminal-native interface. You launch it with `claude` and
type natural-language prompts directly. Unlike a chat UI, the prompt lives
inside your shell — alongside your files, your Git history, and your running
processes. This changes the interaction model fundamentally: the context is
your project, not a blank conversation.

The key architectural insight: in the chat interface, context is a linear
transcript — user turn, assistant turn, user turn.  Even with a 200k-token
window, this is a *flat* structure where information in the interior receives
diminished attention (the "lost in the middle" effect).  In Claude Code, the
filesystem is a tree-structured, randomly addressable store.  The model
doesn't hold the entire codebase in context; it holds a *map* and
dereferences pointers on demand — analogous to a Turing machine's finite-state
controller (the context window) operating on an unbounded tape (the
filesystem).

#### Concept 2: Permissions

When you ask a chatbot for advice, there is no risk — it can only produce
text.  Claude Code can take action: it can read files, write files, and
execute shell commands. This is why the permission model matters.

Permission categories:

- **Accept** — Claude proposes a tool use (e.g., edit a file) and you
  approve it interactively. This is the default for destructive operations.
- **Permission file** — `.claude/settings.json` lets you pre-approve
  categories of actions (e.g., allow all reads, allow writes in `src/`).
  This is how you configure trust boundaries per-project.
- **Read tools** — `cat`, `ls`, `find`, `grep`. Low risk. Typically
  auto-approved.
- **Write tools** — Creating or modifying files. Medium risk. Requires
  approval unless allow-listed.
- **Bash** — Arbitrary shell commands. Highest risk. Guarded most tightly.

The core distinction:

| | Chatbot | Claude Code |
|---|---|---|
| Output | Advice (text) | Action (file changes, commands) |
| Risk | Misunderstanding | Unintended side effects |
| Guard | Your judgment | Permission system + your judgment |

A chatbot gives advice. Claude Code takes action. The permission model exists
because actions have consequences that text does not.

---

### SECTION 2 — Making Claude Personal (Concepts 3–8)

#### Concept 3: The Terminal

Claude Code runs in your terminal emulator, inheriting your shell
environment — `$PATH`, environment variables, project directory.  It is not
a separate IDE or a browser tab; it is a process in your terminal session.
This means it has the same access you do, subject to the permission model.

#### Concept 4: Prompts

Effective prompting in Claude Code differs from chat-style prompting. Because
the tool has access to your filesystem, you can be concrete: "refactor the
error handling in `src/parser.rs` to use `thiserror`" rather than "how should
I handle errors in Rust?" The more specific and scoped the prompt, the better
the result. Multi-step prompts work well — ask Claude to read a file first,
then propose changes, then apply them.

#### Concept 5: Permissions (Deeper Dive)

The `.claude/settings.json` file is where you codify trust. You can
allow-list specific tools, restrict write access to certain directories, and
block bash commands that match patterns. This file is part of your project
and can be version-controlled, meaning your team shares a common trust
configuration.

**Example:**

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

This avoids repeated permission prompts for common commands. Commit
`.claude/settings.json` to the repo so the whole team shares the same
trust boundaries.

#### Concept 6: CLI Tools — Read / Write / Bash

Claude Code's tool use falls into three tiers:

- **Read** — Inspect files, list directories, search codebases. Safe,
  idempotent, no side effects.
- **Write** — Create or modify files. Side effects are contained to the
  filesystem and are reversible via Git.
- **Bash** — Run arbitrary commands. Side effects can be irreversible (e.g.,
  `rm -rf`, network calls, database mutations). This is why bash is the most
  restricted tier.

The bash tier is also where the **verification oracle** lives. The Python
interpreter, the LaTeX compiler, `pytest`, `cargo check` — these tools
provide something unavailable in the chat interface: a binary correctness
signal plus a rich, structured error signal (line numbers, type mismatches,
stack traces).  In the chat interface, "this code compiles" is a *prediction*.
In Claude Code, it is a *verified fact*.

In reinforcement-learning terms, the compiler acts as an immediate reward
signal.  Each read → edit → run → read-error → fix cycle is a dense,
grounded feedback loop — far more informative per token than any
specification you could write in a prompt.  This is why Claude Code can
converge on working code through iteration even when its first attempt has
bugs: the error messages tell it exactly which assumptions were violated.

#### Concept 7: CLAUDE.md

The `CLAUDE.md` file is a project-level instruction file that Claude Code
reads automatically when it starts in a directory. It is where you tell
Claude about your project's conventions, architecture, preferred libraries,
testing strategy, and anything else a new contributor would need to know.
Think of it as onboarding documentation — but the reader is an AI agent.

A good `CLAUDE.md` includes: project overview, directory layout, build and
test commands, coding conventions, and things to avoid.

**Example:**

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
well Claude understands your codebase. Commit it to the repo so the whole
team benefits.

At a deeper level, `CLAUDE.md` functions as a *compressed index* — a
sufficient statistic for the project.  It compresses the enormous state space
of all files, conventions, and architectural decisions into a small,
high-entropy-per-token summary that tells the model *where to look* and
*what patterns to expect*.  It acts like a learned codebook: the model reads
the index, then navigates the filesystem tree to retrieve precisely the
information needed.  The ratio of useful decisions per token of context
consumed is dramatically higher than ingesting raw source files.

#### Concept 8: Context Window and Compaction

Claude Code operates within a finite context window. As a conversation grows,
older content may be compacted or summarized to make room for new information.
Understanding this is important for long sessions: if you've been working for
a while, Claude may lose track of details from earlier in the conversation.

A natural assumption is that simply expanding the context window should
eliminate the need for careful context management. It doesn't, for two
reasons:

- **Attention degradation.** Transformer attention over very long sequences
  is not uniform. Loading every file into a 200k-token window can actually
  *degrade* performance relative to selectively reading three relevant files,
  because the signal-to-noise ratio decreases.
- **Wrong axis of improvement.** Context length is a capacity parameter. The
  filesystem provides a structural capability: random access, hierarchical
  organization, and persistence across reasoning steps. Doubling the context
  window is an improvement along one axis; random addressability is an
  improvement along an orthogonal axis. They are not substitutes.

Claude Code's filesystem enables **demand paging**: loading exactly the needed
information at the top of the current attention window, where it receives
maximal weight.  The filesystem also acts as a **persistent scratchpad** —
when the model writes to a file in step 3 and reads it back in step 7, it
has external working memory that survives between reasoning steps. This
enables problem decomposition strategies that would be impossible with purely
internal state.

Strategies for managing context:

- Keep prompts focused — one task at a time.
- Use `CLAUDE.md` to offload persistent knowledge so it doesn't need to live
  in the conversation.
- Start a fresh session when switching to a fundamentally different task.
- Use the `/compact` command to manually trigger compaction when the context
  is getting full.

---

### SECTION 3 — Power Features (Concepts 9–14)

#### Concept 9: Models

Claude Code can use different models for different tasks:

- **Opus** — Highest capability. Best for complex reasoning, architecture
  decisions, and multi-file refactors. Slower and more expensive.
- **Sonnet** — The default workhorse. Good balance of speed, cost, and
  capability for everyday coding tasks.
- **Haiku** — Fastest and cheapest. Good for simple lookups, formatting,
  and quick questions where deep reasoning isn't needed.

You can switch models mid-session or set a default in configuration.  A
common pattern: use Sonnet for most work, escalate to Opus for hard problems,
drop to Haiku for boilerplate.

#### Concept 10: Denying Access to Files

You can use `.claude/settings.json` or `.claudeignore` to prevent Claude from
reading or modifying specific files or directories.  Use cases include:
secrets files (`.env`, credentials), large vendored dependencies, generated
code that shouldn't be manually edited, and sensitive data files.

#### Concept 11: Flags

Claude Code accepts command-line flags that modify its behavior at launch:

- `--model` — choose the model
- `--allowedTools` — restrict which tools are available
- `--print` — run in non-interactive mode (print output, don't prompt)
- `--output-format` — control output format (text, JSON, stream-JSON)
- `--max-turns` — limit autonomous iteration

Flags are especially useful for scripting and CI/CD integration, where you
want deterministic, non-interactive behavior.

#### Concept 12: Slash Commands

Inside a Claude Code session, slash commands give you meta-control:

- `/compact` — compress the conversation context
- `/clear` — reset the conversation
- `/model` — switch models
- `/cost` — show token usage and cost
- `/help` — list available commands
- `/init` — generate a `CLAUDE.md` for the current project

These operate outside the normal prompt flow — they control the session
itself rather than asking Claude to do something.

---

### SECTION 4 — Using Claude Autonomously (Concepts 15–23)

These mechanisms are not additive — they compound.  The filesystem provides
addressable memory.  CLAUDE.md provides an efficient index into that memory.
Selective file reading provides demand-paged context loading.  Compilation
provides ground-truth verification.  Each read → edit → run → read-error →
fix cycle refines the model's implicit representation of the project, so
subsequent actions require less exploration.  The trajectory through context
space becomes increasingly efficient over a session.

The concepts in this section — skills, hooks, MCP servers, sub-agents — are
all mechanisms for pushing this compounding loop further, faster, and with
less human supervision.

#### Concept 13: Skills

Skills are reusable instruction sets that teach Claude Code how to perform
specific tasks.  They are Markdown files (typically `SKILL.md`) that contain
best practices, tool usage patterns, and step-by-step procedures for a
domain.  Claude reads a skill file before starting a task, much like a
technician reading a manual before a repair.

Skills can be project-specific, shared across an organization, or
community-maintained.

#### Concept 14: Hooks

Hooks let you run custom scripts at specific points in Claude Code's
lifecycle — before a tool call, after a tool call, or on specific events.
This lets you enforce project-specific policies (e.g., "always run the
linter after writing a file"), inject context, or log actions for audit.

#### Concept 15: MCP Servers

The Model Context Protocol (MCP) lets Claude Code connect to external services
— databases, APIs, internal tools — through a standardized interface.  An MCP
server exposes tools that Claude can call, extending its capabilities beyond
the local filesystem.  Examples: a Postgres MCP server for querying databases,
a Jira server for managing tickets, a Figma server for reading designs.

#### Concept 16: Sub-Agents

Claude Code can spawn sub-agents — separate Claude instances that work on a
scoped subtask and return results to the parent session.  This is useful for
parallelism (e.g., "review these five files simultaneously") and for
isolating risky operations in a sandboxed context.

#### Concept 17: Agent Teams

An extension of sub-agents: multiple Claude instances coordinated to work on
different parts of a large task.  One agent plans, others execute, and the
results are merged.  This is the frontier of agentic coding — orchestrating
a team of AI agents the way you'd orchestrate a team of developers.

#### Concept 18: Checkpoints and Undo

Claude Code integrates with Git to create automatic checkpoints before
making changes.  If something goes wrong, you can roll back to a known-good
state.  This is the safety net that makes autonomous operation practical —
you can let Claude try ambitious changes knowing that undo is always
available.

#### Concept 19: Git Integration

Claude Code is deeply Git-aware.  It can read diffs, understand branch
structure, write commit messages, create branches, and reason about merge
conflicts.  Git is both the undo mechanism (checkpoints) and the
collaboration layer (branches, PRs).  A well-configured Git workflow makes
autonomous Claude Code use much safer.

#### Concept 20: Headless Mode

Headless mode runs Claude Code without an interactive terminal — ideal for
CI/CD pipelines, scheduled tasks, and automated workflows.  You pipe in a
prompt, set flags for non-interactive behavior, and capture the output.
Combined with `--max-turns` and `--allowedTools`, this lets you embed Claude
Code in scripts as a programmable coding agent.

Example:

```bash
echo "Write unit tests for src/parser.rs" | claude \
  --print \
  --model sonnet \
  --max-turns 5 \
  --allowedTools "read,write"
```

#### Concept 21: Worktrees

Git worktrees let you check out multiple branches simultaneously in separate
directories.  For Claude Code, this enables parallel autonomous work: one
worktree per task, each with its own Claude instance, all sharing the same
Git history.  When each agent finishes, you merge the worktrees.  This is
the physical infrastructure that makes agent teams practical.

---

## Revision History

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-04-04 | 0.1 | Initial draft — structure and all concepts | JF |
| 2026-04-04 | 0.2 | Integrated architectural framing from "Why Claude Code Outperforms the Chat Interface" — core thesis, demand-paging, verification oracle, compressed index, compounding effect | JF |
| 2026-04-04 | 0.3 | Integrated setup guide — Section 0 (prerequisites, VS Code, Claude Code install, workflow), concrete CLAUDE.md and settings.json examples | JF |

## Source Materials

- "Why Claude Code Outperforms the Chat Interface: Context Architecture, Not
  Model Intelligence" — provides the theoretical backbone for the lesson's
  recurring theme: same model, different architecture.
- "Getting Started with Claude Code on macOS" — practical setup guide for
  Python users using VS Code; basis for Section 0.

---

## Next Steps

- [ ] Draft `pandoc/defaults.yaml` with standard metadata and filters
- [ ] Create `pandoc/reference.docx` with house styling
- [ ] Write the full `justfile` (adapt from the sample above)
- [ ] Expand each concept into a standalone lesson file in `src/`
- [ ] Add exercises and hands-on activities per section
- [ ] Set up `just check` in a GitHub Actions workflow for staleness alerts
