---
description: Quick-fix tail — run cleanup and Codex review loop on existing working-tree changes, skipping planning and implementation
argument-hint: "[--auto] [--max-review-rounds N] [\"short description\"]"
allowed-tools: Bash, Edit, Write, Read, Glob, Grep, Skill
---

Invoke the `pair-with-codex-flow` skill with this command as the entry point and the following raw arguments:

ENTRY_POINT: polish
RAW_ARGUMENTS: $ARGUMENTS

The skill starts at Phase 4 (cleanup), inverts the dirty-tree check (requires a non-empty diff), skips phases 1–3, and then runs the review loop per the spec.
