# Runner Prompt Template

This template is read by `scripts/run-task.sh` and variables are substituted at runtime.
The shell script uses `envsubst` to replace `$VARIABLE` references with checkpoint values.

---

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
   a. If you wrote code: build it and fix any compile errors before moving on
   b. If tests exist for what you changed: run them and fix failures
   c. If the task has acceptance criteria: verify each one is met
   d. If you can't verify (e.g., needs device testing), note it in the progress log
4. After completing AND verifying a task, update these files:
   a. $TASKS_FILE — check off completed tasks ([x]), mark current as in-progress ([~])
   b. $PROGRESS_FILE — update the CHECKPOINT block (active_task, last_completed, next_step, files_modified) AND append a timestamped log entry
5. KEEP GOING — move on to the next task immediately. Do NOT exit after a single task.
   Continue working through tasks until you have completed an entire phase (or sub-phase).
   Checkpoint after each task so progress is saved, but keep working in the same session.
6. If you complete the entire sprint, do a FINAL VERIFICATION:
   a. Run the full test suite
   b. Build the app
   c. Only set phase to 'done' if everything passes
   d. If tests fail, set next_step to describe what needs fixing
7. If you hit a blocker you can't resolve, set phase to 'blocked' and describe the blocker
8. Only stop when you have finished a full phase, the sprint is done, or you are blocked

BUG FIX PHASE (when active_task contains 'Bug Fix' or 'BF-'):
For each bug, follow this TDD workflow:
1. REPRODUCE FIRST: Write a failing test that reproduces the bug. Run it and confirm it fails for the right reason.
2. FIX: Implement a proper, clean fix — not a minimal patch. Follow the same code quality standards as feature work.
   - If the proper fix requires a large refactor (touching many files or changing architecture), do NOT attempt it. Instead set phase to 'blocked' and describe what refactor is needed so the human can decide how to proceed.
3. VERIFY: Run the test again — only mark the bug as done when the test passes.
4. If the bug CANNOT be reproduced as an automated test (e.g., purely visual, gesture-based, or requires device interaction), note why in the progress log, apply your best-effort fix, and mark it. The next manual testing round will catch regressions.

IMPORTANT:
- Work through as many tasks as you can per session — do NOT stop after a single task
- Checkpoint after EACH task (update progress.md + tasks.md) so progress survives crashes, then continue to the next task
- Stop only when: you finish a full phase, the sprint is done, or you are blocked
- NEVER cut, skip, or defer tasks. Every task in tasks.md is committed scope. Complete all of them.
- NEVER mark a task as done ([x]) if the build is broken or tests are failing
- If a test fails, try to fix it. If you can't fix it after a solid attempt, checkpoint with next_step describing the failure and what you tried — a fresh context in the next iteration may help
- Keep files_modified accurate — list every file you created or modified this session

WHEN SETTING PHASE TO DONE:
Before setting phase to 'done', append a '## Manual Testing Checklist' section to the progress log. Scan tasks.md for ALL items that could not be verified automatically (device testing, multi-device sync, UI interactions, visual checks, etc.) and list them as a complete, actionable checklist. Include specific steps to reproduce, not just feature names. This is the handoff to the human tester.
