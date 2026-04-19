---
description: "Pick relevant Dream Team agents to collaboratively review code changes"
argument-hint: "What to review (e.g., 'current changes', 'PR #123', 'the auth refactor')"
---

# Dream Review: $ARGUMENTS

Review code using the Dream Team methodology — run `/simplify` first to clear auto-fixable noise, then launch specialist reviewers in parallel on what's actually worth human judgment. Goal: a review that tells the user what to do, not a dump of every possible concern.

## Step 0: Identify scope

Figure out what to review:
- **PR mentioned** (e.g. "PR #123") — fetch with `gh pr view` and `gh pr diff`
- **"current changes" / vague** — use `git diff` (staged + unstaged) and `git diff --cached`
- **Specific files/feature** — scope to those files

Summarise what changed in one or two sentences before doing anything else — this anchors every downstream decision.

## Step 1: Auto-fix with `/simplify`

Run `/simplify` on the changed code before launching any review agents. It handles reuse, quality, and efficiency mechanically, so review agents spend their tokens on things that actually need human judgment (bugs, security, design) rather than restating "this could be a map".

## Step 2: Select agents

Read `references/agent-roster.md` for the roster and inclusion criteria. Review **does not** use Code Quality Engineer — `/simplify` (step 1) owns that. Review **does** use on-demand built-ins (`type-design-analyzer`, `comment-analyzer`, `pr-test-analyzer`) when relevant to what changed.

State each inclusion/exclusion in one sentence. For trivial changes, skip the whole thing and just eyeball the diff.

## Step 3: Launch in parallel

Spawn all selected agents in a single turn with `run_in_background: true`. Each prompt includes:
- What changed and why (your scope summary)
- The diff or list of modified files
- Their specialist focus and anti-focus
- "Flag issues with severity (critical / warning / nit), file path, and line number. Report only findings — no preamble, no summary of what you checked, no restating the task."

## Step 4: Synthesise

Combine findings into a unified review organised by severity:

- **Critical** — must fix before merge. Bugs, security issues, data loss risks, broken invariants.
- **Warnings** — should fix. Performance cliffs, maintainability traps, missing error paths.
- **Nits** — nice to fix. Style, naming, micro-improvements.
- **Praise** — what was done well. Reinforcing good patterns is as useful as flagging bad ones.

Be strict about severity calibration. A "critical" that's really a nit trains the user to ignore critical findings; a nit dressed as a warning wastes their time. When specialists disagree, call the judgment yourself and note the tradeoff.

## Step 5: Devil's Advocate pass

Resume Devil's Advocate with the synthesis. Did specialists miss anything? Is the overall approach sound, or are we optimising a bad design? Every Devil's Advocate objection gets an explicit response.

## Step 6: Verdict

Present the consolidated review with a clear recommendation:

- **Ship it** — no critical issues, ready to merge
- **Ship with fixes** — minor issues to address, listed concretely
- **Needs work** — significant issues, detailed

## Step 7: File deferred findings as issues

After fixing actionable items, check if the project is a GitHub repo (`gh repo view`). If yes, file each skipped/deferred finding as a GitHub issue with the `tech-debt` label — create the label first if it doesn't exist:

```bash
gh label create "tech-debt" --description "Code quality and maintenance improvements" --color "fbca04"
```

Each issue includes: context (file + line), proposed fix, which review agent surfaced it. This is how deferred work gets remembered instead of forgotten.

## Step 8: Post-fix documentation sweep

If the verdict was "Ship with fixes" or "Needs work" and the user asks you to fix the issues, run `/lean-docs` **after** fixes are applied, not before. Review fixes surface edge cases, gotchas, and non-obvious behaviour — those are the things most worth documenting, and running docs before the fixes means documenting intermediate state.
