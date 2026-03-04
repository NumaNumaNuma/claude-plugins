# Sprint Rules

These rules are non-negotiable for all Dream Team sprints.

## Planning Rules

- **Record plans in `planning/` folder**: All development plans, task breakdowns, and test plans MUST be saved to `planning/sprints/sprint-N-name/` so work can be continued across multiple sessions.
- **Test plan during planning**: If the sprint includes testable features, create `test-plan.md` in the sprint directory during planning. Include unit tests, integration tests, edge cases, and manual QA checklist. Never defer test planning to implementation.
- **Bug Fix Phase**: Always include in tasks.md. Left empty until manual testing finds bugs.

## Implementation Rules

- **TDD for bug fixes**: Write a failing test first, then fix. If the bug can't be reproduced as a test (visual, gesture-based, device interaction), note why in the progress log and apply best-effort fix.
- **Sensible tests only**: Do NOT write excessive unit tests. Focus on core scenarios: happy path, critical edge cases, and failure modes. Quality over quantity.
- **NEVER cut, skip, or defer tasks.** Every task in tasks.md is committed scope. Complete all of them.
- **NEVER mark a task as done ([x]) if the build is broken or tests are failing.**
- **Large refactors**: If a proper fix requires a large refactor (touching many files or changing architecture), do NOT attempt it. Set phase to 'blocked' and describe what refactor is needed so the human can decide.

## Progress Tracking Rules

- **Track progress at every milestone**: After each task, update `progress.md` with:
  - Updated CHECKPOINT block (active_task, last_completed, next_step, files_modified)
  - Timestamped entry in the Progress Log
  - Updated checkboxes in tasks.md
- **Session continuity**: Plans and progress files must be self-contained enough that a fresh session can pick up where the previous one left off by reading `progress.md` first.
- **When starting a sprint**: ALWAYS read `progress.md` before doing anything else.

## Completion Rules

- **Final verification**: Before setting phase to 'done':
  1. Run the full test suite
  2. Build the project
  3. Only set done if everything passes
- **Manual testing checklist**: When setting phase to 'done', append a '## Manual Testing Checklist' section listing all items that need human verification.
- **Keep going**: Work through as many tasks as you can per session. Do NOT stop after a single task. Stop only when you finish a full phase, the sprint is done, or you are blocked.
