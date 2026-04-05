---
title: "Using Claude Autonomously"
date: 2026-04-05
version: 0.1
status: draft
owner: JF
review-due: 2026-10-05
---

# Using Claude Autonomously

## The Compounding Effect

The mechanisms covered in this workshop are not additive — they compound.
The filesystem provides addressable memory.  CLAUDE.md provides an efficient
index into that memory.  Selective file reading provides demand-paged context
loading.  Compilation provides ground-truth verification.

Each read → edit → run → read-error → fix cycle refines the model's implicit
representation of the project, so subsequent actions require less exploration.
The trajectory through context space becomes increasingly efficient over a
session.

The concepts in this section — MCP servers, sub-agents, agent teams — are
all mechanisms for pushing this compounding loop further, faster, and with
less human supervision.

---

## Concept 15: MCP Servers

The Model Context Protocol (MCP) lets Claude Code connect to external
services — databases, APIs, internal tools — through a standardized
interface.  An MCP server exposes tools that Claude can call, extending its
capabilities beyond the local filesystem.

### How MCP Works

1. An MCP server runs as a separate process (local or remote)
2. It exposes a set of tools via the MCP protocol
3. Claude Code connects to the server and discovers available tools
4. Claude can then call those tools just like built-in tools

### Configuration

MCP servers are configured in your settings:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "mcp-server-postgres",
      "args": ["postgresql://localhost/mydb"]
    },
    "github": {
      "command": "mcp-server-github",
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### Example MCP Servers

| Server | Purpose |
|--------|---------|
| Postgres | Query databases, inspect schemas |
| GitHub | Manage issues, PRs, repositories |
| Jira | Read and update tickets |
| Figma | Read design files and components |
| Slack | Read channels, send messages |
| Filesystem (remote) | Access files on remote machines |

### When to Use MCP

Use MCP when Claude needs to interact with systems beyond the local
filesystem.  Instead of asking Claude to write a script that calls an API,
give it direct access via MCP — the feedback loop is tighter and the
iteration is faster.

---

## Concept 16: Sub-Agents

Claude Code can spawn sub-agents — separate Claude instances that work on a
scoped subtask and return results to the parent session.  This is useful for
parallelism and for isolating risky operations in a sandboxed context.

### How Sub-Agents Work

1. The parent Claude identifies a subtask that can be delegated
2. It spawns a sub-agent with a specific prompt and scope
3. The sub-agent works independently (reads files, runs commands)
4. Results are returned to the parent session

### Use Cases

- **Parallel file review:** "Review these five files simultaneously"
- **Isolated experimentation:** Let a sub-agent try a risky refactor in a
  sandboxed context without affecting the main session
- **Divide and conquer:** Break a large task into independent subtasks
- **Specialized analysis:** Spawn a sub-agent with specific instructions
  (e.g., "focus only on security issues")

### Sub-Agent Scoping

Sub-agents can be given restricted tool access and limited context.  This
means a sub-agent reviewing test files doesn't need (or get) access to
production credentials.

---

## Concept 17: Agent Teams

An extension of sub-agents: multiple Claude instances coordinated to work on
different parts of a large task.  One agent plans, others execute, and the
results are merged.

### Orchestration Patterns

**Hub and spoke:** A coordinator agent breaks the task into subtasks, spawns
worker agents, collects results, and synthesizes a final answer.

**Pipeline:** Each agent handles one stage of a multi-stage process.  Output
from one agent feeds into the next.

**Peer review:** Multiple agents work on the same task independently, then
a coordinator compares results and picks the best approach.

### When to Use Agent Teams

Agent teams shine for tasks that are:

- Too large for a single context window
- Naturally decomposable into independent subtasks
- Benefit from multiple perspectives (e.g., security review + performance
  review + correctness review)

This is the frontier of agentic coding — orchestrating a team of AI agents
the way you'd orchestrate a team of developers.

---

## Concept 18: Checkpoints and Undo

Claude Code integrates with Git to create automatic checkpoints before
making changes.  If something goes wrong, you can roll back to a known-good
state.

### How Checkpoints Work

Before Claude makes changes, it creates a Git checkpoint (a commit or stash)
that captures the current state.  If the changes go wrong, you can undo them
instantly.

### Undo: `Esc + Esc`

Press `Esc` twice in quick succession to undo Claude's last set of changes.
Claude will revert the files to their previous state using the checkpoint.

This is the safety net that makes autonomous operation practical — you can
let Claude try ambitious changes knowing that undo is always available.

### Best Practices

- Commit your own work before letting Claude make large changes
- Use Plan Mode first to review the approach
- Let Claude work in Auto-Accept mode for speed, knowing you can undo
- Review diffs before committing Claude's changes to your branch

---

## Concept 19: Git Integration

Claude Code is deeply Git-aware.  It can read diffs, understand branch
structure, write commit messages, create branches, and reason about merge
conflicts.

### What Claude Can Do With Git

- **Read diffs:** Understand what changed and why
- **Write commit messages:** Generate messages that accurately describe
  the changes
- **Create branches:** Set up feature branches for isolated work
- **Resolve conflicts:** Reason about merge conflicts and propose
  resolutions
- **Review history:** Use `git log` and `git blame` to understand code
  evolution

### Git as Safety Infrastructure

Git serves two roles in Claude Code:

1. **Undo mechanism** — Checkpoints enable instant rollback
2. **Collaboration layer** — Branches, PRs, and code review provide
   human oversight of Claude's autonomous work

A well-configured Git workflow makes autonomous Claude Code use much safer.
Always work on a branch, commit frequently, and review before merging.

---

## Concept 20: Headless Mode

Headless mode runs Claude Code without an interactive terminal — ideal for
CI/CD pipelines, scheduled tasks, and automated workflows.

### The `-p` Flag

The `-p` (print) flag runs Claude non-interactively.  Claude processes the
prompt, does the work, prints the result, and exits:

```bash
# Quick audit, output to file
claude -p "List all security concerns in this codebase" > audit.txt

# JSON output for further processing
claude -p "List all TODO comments" --output-format json > todos.json
```

### Combining With Other Flags

For fully automated workflows, combine `-p` with control flags:

```bash
echo "Write unit tests for src/parser.rs" | claude \
  --print \
  --model sonnet \
  --max-turns 5 \
  --allowedTools "Read" "Edit" "Bash(pytest *)"
```

### CI/CD Integration

Headless Claude Code can be embedded in CI/CD pipelines:

```yaml
# Example: GitHub Actions step
- name: Auto-fix lint issues
  run: |
    claude -p "Fix all lint errors found by ruff" \
      --model sonnet \
      --max-turns 3 \
      --allowedTools "Read" "Edit" "Bash(ruff *)"
```

### Output Formats

| Format | Flag | Use case |
|--------|------|----------|
| Text | (default) | Human-readable output |
| JSON | `--output-format json` | Machine processing |
| Stream JSON | `--output-format stream-json` | Real-time processing |

---

## Concept 21: Worktrees

Git worktrees let you check out multiple branches simultaneously in separate
directories.  For Claude Code, this enables parallel autonomous work.

### How Worktrees Work

```bash
# Create a worktree for a feature branch
git worktree add ../my-project-feature feature-branch

# Now you have two directories:
#   ./my-project          (main branch)
#   ../my-project-feature (feature branch)
```

Each worktree is a full working directory with its own checked-out branch,
but they share the same Git history and object store.

### Worktrees + Claude Code

The pattern:

1. Create a worktree for each task
2. Launch a separate Claude Code instance in each worktree
3. Each agent works independently on its task
4. When done, merge the worktree branches back

```bash
# Set up parallel agents
git worktree add ../proj-auth   feature/auth-refactor
git worktree add ../proj-tests  feature/add-tests
git worktree add ../proj-docs   feature/update-docs

# Launch agents (in separate terminals)
cd ../proj-auth  && claude -p "Refactor auth to use OAuth2"
cd ../proj-tests && claude -p "Add missing unit tests"
cd ../proj-docs  && claude -p "Update API documentation"

# Merge when done
git merge feature/auth-refactor
git merge feature/add-tests
git merge feature/update-docs

# Clean up
git worktree remove ../proj-auth
git worktree remove ../proj-tests
git worktree remove ../proj-docs
```

### Why Worktrees Instead of Branches

With regular branches, you'd need to stash, switch, work, switch back.
Worktrees give each agent a physically separate directory — no conflicts,
no stashing, full parallelism.  This is the physical infrastructure that
makes agent teams practical.

---

## Exercises

1. **Headless mode:** Run Claude in non-interactive mode with `-p` to
   perform a code audit.  Try different `--output-format` options and
   examine the results.

2. **Checkpoints and undo:** Let Claude make a change, then press `Esc+Esc`
   to undo it.  Verify the files are restored.

3. **Git workflow:** Ask Claude to create a feature branch, make changes,
   write a commit message, and create a pull request description.

4. **Worktree parallelism:** Create two Git worktrees.  Launch Claude in
   each with different tasks.  Merge the results.

5. **MCP exploration:** If you have a database, set up a Postgres MCP server
   and let Claude query your schema directly.

6. **Autonomous session:** Combine Plan Mode, Auto-Accept, and checkpoints:
   plan first, then let Claude execute autonomously with the safety net of
   `Esc+Esc` undo.
