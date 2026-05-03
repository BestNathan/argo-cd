---
name: wiki-schema
description: Use when setting up a wiki knowledge base, defining wiki conventions, creating page templates, or when wiki pages lack consistent structure, metadata, or cross-referencing rules. Also use when templates exist but agents ignore them, or when CLAUDE.md/schema is missing or thin.
---

# Wiki Schema

Defines the directory structure, page conventions, and workflows for an LLM-maintained wiki under `docs/wiki/`. The wiki is a persistent, compounding knowledge base — the LLM writes it, you read and guide it.

## Core Principle

The schema is the contract between you and future LLM sessions. Without it, agents create disorganized files, skip cross-references, forget to update the index, and let the wiki decay. With it, every session follows the same conventions.

## Directory Structure

```
docs/wiki/
  CLAUDE.md          # This schema — conventions, workflows, page formats
  index.md           # Content catalog: every page listed with link + summary
  log.md             # Chronological append-only log of all operations
  entities/          # Pages about concrete things (people, orgs, products, places, components)
  concepts/          # Pages about ideas, patterns, methodologies, themes, architecture decisions
  sources/           # Summary pages for each ingested source
  queries/           # Answers to significant questions, filed for future reference
  meta/              # Wiki maintenance notes, lint reports, structural decisions
```

Create directories as needed. Not every category must exist from day one.

## Page Conventions

### Frontmatter

Every wiki page MUST have YAML frontmatter:

```yaml
---
title: Page Title
type: entity | concept | source | query | meta
created: 2026-05-02
updated: 2026-05-02
source: filename.md          # which source triggered this page (for source/type)
sources: [file1.md, file2]   # multiple sources contributed (for entity/concept)
tags: [tag1, tag2]
---
```

### Cross-References

- **Inline links**: Use markdown links to other wiki pages on first mention: `[Concept Name](concepts/concept-name.md)`
- **Related section**: End every page with `## Related` listing 3-5 relevant wiki pages
- **Back-links**: When creating or updating a page, check if other pages should link TO it and update them

### Page Body

```markdown
---
# frontmatter above
---

# Page Title

## Overview
One-paragraph summary. What is this? Why does it matter?

## [Section headings — vary by page type]
Content with inline cross-references to other wiki pages.

## Related
- [Related Page 1](type/page-name.md) — one-line why it's related
- [Related Page 2](type/page-name.md)
```

## Source Page Formats

### General Sources (Articles, Papers, Reports)

```markdown
---
title: Source Title
type: source
created: 2026-05-02
updated: 2026-05-02
source: original-filename.pdf
url: https://example.com/article
tags: [tag1, tag2]
---

# Source Title

## Summary
One-paragraph overview of the source and its key contribution.

## Key Takeaways
- Point 1 with context
- Point 2 with context

## Extracted Concepts
- [[concept-name]] — brief explanation
- [[another-concept]] — brief explanation

## Related
- [Relevant Wiki Page](type/page-name.md)
```

### Specs and Design Documents

When ingesting a spec (e.g., `docs/superpowers/specs/*.md`), the source page should capture:

```markdown
---
title: Spec Title
type: source
created: 2026-05-02
updated: 2026-05-02
source: 2026-05-02-spec-name.md
tags: [spec, architecture, component-name]
---

# Spec Title

## Summary
What system or component is being specified.

## Architecture
Brief description of the architecture layers and component relationships.

## Components
| Component | Purpose | Resources |
|-----------|---------|-----------|
| Component A | What it does | Deployment, Service, ConfigMap |

## Scope
- **In scope**: what's covered
- **Out of scope**: what's explicitly excluded (important for future decisions)

## Implementing Plans
- [[plan-slug]] — link to the plan source page

## Related
- [Component A Entity](entities/component-a.md)
- [Architecture Concept](concepts/architecture-pattern.md)
```

### Implementation Plans

When ingesting a plan (e.g., `docs/superpowers/plans/*.md`), the source page should capture:

```markdown
---
title: Plan Title
type: source
created: 2026-05-02
updated: 2026-05-02
source: 2026-05-02-plan-name.md
tags: [plan, implementation]
---

# Plan Title

## Summary
What the plan implements and its relationship to the parent spec.

## Parent Spec
- [[spec-slug]] — link to the spec source page

## Tasks Overview
| Task | Files | Purpose |
|------|-------|---------|
| Task 1 | path/to/file.yaml | What this creates |

## Validation
Pre-commit and post-deploy checks from the plan.

## Related
- [Parent Spec](sources/spec-slug.md)
- [Component Entity](entities/component.md)
```

## Special Files

### index.md

Content-oriented catalog. Organized by type. Updated on every ingest.

```markdown
# Wiki Index

## Entities
- [Page Name](entities/page-name.md) — one-line summary

## Concepts
- [Page Name](concepts/page-name.md) — one-line summary

## Sources
- [Page Name](sources/page-name.md) — one-line summary | ingested: YYYY-MM-DD

## Queries
- [Page Name](queries/page-name.md) — one-line summary | asked: YYYY-MM-DD
```

### log.md

Chronological, append-only. Each entry starts with a parseable prefix:

```markdown
## [2026-05-02] ingest | Source Title
Processed source.md. Created 3 pages, updated 5 pages.

## [2026-05-02] query | "What is X?"
Synthesized answer filed to queries/x-analysis.md.

## [2026-05-02] lint | Full health check
Found 2 contradictions, 1 orphan page, 3 missing cross-refs. Fixed all.
```

## When to Use This Skill

Use when:
- Setting up `docs/wiki/` for the first time
- Page formats are inconsistent (some have frontmatter, some don't)
- Cross-references are missing or broken
- New LLM sessions don't know the wiki conventions
- You need to evolve the schema as the wiki grows
- Spec/plan source formats don't exist and need to be defined

## Common Mistakes

- **No frontmatter**: Pages without frontmatter can't be cataloged by index.md
- **Missing index updates**: Every new page must be added to index.md
- **No back-links**: Creating a page but not updating existing pages that should reference it
- **Skipping log entries**: Without a log, you lose the timeline of what happened and when
- **Over-engineering categories**: Start with entities/concepts/sources. Add queries/meta only when you actually have content for them
- **Spec/plan confusion**: Specs define what, plans define how. Keep them as separate source pages with cross-references
