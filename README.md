# Claude Code CLI Workshop — Quick Start

A Pandoc + `just` build of a Claude Code CLI workshop.

## Build it

```bash
just                  # list all recipes
just pdf-all          # build all lessons as PDFs
just docx-all         # build all lessons as DOCX
just book             # master PDF with table of contents
just check            # validate front matter + INDEX sync + staleness
just clean            # wipe build/
```

One-off builds take a filename (no extension):

```bash
just pdf  claude-code--00-foundations
just docx claude-code--02-power-features
```

Outputs land in `build/` (gitignored).

## Where things are

| Path | What |
|------|------|
| `src/INDEX.md` | Manifest of all lesson files |
| `src/claude-code--00-foundations.md` | Core thesis, prompts, permissions |
| `src/claude-code--01-making-it-personal.md` | Terminal, CLAUDE.md, context, sessions |
| `src/claude-code--02-power-features.md` | Models, flags, slash commands, skills, hooks |
| `src/claude-code--03-autonomous-use.md` | MCP, sub-agents, headless, worktrees |
| `src/claude-code--appendix-a-setup.md` | Software install + settings reference |
| `src/claude-code--appendix-b-git.md` | Git primer |
| `src/claude-code--appendix-c-just.md` | `just` primer |
| `justfile` | Build recipes |
| `pandoc/defaults.yaml` | Pandoc config (fonts, margins, PDF engine) |
| `pandoc/reference.docx` | DOCX styling template |
| `archive/` | Frozen PDFs of record (committed) |
| `build/` | Ephemeral build artifacts (gitignored) |
| `CLAUDE.md` | Project instructions for Claude Code |

## Prerequisites

```bash
brew install just pandoc
brew install --cask mactex   # provides lualatex for PDF output
```

## Publish a release

```bash
just pdf    claude-code--00-foundations
just publish claude-code--00-foundations v1.0
```

Copies the PDF to `archive/YYYY-MM-DD--<file>--v1.0.pdf`, commits it, and tags the repo.

## Edit a lesson

1. Edit the `.md` file in `src/`
2. Bump `version:` in its YAML front matter
3. `just check` to validate
4. `just pdf <filename>` to preview
