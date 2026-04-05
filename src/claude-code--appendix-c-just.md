---
title: "Appendix C: A Just Primer"
date: 2026-04-05
version: 0.1
status: draft
owner: JFC
review-due: 2026-10-05
---

# Appendix C: A Just Primer

This workshop uses `just` — a modern command runner — to build documents
from Markdown source files.  This primer explains what `just` is, how to
install it, and how to use it.

---

## What Is `just`?

[`just`](https://github.com/casey/just) is a command runner similar to `make`
but designed for project-specific recipes rather than file-dependency graphs.
It uses a file called `justfile` (no extension) with a clean, readable syntax.

### Why `just` Instead of `make`?

`make` is built around file-timestamp dependency resolution, which is powerful
for compiling C but overkill for "run pandoc on some Markdown files."  `just`
is simpler:

- Recipes are named commands with arguments
- No tabs-vs-spaces traps (unlike Makefiles)
- Built-in help via `just --list`
- Cross-platform support without GNU vs. BSD `make` differences
- Clear, readable syntax

---

## Installing `just`

### macOS (Homebrew)

```bash
brew install just
```

### Ubuntu / Debian

```bash
sudo apt install just
```

### Cargo (Any Platform With Rust)

```bash
cargo install just
```

### Prebuilt Binary

```bash
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash
```

Verify:

```bash
just --version
```

---

## Anatomy of a Justfile

A `justfile` contains **recipes** — named commands that you run with
`just recipe-name`.

### Basic Recipe

```just
# Greet the user
greet:
    echo "Hello, world!"
```

Run it: `just greet`

The comment above the recipe becomes its help text (shown in `just --list`).

### Recipes With Arguments

```just
# Build a specific file to PDF
pdf file:
    pandoc src/{{file}}.md -o build/{{file}}.pdf
```

Run it: `just pdf my-document`

Arguments use double-brace syntax: `{{argument}}`.

### Default Recipe

The first recipe in the file (or one named `default`) runs when you type
`just` with no arguments:

```just
# List available commands
default:
    @just --list
```

The `@` prefix suppresses printing the command itself — only the output is
shown.

### Multi-Line Recipes (Shebang)

For recipes that need shell scripting (loops, conditionals), use a shebang:

```just
# Build all source files
build-all:
    #!/usr/bin/env bash
    mkdir -p build
    for f in src/*.md; do
      base=$(basename "$f" .md)
      pandoc "$f" -o "build/${base}.pdf"
    done
```

Without the shebang, each line runs as a separate shell command.  With it,
the entire block runs as a single script.

### Dependencies

Recipes can depend on other recipes:

```just
setup:
    mkdir -p build

build: setup
    pandoc src/doc.md -o build/doc.pdf
```

Running `just build` will first run `setup`, then `build`.

---

## Common Usage

```bash
just                    # run the default recipe (usually --list)
just --list             # show available recipes with descriptions
just recipe-name        # run a specific recipe
just recipe arg1 arg2   # run a recipe with arguments
just --dry-run recipe   # show what would run without executing
```

---

## Using `just` in This Workshop

The workshop repository's `justfile` provides these recipes:

| Recipe | What it does |
|--------|-------------|
| `just` | List available recipes |
| `just setup` | Create required directories |
| `just docx file` | Build one source file to DOCX |
| `just docx-all` | Build all source files to DOCX |
| `just pdf file` | Build one source file to PDF |
| `just pdf-all` | Build all source files to PDF |
| `just book` | Build master PDF with table of contents |
| `just publish file version` | Archive a PDF and create a Git tag |
| `just check` | Validate front matter, INDEX sync, staleness |
| `just clean` | Remove build artifacts |

### Building the Workshop Materials

```bash
# Build everything as PDF
just pdf-all

# Build the combined master document
just book

# Check that all files have proper front matter
just check
```

### Publishing a Release

```bash
# Build the PDF
just pdf claude-code--00-foundations

# Archive it with a version tag
just publish claude-code--00-foundations v1.0
```

This copies the PDF to `archive/` with a date stamp and creates a Git tag
linking the archive artifact back to the source commit.
