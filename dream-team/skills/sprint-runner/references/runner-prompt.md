# Runner Prompt Template

This template is read by `scripts/run-task.sh` and variables are substituted at runtime using `envsubst` — each `$VARIABLE` gets replaced with checkpoint values before the prompt reaches Claude.

---

You are continuing work on **Sprint $SPRINT_NUM ($SPRINT_NAME)**.

Read these files first — they are the complete context for this iteration:

- **$PLAN_FILE** — sprint plan with approach and phases
- **$TASKS_FILE** — task checklist; check items off as you complete them
- **$PROGRESS_FILE** — checkpoint and progress log

## Current state (from checkpoint)

- **Active task**: $ACTIVE_TASK
- **Last completed**: $LAST_COMPLETED
- **Next step**: $NEXT_STEP
- **Blockers**: $BLOCKERS

## What to do

1. Read the plan + tasks files to understand the full context. Don't skim — the plan encodes decisions you'll need.
2. Execute the `next_step` above.
3. **Verify your work before marking it done.** Evidence before assertions:
   - Wrote code? Build it. Fix compile errors before moving on.
   - Tests cover what you changed? Run them. Fix failures.
   - Task has acceptance criteria? Verify each.
   - Can't verify (needs device/manual testing)? Note it in the progress log so the next iteration or human tester knows.
4. Update state files:
   - **$TASKS_FILE** — check off completed tasks (`[x]`), mark current in-progress (`[~]`).
   - **$PROGRESS_FILE** — update the CHECKPOINT block (`active_task`, `last_completed`, `next_step`, `files_modified`) and append a timestamped log entry.
5. **Keep going.** Move on to the next task immediately. Do not exit after a single task — the session's warm context is expensive to rebuild, and sprints stall if each iteration only ships one task. Continue until you finish a full phase (or sub-phase), the sprint is done, or you are genuinely blocked.
6. **At sprint completion**, do a final verification pass:
   - Run the full test suite
   - Build the app
   - Set `phase: done` only if both pass
   - If tests fail, set `phase: implementing` and make `next_step` describe what needs fixing
7. **If blocked**, set `phase: blocked` and describe the blocker concretely enough that a human reading it can decide what to do.

## Bug Fix Phase (active_task contains "Bug Fix" or "BF-")

For each bug, TDD workflow:

1. **Reproduce first.** Write a failing test that reproduces the bug. Run it, confirm it fails for the right reason — not a test-level typo.
2. **Fix cleanly.** Same quality standards as feature work, not a minimal patch.
   - If a proper fix requires a large refactor (many files, architecture change), don't attempt it. Set `phase: blocked` and describe what refactor is needed. The sprint's job isn't to smuggle in rewrites.
3. **Verify.** Re-run the test. Mark done only when it passes.
4. **Unverifiable bugs.** If the bug can't be reproduced as an automated test (visual, gesture-based, device interaction), note why in the progress log, apply a best-effort fix, mark it. Manual QA is the safety net.

## Bright lines (the rules that never bend)

- **Every task in `tasks.md` is committed scope.** Don't silently cut, skip, or defer. If scope genuinely needs to change, block on it.
- **Never mark a task done (`[x]`) with a broken build or failing tests.** A green checkbox over red tests trains the next iteration to trust lies.
- **Checkpoint after every task.** This is how the runner knows where to resume; it's also how crashed sessions recover without losing work.
- **Keep `files_modified` accurate.** Every file created or modified this session. The next iteration reads this to know what to look at.

## When setting phase to done

Before flipping `phase: done`, append a `## Manual Testing Checklist` section to the progress log. Scan `tasks.md` for everything that couldn't be verified automatically — device testing, multi-device sync, UI interactions, visual checks — and list them with specific reproduction steps. Feature names alone generate vague bug reports; steps generate actionable ones. This is the handoff to the human tester.
