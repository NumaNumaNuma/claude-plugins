---
description: "Pick relevant Dream Team agents to collaboratively implement a feature"
argument-hint: "Feature to implement (e.g., 'sprint 5' or 'dark mode support')"
---

# Dream Implement: $ARGUMENTS

You are implementing the feature described above using the Dream Team methodology, but with **selective agent activation** — only launch agents that are relevant to this specific feature.

## Step 0: Find the Plan

First, check if there's an existing sprint plan:
- If "$ARGUMENTS" references a sprint number, read `planning/sprints/sprint-N-*/progress.md` first (checkpoint has current state)
- If "$ARGUMENTS" references a plan file, read it
- If no plan exists, tell the user to run `/dream-plan` first

If resuming a sprint, read `progress.md` FIRST — the CHECKPOINT block has the exact current state.

## Agent Selection

Review the feature description and decide which of these agents to activate. **You must justify each inclusion/exclusion in a brief sentence before launching.**

### Core Team (select relevant ones)

1. **Code Architect** — **Almost always relevant.** Designs the implementation blueprint: files to create/modify, component boundaries, data flow, and build sequence. Skip only for trivial changes.
   - Use `feature-dev:code-architect` if available. If the Task tool returns an error about an unknown agent type, retry with `general-purpose` using this prompt: "You are a senior software architect. Design the implementation blueprint: files to create/modify, component boundaries, data flow, and build sequence. Read relevant existing code, docs, and CLAUDE.md files."

2. **Performance Analyst** — Relevant when the feature involves data fetching, list rendering, real-time updates, caching, or anything with scaling concerns.
   - Use `feature-dev:code-explorer` if available. Fallback prompt: "You are a performance analyst. Analyze the implementation for algorithmic complexity, memory usage, network calls, and bottlenecks."

3. **Security Reviewer** — Relevant when the feature involves auth, user data, API calls, user input, or permissions.
   - Use `pr-review-toolkit:silent-failure-hunter` if available. Fallback prompt: "You are a security reviewer. Check for OWASP top 10 vulnerabilities, auth issues, data exposure, silent failures, and inadequate error handling."

4. **UI/UX Designer** (`general-purpose`) — Relevant when the feature has user-facing components, interactions, navigation changes, or accessibility implications. Skip for purely backend/infrastructure work.

5. **Devil's Advocate** (`general-purpose`) — **Always include.** Challenges assumptions, proposes alternatives, identifies edge cases and failure modes. Non-negotiable.

### Optional (include only when clearly needed)

6. **Database Architect** (`general-purpose`) — Include when the feature requires new tables, columns, access policies, triggers, or DB functions.

7. **Test Engineer** (`general-purpose`) — Include when the sprint plan includes testable features. Writes the tests identified during planning, verifies coverage. Skip only for trivial changes with no testable logic.

## Workflow

### Phase 1: Quick Architecture Scan

1. **Select agents**: State which agents you're activating and why (1-2 sentences each). State which you're skipping and why.

2. **Launch architect + explorer in parallel**: Before implementing, launch the Code Architect and any relevant exploration agents with `run_in_background: true` to understand the codebase and produce a brief implementation blueprint.

   Each agent prompt must include:
   - The feature description: "$ARGUMENTS"
   - Instruction to explore the codebase, read relevant files, and produce a concise implementation plan
   - List of files to create/modify, in what order
   - Reminder to read relevant existing code, docs, and CLAUDE.md files
   - "Report only your findings. No preamble, no summaries of what you checked, no restating the task."

3. **Synthesize into build order**: Combine agent findings into a concrete ordered list of implementation steps.

### Phase 2: Implement

4. **Implement step by step**: Execute the build plan yourself, writing the actual code. Follow existing project patterns and conventions. After each major step, briefly note what was done.

   - Database changes first (migrations, schema, functions)
   - Model/type changes next
   - Service layer changes
   - View/UI changes last
   - Wire everything together

5. **Checkpoint after each task**: Update `progress.md` (CHECKPOINT block + log entry) and `tasks.md` (check off completed tasks). This is mandatory — it enables session resumption and the autonomous runner.

### Phase 3: Post-Implementation Review

6. **Run `/simplify`**: Before launching review agents, invoke the `/simplify` skill on the changed code. This automatically reviews and fixes reuse, quality, and efficiency issues — so review agents focus on real problems rather than style nits.

7. **Launch review agents in parallel**: After `/simplify` is done, launch the relevant review agents (Security Reviewer, Performance Analyst, Devil's Advocate) with `run_in_background: true` to review what was built.

   Each review agent prompt must include:
   - The feature description: "$ARGUMENTS"
   - Instruction to review the recently modified files (use `git diff`) for issues from their specialist perspective
   - Explicit instruction: "Review only. Flag issues with file paths and line numbers."
   - "Report only your findings. No preamble, no summaries of what you checked, no restating the task."

8. **Address findings**: Fix any issues flagged by the review agents. For disagreements between agents, use your judgment and note the trade-off.

### Phase 4: Test Verification

9. **Run existing tests**: Build the project and run the existing test suite using the project's build system. If any tests fail due to the changes, fix them before proceeding. This is non-negotiable — broken tests mean the implementation is incomplete.

10. **Write new tests**: If the sprint plan includes a test plan, write the new tests identified during planning.

### Phase 5: Documentation Sweep

Run this phase AFTER review fixes and tests — not before. Review fixes often surface edge cases, gotchas, and non-obvious behavior that are the most valuable things to document.

11. **Run `/lean-docs`**: Invoke the `/lean-docs` skill to audit and update project documentation. This covers `docs/`, subdirectory `CLAUDE.md` files, and `docs/gotchas.md`. It will identify stale or missing documentation based on what changed.

12. **Final summary**: Present what was built, any trade-offs made, and any remaining open items. Update `progress.md` with final state.

## Bug Fix Phase (when active_task contains 'Bug Fix' or 'BF-')

For each bug, follow this TDD workflow:
1. **REPRODUCE FIRST**: Write a failing test that reproduces the bug. Run it and confirm it fails for the right reason.
2. **FIX**: Implement a proper, clean fix — not a minimal patch. Same code quality standards as feature work.
   - If the proper fix requires a large refactor (touching many files or changing architecture), do NOT attempt it. Instead set phase to 'blocked' and describe what refactor is needed.
3. **VERIFY**: Run the test again — only mark the bug as done when the test passes.
4. If the bug CANNOT be reproduced as an automated test (purely visual, gesture-based, device interaction), note why in the progress log and apply best-effort fix.

## Sprint Rules (non-negotiable)

- **NEVER cut, skip, or defer tasks.** Every task in tasks.md is committed scope.
- **NEVER mark a task as done if the build is broken or tests are failing.**
- **Work through as many tasks as you can per session.** Do NOT stop after a single task.
- **Checkpoint after EACH task** so progress survives crashes, then continue to the next task.
