---
description: "Autonomous sprint execution with checkpoint-based progress tracking. Use when the user wants unattended/overnight sprint runs, mentions the sprint runner, wants to resume an existing sprint autonomously, or asks to 'keep going' through a sprint that has a planning/sprints/sprint-N directory."
---

# Sprint Runner

The sprint runner (`scripts/run-task.sh`) enables autonomous execution of sprint tasks. It reads the checkpoint from `progress.md`, launches Claude with fresh context each iteration, and loops until the sprint is complete or blocked.

## How it works

The runner exists because long sprints blow out the context window. The loop keeps each iteration cheap and stateless — all persistent state lives in files:

1. **Checkpoint loop** — each iteration reads the `<!-- CHECKPOINT -->` block from `progress.md` to know current state.
2. **Fresh context** — Claude gets a new session per iteration, loaded only with the sprint files. This prevents context exhaustion on multi-day sprints.
3. **Progress tracking** — after each task, the agent updates `progress.md` (checkpoint + log) and `tasks.md` (checkboxes).
4. **Completion detection** — runner stops when `phase: done` or `phase: blocked`.
5. **Failure recovery** — if Claude exits with an error, the runner retries (up to 3 consecutive failures).

## Setup

### 1. Create the sprint directory

```bash
SPRINT_DIR=planning/sprints/sprint-N-name
mkdir -p $SPRINT_DIR
```

### 2. Create sprint files from templates

Copy from this plugin's `templates/` directory:
- `plan.md` — architecture decisions, phases, risks
- `tasks.md` — task checklist with status tracking
- `progress.md` — checkpoint block + progress log

### 3. Fill in the plan

Complete `plan.md` with architecture decisions and phases. Fill `tasks.md` with all implementation tasks. Initialise `progress.md` with the first checkpoint.

### 4. Run

```bash
./scripts/run-task.sh planning/sprints/sprint-N-name
```

## Writing good checkpoints

The checkpoint is the only state that persists between runner iterations. It's a contract with the next iteration's fresh Claude — write it like that Claude is reading it cold.

```markdown
<!-- CHECKPOINT
sprint: 5
sprint_name: dark-mode
active_task: "Implement theme provider service"
phase: implementing
last_completed: "Created ThemeConfig model with color palette and font definitions"
next_step: "Create ThemeProvider service with system preference detection and manual toggle"
blockers: none
files_modified: src/models/ThemeConfig.ts
-->
```

- `active_task` — exact task name from `tasks.md`.
- `next_step` — specific enough that a fresh session can start immediately without guessing. "Keep working" is not a next step.
- `files_modified` — every file touched in the current session so the next iteration knows what to read.

## Bug Fix Phase

When the active task is a bug, the runner follows TDD:

1. Write a failing test that reproduces the bug.
2. Implement the fix.
3. Verify the test passes.
4. If the bug can't be expressed as an automated test (visual, gesture, device-specific), document why and apply a best-effort fix — the next manual QA round is the safety net.

## Common issues

- **Runner stops after one task** — `next_step` in the checkpoint is too vague. Be specific about the next concrete action.
- **Runner loops on the same task** — the checkpoint isn't being updated. Check file permissions and that the agent has write access to `progress.md`.
- **Build failures cascade** — if a task breaks the build, checkpoint the failure and continue in the next iteration with fresh context. Trying to debug in the same broken session often makes it worse.
