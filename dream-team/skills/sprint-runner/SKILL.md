---
description: "Autonomous sprint execution with checkpoint-based progress tracking"
---

# Sprint Runner

The sprint runner (`scripts/run-task.sh`) enables autonomous execution of sprint tasks. It reads the checkpoint from `progress.md`, launches Claude with fresh context each iteration, and loops until the sprint is complete or blocked.

## How It Works

1. **Checkpoint loop**: Each iteration reads the `<!-- CHECKPOINT -->` block from `progress.md` to determine current state
2. **Fresh context**: Claude gets a new session each iteration with only the sprint files as context — this prevents context window exhaustion on long sprints
3. **Progress tracking**: After each task, the agent updates `progress.md` (checkpoint + log) and `tasks.md` (checkboxes)
4. **Completion detection**: Runner stops when `phase: done` or `phase: blocked`
5. **Failure recovery**: If Claude exits with an error, the runner retries (up to 3 consecutive failures)

## Setup

### 1. Create sprint directory

```bash
SPRINT_DIR=planning/sprints/sprint-N-name
mkdir -p $SPRINT_DIR
```

### 2. Create sprint files from templates

Copy the templates from this plugin's `templates/` directory:
- `plan.md` — Architecture decisions, phases, risks
- `tasks.md` — Task checklist with status tracking
- `progress.md` — Checkpoint block + progress log

### 3. Fill in the plan

Complete `plan.md` with architecture decisions and phases. Fill in `tasks.md` with all implementation tasks. Initialize `progress.md` with the first checkpoint.

### 4. Run

```bash
./scripts/run-task.sh planning/sprints/sprint-N-name
```

## Writing Good Checkpoints

The checkpoint is the ONLY state that persists between runner iterations. Make it precise:

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

- `active_task`: Exact task name from tasks.md
- `next_step`: Specific enough that a fresh session can start immediately
- `files_modified`: Every file touched in the current session (helps the next iteration know what to read)

## Bug Fix Phase

The runner handles bug fixes with a TDD workflow:
1. Write a failing test that reproduces the bug
2. Implement the fix
3. Verify the test passes
4. If the bug can't be reproduced as a test, note why and apply best-effort fix

## Common Issues

- **Runner stops after one task**: Check that `next_step` in the checkpoint points to the next task, not a vague description
- **Runner loops on same task**: The checkpoint isn't being updated — check file permissions and that the agent has write access
- **Build failures cascade**: If a task breaks the build, the runner should checkpoint with the failure and continue in the next iteration with fresh context
