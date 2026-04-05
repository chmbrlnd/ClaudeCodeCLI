# Claude Code Setup Reference

## Am I in the right mode?

**Yes.** When you see this message on launch:

> "Your bash commands will be sandboxed. Disable with /sandbox."

That means your `~/.claude/settings.json` is active and working. You don't need to do anything else.

---

## How my settings.json works

The file lives at `~/.claude/settings.json` and controls three things: **permissions**, **sandbox**, and **network access**.

### Permissions: allow / ask / deny

**Allow (runs without prompting):**
git status, git diff, git add, git commit, git log, python, python3, pip install, pytest, ls, cat, head, tail, wc, grep, find, mkdir.

**Ask (Claude will prompt before running):**
git push, git checkout, git branch -d, rm. These are potentially destructive — you'll confirm each one.

**Deny (blocked entirely):**
Reading `~/.ssh/`, `~/.aws/`, `~/.gnupg/`, `~/.config/gcloud/`, `.env`, `.env.*`, and `./secrets/`. Claude cannot access these regardless of what you tell it.

### Sandbox settings

- `sandbox.enabled: true` — bash commands run in a restricted container.
- `autoAllowBashIfSandboxed: true` — because commands are sandboxed, Claude skips the permission prompt for them. **This is why most commands just run.**
- `allowUnsandboxedCommands: false` — anything that can't be sandboxed and isn't in the allow list is blocked (not prompted).

### Network access

Only these domains are reachable from within the sandbox: google.com, orcid.org, github.com, npmjs.org, pypi.org, and their subdomains. Everything else is blocked.

---

## Quick-start checklist

1. `cd ~/Sandbox/YourProject`
2. `claude` (starts a session)
3. Verify you see the sandbox message
4. Optionally run `/init` to generate a `CLAUDE.md` for the project
5. Start working

---

## Useful commands to remember

| Command | What it does |
|---------|-------------|
| `Shift+Tab` | Cycle permission mode: Normal → Auto-accept → Plan |
| `/init` | Generate a starter CLAUDE.md for this project |
| `/rename name` | Name your session for easy resume |
| `claude -r name` | Resume a named session |
| `/compact` | Compress conversation when context gets full |
| `/context` | See how much context window is used |
| `/clear` | Reset conversation completely |
| `Esc + Esc` | Undo — rewind Claude's last changes |

---

## Settings file location

```
~/.claude/settings.json
```

To edit: `code ~/.claude/settings.json` or `claude /config`

Last verified: March 2026
