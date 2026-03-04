---
description: "Set up or audit agent-legible documentation for the current project"
argument-hint: "Optional: 'audit' to check existing docs, or blank for guided setup"
---

# Lean Docs: $ARGUMENTS

You are setting up (or auditing) agent-legible documentation for this project using the Lean Docs methodology.

## Mode Selection

- If "$ARGUMENTS" is empty or says "setup": run the **Setup** workflow
- If "$ARGUMENTS" says "audit": run the **Audit** workflow
- If "$ARGUMENTS" mentions a specific step (e.g., "step 3", "subdirectory claude.md files"): jump to that step

Read the full playbook from `skills/lean-docs/SKILL.md` for detailed guidance. Use the templates from `skills/lean-docs/references/` when creating files.

## Setup Workflow

Work through the 9 steps from the SKILL.md playbook in order. For each step:
1. Check what already exists in the project
2. Show the user what you'd create/change
3. Get approval before writing files
4. Move to the next step

After setup, present a summary and suggest the user tests it:
> Ask Claude Code a task and see if it finds the right docs without being told where to look.

## Audit Workflow

Follow the "Audit Workflow" section in `skills/lean-docs/SKILL.md`. Use the concrete check steps (Glob, Read) to verify each item, then present results as a table and offer to fix gaps.
