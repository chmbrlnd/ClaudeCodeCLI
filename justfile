# Claude Code CLI Workshop — Build Recipes
# Run `just` or `just --list` to see available commands.

# Default recipe: list available commands
default:
    @just --list

# Create required directories
setup:
    mkdir -p build archive

# Build a single source file to docx
docx file:
    mkdir -p build
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

# Build a single source file to PDF
pdf file:
    mkdir -p build
    pandoc src/{{file}}.md \
      --defaults pandoc/defaults.yaml \
      -o build/{{file}}.pdf

# Build all source files to PDF
pdf-all:
    #!/usr/bin/env bash
    mkdir -p build
    for f in src/claude-code--*.md; do
      base=$(basename "$f" .md)
      pandoc "$f" \
        --defaults pandoc/defaults.yaml \
        -o "build/${base}.pdf"
    done

# Build master PDF — all lessons concatenated with a table of contents
book:
    mkdir -p build
    pandoc src/claude-code--*.md \
      --defaults pandoc/defaults.yaml \
      --metadata title="Claude Code CLI Workshop" \
      --toc --toc-depth=2 \
      -o build/claude-code-master.pdf

# Publish: copy a built PDF to the archive with today's date and a version tag
publish file version:
    cp build/{{file}}.pdf archive/$(date +%Y-%m-%d)--{{file}}--{{version}}.pdf
    git add archive/
    git commit -m "Publish {{file}} {{version}}"
    git tag "{{file}}/{{version}}"

# Validate front matter, INDEX sync, and document staleness
check:
    #!/usr/bin/env bash
    errors=0
    echo "--- Front matter check ---"
    for f in src/claude-code--*.md; do
      if ! head -10 "$f" | grep -q "^status:"; then
        echo "MISSING status: $f"
        errors=$((errors + 1))
      fi
    done
    echo "--- Stale document check ---"
    for f in src/claude-code--*.md; do
      due=$(grep "^review-due:" "$f" | awk '{print $2}')
      if [[ -n "$due" && "$due" < "$(date +%Y-%m-%d)" ]]; then
        echo "OVERDUE: $f (due $due)"
        errors=$((errors + 1))
      fi
    done
    echo "--- INDEX sync check ---"
    for f in src/claude-code--*.md; do
      base=$(basename "$f")
      if ! grep -q "$base" src/INDEX.md; then
        echo "NOT IN INDEX: $base"
        errors=$((errors + 1))
      fi
    done
    if [[ $errors -eq 0 ]]; then
      echo "All checks passed."
    else
      echo "$errors issue(s) found."
      exit 1
    fi

# Clean build artifacts
clean:
    rm -rf build/*
