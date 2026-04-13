---
description: Abort the current pair-with-codex session — clears session state, leaves git commits alone
allowed-tools: Bash, Read, Skill
---

Invoke the `pair-with-codex-flow` skill with this command as the entry point:

ENTRY_POINT: abort
RAW_ARGUMENTS: $ARGUMENTS

The skill clears the session state file for the current repo and prints a summary of what was left behind. Does not touch git.
