# Runner Prompt Template

This is the prompt template used by `scripts/run-task.sh` to invoke Claude on each iteration. The variables (`$SPRINT_NUM`, `$ACTIVE_TASK`, etc.) are extracted from the checkpoint in `progress.md`.

```
You are continuing work on Sprint $SPRINT_NUM ($SPRINT_NAME).

Read these files to understand the full context:
- $PLAN_FILE (sprint plan with approach and phases)
- $TASKS_FILE (task checklist — update checkboxes as you complete work)
- $PROGRESS_FILE (checkpoint and progress log)

CURRENT STATE from checkpoint:
- Active task: $ACTIVE_TASK
- Last completed: $LAST_COMPLETED
- Next step: $NEXT_STEP
- Blockers: $BLOCKERS

YOUR INSTRUCTIONS:
1. Read the plan and tasks files to understand the full context
2. Execute the 'next_step' described above
3. VERIFY your work:
   a. If you wrote code: build it using the project's build system and fix any compile errors
   b. If tests exist for what you changed: run them and fix failures
   c. If the task has acceptance criteria: verify each one is met
   d. If you can't verify (e.g., needs device testing), note it in the progress log
4. After completing AND verifying a task, update these files:
   a. $TASKS_FILE — check off completed tasks ([x]), mark current as in-progress ([~])
   b. $PROGRESS_FILE — update the CHECKPOINT block and append a timestamped log entry
5. KEEP GOING — move on to the next task immediately. Do NOT exit after a single task.
   Continue working through tasks until you have completed an entire phase.
   Checkpoint after each task so progress is saved, but keep working in the same session.
6. If you complete the entire sprint, do a FINAL VERIFICATION:
   a. Run the full test suite
   b. Build the project
   c. Only set phase to 'done' if everything passes
   d. If tests fail, set next_step to describe what needs fixing
7. If you hit a blocker you can't resolve, set phase to 'blocked' and describe the blocker
8. Only stop when you have finished a full phase, the sprint is done, or you are blocked

BUG FIX PHASE (when active_task contains 'Bug Fix' or 'BF-'):
For each bug, follow this TDD workflow:
1. REPRODUCE FIRST: Write a failing test that reproduces the bug
2. FIX: Implement a proper, clean fix — not a minimal patch
3. VERIFY: Run the test again — only mark done when it passes
4. If the bug CANNOT be reproduced as a test, note why and apply best-effort fix

IMPORTANT:
- Work through as many tasks as you can per session
- Checkpoint after EACH task so progress survives crashes
- NEVER cut, skip, or defer tasks
- NEVER mark a task as done if the build is broken or tests are failing

WHEN SETTING PHASE TO DONE:
Append a '## Manual Testing Checklist' section to the progress log. List ALL items that
could not be verified automatically (device testing, multi-device sync, UI interactions,
visual checks, etc.) as a complete, actionable checklist with specific steps to reproduce.
```
