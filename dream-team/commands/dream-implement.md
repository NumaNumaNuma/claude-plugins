---
description: "Pick relevant Dream Team agents to collaboratively implement a feature"
argument-hint: "Feature to implement (e.g., 'sprint 5' or 'dark mode support')"
---

# Dream Implement: $ARGUMENTS

Implement this feature using the Dream Team methodology: quick architect-led scan, implement step-by-step, post-implementation specialist review, test verification, docs sweep. Goal: finished work that's been reviewed and documented, not just code that compiles.

## Step 0: Find the plan

Check for an existing sprint plan:
- If "$ARGUMENTS" references a sprint number, read `planning/sprints/sprint-N-*/progress.md` **first** — the CHECKPOINT block has the exact current state
- If "$ARGUMENTS" references a plan file, read it
- If no plan exists, stop and tell the user to run `/dream-plan` first

For a resumed sprint, `progress.md` is the source of truth for where you are. Reading the code first and inferring state is how you re-do work that's already done.

## Agent Selection

Read `references/agent-roster.md` for the roster. Implementation does **not** use Code Quality Engineer (`/simplify` in Phase 3 owns that). Implementation **does** use Test Engineer to write tests planned during planning.

State each agent inclusion/exclusion in one sentence before launching. For trivial changes, skip the whole workflow.

---

## Phase 1: Quick Architecture Scan

### 1. Launch architect + explorers in parallel
Before writing any code, launch the Code Architect and any exploration agents in a single turn with `run_in_background: true`. Each prompt includes:
- Feature description: "$ARGUMENTS"
- "Explore the codebase, read relevant CLAUDE.md + `docs/` files, produce a concise implementation blueprint: files to create/modify, in what order. No code — plan only. Report only findings, no preamble."

### 2. Synthesise into build order
Combine agent findings into a concrete ordered list of implementation steps. If specialists disagree on approach, resolve it yourself with a written tradeoff — don't leave ambiguity for your implementation self to rediscover.

---

## Phase 2: Implement

### 3. Build step by step
Execute the plan yourself — write the actual code, follow existing project patterns, match the style of neighbouring files. Standard build order:

1. Database changes (migrations, schema, functions)
2. Model / type changes
3. Service layer
4. View / UI
5. Wire it all together

After each major step, note briefly what was done.

### 4. Checkpoint after each task
Update `progress.md` (CHECKPOINT block + timestamped log entry) and check off completed items in `tasks.md`. The checkpoint is how a crashed or ended session resumes cleanly — and how the autonomous runner knows what to do next. Skipping checkpoints is how work gets lost or re-done.

---

## Phase 3: Post-Implementation Review

### 5. Run `/simplify`
Before launching review agents, run `/simplify` on what you wrote. It fixes reuse, quality, and efficiency issues mechanically, so review agents focus on real problems instead of style.

### 6. Launch review agents in parallel
Spawn relevant review agents (Security Reviewer, Performance Analyst, Devil's Advocate) in a single turn with `run_in_background: true`. Each prompt includes:
- Feature description: "$ARGUMENTS"
- "Review recently modified files (use `git diff`) from your specialist perspective. Flag issues with severity, file path, line number. Review only — don't write code. Report only findings, no preamble."

### 7. Address findings
Fix flagged issues. When specialists disagree, make the call yourself and note the tradeoff in the progress log — don't leave a TODO for a later session to rediscover the debate.

---

## Phase 4: Test Verification

### 8. Run the existing test suite
Build the project and run tests using the project's build system. Failures caused by your changes get fixed before you move on — a passing checkbox on broken tests is worse than no checkbox.

### 9. Write planned tests
If the sprint plan includes a test plan, write those tests now.

---

## Phase 5: Documentation Sweep

This phase runs **after** review fixes and tests, not before. Review fixes surface edge cases, gotchas, and non-obvious behaviour — running docs before means documenting an intermediate state that'll rot within a day.

### 10. Run `/lean-docs`
Invoke `/lean-docs` to audit and update project documentation (`docs/`, subdirectory `CLAUDE.md` files, `docs/gotchas.md`). It'll identify stale or missing docs based on what changed.

### 11. Final summary
Present what was built, any tradeoffs made, and remaining open items. Update `progress.md` with the final state.

---

## Bug Fix Phase (active_task contains "Bug Fix" or "BF-")

For each bug, follow this TDD workflow:

1. **Reproduce first.** Write a failing test that reproduces the bug. Run it, confirm it fails for the right reason (not a typo in the test).
2. **Fix cleanly.** Implement a proper fix with the same quality bar as feature work — not a minimal patch.
   - If a proper fix needs a large refactor (many files, architecture change), set `phase: blocked`, describe the refactor needed, and let the user decide. The sprint's job isn't to smuggle in rewrites.
3. **Verify.** Re-run the test. Mark done only when it passes.
4. **Unverifiable bugs.** If the bug can't be reproduced as a test (visual, gesture-based, device-specific), note why in the progress log, apply a best-effort fix, mark it. The next manual QA round is the safety net.

## Sprint Rules

Read `references/sprint-rules.md` for the full sprint rules.
