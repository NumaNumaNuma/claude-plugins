# Dream Team Plugin

Multi-agent collaborative workflow for planning, implementing, and reviewing features.

## When to Activate

When the user says "dream team" (e.g., "dream team review this", "dream team plan this feature", "dream team implement X"), activate the Dream Team workflow. Use the corresponding `/dream-plan`, `/dream-implement`, or `/dream-review` command.

- **"dream team review X"** — Run `/dream-review`
- **"dream team plan X"** — Run `/dream-plan`
- **"dream team implement X"** — If an existing plan (sprint, phase, exec-plan) is referenced, skip planning and run `/dream-implement`. If no plan exists, run `/dream-plan` first, get approval, then `/dream-implement`.

## Agent Selection Strategy

The team has 6 core agents + the `/simplify` skill for code quality:

| Dream Team Role | Preferred Agent | Fallback |
|---|---|---|
| Code Architect | `feature-dev:code-architect` | `general-purpose` with architect prompt |
| Code Quality Engineer | `feature-dev:code-reviewer` | `general-purpose` with quality prompt |
| Performance Analyst | `feature-dev:code-explorer` | `general-purpose` with performance prompt |
| Security Reviewer | `pr-review-toolkit:silent-failure-hunter` | `general-purpose` with security prompt |

The remaining 3 are always `general-purpose`: UI/UX Designer, Devil's Advocate, Test Engineer. Database Architect is an optional `general-purpose` agent included when needed.

**Code Quality Engineer is planning-only.** During implementation and review, the `/simplify` skill replaces it — `/simplify` auto-fixes reuse, quality, and efficiency issues in changed code, which is more effective than review-only feedback.

**Test Engineer** is included in planning (coverage strategy) and implementation (writes tests). During review, the built-in `pr-review-toolkit:pr-test-analyzer` handles test coverage analysis instead.

**On-demand built-in agents** (not part of the core team, invoked when relevant):
- `pr-review-toolkit:type-design-analyzer` — type/model design review
- `pr-review-toolkit:comment-analyzer` — comment accuracy review
- `pr-review-toolkit:pr-test-analyzer` — test coverage analysis (used in review phase)

If a preferred agent type returns an error about an unknown agent type, retry with `general-purpose` using the specialist prompt from the command file.

## Pre-Commit Documentation Rule

**Before any `git commit` or `git push`, always run `/lean-docs` first.** This is non-negotiable — even if the user forgets and says "commit this" or "push it", run the docs pass before executing the git command. This ensures documentation always reflects the final state of the code, including edge cases and gotchas discovered during review fixes.

## Context Budget Rules

- **Run agents in background** (`run_in_background: true`) when possible — read results with the Read tool instead of waiting
- **Summarize, don't relay** — Synthesize findings into a single concise summary. Never paste raw agent output
- **Skip agents that aren't relevant** — A pure DB migration doesn't need UI/UX or Performance
- **Resume, don't re-launch** — Use the `resume` parameter to continue an agent's work

## Sprint Rules

- **NEVER cut, skip, or defer tasks.** Every task in tasks.md is committed scope. Complete all of them.
- **TDD for bug fixes**: Write a failing test first, then fix. If the bug can't be reproduced as a test (visual, gesture-based), note why and apply best-effort fix.
- **Sensible tests only**: Focus on happy path, critical edge cases, and failure modes. Quality over quantity.
- **Checkpoint after EACH task**: Update progress.md + tasks.md so progress survives crashes, then continue to next task.
- **Bug Fix Phase**: Always included in tasks.md. Added after manual device testing. The runner completes all bugs before setting phase to done.
- **NEVER mark a task as done if the build is broken or tests are failing.**
- **Session continuity**: Plans and progress files must be self-contained enough that a fresh session can resume by reading progress.md first.

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
