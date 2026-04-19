---
description: "Set up or audit agent-legible documentation for the current project"
argument-hint: "Optional: 'audit' to check existing docs, or blank for guided setup"
---

# Lean Docs: $ARGUMENTS

Set up (or audit) agent-legible documentation for this project using the Lean Docs methodology — a slim root `CLAUDE.md` index, deep topic files in `docs/`, directory-specific rules in subdirectory `CLAUDE.md` files.

## Mode Selection

- "$ARGUMENTS" empty or "setup" → run **Setup**
- "$ARGUMENTS" says "audit" → run **Audit**
- "$ARGUMENTS" mentions a specific step (e.g. "step 3", "subdirectory claude.md files") → jump to that step

Read the full playbook from `skills/lean-docs/SKILL.md` for detailed guidance. Use the templates from `skills/lean-docs/references/` when creating files.

## Setup Workflow

Work through the 9 steps from the playbook in order. For each step:

1. Check what already exists in the project (`Read`, `Glob` — don't assume).
2. Show the user what you'd create or change, and why.
3. Get approval before writing files.
4. Move to the next step.

After setup, suggest the user tests it:

> Ask Claude Code a task and see if it finds the right docs without being told where to look.

That's the real measure of whether the hierarchy works.

## Audit Workflow

Follow the "Audit Workflow" section in `skills/lean-docs/SKILL.md`. Use the concrete `Glob` / `Read` checks listed there for each step, then present results as a table and offer to fix gaps. Don't audit by impression — concrete checks avoid the "it looks fine" failure mode.
