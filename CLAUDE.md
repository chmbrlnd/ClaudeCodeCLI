# Claude Code CLI Workshop

A Markdown-is-source-code workshop on Claude Code, built with Pandoc and Just.

## Directory Layout

```
justfile                        # build recipes (just --list)
pandoc/
  defaults.yaml                 # pandoc config (fonts, margins, pdf-engine)
  reference.docx                # Word template for DOCX output
src/
  INDEX.md                      # manifest of all lesson files
  claude-code--00-foundations.md
  claude-code--01-making-it-personal.md
  claude-code--02-power-features.md
  claude-code--03-autonomous-use.md
  claude-code--appendix-a-setup.md
  claude-code--appendix-b-git.md
  claude-code--appendix-c-just.md
build/                          # gitignored — ephemeral build artifacts
archive/                        # committed — frozen PDFs of record
```

## Build Commands

```bash
just                  # list all recipes
just pdf-all          # build all lessons as PDF
just docx-all         # build all lessons as DOCX
just book             # master PDF with table of contents
just check            # validate front matter, INDEX sync, staleness
just clean            # remove build artifacts
```

Requires: [Pandoc](https://pandoc.org/), LuaLaTeX, [just](https://github.com/casey/just).

## Conventions

- Markdown is the canonical source of truth; all other formats are derived
- Each `src/` file carries YAML front matter: title, date, version, status, owner, review-due
- File naming: `claude-code--<section>.md` — glob sort determines build order
- Archive PDFs are named `YYYY-MM-DD--<file>--<version>.pdf` with matching Git tags

## Revision History

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-04-04 | 0.1 | Initial draft — structure and all concepts | JF |
| 2026-04-04 | 0.2 | Integrated architectural framing | JF |
| 2026-04-04 | 0.3 | Integrated setup guide | JF |
| 2026-04-05 | 0.4 | Repository build-out — lesson files, appendices, build infrastructure | JF |
