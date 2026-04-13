---
description: Resume an interrupted pair-with-codex session from the last persisted phase
allowed-tools: Bash, Edit, Write, Read, Glob, Grep, Skill
---

Invoke the `pair-with-codex-flow` skill with this command as the entry point:

ENTRY_POINT: resume
RAW_ARGUMENTS: $ARGUMENTS

The skill reads session state for the current repo, prints the last known phase and recent commits, reattaches to any running Codex job via `/codex:status`, and continues the flow from that phase.
