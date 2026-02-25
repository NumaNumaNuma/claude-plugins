---
description: "Set up or audit agent-legible documentation for the current project"
argument-hint: "Optional: 'audit' to check existing docs, or blank for guided setup"
---

# Lean Docs: $ARGUMENTS

You are setting up (or auditing) agent-legible documentation for this project using the Lean Docs methodology.

## Mode Selection

- If "$ARGUMENTS" is empty or says "setup": run the **Setup** workflow below
- If "$ARGUMENTS" says "audit": run the **Audit** workflow below
- If "$ARGUMENTS" mentions a specific step (e.g., "step 3", "subdirectory claude.md files"): jump to that step

## Setup Workflow

Work through these steps in order. For each step:
1. Check what already exists in the project
2. Show the user what you'd create/change
3. Get approval before writing files
4. Move to the next step

Read the full playbook from `skills/lean-docs/SKILL.md` and the templates from `skills/lean-docs/references/` for detailed guidance on each step.

### The 9 Steps

1. **Slim down CLAUDE.md** — Audit the current CLAUDE.md (or create one). Move deep content to `docs/`. Target 80-120 lines with build commands, key rules, and a docs index table.

2. **Create domain docs** — Split extracted content into topic files in `docs/`. Common files: `architecture.md`, `database.md`, `api.md`, `testing.md`, `quality-grades.md`.

3. **Subdirectory CLAUDE.md files** — Create 10-30 line CLAUDE.md files in major packages/directories with rules specific to that code (what NOT to do, patterns to follow, key files).

4. **Design docs & core beliefs** — Create `docs/design-docs/core-beliefs.md` with 5-10 operating principles that explain the "why" behind the project's rules.

5. **Execution plan structure** — Set up `docs/exec-plans/` with an index and template for tracking feature plans.

6. **Golden principles & GC** — Create `docs/golden-principles.md` with mechanical always/never rules and a monthly doc gardening checklist.

7. **Auto-generated docs** — Set up `docs/generated/` with auto-generated schema dumps, API route lists, or similar. Show how to regenerate.

8. **LLM-readable reference docs** — Create `docs/references/` with curated SDK/framework cheat sheets (200-300 lines each, only features the project uses).

9. **Lint rules as taste** — Identify project-specific "taste" rules and encode them as lint rules with agent-friendly error messages.

### After Setup

Present a summary of what was created and suggest the user tests it:
> Ask Claude Code a task and see if it finds the right docs without being told where to look.

## Audit Workflow

Scan the project against the 9-step checklist:

1. Read CLAUDE.md — is it under 120 lines? Does it have a docs index?
2. Check `docs/` — do topic files exist? Are any >400 lines (need splitting)?
3. Check for subdirectory CLAUDE.md files — are major packages covered?
4. Check for `docs/design-docs/core-beliefs.md`
5. Check for execution plan structure
6. Check for `docs/golden-principles.md` with GC cadence
7. Check for `docs/generated/` with auto-generated content
8. Check for `docs/references/` with curated SDK docs
9. Check for lint config with custom rules

Present results as a table:

| Step | Status | Notes |
|------|--------|-------|
| 1. CLAUDE.md | Pass/Needs work | [details] |
| ... | ... | ... |

Then offer to fix any gaps.
