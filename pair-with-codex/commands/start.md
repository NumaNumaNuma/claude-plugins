---
description: Start the full pair-with-codex flow — brainstorm, spec, Codex implement, cleanup, review loop, done
argument-hint: "[--auto] [--allow-dirty] [--max-review-rounds N] [--new-branch [name]] [--new-worktree] [--implement-existing-spec <path>] \"task description\""
allowed-tools: Bash, Edit, Write, Read, Glob, Grep, Skill
---

Invoke the `pair-with-codex-flow` skill with this command as the entry point and the following raw arguments:

ENTRY_POINT: start
RAW_ARGUMENTS: $ARGUMENTS

The skill parses flags and the task description from RAW_ARGUMENTS and orchestrates the full flow per `docs/superpowers/specs/2026-04-13-pair-with-codex-design.md` in the pair-with-codex plugin repo.

If the user did not supply a task description (RAW_ARGUMENTS is empty or contains only flags), the skill must ask for one before proceeding.
