# Sprint Rules

These are the operating principles for Dream Team sprints. Where something is a true bright line (won't-bend rule), it's marked that way. Everything else is a principle that the model should apply with judgment.

## Planning

- **Plans live in `planning/sprints/sprint-N-name/`.** Sessions don't share memory, so durable plans are how work survives session boundaries. A plan that isn't written down is a plan that gets relearned three times.
- **Write `test-plan.md` during planning, not later.** If the sprint has testable features, cover unit, integration, edge cases, and manual QA during planning. Deferring test planning to implementation is how you get features that ship untested.
- **Always include a Bug Fix Phase in `tasks.md`.** Leave it empty at planning time — manual testing will fill it in. The phase exists because features always have bugs; pretending otherwise leads to ad-hoc fix sprints later.

## Implementation

- **TDD for bug fixes.** A failing test comes before the fix so you know the test actually exercises the bug. If the bug can't be reproduced as a test (visual, gesture-based, device-specific), document why in the progress log and apply a best-effort fix — the next manual QA round is your safety net.
- **Test for signal, not coverage.** Write tests for happy path, critical edges, and failure modes. Excessive unit tests are costume, not pizza — they cost maintenance and don't catch bugs proportional to their count.
- **Every task in `tasks.md` is committed scope (bright line).** If scope genuinely needs to change, talk to the user — don't silently cut, skip, or defer. The list is the contract.
- **Don't mark a task done with a broken build or failing tests (bright line).** "Done" means the code works. A green checkbox over red tests is worse than an unchecked one.
- **Large refactors are a blocker, not a sub-task.** If a proper fix requires touching many files or changing architecture, set `phase: blocked`, describe the refactor, and let the user decide. The sprint's job isn't to smuggle in rewrites.

## Progress Tracking

- **Checkpoint after every task.** Update `progress.md` (CHECKPOINT block + timestamped log entry) and check off `tasks.md`. This is how a crashed or ended session recovers — if the checkpoint is stale, recovery reads lies.
- **Checkpoints are a contract with the next session.** `active_task` / `next_step` / `files_modified` should be specific enough that a fresh Claude can pick up cold and know exactly what to do.
- **Start every session by reading `progress.md`.** The CHECKPOINT block is the single source of truth about where work stands.

## Completion

Before setting `phase: done`:

1. Run the full test suite.
2. Build the project.
3. Set `done` only if both pass.

When setting `done`, append a `## Manual Testing Checklist` section to the progress log listing everything that couldn't be verified automatically — device behaviour, multi-device sync, UI interactions, visual checks. Specific reproduction steps, not just feature names. This is the handoff to the human tester, and vague checklists generate vague bug reports.

## Session Behaviour

Work through as many tasks as you can per session. Stop only when a full phase finishes, the sprint completes, or you hit a genuine blocker. Stopping after one task wastes the session's warm context and drags out simple sprints into week-long affairs.
