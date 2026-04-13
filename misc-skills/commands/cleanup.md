---
description: "Cleanup pipeline: simplify code, audit & run tests per project rules, update docs"
argument-hint: "[optional: number of commits (e.g. 3) or commit range (e.g. abc..def)]"
---

# Cleanup Pipeline

Run a 4-step cleanup on recent changes: simplify, audit tests, run only the changed tests (following the project's own rules), update docs.

This command is project-agnostic. For anything test-related, load the project's testing conventions from its `CLAUDE.md` (and any docs linked from there) and follow them exactly. If the project has no tests or no testing guidance, skip the test steps and say so.

## Input

$ARGUMENTS

## Step 0: Determine the diff scope

- If the argument is a number (e.g. `3`), scope is `HEAD~N..HEAD`.
- If the argument is a commit range (e.g. `abc123..def456`), use it directly.
- If no argument, use the working tree changes (staged + unstaged vs HEAD).
- Run `git diff --name-only <scope>` to collect the changed files. Keep this list — every later step operates on it.
- If the list is empty, stop and tell the user.

## Step 1: Simplify

Invoke `/simplify` on the Step 0 changes. If a commit range was given, pass it so simplify knows what to review.

Wait for simplify to finish before continuing — its edits feed Step 2.

## Step 2: Audit and update tests

First, load the project's testing conventions. Read the root `CLAUDE.md`, any subdirectory `CLAUDE.md` that covers the changed files, and every test-related doc they link to. From these, you need to learn:

- Whether the project has tests at all.
- Where tests live and how test files map to source files.
- Which test frameworks / targets / schemes are in use and any quirks.
- Any rules about which tests run where (destinations, runtimes, parallelism).
- The command(s) for running an individual test, including identifier format.

If the project has no tests or no testing instructions: skip Steps 2 and 3, note it in the final summary, and jump to Step 4.

Otherwise, for each source file changed in Step 0 plus any edits simplify made in Step 1:

1. Locate its corresponding test file(s) using the project's convention.
2. Re-read the changed source to understand what was modified.
3. Check whether existing tests cover the changes.
4. Add or update test functions as needed — do NOT delete existing passing tests.

Keep a list of every test function you added or modified — Step 3 needs the identifiers.

If no test changes are needed, note that and skip to Step 4.

## Step 3: Run only the changed tests

Run ONLY the tests you added or modified in Step 2. Never run the full suite.

Use the project's documented command(s) for running a specific test — the ones you loaded in Step 2. Respect every rule you find there:

- Scheme / target / framework / destination for each kind of test.
- Any required pre-test environment checks.
- Parallelism rules ("run these in parallel sub-agents", "do NOT parallelize", etc.).
- Identifier format quirks (e.g., Swift Testing `()` suffix, pytest `::`, Jest `-t`, …).

If a test fails, fix it and re-run only that test. Do not proceed until all modified tests pass.

## Step 4: Update docs

Invoke `/lean-docs:lean-docs` to audit and update documentation and gotchas based on everything that changed in Steps 1–3.

## Summary

Print a brief summary:
- What was simplified (Step 1).
- Tests added/updated (Step 2) — or "skipped: project has no tests/test docs".
- Test results (Step 3).
- Docs updated (Step 4).
