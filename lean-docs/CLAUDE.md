# Lean Docs Plugin

Makes codebases agent-legible through a structured documentation hierarchy: a slim `CLAUDE.md` index at the root, deep content in `docs/`, directory-specific rules in subdirectory `CLAUDE.md` files.

## When writing or updating docs

These rules apply any time you create, update, or reorganise documentation — even without an explicit `/lean-docs` invocation. "Document this", "add docs", "update the docs", and similar all trigger them. The reason: agent context is finite and context spent re-reading encyclopedic root docs is context not spent on the task.

### Where things go

- **`CLAUDE.md` is an index, not an encyclopedia.** Target 80–120 lines: build/test/lint commands, key rules, docs index table. The smaller the root file, the lower the cost of every task that loads it.
- **Deep content belongs in `docs/`.** Any section over ~15 lines that's only relevant to some tasks is a `docs/` file. Keep each under 400 lines; split into focused sub-files past that.
- **Directory-specific rules live in subdirectory `CLAUDE.md` files.** 10–30 lines each in major source directories (services, components, models, utils). Claude Code uses the *closest* `CLAUDE.md`, so these override/supplement root. Focus on what NOT to do and patterns to follow.
- **Don't create new top-level doc structures.** If `docs/` already exists, add to the existing layout and match its naming and style. Parallel hierarchies fragment attention.

### How to write

- **Link, don't duplicate.** Cross-references stay true across edits; copies rot the moment one of them is updated.
- **Tables beat bullets for indexes.** Agents and humans scan tables faster.
- **Don't over-document.** A `docs/` file under 10 lines merges into a neighbour.
- **Reference docs are curated, not comprehensive.** Only document SDK patterns the project actually uses. ~200–300 lines max per reference file.

### Updating `CLAUDE.md`

- Created a new file in `docs/`? Add an entry to the docs index table.
- Created a new subdirectory `CLAUDE.md`? Mention it in the subdirectory section.
- Your change would push `CLAUDE.md` over ~120 lines? Move, don't grow — extract the new content to a doc file and add an index entry instead.

### Recording learnings in `docs/gotchas.md`

When you hit a genuinely surprising issue during any task — non-obvious API behaviour, hidden config requirement, multi-attempt fix, dead-end you don't want the next agent to relive — record it. The bar is: *would a future agent waste time on this same problem?*

Not gotchas-worthy: typos, missing imports, standard error handling, normal debugging work.

Format — one entry per issue, strict structure (deviation makes the file harder to scan):

```markdown
## [Short title]
**Symptom**: What you observed (error message, unexpected behavior)
**Cause**: Why it happened
**Fix**: What to do instead
```

Check for existing entries first; don't duplicate. Remove entries about issues fixed by dependency upgrades once the project passes that version.

**When `docs/gotchas.md` grows past ~30 entries**, split into topic files under `docs/gotchas/` and turn `gotchas.md` into a slim index. Same hierarchy principle as `CLAUDE.md` → `docs/` — scan the index to find the right topic file, then read only that file.

```
docs/
  gotchas.md                → Index with one-line summaries linking to topic files
  gotchas/
    database.md             → Database/query/migration gotchas
    auth.md                 → Auth and permissions gotchas
    sdk-quirks.md           → Third-party SDK surprises
    build-deploy.md         → Build, CI, deployment gotchas
```

## Full hierarchy and setup

See `skills/lean-docs/SKILL.md` for the complete documentation hierarchy and 9-step playbook. Run `/lean-docs` for guided setup, `/lean-docs audit` to check an existing project against the playbook.
