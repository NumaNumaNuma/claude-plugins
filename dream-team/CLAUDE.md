# Dream Team Plugin

Multi-agent collaborative workflow for planning, implementing, and reviewing features. The core idea: spin up a team of specialists in parallel, synthesise their output, then act — rather than reasoning everything through a single stream.

## When to Activate

When the user says "dream team" (e.g. "dream team review this", "dream team plan X", "dream team implement Y"), route to the matching command:

- **"dream team review X"** → `/dream-review`
- **"dream team plan X"** → `/dream-plan`
- **"dream team implement X"** → If a plan already exists (sprint/phase/exec-plan is referenced or obvious), skip planning and run `/dream-implement`. Otherwise run `/dream-plan` first, get approval, then `/dream-implement`.

## Agent Selection Strategy

See `references/agent-roster.md` for the roster, fallback prompts, and per-phase inclusion criteria. A few rules that don't appear in the roster:

- **Code Quality Engineer is planning-only.** During implementation and review, `/simplify` replaces it — running a tool that actually fixes reuse/quality issues beats another layer of review prose.
- **Test Engineer**: plans coverage during planning, writes tests during implementation. During review, `pr-review-toolkit:pr-test-analyzer` handles coverage.
- **Devil's Advocate is always included.** Every team needs someone whose job is to push back.
- **Preferred agent failed?** Retry with `general-purpose` and the roster's fallback prompt. Don't drop the role.

## Parallelism

When launching multiple specialist agents, spawn them in a single turn with `run_in_background: true`. Parallel launches are both faster and give you cleaner synthesis — you read their outputs only when you need them instead of waiting on each sequentially. The one exception is when a later agent genuinely depends on an earlier one's output.

## Pre-Commit Documentation Rule

Before any `git commit` or `git push`, run `/lean-docs` first — even if the user said "commit this" or "push it". The reason: review fixes and late implementation discoveries are exactly when edge cases, gotchas, and non-obvious behaviour surface. Running `/lean-docs` before commit captures that knowledge while it's fresh rather than losing it to the next session.

## Context Budget Rules

- **Background agents, then read** — spawn with `run_in_background: true`, check results with Read. Keeps the main context clean.
- **Synthesise, don't relay** — combine agent findings into a concise unified summary. Never paste raw agent output into the user-facing response.
- **Skip irrelevant agents** — a pure DB migration doesn't need UI/UX or Performance. Be decisive about exclusions.
- **Resume, don't re-launch** — use `resume` to continue an agent's work rather than starting fresh.

## Sprint Rules

See `references/sprint-rules.md` for the full sprint rules (planning, implementation, progress tracking, completion).

## Sprint Directory Structure

```
planning/sprints/sprint-N-name/
├── plan.md        — Architecture decisions, phases, risks
├── tasks.md       — Checklist with status tracking
├── progress.md    — Checkpoint block + progress log
├── test-plan.md   — What to test (created during planning)
└── runner-logs/   — Autonomous runner iteration logs
```

## Progress Checkpoint Format

```markdown
<!-- CHECKPOINT
sprint: N
sprint_name: name
active_task: "Current task description"
phase: implementing | blocked | done
last_completed: "What was just finished"
next_step: "Exact next action to take"
blockers: none | "Description of blocker"
files_modified: src/services/auth.ts, src/models/user.ts
-->
```

Update the checkpoint after each task or subtask. Append a timestamped entry to the Progress Log. The checkpoint is the single source of state between runner iterations — treat it as a contract with future-you.
