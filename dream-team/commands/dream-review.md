---
description: "Pick relevant Dream Team agents to collaboratively review code changes"
argument-hint: "What to review (e.g., 'current changes', 'PR #123', 'the auth refactor')"
---

# Dream Review: $ARGUMENTS

You are reviewing code using the Dream Team methodology, but with **selective agent activation** — only launch agents that are relevant to the changes being reviewed.

## Step 0: Identify What to Review

First, determine the scope of the review:
- If "$ARGUMENTS" mentions a PR number, fetch it with `gh pr view` and `gh pr diff`
- If "$ARGUMENTS" says "current changes" or is vague, use `git diff` (staged + unstaged) and `git diff --cached`
- If "$ARGUMENTS" references specific files or features, focus on those

Briefly summarize the changes before selecting agents.

## Agent Selection

Review the changes and decide which of these agents to activate. **You must justify each inclusion/exclusion in a brief sentence before launching.**

### Core Team (select relevant ones)

1. **Code Quality Engineer** — **Almost always relevant.** Reviews for bugs, logic errors, code quality, DRY/KISS/YAGNI, consistent patterns, readability, and adherence to project conventions.
   - Use `feature-dev:code-reviewer` if available. If the Task tool returns an error about an unknown agent type, retry with `general-purpose` using this prompt: "You are a code quality engineer. Review the code changes for bugs, logic errors, code quality issues, DRY/KISS/YAGNI violations, consistent patterns, readability, and adherence to project conventions."

2. **Security Reviewer** — Relevant when changes involve auth, user data, API calls, user input, error handling, or permissions. Skip for purely cosmetic changes.
   - Use `pr-review-toolkit:silent-failure-hunter` if available. Fallback prompt: "You are a security reviewer. Check changes for OWASP top 10 vulnerabilities, auth issues, data exposure, silent failures, and inadequate error handling."

3. **Performance Analyst** — Relevant when changes involve data fetching, loops, list rendering, real-time updates, caching, or queries. Skip for simple UI tweaks or documentation.
   - Use `feature-dev:code-explorer` if available. Fallback prompt: "You are a performance analyst. Analyze the code changes for algorithmic complexity, memory usage, network calls, and bottlenecks."

4. **UI/UX Designer** (`general-purpose`) — Relevant when changes affect user-facing components, interactions, navigation, or accessibility. Skip for purely backend/infrastructure work.

5. **Devil's Advocate** (`general-purpose`) — **Always include.** Challenges the approach taken, questions whether simpler alternatives exist, identifies edge cases and failure modes, and flags anything that "smells off."

### Optional (include only when clearly needed)

6. **Type/Model Reviewer** — Include when changes introduce or modify types, models, or data structures.
   - Use `pr-review-toolkit:type-design-analyzer` if available. Fallback prompt: "You are a type design analyst. Review new or modified types for encapsulation, invariant expression, usefulness, and enforcement quality."

7. **Comment Analyzer** — Include when changes add significant documentation or comments.
   - Use `pr-review-toolkit:comment-analyzer` if available. Fallback prompt: "You are a documentation reviewer. Check comments for accuracy, completeness, and long-term maintainability."

8. **Test Analyst** — Include when changes include tests, or when you want to flag missing test coverage.
   - Use `pr-review-toolkit:pr-test-analyzer` if available. Fallback prompt: "You are a test coverage analyst. Review test changes for completeness, edge case coverage, and quality."

9. **Database Reviewer** (`general-purpose`) — Include when changes involve migrations, access policies, triggers, or DB functions. Should inspect the SQL for correctness and security.

## Workflow

1. **Identify scope**: Summarize what's being reviewed (files changed, nature of changes).

2. **Select agents**: State which agents you're activating and why. State which you're skipping and why.

3. **Launch in parallel**: Launch all selected agents simultaneously using the Task tool with `run_in_background: true`. Each agent receives:
   - Description of the changes and their purpose
   - The diff or list of modified files to focus on
   - Instruction to review from their specialist perspective
   - Explicit instruction: "Flag issues with severity (critical/warning/nit), file path, and line number where possible."
   - "Report only your findings. No preamble, no summaries of what you checked, no restating the task."

4. **Synthesize**: After all agents return, combine findings into a unified review. Organize by severity:
   - **Critical** — Must fix before merging. Bugs, security issues, data loss risks.
   - **Warnings** — Should fix. Code quality, performance, maintainability concerns.
   - **Nits** — Nice to fix. Style, naming, minor improvements.
   - **Praise** — What was done well. Reinforce good patterns.

5. **Devil's Advocate pass**: Resume the Devil's Advocate agent with the synthesis for a final challenge. Are there issues the other reviewers missed? Is the overall approach sound?

6. **Final verdict**: Present the consolidated review with a clear recommendation:
   - **Ship it** — No critical issues, ready to merge
   - **Ship with fixes** — Minor issues to address, list them
   - **Needs work** — Significant issues, detail what needs to change
