# Lean Docs Plugin

Makes codebases agent-legible through structured documentation hierarchy.

## Core Principle

A single large CLAUDE.md becomes a context hog. Agents work better with a short stable entry point (~100 lines) that links to deeper docs on demand. Think table of contents, not encyclopedia.

## Documentation Hierarchy

```
CLAUDE.md                    → 80-120 lines, build commands + rules + docs index
docs/
  architecture.md            → App structure, patterns, directory layout
  database.md                → Schema, migrations, key queries
  api.md                     → Endpoints, auth, error handling
  testing.md                 → Test patterns, fixtures, gotchas
  quality-grades.md          → Per-domain quality ratings
  golden-principles.md       → Mechanical always/never rules + GC cadence
  gotchas.md                 → Hard-won lessons
  design-docs/
    core-beliefs.md          → 5-10 operating principles (the "why")
  generated/
    db-schema.md             → Auto-generated schema dump
  references/
    [framework]-sdk.md       → Curated SDK patterns (not full API docs)
src/services/CLAUDE.md       → 10-30 lines, directory-specific rules
src/components/CLAUDE.md     → 10-30 lines, directory-specific rules
```

## Key Rules

- **If a CLAUDE.md section is >15 lines and only relevant to some tasks, move it to docs/**
- **Subdirectory CLAUDE.md files**: 10-30 lines each, focus on what NOT to do and patterns to follow
- **Reference docs are curated, not comprehensive**: Only document what your project actually uses (~200-300 lines per file)
- **Don't over-document**: If a doc file is <10 lines, merge it into a neighbor
- **GC monthly**: Stale docs are worse than no docs
- **Encode taste as lint rules**: If a pattern matters, make it a lint rule with an agent-friendly error message
