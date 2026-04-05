# Claude Code Quickstart — The "How"

## 1. Sessions: naming, listing, resuming

### Name your session early

Once you're in a Claude session, name it right away:

```
/rename auth-refactor
```

This makes it trivially easy to come back later.

### Resume a named session

```bash
claude -r auth-refactor       # resume by name
claude -c                     # resume most recent (same project directory)
claude -r                     # open the interactive picker
```

The interactive picker lets you search, preview, rename, and filter sessions. Key shortcuts inside the picker: `P` to preview, `R` to rename, `/` to search, `A` to toggle between current project and all projects.

### What "resume" actually means

When you resume, the full conversation history is restored — messages, tool results, everything. Claude picks up where you left off. However, context window space is still consumed by the old messages, so long sessions may need a `/compact` before continuing.

### Gotcha: sessions are per-project

Sessions are tied to the git repo (or directory) you started them from. If you `cd` somewhere else and run `claude -r`, you won't see sessions from the other project. Use the `A` key in the picker to toggle and see all projects.

---

## 2. Giving Claude instructions: three layers

There are three ways to give Claude standing instructions, and they stack.

### Layer 1: `~/.claude/CLAUDE.md` (global, all projects)

Create this file for preferences that apply everywhere — your coding style, preferred languages, formatting opinions.

```markdown
# Global preferences
- Prefer Python 3.11+ syntax
- Use type hints always
- Write docstrings in Google style
- When writing tests, use pytest
```

### Layer 2: Project `CLAUDE.md` (per-repo)

Lives at `./CLAUDE.md` or `./.claude/CLAUDE.md` in your project root. Checked into git, shared with collaborators. Contains project-specific conventions.

```markdown
# Project: my-api
- Run tests with: pytest tests/ -v
- Linter: ruff check .
- This project uses SQLAlchemy 2.0 async syntax
- Always run tests after making changes
```

### Layer 3: CLI flags (one-off overrides)

For ad-hoc tasks where you want to inject instructions without editing any files:

```bash
# Append extra rules to the default prompt
claude --append-system-prompt "Focus only on security vulnerabilities. Be terse."

# Load rules from a file
claude --append-system-prompt-file ./audit-rules.txt

# Replace the entire system prompt (advanced, rarely needed)
claude --system-prompt "You are a code auditor. Only report issues."
```

### How the layers combine

More specific wins. Claude sees all of them, but project-level overrides global, and CLI flags override both. A `CLAUDE.local.md` in the project root is like project-level but personal (auto-added to `.gitignore`).

### Subdirectory CLAUDE.md files

You can place a `CLAUDE.md` inside any subfolder (e.g., `src/api/CLAUDE.md`). These load on-demand — only when Claude reads files in that directory. Useful for module-specific rules in larger projects.

---

## 3. External workflows: auditing a folder you're not "in"

You don't have to `cd` into a project to work on it. Use `--add-dir`:

```bash
# Audit a project from anywhere
claude --add-dir ~/Sandbox/VScode/my-project -p "Do a professional code audit. Check for security issues, code smells, and missing tests."

# Combine with custom instructions
claude --add-dir ~/Sandbox/VScode/my-project \
  --append-system-prompt-file ~/Sandbox/ClaudeCLI/audit-rules.txt \
  -p "Audit this codebase"

# Work with multiple directories at once
claude --add-dir ~/Sandbox/VScode/frontend ~/Sandbox/VScode/backend \
  -p "Check for API contract mismatches between frontend and backend"
```

**Note:** CLAUDE.md files inside `--add-dir` directories are *not* loaded by default. To load them, set the environment variable:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ~/project -p "audit"
```

### The `-p` flag: one-shot mode

The `-p` (print) flag runs Claude non-interactively. Claude processes the prompt, does the work, prints the result, and exits. Great for scripted tasks:

```bash
# Quick audit, output to file
claude --add-dir ~/project -p "List all security concerns" > audit-results.txt

# JSON output for further processing
claude --add-dir ~/project -p "List all TODO comments" --output-format json > todos.json
```

Without `-p`, Claude opens an interactive session and you can have a back-and-forth conversation — better for exploratory work.

---

## 4. Plan Mode: think before acting

Plan Mode is read-only. Claude can explore your codebase and reason about it, but cannot edit files or run commands. This is how you prevent Claude from charging ahead in the wrong direction.

### Entering Plan Mode

**Option A — Start in Plan Mode from the terminal:**
```bash
claude --permission-mode plan
```

**Option B — Switch mid-session:**
Press `Shift+Tab` twice (Normal → Auto-Accept → Plan).

**Option C — Set as default in settings.json:**
```json
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

### What Claude can and cannot do in Plan Mode

| Can do | Cannot do |
|--------|-----------|
| Read and analyze files | Edit or create files |
| Trace through code paths | Run bash commands |
| Ask you clarifying questions | Make any changes |
| Propose a detailed plan | Execute anything |

### The Plan Mode workflow

1. **Enter Plan Mode** (Shift+Tab twice, or `--permission-mode plan`)
2. **Describe what you want:** "I need to refactor the auth system to use OAuth2"
3. **Claude explores and proposes a plan** — it reads files, traces dependencies, identifies what needs to change
4. **Refine the plan** — ask follow-up questions: "What about backward compatibility?" or "Can you break this into smaller steps?"
5. **Edit the plan** — press `Ctrl+G` to open the plan in your editor and tweak it
6. **Switch to Normal Mode** — press `Shift+Tab` to cycle back to Normal
7. **Claude executes the plan** — it already knows what to do from the planning phase

### When to use Plan Mode

Use it for anything that touches more than a couple of files, involves architectural decisions, or where you'd want to review the approach before Claude starts writing code. Basically: if you'd want a human developer to explain their plan before coding, use Plan Mode.

---

## 5. Auto-Accept Mode: letting Claude work faster

### The Shift+Tab cycle

`Shift+Tab` cycles through three modes:

```
Normal Mode  →  Auto-Accept Mode  →  Plan Mode  →  (back to Normal)
```

**Normal Mode (default):** Claude asks permission before editing files or running commands. You approve each action.

**Auto-Accept Mode (`⏵⏵ accept edits on`):** Claude automatically applies file edits without asking. Bash commands still follow your settings.json rules (allow/ask/deny). This is the sweet spot for productive coding sessions where you trust Claude's direction but want destructive commands gated.

**Plan Mode (`⏸ plan mode on`):** Read-only, no changes possible.

### How Auto-Accept interacts with your settings.json

Your settings.json has `autoAllowBashIfSandboxed: true`, which means sandboxed bash commands already run without prompting. So in practice:

| Action | Normal Mode | Auto-Accept Mode |
|--------|------------|-----------------|
| File edits | Prompts you | **Auto-approved** |
| Sandboxed bash (in allow list) | Auto-approved | Auto-approved |
| `git push`, `rm`, etc. (in ask list) | Prompts you | **Still prompts you** |
| Reading denied paths | Blocked | Blocked |

The `ask` list in your settings is respected regardless of mode. Auto-Accept only removes the prompt for file edits — it doesn't override your safety gates.

### When to use Auto-Accept

Turn it on when you've agreed on a plan and want Claude to execute without stopping to ask "Can I edit this file?" every few seconds. Turn it off (back to Normal) when you're exploring or unsure of the direction.

### The `--allowedTools` flag (more granular)

For scripted/CI use, you can pre-approve specific tools from the CLI:

```bash
claude --allowedTools "Edit" "Read" "Bash(npm run test)" -p "fix lint errors and run tests"
```

This is more surgical than Auto-Accept — you're saying "these exact tools are fine, prompt for everything else."

---

## 6. Putting it all together: example workflows

### Workflow A: Focused coding session

```bash
cd ~/Sandbox/VScode/my-project
claude
```
```
/rename feature-user-profiles
```
→ Shift+Tab twice → Plan Mode
→ "I need to add user profile pages with avatar upload"
→ Claude proposes plan
→ Shift+Tab → back to Normal (or Auto-Accept for speed)
→ Claude implements
→ "Run the tests"
→ `/compact` if the conversation gets long
→ Done for now? Just exit. Resume later with `claude -r feature-user-profiles`

### Workflow B: Quick external audit

```bash
claude --add-dir ~/Sandbox/VScode/my-project \
  --append-system-prompt "You are a senior code reviewer. Be thorough but concise." \
  -p "Review this codebase for security issues, missing error handling, and test coverage gaps. Prioritize by severity."
```

One-shot. Results print to terminal. Pipe to a file if you want to keep them.

### Workflow C: Multi-step refactor with safety

```bash
cd ~/Sandbox/VScode/my-project
claude --permission-mode plan
```
```
/rename refactor-database-layer
```
→ "Analyze the database layer. I want to migrate from raw SQL to SQLAlchemy ORM."
→ Claude reads everything, proposes a migration plan
→ Review the plan, ask questions
→ Shift+Tab → Normal Mode
→ "Start with step 1 of your plan"
→ After each step: "Run tests to make sure nothing broke"
→ Repeat until done

---

## 7. Cheat sheet

| I want to... | Do this |
|--------------|---------|
| Name my session | `/rename my-task-name` |
| Resume a session | `claude -r my-task-name` |
| Resume most recent | `claude -c` |
| Browse all sessions | `claude -r` then use picker |
| Enter Plan Mode | `Shift+Tab` twice, or `--permission-mode plan` |
| Enter Auto-Accept | `Shift+Tab` once |
| Go back to Normal | `Shift+Tab` again |
| Audit external code | `claude --add-dir /path -p "audit this"` |
| Add one-off instructions | `--append-system-prompt "your rules"` |
| Load instructions from file | `--append-system-prompt-file ./rules.txt` |
| Compress long conversations | `/compact` |
| Undo Claude's changes | `Esc + Esc` |
| See context usage | `/context` |
| Run bash directly | `! npm test` (prefix with `!`) |
| Reference a file | `@src/main.py` (prefix with `@`) |

---

## 8. Keeping your Mac awake for long tasks

Claude Code sessions can run for a while. Use the built-in `caffeinate` command to prevent sleep:

```bash
# Wrap your Claude command — sleep is prevented until Claude exits
caffeinate -dims claude -p "your long task here"

# Or if Claude is already running in another tab, open a second tab:
caffeinate -dims -t 14400    # stay awake for 4 hours (adjust seconds as needed)
```

Flags: `-d` display, `-i` idle, `-m` disk, `-s` system (even on battery). When the command or timer ends, normal sleep resumes.

---

## 9. Session hygiene

**Sessions are tied to the starting directory**, not the files you created. If you `cd ~/Sandbox/VScode/coe-data` and run Claude there, the session is filed under `coe-data` — even if Claude created files in `coe-data-dummy/`.

This is fine. Just know that `claude -r` from a different directory won't show it unless you press `A` in the picker to toggle "all projects."

**You don't need to clean up after completing a session.** Just `Ctrl+D` to exit. The named session is saved automatically and can be resumed anytime with `claude -r session-name`.

Last updated: March 2026
