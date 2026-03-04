# Dream Team Agent Roster

## Core Agents

### Code Architect
Analyzes architecture, patterns, data flow, component design. Proposes the high-level approach and identifies files/modules affected.

- **Preferred agent**: `feature-dev:code-architect`
- **Fallback prompt**: "You are a senior software architect. Read the project's CLAUDE.md and relevant docs/ files first. Then analyze the codebase architecture, patterns, data flow, and component design. Propose the high-level approach and identify files/modules affected."
- **When to include**: Almost always. Skip only for trivial changes with no architectural impact.
- **Note**: If the Task tool returns an error about an unknown agent type, retry with `general-purpose` using the fallback prompt.

### Code Quality Engineer
Evaluates DRY/KISS/YAGNI, module boundaries, abstraction levels, and consistency with existing patterns.

- **Preferred agent**: `feature-dev:code-reviewer`
- **Fallback prompt**: "You are a code quality engineer. Read the project's CLAUDE.md and relevant docs/ files first. Then evaluate the proposed changes for DRY/KISS/YAGNI violations, abstraction levels, module boundaries, decoupling, and consistency with existing patterns."
- **When to include**: When the feature touches existing code patterns, introduces new abstractions, or could create duplication.
- **Planning only**: During implementation and review, the `/simplify` skill replaces this agent — `/simplify` auto-fixes reuse, quality, and efficiency issues in changed code, which is more effective than review-only feedback.

### Performance Analyst
Analyzes algorithmic complexity, memory usage, network calls, and potential bottlenecks.

- **Preferred agent**: `feature-dev:code-explorer`
- **Fallback prompt**: "You are a performance analyst. Read the project's CLAUDE.md and relevant docs/ files first. Then analyze the code for algorithmic complexity, memory usage, network calls, and bottlenecks. Identify scaling concerns and propose optimizations."
- **When to include**: When the feature involves data fetching, loops, list rendering, real-time updates, caching, or queries. Skip for simple UI tweaks or documentation.

### Security Reviewer
Checks for OWASP top 10 vulnerabilities, auth issues, data exposure, silent failures, and inadequate error handling.

- **Preferred agent**: `pr-review-toolkit:silent-failure-hunter`
- **Fallback prompt**: "You are a security reviewer. Read the project's CLAUDE.md and relevant docs/ files first. Then check for OWASP top 10 vulnerabilities, auth issues, data exposure, silent failures, and inadequate error handling. Focus on security boundaries and trust assumptions."
- **When to include**: When changes involve auth, user data, API calls, user input, error handling, or permissions. Skip for purely cosmetic changes or internal refactors with no security surface.

### UI/UX Designer
Reviews user-facing components, interactions, navigation, and accessibility.

- **Agent**: `general-purpose`
- **When to include**: When changes affect user-facing components, interactions, navigation, or accessibility. Skip for purely backend/infrastructure work.

### Devil's Advocate
Challenges assumptions, proposes alternatives, identifies edge cases and failure modes, flags anything that "smells off."

- **Agent**: `general-purpose`
- **When to include**: **Always.** Non-negotiable.

## Optional Agents

### Database Architect
Reviews migrations, access policies, triggers, DB functions for correctness and security.

- **Agent**: `general-purpose`
- **When to include**: When changes involve new tables, columns, access policies, triggers, or DB functions.

### Test Engineer
Plans test coverage strategy, writes tests, verifies coverage.

- **Agent**: `general-purpose`
- **When to include**: When the feature has testable logic. Plans coverage during planning, writes tests during implementation.
- **During review**: The built-in `pr-review-toolkit:pr-test-analyzer` handles test coverage analysis instead.

## On-Demand Built-in Agents (review phase only)

These are invoked when clearly relevant, not part of the core team:

| Agent | When to include |
|-------|----------------|
| `pr-review-toolkit:type-design-analyzer` | Changes introduce or modify types, models, or data structures |
| `pr-review-toolkit:comment-analyzer` | Changes add significant documentation or comments |
| `pr-review-toolkit:pr-test-analyzer` | Changes include tests, or to flag missing test coverage |
