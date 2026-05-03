# Wiki Schema

Defines the directory structure, page conventions, and workflows for the nitops project wiki.

## Directory Structure

```
docs/wiki/
  CLAUDE.md          # This schema
  index.md           # Content catalog: every page listed with link + summary
  log.md             # Chronological append-only log of all operations
  entities/          # Pages about concrete things (components, infrastructure)
  concepts/          # Pages about ideas, patterns, architecture decisions
  sources/           # Summary pages for each ingested source
```

## Page Conventions

### Frontmatter

Every wiki page MUST have YAML frontmatter:

```yaml
---
title: Page Title
type: entity | concept | source
created: 2026-05-03
updated: 2026-05-03
sources: [file1.md, file2]   # which sources contributed
tags: [tag1, tag2]
---
```

### Cross-References

- **Inline links**: Use markdown links to other wiki pages on first mention
- **Related section**: End every page with `## Related` listing 3-5 relevant wiki pages
- **Back-links**: When creating or updating a page, check if other pages should link TO it

### Page Body

```markdown
---
# frontmatter above
---

# Page Title

## Overview
One-paragraph summary.

## [Section headings]
Content with inline cross-references.

## Related
- [Related Page 1](type/page-name.md) — one-line why
```
