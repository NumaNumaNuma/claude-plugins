# Lean Docs Plugin

Makes codebases agent-legible through structured documentation hierarchy.

## When Writing or Updating Documentation

Follow these rules whenever you create, update, or reorganize documentation — even if the user doesn't explicitly mention lean-docs. These apply any time someone says "document this", "add docs", "update the docs", etc.

### Where to put things

- **CLAUDE.md is an index, not an encyclopedia.** Keep it at 80-120 lines. It holds build commands, key rules, and a docs index table. Nothing else.
- **Deep content goes in `docs/`**. If a section is >15 lines and only relevant to some tasks, it belongs in a topic file under `docs/`, not in CLAUDE.md.
- **Directory-specific rules go in subdirectory CLAUDE.md files.** Create a 10-30 line CLAUDE.md in each major source directory (services, components, models, utils). Focus on what NOT to do and patterns to follow.
- **Don't create new top-level docs.** If a `docs/` directory already exists, add to the existing structure. Match existing file naming and style.

### How to write docs

- **Link, don't duplicate.** If the information already exists in another doc, link to it. Never copy content between files.
- **Keep doc files under 400 lines.** Split into focused sub-files beyond that.
- **Don't over-document.** If a doc file would be <10 lines, merge it into a related neighbor.
- **Reference docs are curated, not comprehensive.** Only document SDK patterns the project actually uses. ~200-300 lines max per reference file.
- **Use tables for indexes and lists.** Tables scan faster than bullet lists for both agents and humans.

### When updating CLAUDE.md

- **Add a docs index entry** if you created a new file in `docs/`. Use the existing table format.
- **Move, don't grow.** If your change would push CLAUDE.md over 120 lines, extract the new content to a doc file and add an index entry instead.
- **List subdirectory CLAUDE.md files** if you created a new one.

### Recording learnings

When you encounter and fix an unexpected issue — a surprising API behavior, a non-obvious configuration requirement, a debugging dead end, a fix that took multiple attempts — record it in `docs/gotchas.md`. This applies during any task, not just documentation tasks.

**When to record**: Only when the issue was genuinely surprising or non-obvious. Don't record routine fixes like typos, missing imports, or standard error handling. The bar is: "would a future agent waste time on this same problem?"

**Format** — one entry per issue, strict structure:

```markdown
## [Short title]
**Symptom**: What you observed (error message, unexpected behavior)
**Cause**: Why it happened
**Fix**: What to do instead
```

**Keeping it lean**:
- Check if the lesson already exists before adding. Don't duplicate.
- Max 30 entries. When you'd exceed 30, scan for entries that are now covered by updated docs, fixed upstream, or no longer relevant, and remove them.
- If multiple entries share a theme (e.g., 3 entries about the same SDK), merge them into one.
- Entries about issues fixed in dependency updates should be removed once the project upgrades past that version.

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

Not every project needs all of these. Create files as they become relevant — don't scaffold empty docs.

## Setup & Audit

Run `/lean-docs` to set up this structure for a new project, or `/lean-docs audit` to check an existing project against the playbook.
