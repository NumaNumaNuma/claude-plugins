# pair-with-codex

**Philosophy:** Claude plans and reviews, Codex writes the code. Loop until clean, then commit.

A Claude Code plugin that orchestrates a collaborative workflow between Claude and OpenAI Codex. You describe a task; Claude brainstorms the design and writes a spec; Codex implements it; Claude runs cleanup and simplify on the diff; Codex reviews; Claude addresses findings; loop until the review is clean; every phase gets its own commit so you can see exactly what happened.

## Two modes

- **Hybrid (default)** — pauses at each phase boundary so you can approve, reject, or redirect. Good when you're learning the flow or working on something you care about.
- **Autonomous (`--auto`)** — no pauses, no prompts. Kick it off and walk away. Stops on failure, writes a `last-run-summary.md` on success. Meant for overnight runs where you wake up to the work done.

## Commands

| Command | What it does |
|---|---|
| `/pair-with-codex:start "task"` | Full flow: brainstorm → spec → approval gate → Codex implement → cleanup → review loop → done |
| `/pair-with-codex:polish` | Quick-fix tail. Works on changes already in your working tree. Skips planning, runs cleanup + review loop. |
| `/pair-with-codex:resume` | Continue an interrupted session from the last persisted phase. Survives terminal restarts. |
| `/pair-with-codex:status` | Read-only. Shows current phase, commits made, Codex job status, elapsed time. |
| `/pair-with-codex:abort` | Clear session state. Does not touch git — any commits already made stay on the branch. |

## Flags for `/pair-with-codex:start`

- `--auto` — autonomous mode (no pause gates)
- `--allow-dirty` — don't refuse on a dirty working tree
- `--max-review-rounds N` — override the default of 5
- `--new-branch [name]` — opt in to branch creation (auto-names from task if omitted)
- `--new-worktree` — opt in to worktree creation (implies `--new-branch`)
- `--implement-existing-spec <path>` — skip brainstorming, jump straight to Codex implement using the given file (works for superpowers plans, specs, or any implementation guide)

You can also trigger the flow in natural conversation: "pair with codex on adding JWT auth, run it overnight on a new branch" — the skill infers flags from the wording.

## How it works

Each phase gets its own commit so history is auditable:

```
spec: add JWT auth
implement: add JWT auth
cleanup: add JWT auth
review 1: address auth edge cases
review 2: fix token rotation bug
```

By default the flow stays on your current branch (no auto-branching). The working tree must be clean at preflight unless you pass `--allow-dirty`. Multiple concurrent runs on different repos work fine — session state is keyed by a hash of the git root path, so nothing contends.

Session state lives at `~/.claude/pair-with-codex/sessions/<hash>.json`. On completion, it's archived to `~/.claude/pair-with-codex/sessions/archive/` alongside a `last-run-summary.md`.

## Review loop termination

The review loop stops when:
1. Codex's review returns no actionable findings (**clean**), OR
2. It hits `--max-review-rounds` (default 5), OR
3. In hybrid mode, you say stop at the between-rounds gate.

Codex's findings include pre-existing simple/isolated fixes — not just new code. The loop only skips findings that would require a large refactor.

## Dependencies

Requires two other plugins:

- **`superpowers`** — provides `brainstorming`, `writing-plans`, and `simplify` skills
- **`codex`** (OpenAI Codex plugin) — provides `/codex:rescue`, `/codex:review`, `/codex:status`

You also need to run `/codex:setup` once to authenticate Codex before the first `pair-with-codex` run.

## Install

See the [main README](../README.md) for marketplace install instructions. Short version:

```
/plugin marketplace add NumaNumaNuma/claude-plugins
/plugin install pair-with-codex@numa-plugins
```

Then `/reload-plugins` and the `/pair-with-codex:*` commands will be available.

## Design spec

Full design doc lives at [`docs/superpowers/specs/2026-04-13-pair-with-codex-design.md`](../docs/superpowers/specs/2026-04-13-pair-with-codex-design.md) in this repo. Read it if you want the deep dive on phase flow, error handling, and edge cases.

## Testing

Smoke tests (manual walkthroughs, not automated) live in `testing/smoke/`. Start with `happy-path.md` on a toy repo:

```bash
./testing/setup-toy-repo.sh /tmp/toy
cd /tmp/toy
# then run /pair-with-codex:start "..." in Claude Code
```
