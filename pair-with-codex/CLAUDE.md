# pair-with-codex

Plugin that orchestrates a Claude + Codex collaborative workflow.

## What it does

Routes a development task through a repeatable pipeline:

1. **Plan** — Claude runs `superpowers:brainstorming` + `superpowers:writing-plans` to produce a spec and implementation plan
2. **Implement** — Codex is invoked via `/codex:rescue --write --background` to implement per the spec
3. **Cleanup** — Claude runs the `simplify` skill and any detected project checks (lint, test, build) on the Codex diff
4. **Review loop** — `/codex:review` produces findings, Claude addresses them, loop up to 5 rounds or until clean
5. **Done** — archive state, write a summary

## Commands

- `/pair-with-codex:start "task"` — full flow
- `/pair-with-codex:polish` — quick-fix tail (skip planning, start from cleanup)
- `/pair-with-codex:resume` — continue a session after interruption
- `/pair-with-codex:status` — show current phase, commits, timing
- `/pair-with-codex:abort` — clear session state

## Modes

- **Hybrid (default):** pauses at each phase boundary for user confirmation
- **Autonomous (`--auto`):** runs the full flow unattended, stops on failure

## State

Per-repo session state lives in `~/.claude/pair-with-codex/sessions/<hash>.json`, keyed by the sha1 of `git rev-parse --show-toplevel`. Multiple repos run concurrently without contention.

## Dependencies

- `superpowers` plugin (brainstorming, writing-plans, simplify)
- `codex` plugin (codex:rescue, codex:review, codex:status)

See `docs/superpowers/specs/2026-04-13-pair-with-codex-design.md` in the plugin repo for the full design.
