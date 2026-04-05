---
title: "Appendix B: A Git Primer"
date: 2026-04-05
version: 0.1
status: draft
owner: JFC
review-due: 2026-10-05
---

# Appendix B: A Git Primer

Git is the version control system that underpins every modern software
project — and it is deeply integrated into Claude Code.  This primer covers
the fundamentals you need to work through the workshop.

---

## What Is Git?

Git tracks **snapshots** of your project over time.  Every time you commit,
Git takes a picture of what every file looks like at that moment and stores
a reference to that snapshot.  If a file hasn't changed, Git doesn't store
it again — it just links to the previous identical copy.

This is different from systems that track *diffs* (changes).  Git thinks in
snapshots, not deltas.

---

## Core Concepts

### Repository (Repo)

A directory whose history Git is tracking.  Created with `git init` (new
project) or `git clone` (copy an existing one).  The history lives in a
hidden `.git/` directory.

### Commit

A snapshot of your entire project at a point in time.  Each commit has:

- A unique hash (e.g., `a1b2c3d`)
- A message describing what changed
- A pointer to its parent commit(s)

Commits form a chain — each one points back to the previous one, creating
a full history.

### Branch

A movable pointer to a commit.  When you create a branch, you're saying
"I want to diverge from here and work independently."  The default branch
is usually called `main`.

```
main:    A -- B -- C
                    \
feature:             D -- E
```

### Remote

A copy of the repository hosted elsewhere (typically GitHub, GitLab, or
Bitbucket).  The default remote is called `origin`.  You `push` your
commits to the remote and `pull` others' commits from it.

### Staging Area (Index)

A holding area between your working directory and the next commit.  When you
`git add` a file, you're putting it in the staging area.  When you
`git commit`, everything in the staging area becomes the next snapshot.

```
Working Directory  →  Staging Area  →  Repository
     (edit)          (git add)       (git commit)
```

---

## Essential Commands

### Starting a Project

```bash
# Create a new repository
git init

# Clone an existing repository
git clone https://github.com/user/repo.git
```

### Day-to-Day Commands

```bash
# See what's changed
git status              # which files are modified, staged, untracked
git diff                # see unstaged changes line by line
git diff --staged       # see staged changes (what will be committed)

# Stage changes
git add file.py         # stage a specific file
git add src/            # stage an entire directory
git add -u              # stage changes to tracked files only (safe default)
git add -A              # also stage untracked files (use with caution)

# Commit
git commit -m "Add user login feature"

# View history
git log                 # full commit history
git log --oneline       # compact one-line-per-commit view
git log --graph         # visual branch/merge graph
```

### Working With Remotes

```bash
# Push your commits to the remote
git push

# Pull changes from the remote
git pull                           # fetch + merge (default)
git pull --rebase                  # fetch + rebase (cleaner history)

# See what remotes are configured
git remote -v
```

### When Origin and Local Diverge

If you've made commits locally and someone else has pushed commits to
`origin` in the meantime, `git push` will be rejected — the two histories
have diverged and Git won't silently pick a winner.

The fix is to replay your local commits on top of what's now on the
remote.  That's a **rebase**:

```bash
git fetch origin                   # see what's new on the remote
git rebase origin/main             # replay your commits on top of it
git push                           # now push the rebased history
```

Or, as a one-liner:

```bash
git pull --rebase                  # fetch + rebase in one step
git push
```

**Why rebase instead of merge?**  A plain `git pull` creates a merge
commit every time histories diverge, littering the log with "Merge
branch 'main'" entries.  Rebasing keeps the history linear — your
commits appear as if you'd written them after the latest remote
changes.

**If rebase hits a conflict**, Git pauses and shows the conflicted files.
Resolve them (see *Merge Conflicts* below), then:

```bash
git add <resolved-file>
git rebase --continue
```

To abort and go back to where you started: `git rebase --abort`.

---

## A Typical Workflow

```bash
# 1. Clone the repository
git clone https://github.com/team/project.git
cd project

# 2. Make your changes
#    (edit files, add features, fix bugs)

# 3. Stage your changes
git add src/profiles.py tests/test_profiles.py

# 4. Commit with a descriptive message
git commit -m "Add user profile page with avatar upload"

# 5. Sync with the remote (in case others pushed while you were working)
git pull --rebase

# 6. Push to the remote
git push
```

---

## Git and Claude Code

Claude Code uses Git in several important ways:

### Checkpoints

Before making changes, Claude creates Git checkpoints so you can undo its
work.  Press `Esc+Esc` to revert to the previous checkpoint.

### Branch Awareness

Claude understands which branch you're on and what's changed.  You can ask
it to create branches, write commit messages, and even reason about merge
conflicts.

### Diff Understanding

Claude can read `git diff` output and understand what changed.  This makes
code review and debugging much more targeted — Claude sees exactly what's
different, not the entire file.

### Commit Messages

Claude can write commit messages that accurately describe changes.  Ask it:
"commit these changes with a good message" and it will analyze the diff and
generate a descriptive commit.

---

## Common Gotchas

### Detached HEAD

If you see "HEAD detached at abc1234," you've checked out a specific commit
rather than a branch.  Any new commits won't be associated with a branch.
Fix: `git switch -c my-new-branch` to create a branch at your current
position.

### Merge Conflicts

When two branches change the same lines, Git can't automatically merge.
You'll see conflict markers in the file:

```
<<<<<<< HEAD
your changes
=======
their changes
>>>>>>> feature/auth
```

Resolve by choosing which version to keep (or combining them), then:

```bash
git add resolved-file.py
git commit -m "Resolve merge conflict in resolved-file.py"
```

Claude Code can help resolve conflicts — it understands both versions and
can propose a sensible merge.

### .gitignore

A `.gitignore` file tells Git which files to ignore.  Common entries:

```
.venv/          # virtual environments
.DS_Store       # macOS metadata
__pycache__/    # Python bytecode
*.pyc           # compiled Python
.env            # secrets
build/          # build artifacts
node_modules/   # npm dependencies
```

Create this file early in your project to avoid accidentally committing
files you don't want tracked.

### Undoing Mistakes

```bash
# Unstage a file (keep changes)
git restore --staged file.py

# Discard changes to a file (destructive!)
git restore file.py

# Undo the last commit (keep changes staged)
git reset --soft HEAD~1

# Undo the last commit (keep changes unstaged)
git reset HEAD~1
```
