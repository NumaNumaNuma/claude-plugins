---
description: "Agent-legible documentation setup and auditing for any codebase"
---

# Lean Docs Playbook

A step-by-step guide to making any codebase agent-legible. Agents work better with a short stable entry point (~100 lines) that links to deeper docs on demand. Think table of contents, not encyclopedia.

Based on the [harness engineering approach](https://openai.com/index/introducing-codex/).

---

## Step 1: Slim Down CLAUDE.md (~30 min)

Your CLAUDE.md should only contain what **every** task needs:

- Build/test/lint commands
- Package manager commands
- Connection strings / credentials location
- Key rules (indentation, language version, framework constraints)
- **Docs index table** pointing to everything else

Everything else moves to `docs/`. Target: **80-120 lines**.

See `references/claude-md-template.md` for the full template.

---

## Step 2: Create Domain Docs (`docs/`)

Split your old CLAUDE.md content into topic files. Common set:

| File | What goes in it |
|------|----------------|
| `architecture.md` | App structure, patterns, directory layout, service lifecycle |
| `database.md` | Tables, key functions/triggers, data model, migration patterns |
| `api.md` | Endpoints, auth, error handling (or `realtime.md` for WebSocket apps) |
| `feature-x.md` | Per-feature deep docs (only for complex features) |
| `notifications.md` | Push/email notification flow |
| `ui-patterns.md` | Component catalog, layout patterns, design system |
| `testing.md` | Test commands, decoder rules, fixture patterns |
| `gotchas.md` | Hard-won lessons and pitfalls |
| `quality-grades.md` | Per-domain quality table (see template in references) |

**Rule of thumb**: If a section in CLAUDE.md is >15 lines and only relevant to some tasks, it belongs in a doc file.

---

## Step 3: Subdirectory CLAUDE.md Files (~20 min)

Create a `CLAUDE.md` in each major package/directory with rules specific to that code. Claude Code uses the **closest** CLAUDE.md, so these override/supplement the root.

**Examples:**

```
src/services/CLAUDE.md    -> "No UI imports, pure business logic, use async/await"
src/components/CLAUDE.md  -> "All components need stories, 44pt touch targets"
src/models/CLAUDE.md      -> "Never use auto key decoding, always explicit mapping"
src/utils/CLAUDE.md       -> "Pure functions only, no side effects, document edge cases"
```

Keep each one **10-30 lines**. Focus on:
- What NOT to do (common mistakes in this directory)
- Patterns to follow (with 2-3 line examples)
- Key files and what they do

---

## Step 4: Design Docs & Core Beliefs (~15 min)

```
docs/design-docs/
  index.md          -> List of design docs with status
  core-beliefs.md   -> 5-10 operating principles (the "why" behind your rules)
```

See `references/core-beliefs-template.md` for the template.

Examples of core beliefs:
- "One concurrency model — single async pattern reduces an entire class of bugs."
- "Optimistic updates first — show the result immediately, reconcile with server async."
- "Repo is the single source of knowledge — if it's not in-repo, it doesn't exist for agents."
- "Prefer boring technology — well-documented, stable APIs that agents can reason about."

---

## Step 5: Execution Plans (~10 min)

```
docs/exec-plans/
  index.md       -> Links to active and completed plans
  template.md    -> Standard format for new plans
  active/        -> Plans currently in progress
  completed/     -> Archived plans (reference only)
```

See `references/exec-plan-template.md` for the template.

---

## Step 6: Golden Principles & GC Process (~15 min)

`docs/golden-principles.md` — Mechanical rules that prevent codebase drift. These are the "always/never" rules, not the "why" (that's core-beliefs).

See `references/golden-principles-template.md` for the template.

Key sections:
- File organization (max lines per file, one type per file)
- Naming & style (indent rule, naming conventions)
- Framework-specific rules (always/never rules for your stack)
- Doc Gardening (GC Cadence) — monthly checklist

---

## Step 7: Auto-Generated Docs (~20 min)

```
docs/generated/
  db-schema.md     -> Full schema dump (tables, columns, types, policies, triggers)
  api-routes.md    -> Auto-generated API route list (if applicable)
```

**For databases**: Use your ORM's schema dump, query `information_schema`, or use your database provider's tools. Include: columns with types/nullability/defaults, foreign keys, unique constraints, access policies, triggers, functions, indexes. Regenerate after each migration.

**For APIs**: Generate from OpenAPI spec, route definitions, or framework introspection.

---

## Step 8: LLM-Readable Reference Docs (~30 min)

```
docs/references/
  [framework]-sdk.md       -> Key SDK patterns for your main framework
  [language]-patterns.md   -> Language-specific patterns and gotchas
```

These are **not** copies of official docs. They're curated, minimal references covering only what your project uses. Think "cheat sheet for an agent working on this codebase."

### What to include:
- Setup/init patterns
- CRUD operations with your actual model names as examples
- Auth patterns
- Real-time/WebSocket patterns (if applicable)
- Common gotchas specific to your usage
- **~200-300 lines per file** — enough to be useful, short enough to not bloat context

### What NOT to include:
- Features you don't use
- Full API surface
- Tutorials or explanations

---

## Step 9: Taste Invariants as Lint Rules (~20 min)

Encode your "taste" (code style preferences) as lint rules with **agent-friendly error messages**. The error message should tell the agent what to do instead.

### ESLint Example

```json
{
  "rules": {
    "no-restricted-imports": ["error", {
      "patterns": [{
        "group": ["lodash"],
        "message": "Use native array methods instead of lodash."
      }]
    }]
  }
}
```

### Ruff (Python) Example

```toml
[tool.ruff.lint]
select = ["E", "F", "I", "N"]
[tool.ruff.lint.isort]
known-first-party = ["myproject"]
```

### SwiftLint Example

```yaml
custom_rules:
  no_combine_import:
    name: "No Combine"
    regex: "import Combine"
    message: "Do not use Combine. Use async/await instead."
    severity: error
```

### Key rules to encode:
- Banned imports (wrong framework, deprecated libraries)
- File length limits
- Function length limits
- Project-specific patterns

---

## Quick Start Checklist

For a new repo, do these in order:

- [ ] Audit existing CLAUDE.md (or create one) — identify what's essential vs deep
- [ ] Create `docs/` directory
- [ ] Move deep content into topic files
- [ ] Rewrite CLAUDE.md as a short index
- [ ] Add subdirectory CLAUDE.md files for each major package
- [ ] Write `docs/design-docs/core-beliefs.md` (5-10 principles)
- [ ] Set up execution plan structure
- [ ] Write `docs/golden-principles.md` with GC cadence
- [ ] Generate `docs/generated/db-schema.md` (or equivalent)
- [ ] Write 2-3 LLM-readable reference docs for your key dependencies
- [ ] Add lint rules with agent-friendly messages
- [ ] Create `docs/quality-grades.md`

**Total time for an existing codebase: ~3 hours**
**Total time for a new project: ~1-2 hours** (less content to split)

---

## Tips

- **Don't over-document**: If a doc file is <10 lines, merge it into a neighbor
- **Keep CLAUDE.md stable**: It should change rarely. Deep docs change more often
- **Test with an agent**: After setup, ask Claude Code a task and see if it finds the right docs
- **GC monthly**: Stale docs are worse than no docs. Run the gardening checklist
- **Reference docs are curated, not comprehensive**: Only document what your project actually uses
