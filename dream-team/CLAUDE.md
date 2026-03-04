# Dream Team Plugin

Multi-agent collaborative workflow for planning, implementing, and reviewing features.

## When to Activate

When the user says "dream team" (e.g., "dream team review this", "dream team plan this feature", "dream team implement X"), activate the Dream Team workflow. Use the corresponding `/dream-plan`, `/dream-implement`, or `/dream-review` command.

- **"dream team review X"** — Run `/dream-review`
- **"dream team plan X"** — Run `/dream-plan`
- **"dream team implement X"** — If an existing plan (sprint, phase, exec-plan) is referenced, skip planning and run `/dream-implement`. If no plan exists, run `/dream-plan` first, get approval, then `/dream-implement`.

## Agent Selection Strategy

See `references/agent-roster.md` for the full roster with preferred agents, fallback prompts, and inclusion criteria per phase. Key rules:

- **Code Quality Engineer is planning-only** — `/simplify` replaces it during implementation and review
- **Test Engineer**: planning (coverage strategy) + implementation (writes tests). During review, `pr-review-toolkit:pr-test-analyzer` handles coverage analysis
- **Devil's Advocate**: always included, non-negotiable
- If a preferred agent type returns an error, retry with `general-purpose` using the fallback prompt from the roster

## Pre-Commit Documentation Rule

**Before any `git commit` or `git push`, always run `/lean-docs` first.** This is non-negotiable — even if the user forgets and says "commit this" or "push it", run the docs pass before executing the git command. This ensures documentation always reflects the final state of the code, including edge cases and gotchas discovered during review fixes.

## Context Budget Rules

- **Run agents in background** (`run_in_background: true`) when possible — read results with the Read tool instead of waiting
- **Summarize, don't relay** — Synthesize findings into a single concise summary. Never paste raw agent output
- **Skip agents that aren't relevant** — A pure DB migration doesn't need UI/UX or Performance
- **Resume, don't re-launch** — Use the `resume` parameter to continue an agent's work

## Sprint Rules

See `references/sprint-rules.md` for the full non-negotiable sprint rules (planning, implementation, progress tracking, completion).

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

Update the checkpoint after completing each task or subtask. Append a timestamped entry to the Progress Log section.
