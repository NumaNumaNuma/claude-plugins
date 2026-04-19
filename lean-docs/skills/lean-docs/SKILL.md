---
description: "Agent-legible documentation setup and auditing for any codebase. Use whenever the user asks to set up docs, audit docs, create or slim down CLAUDE.md, organise documentation, mentions 'lean docs' or 'doc hierarchy', or when documentation is clearly missing/disorganised in a project being worked on — even if the user hasn't explicitly asked for a docs pass."
---

# Lean Docs Playbook

A step-by-step guide for making any codebase agent-legible. The core idea: agents work much better with a short, stable entry point (~100 lines) that links to deeper docs on demand. Think table of contents, not encyclopedia. Every byte in the root `CLAUDE.md` is loaded by every task — so the root pays context tax on work it's not relevant to.

---

## Step 1: Slim down `CLAUDE.md`

The root `CLAUDE.md` holds only what *every* task needs:

- Build / test / lint commands
- Package manager commands
- Connection strings and credentials location (not secrets themselves)
- Key rules (indent style, language version, framework constraints)
- **Docs index table** pointing to everything else

Everything else moves to `docs/`. Target **80–120 lines**.

See `references/claude-md-template.md` for the full template.

---

## Step 2: Create domain docs under `docs/`

Split your old `CLAUDE.md` content into topic files. A common set:

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

**Rule of thumb**: if a section is over ~15 lines and only relevant to some tasks, it belongs in a topic file.

---

## Step 3: Subdirectory `CLAUDE.md` files

Create a `CLAUDE.md` in each major package/directory with rules specific to that code. Claude Code uses the **closest** `CLAUDE.md`, so these override or supplement the root — which keeps the root lean.

**Examples:**

```
src/services/CLAUDE.md    -> "No UI imports, pure business logic, use async/await"
src/components/CLAUDE.md  -> "All components need stories, 44pt touch targets"
src/models/CLAUDE.md      -> "Never use auto key decoding, always explicit mapping"
src/utils/CLAUDE.md       -> "Pure functions only, no side effects, document edge cases"
```

Keep each one **10–30 lines**. Focus on:
- What NOT to do (common mistakes in this directory)
- Patterns to follow (with 2–3 line examples)
- Key files and what they do

---

## Step 4: Design docs and core beliefs

```
docs/design-docs/
  index.md          -> List of design docs with status
  core-beliefs.md   -> 5-10 operating principles (the "why" behind your rules)
```

See `references/core-beliefs-template.md` for the template.

Example beliefs:
- "One concurrency model — a single async pattern reduces an entire class of bugs."
- "Optimistic updates first — show the result immediately, reconcile with server async."
- "Repo is the single source of knowledge — if it's not in-repo, it doesn't exist for agents."
- "Prefer boring technology — well-documented, stable APIs that agents can reason about."

---

## Step 5: Execution plans

```
docs/exec-plans/
  index.md       -> Links to active and completed plans
  template.md    -> Standard format for new plans
  active/        -> Plans currently in progress
  completed/     -> Archived plans (reference only)
```

See `references/exec-plan-template.md` for the template.

---

## Step 6: Golden principles and GC process

`docs/golden-principles.md` — mechanical rules that prevent codebase drift. The "always/never" rules, not the "why" (that's `core-beliefs.md`).

See `references/golden-principles-template.md` for the template.

Key sections:
- File organisation (max lines per file, one type per file)
- Naming & style (indent, naming conventions)
- Framework-specific rules (always/never for your stack)
- Doc Gardening (GC Cadence) — monthly checklist

---

## Step 7: Auto-generated docs

```
docs/generated/
  db-schema.md     -> Full schema dump (tables, columns, types, policies, triggers)
  api-routes.md    -> Auto-generated API route list (if applicable)
```

**For databases**: use your ORM's schema dump, query `information_schema`, or your provider's tools. Include columns with types/nullability/defaults, foreign keys, unique constraints, access policies, triggers, functions, indexes. Regenerate after each migration.

**For APIs**: generate from OpenAPI spec, route definitions, or framework introspection.

Why generated and not curated: these files are truth the codebase already knows, and regenerating is the only way to keep them from rotting.

---

## Step 8: LLM-readable reference docs

```
docs/references/
  [framework]-sdk.md       -> Key SDK patterns for your main framework
  [language]-patterns.md   -> Language-specific patterns and gotchas
```

These are **not** copies of official docs. They're curated, minimal references covering only what your project uses. Think "cheat sheet for an agent working on this codebase."

**Include:**
- Setup / init patterns
- CRUD operations with your actual model names as examples
- Auth patterns
- Real-time / WebSocket patterns (if applicable)
- Common gotchas specific to your usage
- **~200–300 lines per file** — enough to be useful, short enough to not bloat context

**Don't include:**
- Features you don't use
- Full API surface
- Tutorials or explanations

---

## Step 9: Taste invariants as lint rules

Encode your "taste" (code style preferences) as lint rules with **agent-friendly error messages**. The error message should tell the agent what to do instead of just what's wrong — an agent reading "don't use Combine" will spend tokens asking why; an agent reading "use async/await instead" already knows the path forward.

See `references/lint-examples.md` for examples across ESLint, Ruff, and SwiftLint.

Key rules to encode:
- Banned imports (wrong framework, deprecated libraries)
- File length limits
- Function length limits
- Project-specific patterns

---

## Audit Workflow

When auditing existing docs (`/lean-docs audit`), scan the project against the 9-step checklist using the concrete checks below — not vague impressions. Present results as a table and offer to fix gaps.

### How to check

Use these commands:
- `Read CLAUDE.md` and count lines — under 120?
- `Glob "docs/**/*.md"` to find existing topic files — any over 400 lines that need splitting?
- `Glob "**/CLAUDE.md"` to find subdirectory `CLAUDE.md` files — are major packages covered?
- `Glob "docs/generated/*"` for auto-generated content
- `Glob ".swiftlint.yml" or ".eslintrc*" or "ruff.toml"` for lint config

### The checklist

1. `CLAUDE.md` under 120 lines with a docs index
2. `docs/` topic files exist, none over 400 lines
3. Subdirectory `CLAUDE.md` files in major packages
4. `docs/design-docs/core-beliefs.md`
5. Execution plan structure
6. `docs/golden-principles.md` with GC cadence
7. `docs/generated/` with auto-generated content
8. `docs/references/` with curated SDK docs
9. Lint config with custom rules and agent-friendly messages

Present results:

| Step | Status | Notes |
|------|--------|-------|
| 1. CLAUDE.md | Pass / Needs work | [details] |
| ... | ... | ... |

Then offer to fix any gaps.

---

## Quick Start Checklist

For a new repo, in order:

- [ ] Audit existing `CLAUDE.md` (or create one) — identify essential vs deep
- [ ] Create `docs/` directory
- [ ] Move deep content into topic files
- [ ] Rewrite `CLAUDE.md` as a short index
- [ ] Add subdirectory `CLAUDE.md` files for each major package
- [ ] Write `docs/design-docs/core-beliefs.md` (5–10 principles)
- [ ] Set up execution plan structure
- [ ] Write `docs/golden-principles.md` with GC cadence
- [ ] Generate `docs/generated/db-schema.md` (or equivalent)
- [ ] Write 2–3 LLM-readable reference docs for your key dependencies
- [ ] Add lint rules with agent-friendly messages
- [ ] Create `docs/quality-grades.md`

---

## Tips

- **Don't over-document.** A `docs/` file under 10 lines merges into a neighbour.
- **`CLAUDE.md` should change rarely.** If you're editing it often, you're probably adding content that should live deeper.
- **Test with an agent.** After setup, ask Claude Code a task and see if it finds the right docs without being told where to look. That's the real measure of whether the hierarchy works.
- **GC monthly.** Stale docs are worse than no docs — they actively mislead. Run the gardening checklist.
- **Reference docs are curated, not comprehensive.** Only document what the project actually uses.
