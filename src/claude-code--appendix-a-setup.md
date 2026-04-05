---
title: "Appendix A: Software Setup"
date: 2026-04-05
version: 0.1
status: draft
owner: JF
review-due: 2026-10-05
---

# Appendix A: Software Setup

This appendix covers everything you need to install and configure before the
workshop.  Complete these steps ahead of time so you can focus on learning
during the session.

---

## Prerequisites

### Homebrew (macOS Package Manager)

If not already installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Verify:

```bash
brew --version
```

### Git via Xcode Command Line Tools

```bash
xcode-select --install
git --version
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

### Python and pip

Use a Homebrew-managed version rather than the system Python:

```bash
brew install python
python3 --version && pip3 --version
```

---

## VS Code

### Installation

Install via Homebrew (recommended — keeps it in your `brew upgrade` flow):

```bash
brew install --cask visual-studio-code
```

### Recommended Extensions

- **Python** (`ms-python.python`) — IntelliSense, linting, debugging
- **Claude Code** (`anthropic.claude-code`) — Claude AI in the editor sidebar
- **LaTeX Workshop** (`james-yu.latex-workshop`) — if you work with LaTeX

### Virtual Environments

For each project, create a virtual environment and tell VS Code about it:

```bash
cd your-project
python3 -m venv .venv
```

VS Code should auto-detect the `.venv`.  If not, open the Command Palette
(Cmd+Shift+P), select "Python: Select Interpreter," and choose the one
inside `.venv`.

To make this sticky per-project, add `.vscode/settings.json`:

```json
{ "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python" }
```

Add `.venv/` to your `.gitignore` so virtual environments are not tracked.

---

## Installing Claude Code

Claude Code comes in two forms — a CLI tool and a VS Code extension.  You
want both.

### CLI — Homebrew (Recommended)

```bash
brew install --cask claude-code
claude --version
```

The Homebrew install requires no Node.js and integrates with your system PATH.
It does not auto-update; run `brew upgrade claude-code` periodically.

### CLI — npm (Alternative)

```bash
npm install -g @anthropic-ai/claude-code
```

### VS Code Extension

Open Extensions (Cmd+Shift+X), search "Claude Code," click Install.
Authentication is shared between the CLI and the extension — sign in once.

### Authentication

Run `claude` in your terminal.  The first time, it opens a browser tab.
Sign in with your Claude Pro or Max plan, or paste an Anthropic Console API
key.

### Diagnostics

Run `claude doctor` to check your installation type, version, and common
configuration issues.

### Useful CLI Commands

```bash
claude                # start an interactive session
claude doctor         # diagnose installation issues
claude --version      # check installed version
claude --help         # see all available flags
```

---

## Settings Configuration

Claude Code's behavior is controlled by `~/.claude/settings.json`.  This
file manages three things: **permissions**, **sandbox**, and **network
access**.

### Permissions: Allow / Ask / Deny

**Allow (runs without prompting):**
`git status`, `git diff`, `git add`, `git commit`, `git log`, `python`,
`python3`, `pip install`, `pytest`, `ls`, `cat`, `head`, `tail`, `wc`,
`grep`, `find`, `mkdir`.

**Ask (Claude will prompt before running):**
`git push`, `git checkout`, `git branch -d`, `rm`.  These are potentially
destructive — you'll confirm each one.

**Deny (blocked entirely):**
Reading `~/.ssh/`, `~/.aws/`, `~/.gnupg/`, `~/.config/gcloud/`, `.env`,
`.env.*`, and `./secrets/`.  Claude cannot access these regardless of what
you tell it.

### Sandbox Settings

- `sandbox.enabled: true` — bash commands run in a restricted container.
- `autoAllowBashIfSandboxed: true` — because commands are sandboxed, Claude
  skips the permission prompt for them.  **This is why most commands just
  run.**
- `allowUnsandboxedCommands: false` — anything that can't be sandboxed and
  isn't in the allow list is blocked (not prompted).

### Network Access

Only these domains are reachable from within the sandbox: google.com,
orcid.org, github.com, npmjs.org, pypi.org, and their subdomains.
Everything else is blocked.

### Am I in the Right Mode?

When you see this message on launch:

> "Your bash commands will be sandboxed.  Disable with /sandbox."

That means your `~/.claude/settings.json` is active and working.  You don't
need to do anything else.

### Settings File Location

```
~/.claude/settings.json
```

To edit: `code ~/.claude/settings.json` or `claude /config`

---

## Typical Workflow

1. Clone or create a repo and open it in VS Code.
2. Create a `.venv` (`python3 -m venv .venv`) and select it as the
   interpreter.
3. Add a `CLAUDE.md` summarizing the project for Claude (see Concept 7).
4. Use the Claude Code sidebar in VS Code for inline questions, code
   generation, and diffs.
5. Use the CLI (`claude`) in your terminal for larger tasks: refactoring,
   writing tests, git operations.
6. Commit regularly.  Claude can help with commit messages and branch
   management.

---

## Keeping Your Mac Awake

Claude Code sessions can run for a while.  Use the built-in `caffeinate`
command to prevent sleep:

```bash
# Wrap your Claude command — sleep is prevented until Claude exits
caffeinate -dims claude -p "your long task here"

# Or if Claude is already running in another tab, open a second tab:
caffeinate -dims -t 14400    # stay awake for 4 hours (adjust as needed)
```

Flags: `-d` display, `-i` idle, `-m` disk, `-s` system (even on battery).
When the command or timer ends, normal sleep resumes.

---

## Environment Validation Checklist

Run these commands to verify your setup is complete:

```bash
brew --version          # Homebrew installed
git --version           # Git installed
python3 --version       # Python 3 installed
pip3 --version          # pip installed
code --version          # VS Code installed
claude --version        # Claude Code CLI installed
claude doctor           # No issues reported
```

If any command fails, revisit the corresponding section above.
