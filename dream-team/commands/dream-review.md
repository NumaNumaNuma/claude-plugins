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

## Step 1: Auto-fix with `/simplify`

Before launching any review agents, run the `/simplify` skill on the changed code. This automatically reviews and fixes reuse, quality, and efficiency issues — eliminating noise so review agents can focus on real problems.

## Agent Selection

Read `references/agent-roster.md` for the full roster with preferred agents, fallback prompts, and inclusion criteria. **Review does not use Code Quality Engineer** — `/simplify` (step 1) handles code quality. Review does use the on-demand built-in agents (type-design-analyzer, comment-analyzer, pr-test-analyzer) when relevant.

Review the changes and decide which agents to activate. **Justify each inclusion/exclusion in a brief sentence before launching.** For trivial changes (single-line fixes, typo corrections), skip the full review process.

## Workflow

1. **Identify scope**: Summarize what's being reviewed (files changed, nature of changes).

2. **Run `/simplify`**: Invoke the `/simplify` skill on the changed code. This auto-fixes quality, reuse, and efficiency issues before the review agents run.

3. **Select agents**: State which agents you're activating and why. State which you're skipping and why.

4. **Launch in parallel**: Launch all selected agents simultaneously using the Task tool with `run_in_background: true`. Each agent receives:
   - Description of the changes and their purpose
   - The diff or list of modified files to focus on
   - Instruction to review from their specialist perspective
   - Explicit instruction: "Flag issues with severity (critical/warning/nit), file path, and line number where possible."
   - "Report only your findings. No preamble, no summaries of what you checked, no restating the task."

5. **Synthesize**: After all agents return, combine findings into a unified review. Organize by severity:
   - **Critical** — Must fix before merging. Bugs, security issues, data loss risks.
   - **Warnings** — Should fix. Performance, maintainability concerns.
   - **Nits** — Nice to fix. Style, naming, minor improvements.
   - **Praise** — What was done well. Reinforce good patterns.

6. **Devil's Advocate pass**: Resume the Devil's Advocate agent with the synthesis for a final challenge. Are there issues the other reviewers missed? Is the overall approach sound?

7. **Final verdict**: Present the consolidated review with a clear recommendation:
   - **Ship it** — No critical issues, ready to merge
   - **Ship with fixes** — Minor issues to address, list them
   - **Needs work** — Significant issues, detail what needs to change

8. **File deferred findings as GitHub issues**: After fixing actionable items, check if the project is a GitHub repository (`gh repo view`). If so, file each skipped/deferred finding as a GitHub issue with the `tech-debt` label (create the label first if it doesn't exist: `gh label create "tech-debt" --description "Code quality and maintenance improvements" --color "fbca04"`). Each issue should include: context (file + line), proposed fix, and which review agent found it. This ensures deferred work is tracked and not lost.

9. **Post-fix documentation sweep**: If the verdict was "Ship with fixes" or "Needs work" and the user asks you to fix the issues, run `/lean-docs` AFTER the fixes are applied. Review fixes often surface edge cases, gotchas, and non-obvious behavior — these are the most valuable things to document. This step ensures documentation reflects the final state of the code, not an intermediate one.
