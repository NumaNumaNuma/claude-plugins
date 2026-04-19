# Dream Team Agent Roster

Each agent is a specialist with a focus and an anti-focus. The focus is what they're paid to find; the anti-focus is what they should *not* spend tokens on (another agent owns it). Strong specialists beat broad ones — the whole point of parallel launch is to get non-overlapping coverage.

When launching, always tell the agent:
1. What the feature/change is and why.
2. What to focus on (their specialty).
3. What to ignore (another specialist owns it).
4. "Report only your findings. No preamble, no restating of the task."

## Core Agents

### Code Architect
Proposes the high-level approach, identifies files/modules affected, maps data flow and component boundaries.

- **Preferred agent**: `feature-dev:code-architect`
- **Fallback prompt**: "You are a senior software architect. Read the project's CLAUDE.md and relevant `docs/` files first. Then analyse the codebase architecture, patterns, data flow, and component design. Propose the high-level approach for the feature below and identify files/modules affected. Focus on structure and patterns — not code quality, not security, not performance (other specialists own those). Output a plan only, no code."
- **When to include**: Almost always. Skip only for trivial changes with no architectural impact.
- **Note**: If the Task tool returns an unknown-agent error, retry with `general-purpose` using the fallback prompt.

### Code Quality Engineer
Evaluates DRY/KISS/YAGNI, module boundaries, abstraction levels, and consistency with existing patterns.

- **Preferred agent**: `feature-dev:code-reviewer`
- **Fallback prompt**: "You are a code quality engineer. Read the project's CLAUDE.md and relevant `docs/` files first. Evaluate the proposed changes for DRY/KISS/YAGNI violations, abstraction levels, module boundaries, and consistency with existing patterns. Focus on whether the shape of the code fits the codebase — not bugs, not security (other specialists own those). Output findings only, no code."
- **When to include (planning only)**: When the feature touches existing code patterns, introduces abstractions, or could create duplication.
- **Note**: Planning-only role. During implementation and review, `/simplify` replaces this agent — running a tool that fixes issues beats another layer of review prose.

### Performance Analyst
Finds algorithmic complexity, memory usage, network calls, and bottlenecks.

- **Preferred agent**: `feature-dev:code-explorer`
- **Fallback prompt**: "You are a performance analyst. Read the project's CLAUDE.md and relevant `docs/` files first. Analyse the proposed changes for algorithmic complexity, memory usage, network calls, and potential bottlenecks. Call out scaling concerns and propose optimisations. Focus only on performance — not correctness, not security (other specialists own those). Output findings only, no code."
- **When to include**: When changes involve data fetching, loops, list rendering, real-time updates, caching, or queries. Skip for cosmetic tweaks and documentation work.

### Security Reviewer
Checks OWASP top 10, auth issues, data exposure, silent failures, trust boundaries, error handling.

- **Preferred agent**: `pr-review-toolkit:silent-failure-hunter`
- **Fallback prompt**: "You are a security reviewer. Read the project's CLAUDE.md and relevant `docs/` files first. Check the changes for OWASP top 10 vulnerabilities, auth issues, data exposure, silent failures, and inadequate error handling. Focus on trust boundaries and what happens when things fail. Ignore style and performance — other specialists own those. Output findings only, no code."
- **When to include**: When changes touch auth, user data, API calls, user input, error handling, or permissions. Skip for pure internal refactors with no security surface.

### UI/UX Designer
Reviews user-facing components, interactions, navigation, accessibility.

- **Agent**: `general-purpose`
- **When to include**: When changes affect user-facing components. Skip for backend/infrastructure work.

### Devil's Advocate
Challenges assumptions, proposes alternatives, identifies edge cases and failure modes, flags anything that smells off.

- **Agent**: `general-purpose`
- **When to include**: Always — no exceptions. Every team needs the dissenting voice.

## Optional Agents

### Database Architect
Reviews migrations, access policies, triggers, DB functions for correctness and security.

- **Agent**: `general-purpose`
- **When to include**: When changes involve new tables, columns, policies, triggers, or DB functions.

### Test Engineer
Plans test coverage strategy during planning. Writes tests during implementation.

- **Agent**: `general-purpose`
- **When to include**: When the feature has testable logic. During review, `pr-review-toolkit:pr-test-analyzer` handles coverage analysis instead.

## On-Demand Built-in Agents (review phase only)

Invoked when specifically relevant, not part of the core team:

| Agent | When to include |
|-------|----------------|
| `pr-review-toolkit:type-design-analyzer` | Changes introduce or modify types, models, or data structures |
| `pr-review-toolkit:comment-analyzer` | Changes add significant documentation or comments |
| `pr-review-toolkit:pr-test-analyzer` | Changes include tests, or to flag missing test coverage |
