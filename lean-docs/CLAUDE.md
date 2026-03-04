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
- Remove entries about issues fixed in dependency updates once the project upgrades past that version.
- **When `docs/gotchas.md` grows beyond ~30 entries**, split into topic files under `docs/gotchas/` and turn `docs/gotchas.md` into a slim index:

```
docs/
  gotchas.md                → Index with one-line summaries linking to topic files
  gotchas/
    database.md             → Database/query/migration gotchas
    auth.md                 → Auth and permissions gotchas
    sdk-quirks.md           → Third-party SDK surprises
    build-deploy.md         → Build, CI, deployment gotchas
```

The index format:

```markdown
# Gotchas

| Topic | Key lessons |
|-------|-------------|
| [Database](gotchas/database.md) | Partial writes on timeout, migration ordering |
| [Auth](gotchas/auth.md) | Token refresh race, session expiry edge case |
```

This way the agent scans the index to find the right topic file, then reads only that file. Same hierarchy principle as CLAUDE.md → docs/.

## Full Hierarchy & Setup

See `skills/lean-docs/SKILL.md` for the complete documentation hierarchy and the 9-step playbook. Run `/lean-docs` for guided setup or `/lean-docs audit` to check an existing project.
