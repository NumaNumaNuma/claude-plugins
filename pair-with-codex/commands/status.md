---
description: Show the current phase, commits, and Codex job status for the pair-with-codex session in this repo
allowed-tools: Bash, Read, Skill
---

Invoke the `pair-with-codex-flow` skill with this command as the entry point:

ENTRY_POINT: status
RAW_ARGUMENTS: $ARGUMENTS

The skill reads session state for the current repo and prints phase, task description, iteration count, commits made so far, Codex job status if applicable, and elapsed time. Read-only.
