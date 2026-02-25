---
description: "Pick relevant Dream Team agents to collaboratively plan a feature"
argument-hint: "Feature to plan (e.g., 'user notifications system')"
---

# Dream Plan: $ARGUMENTS

You are planning the feature described above using the Dream Team methodology, but with **selective agent activation** — only launch agents that are relevant to this specific feature.

## Agent Selection

Review the feature description and decide which of these agents to activate. **You must justify each inclusion/exclusion in a brief sentence before launching.**

### Core Team (select relevant ones)

1. **Code Architect** — **Almost always relevant.** Analyzes architecture, patterns, data flow, component design. Proposes the high-level approach and identifies files/modules affected. Skip only for trivial changes.
   - Use `feature-dev:code-architect` if available. If the Task tool returns an error about an unknown agent type, retry with `general-purpose` using this prompt: "You are a senior software architect. Analyze the codebase architecture, patterns, data flow, and component design. Propose the high-level approach and identify files/modules affected. Read relevant existing code, docs, and CLAUDE.md files before making recommendations."

2. **Code Quality Engineer** — Relevant when the feature touches existing code patterns, introduces new abstractions, or could create duplication. Evaluates DRY/KISS/YAGNI, module boundaries, and reuse.
   - Use `feature-dev:code-reviewer` if available. Fallback prompt: "You are a code quality engineer. Evaluate the proposed changes for DRY/KISS/YAGNI violations, abstraction levels, module boundaries, decoupling, and consistency with existing patterns. Read the codebase conventions before analyzing."

3. **Performance Analyst** — Relevant when the feature involves data fetching, list rendering, real-time updates, caching, or anything with scaling concerns. Skip for purely cosmetic UI changes.
   - Use `feature-dev:code-explorer` if available. Fallback prompt: "You are a performance analyst. Analyze algorithmic complexity, memory usage, network calls, and potential bottlenecks. Identify scaling concerns and propose optimizations."

4. **Security Reviewer** — Relevant when the feature involves auth, user data, API calls, user input, or permissions. Skip for internal refactors with no security surface.
   - Use `pr-review-toolkit:silent-failure-hunter` if available. Also launch `feature-dev:code-reviewer` focused on security. Fallback prompt: "You are a security reviewer. Check for OWASP top 10 vulnerabilities, auth issues, data exposure, silent failures, and inadequate error handling. Focus on security boundaries and trust assumptions."

5. **UI/UX Designer** (`general-purpose`) — Relevant when the feature has user-facing components, interactions, navigation changes, or accessibility implications. Skip for purely backend/infrastructure work.

6. **Devil's Advocate** (`general-purpose`) — **Always include.** Challenges assumptions, proposes alternatives, identifies edge cases and failure modes. Non-negotiable.

### Optional (include only when clearly needed)

7. **Database Architect** (`general-purpose`) — Include when the feature requires new tables, columns, access policies, triggers, or DB functions.

8. **Documentalist** (`general-purpose`) — Include when the feature is complex enough to warrant documentation updates or lessons learned capture.

9. **Test Engineer** (`general-purpose`) — Include when the plan identifies new tests are needed or when the feature will affect existing tests. Plans what tests to write/update, identifies affected test files, and specifies expected behavior. Skip only for trivial changes with no testable logic.

## Workflow

1. **Select agents**: State which agents you're activating and why (1-2 sentences each). State which you're skipping and why.

2. **Launch in parallel**: Launch all selected agents simultaneously using the Task tool with `run_in_background: true`. Each agent receives the full feature description and is told to focus on **planning only** — no implementation.

   Each agent prompt must include:
   - The feature description: "$ARGUMENTS"
   - Instruction to explore the codebase and produce a planning analysis from their specialist perspective
   - Reminder to read relevant existing code, docs, and CLAUDE.md files before making recommendations
   - Explicit instruction: "Output a plan/analysis only. Do not write any code."
   - "Report only your findings. No preamble, no summaries of what you checked, no restating the task."

3. **Synthesize**: After all agents return, combine their findings into a unified plan. Highlight:
   - Points of agreement across agents
   - Conflicts or tensions between recommendations
   - Open questions that need user input

4. **Devil's Advocate pass**: Resume the Devil's Advocate agent with the synthesis for a final challenge. Address every objection — either incorporate it or explain why it's dismissed.

5. **Edge case sweep**: Review the plan yourself with fresh eyes and specifically hunt for missed edge cases. For each component in the plan, ask:
   - What happens on first use? (empty states, no data, new user)
   - What happens at scale? (1000+ items, concurrent users, large payloads)
   - What happens on failure? (network down, timeout, partial write, auth expired)
   - What happens with bad input? (empty strings, nulls, duplicates, special characters)
   - What happens out of order? (race conditions, double-taps, stale data, back navigation)
   - What happens on different devices/contexts? (small screens, offline, background/foreground transitions)

   Add any newly discovered edge cases to the plan. If an edge case would require a new task, add it. If it's a risk, add it to the risks table.

6. **Create sprint directory**: Save the plan to the project's planning directory:
   ```
   planning/sprints/sprint-N-name/
   ├── plan.md         — Copy from templates/sprint-plan.md, fill in architecture decisions
   ├── tasks.md        — Copy from templates/tasks.md, fill in implementation tasks
   ├── progress.md     — Copy from templates/progress.md, initialize checkpoint
   └── test-plan.md    — What to test (if Test Engineer was activated)
   ```
   Use the templates from this plugin's `templates/` directory as starting points.

7. **Final plan**: Present the consolidated implementation plan with:
   - Architecture decisions (with rationale)
   - Files to create/modify
   - Database changes (if any)
   - Implementation sequence (what to build first)
   - Edge cases and risks identified
   - Open questions for the user

Present the final plan clearly and ask the user if they'd like to proceed with implementation.

## Sprint Rules (non-negotiable)

- **NEVER cut, skip, or defer tasks.** Every task in tasks.md is committed scope.
- **Bug Fix Phase**: Always include in tasks.md. Left empty until manual testing finds bugs. Runner completes all bugs before marking sprint done.
- **Test plan**: If the sprint includes testable features, create test-plan.md during planning. Never defer test planning to implementation.
