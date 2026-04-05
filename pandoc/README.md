# Pandoc Configuration

This directory holds Pandoc build configuration for the workshop.

## Files

- `defaults.yaml` — Pandoc defaults (markdown extensions, PDF engine, fonts, margins)
- `reference.docx` — Word template for styled DOCX output

## Generating reference.docx

If `reference.docx` is missing, generate it with:

```bash
pandoc -o pandoc/reference.docx --print-default-data-file reference.docx
```

Then customize styles in Word as needed.
