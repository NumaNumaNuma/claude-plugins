---
name: pair-with-codex-flow
description: >
  Orchestrate a Claude + Codex collaborative development loop. Use when the user asks to pair Claude with Codex, run a plan → implement → review → simplify workflow, kick off an overnight coding session, use /pair-with-codex:start, /pair-with-codex:polish, /pair-with-codex:resume, /pair-with-codex:status, or /pair-with-codex:abort, or describes wanting Codex to implement a spec while Claude reviews and cleans up.
---

## 1. Overview

This skill orchestrates a full Claude + Codex collaborative development loop. Claude plans the work (brainstorming + spec), Codex implements it, Claude cleans up and simplifies the diff, Codex reviews for issues, Claude addresses findings, and the loop repeats until the code is clean or the round ceiling is reached — all tracked in a per-repo state file so sessions survive interruptions.

The workflow runs in one of two modes: **hybrid** (default) — Claude pauses at each phase boundary to show the user what just happened and ask whether to continue — or **autonomous** (`--auto`) — all gates are skipped and the flow runs unattended until done or failed. Hybrid mode is the safe default for daytime work; `--auto` is for overnight or hands-off runs where the user checks results in the morning.

Five entry points feed into this skill: `start` (full flow), `polish` (tail-only — cleanup → review → done), `resume` (reattach to a paused session), `status` (read-only snapshot), and `abort` (clear state).

---

## 2. Preconditions

Before doing anything, verify these hold:

- The `superpowers` plugin is installed (needed for `brainstorming`, `writing-plans`, `simplify`).
- The `codex` plugin is installed (needed for `/codex:rescue`, `/codex:review`, `/codex:status`).
- `/codex:setup` has been run and Codex is authenticated. If Codex is missing or unauthenticated, abort immediately and tell the user to run `/codex:setup`.
- The current directory is inside a git repository (`git rev-parse --show-toplevel` succeeds). If it is not, abort with a clear message — the harness is git-dependent and cannot operate without one.

---

## 3. Entry Point Routing

The command `.md` forwarders each inject an `ENTRY_POINT:` value at the top of `$ARGUMENTS`. Route based on it:

| `ENTRY_POINT:` value | Starting phase |
|---|---|
| `start` | Phase 1 — Preflight → plan → spec_approval → implement → cleanup → review_loop → done |
| `polish` | Phase 4 — Cleanup (inverted dirty-tree check) → review_loop → done |
| `resume` | Read state → reattach to persisted phase |
| `status` | Read-only status report, then stop |
| `abort` | Clear state file, print summary, then stop |

If the skill is invoked via natural language (no slash command, no `ENTRY_POINT:` prefix), infer the entry point from intent. "Let's pair with codex on X" → `start`. "Polish this" or "clean up these changes" → `polish`. "Resume" or "pick up where we left off" → `resume`.

---

## 4. Flag Parsing

### 4.1 Explicit flags (Path A — slash command with args)

Parse these from `$ARGUMENTS`:

| Flag | Effect |
|---|---|
| `--auto` | Skip all pause gates; start immediately after printing the resolved flag set |
| `--allow-dirty` | Do not refuse on a non-empty working tree |
| `--max-review-rounds N` | Override the default of 5 review rounds |
| `--new-branch [name]` | Create a new branch before starting. If `name` is omitted, auto-name from the task (e.g., `feature/add-jwt-auth`). If the task contains a Jira ticket (`JIG-\d+`), use `feature/JIG-xxxx-<slug>` |
| `--new-worktree` | Create a new git worktree; implies `--new-branch` |
| `--resume-existing-spec <path>` | Skip brainstorming; use the given file as the spec and jump directly to Phase 3 (implement) |

### 4.2 Natural-language phrase mapping (Path B — conversational invocation)

When the user does not use a slash command, map these phrases to flags:

| Phrase | Resolved flag |
|---|---|
| "auto", "autonomous", "overnight", "unattended", "don't wait for me" | `--auto` |
| "ignore the dirty tree", "just proceed", "I know there's uncommitted stuff" | `--allow-dirty` |
| "new branch", "make a branch", "on a branch" | `--new-branch` |
| "new worktree", "isolate it" | `--new-worktree` |
| "up to N rounds", "N reviews max" | `--max-review-rounds N` |

### 4.3 Confirmation before starting

Regardless of invocation path, echo the resolved flag set before doing anything:

```
Starting pair-with-codex:
  Task: <task description>
  Mode: hybrid (pause at each phase) | autonomous (no pause gates)
  Branch: current | new (<branch-name>)
  Max review rounds: <N>
  Working tree: clean ✓ | dirty (--allow-dirty set)
Proceed? (y/n/edit)
```

The `edit` option lets the user change any flag without restarting. In `--auto` mode, print the same summary but do **not** prompt — proceed immediately. The user can abort with ESC if they spot a problem.

### 4.4 Path C — slash command without args, conversational follow-up

If `$ARGUMENTS` is empty (user typed `/pair-with-codex:start` with no task), ask: "What should I pair with Codex on?" Apply the natural-language parser to the user's reply.

---

## 5. State Script Interface

The state file is keyed by the sha1 of `git rev-parse --show-toplevel`. The script at `${CLAUDE_PLUGIN_ROOT}/scripts/session-state.mjs` handles all hashing and file I/O. Call it from `Bash`. Every phase transition must be persisted before continuing.

### 5.1 Subcommand reference

```bash
REPO=$(git rev-parse --show-toplevel)
STATE_SCRIPT="${CLAUDE_PLUGIN_ROOT}/scripts/session-state.mjs"

# Read current state (returns {} if none)
node "$STATE_SCRIPT" get "$REPO"

# Write a complete new state object
node "$STATE_SCRIPT" set "$REPO" '{"version":1,"phase":"preflight",...}'

# Merge a partial update into the current state (also sets updated_at)
node "$STATE_SCRIPT" update "$REPO" '{"phase":"implement","spec_path":"docs/..."}'

# Delete the state file (abort/clear)
node "$STATE_SCRIPT" clear "$REPO"

# Move state file to archive/ with a timestamp prefix
node "$STATE_SCRIPT" archive "$REPO"

# List all active sessions across all repos
node "$STATE_SCRIPT" list

# Print the sha1 used for this repo's state file
node "$STATE_SCRIPT" hash "$REPO"
```

### 5.2 State schema (reference)

```json
{
  "version": 1,
  "repo_path": "/abs/path/to/repo",
  "repo_hash": "<sha1>",
  "task_description": "add JWT auth",
  "started_at": "2026-04-13T22:15:00Z",
  "updated_at": "2026-04-13T22:47:12Z",
  "mode": "hybrid",
  "flags": {
    "allow_dirty": false,
    "max_review_rounds": 5,
    "new_branch": "feature/add-jwt-auth",
    "new_worktree": false
  },
  "phase": "review_loop",
  "spec_path": "docs/superpowers/specs/2026-04-13-jwt-auth-design.md",
  "iteration": 2,
  "commits": [
    { "phase": "spec",      "sha": "abc123", "message": "spec: add JWT auth" },
    { "phase": "implement", "sha": "def456", "message": "implement: add JWT auth" },
    { "phase": "cleanup",   "sha": "789abc", "message": "cleanup: add JWT auth" },
    { "phase": "review_1",  "sha": "456def", "message": "review 1: address auth edge cases" }
  ],
  "codex_job": {
    "status": "running",
    "job_id": "codex-xyz-789",
    "started_at": "2026-04-13T22:45:00Z",
    "kind": "review"
  },
  "summary": null
}
```

Valid `phase` values: `preflight`, `plan`, `spec_approval`, `implement`, `cleanup`, `review_loop`, `done`, `aborted`, `failed`.

---

## 6. Phase Flow — Full Start

This is the flow for `ENTRY_POINT: start`. Each phase: what Claude does, what commit to write, what state update to make, and how the hybrid gate and auto mode differ.

### Phase 1 — Preflight

**What Claude does:**

1. Run `git rev-parse --show-toplevel` to confirm the directory is inside a git repo. If it fails, abort with: "This directory is not inside a git repository. pair-with-codex requires git."
2. Run `git status --porcelain`. If non-empty and `--allow-dirty` is NOT set, abort with a dirty-tree refusal (see Section 10).
3. Check for an existing session state: `node "$STATE_SCRIPT" get "$REPO"`. If phase is not `done`/`aborted`/`failed` and a state file exists, refuse with a concurrent-session message (see Section 10).
4. Verify Codex is available: try `/codex:status` or equivalent. If Codex is missing or unauthenticated, abort and tell the user to run `/codex:setup`.
5. If `--new-branch [name]` is set: run `git checkout -b <name>`. If the branch already exists, abort (see Section 10).
6. If `--new-worktree` is set: run `git worktree add <path> -b <name>` and switch into it.
7. Write the initial state file with `phase: preflight` and all resolved flags.

**Commit:** none in this phase.

**State update:**
```json
{ "version": 1, "phase": "preflight", "task_description": "...", "mode": "hybrid|auto", "flags": {...}, "started_at": "...", "commits": [] }
```

**Gate:** none — preflight always proceeds immediately.

### Phase 2 — Plan

**What Claude does:**

1. Update state: `{ "phase": "plan" }`.
2. Invoke `superpowers:brainstorming` with the task description. Let it run its full flow (clarifying questions → propose approaches → design).
3. When brainstorming hands off to `superpowers:writing-plans`, let that run as well. The result is a spec document written to disk.
4. Note the spec file path.

**Commit:** `spec: <task title>` — commit the spec file immediately after the spec is approved (see gate below).

**State update after commit:**
```json
{ "phase": "implement", "spec_path": "<path>", "commits": [..., { "phase": "spec", "sha": "<sha>", "message": "spec: <title>" }] }
```

**Gate (hybrid):** "Spec ready at `<path>`. Approve and continue to implementation? (y/n/edit)"
- `y` → commit the spec and proceed.
- `n` → spec rejection flow (see Section 10).
- `edit` → open the spec for manual editing; re-read it when the user says "continue", then re-prompt.

**Gate (auto):** auto-approve. Commit the spec. Proceed.

### Phase 3 — Implement

**What Claude does:**

1. Update state: `{ "phase": "implement" }`.
2. Invoke `/codex:rescue --write --background` with a prompt that references the spec file path and instructs Codex to implement exactly per the spec. The `--write` flag is mandatory — Codex must be write-capable. Never invoke `/codex:rescue` without `--write` in this phase.
3. Capture the Codex job ID from the rescue output. Persist it: `{ "codex_job": { "status": "running", "job_id": "...", "kind": "implement", "started_at": "..." } }`.
4. Poll `/codex:status` every 30 seconds. While polling, do nothing else — the session must stay open.
5. Stall detection: if Codex is silent for 10+ minutes with no status change:
   - **Hybrid:** print a warning and ask "Codex silent for 10min. Wait longer / cancel and retry / abort?"
   - **Auto:** wait up to 30 minutes total, then cancel-and-retry once. If the second attempt also stalls, fail the phase (see Section 10).
6. When Codex reports done: check the diff. If the diff is empty or nonsensical, do not silently proceed — see Codex empty-diff error handling in Section 10.
7. Run `git add -A && git commit -m "implement: <task title>"`.

**Commit:** `implement: <task title>`

**State update after commit:**
```json
{ "phase": "cleanup", "codex_job": { "status": "done", ... }, "commits": [..., { "phase": "implement", "sha": "...", "message": "implement: <title>" }] }
```

**Gate (hybrid):** "Codex done. N files changed, +X -Y lines. Continue to cleanup? (y/n/diff)"
- `diff` → print the diff and re-prompt.

**Gate (auto):** auto-continue.

### Phase 4 — Cleanup

**What Claude does:**

1. Update state: `{ "phase": "cleanup" }`.
2. Invoke the `simplify` skill, scoped to the diff that Codex just produced. Let `simplify` review and fix issues inline.
3. Detect project-local checks from manifest files present in the repo:
   - `package.json` → `npm run lint` and `npm test`
   - `Package.swift` or `.xcodeproj` → `swift build`
   - `Cargo.toml` → `cargo check` and `cargo test`
   - Similar heuristics for other ecosystems.
4. Run every detected check. Each one must pass.
   - If a check fails, read the error, edit the offending files, re-run. Up to 3 attempts.
   - If all 3 attempts fail: write state `{ "phase": "failed", "error": "<last error>" }`, do not commit, abort cleanup. Both hybrid and auto mode stop here. Tell the user to fix manually and run `:resume` or `:abort`.
5. If no checks were detected, log `{ "checks_detected": [] }` in state and proceed — but include a note in the Done summary so the user knows to verify manually.
6. If cleanup produced changes: commit as `cleanup: <task title>`. If nothing changed: record `"cleanup: no changes"` in state but do not create an empty commit.

**Commit:** `cleanup: <task title>` (only if there are changes).

**State update:**
```json
{ "phase": "review_loop", "iteration": 0, "commits": [...] }
```

**Gate (hybrid):** "Cleanup done. Continue to review loop? (y/n)"

**Gate (auto):** auto-continue.

### Phase 5 — Review Loop

Update state: `{ "phase": "review_loop" }`.

For `N` from 1 up to `max_review_rounds`:

**Step 1 — Run review.** Invoke `/codex:review`. This is a read-only review and runs in the foreground.

**Step 2 — Classify findings.** Parse Codex's review output. Claude determines which findings are actionable. The rules are (apply all of these):

- Lean on Codex's own severity ratings if present. Act on anything labeled medium or higher.
- **Pre-existing issues that are simple and isolated fixes ARE in scope.** Do not dismiss findings just because they were not introduced by the current change. The scope includes easy wins in the surrounding code.
- Skip only findings that would require a large refactor or a significant out-of-scope architectural change.
- Nit-level style suggestions are not actionable unless Codex explicitly flags them as a problem (medium+).

**Step 3 — Check clean.** If no actionable findings remain, break out of the loop with `exit_reason = clean` and go to Done.

**Step 4 — Address findings.** Claude reads, edits, and re-runs cleanup checks for each actionable finding, following the same 3-attempt lint/test fix loop as in Phase 4.

**Step 5 — Commit.** `review <N>: <short summary of what was addressed>`

**Step 6 — Update state.**
```json
{ "iteration": N, "commits": [..., { "phase": "review_N", "sha": "...", "message": "review N: ..." }] }
```

**Step 7 — Check ceiling.** If `N == max_review_rounds`, break with `exit_reason = max_rounds` and go to Done. **The hybrid gate in Step 8 is skipped on this final iteration — there is nothing left to decide.**

**Step 8 — Hybrid gate (only when N < max_review_rounds):** "Round N done. Codex found M issues, addressed all. Run another review? (y/n/stop)"
- `y` → continue to N+1.
- `n` or `stop` → break with `exit_reason = user_stopped`.

In **auto mode**, Step 8 is skipped entirely — always continue to N+1 until clean or ceiling.

When the loop exits with `exit_reason = max_rounds`, the Done phase surfaces the remaining unresolved findings from the last review in the summary.

---

## 7. Phase Flow — Polish

`ENTRY_POINT: polish` starts at Phase 4 (Cleanup) and skips Phases 1–3.

**Differences from full start:**

- Preflight still runs, but the dirty-tree check is **inverted**: polish requires a non-empty diff (there must be something to polish). If the working tree is clean, refuse: "Nothing to polish — the working tree is clean. Make some changes first."
- There is no spec and no spec commit.
- The first commit is `cleanup: <description>`, where `<description>` comes from the polish command's optional argument or is auto-generated from the diff if omitted.
- Everything from Phase 4 (Cleanup) onward is identical to the full flow.

State initialization for polish:
```json
{ "version": 1, "phase": "cleanup", "task_description": "<description>", "mode": "...", "flags": {...}, "started_at": "...", "commits": [] }
```

---

## 8. Phase Flow — Resume

`ENTRY_POINT: resume`. No flags parsed (no arguments expected).

**What Claude does:**

1. Compute `REPO=$(git rev-parse --show-toplevel)`.
2. Read state: `node "$STATE_SCRIPT" get "$REPO"`. If state is `{}` (no active session), tell the user: "No active session for this repo. Use `/pair-with-codex:start` to begin."
3. Print the persisted state: current phase, task description, iteration count, commits made so far, elapsed time.
4. If `codex_job.status == "running"`, reattach to the Codex job via `/codex:status` to check its current status before continuing.
5. Ask (hybrid): "Resume from phase `<phase>`? (y/n)"
6. In auto mode, resume immediately without prompting.
7. Jump to the persisted phase and continue from there. All state (flags, iteration, commits, spec_path) is read from the state file and honored.

---

## 9. Review Loop — Actionable Finding Classification

This is the full ruleset for Step 2 of the review loop (repeated here for emphasis because getting it wrong is the most common failure mode):

1. **Use Codex severity ratings as the primary signal.** Act on anything labeled medium or higher. Low/info severity items may be skipped unless they fall under rule 2.
2. **Pre-existing simple/isolated fixes ARE in scope.** If Codex flags a bug or quality issue that predates the current change but is a simple, isolated fix (e.g., a null check, a type error, an unused import that causes a warning), address it. Do not dismiss it as "out of scope" just because you did not introduce it.
3. **Skip only genuinely large refactors.** A finding is out of scope only if addressing it would require architectural changes, touching many files, or a significant design decision that the user has not authorized. A 2-line fix is never "too large."
4. **Nit-level style is not actionable.** Formatting preferences, naming conventions the project does not enforce, subjective code style — skip unless Codex rates them medium+.

When in doubt, err toward addressing the finding. It is better to make one extra small fix than to ship a known bug because it was "technically out of scope."

---

## 10. Error Handling

### Dirty tree refusal

Triggered when `git status --porcelain` is non-empty and `--allow-dirty` is not set.

```
Cannot start: working tree is dirty.
  Uncommitted changes detected. Clean up or commit first.
  Or re-run with --allow-dirty to proceed anyway.
```

For `polish`, the inverse applies — refuse if the tree is clean.

### Concurrent session refusal

Triggered when a state file already exists for this repo with a phase that is not `done`/`aborted`/`failed`.

```
Session already in progress for this repo:
  Task: <previous task>
  Phase: <phase>
  Started: <timestamp>
Run /pair-with-codex:status, /pair-with-codex:resume, or /pair-with-codex:abort first.
```

### Codex job errors — three sub-modes

**a) Codex companion reports an error.** Bubble up the exact error message verbatim. Write state `{ "phase": "failed", "error": "<exact error>" }`. Print a clear next-step message (usually: run `/codex:setup`, then `:resume`).

**b) Codex stalls** (no output for 10+ minutes, no status change):
- **Hybrid:** "Codex silent for 10min. [W]ait longer / [C]ancel and retry / [A]bort?" — wait for user choice.
- **Auto:** wait up to 30 minutes total, then cancel-and-retry once. If the second attempt also stalls, write state `{ "phase": "failed", "error": "Codex stalled twice" }` and stop.

**c) Codex returns but the diff is empty or nonsensical:**
- **Hybrid:** print Codex's output and ask "Codex made no changes. [C]ontinue to cleanup / [R]etry with clarification / [A]bort?" — never silently proceed.
- **Auto:** write state `{ "phase": "failed", "error": "codex produced no changes" }` and stop.

### Lint or test fails in cleanup — 3-attempt fix loop

1. Read the error output.
2. Edit the offending files to fix it.
3. Re-run the check.
4. Repeat up to 3 times.
5. If all 3 attempts fail: write `{ "phase": "failed", "error": "<last error text>" }`. Do not commit. Stop. Tell the user to fix manually and run `:resume` or `:abort`.

This applies in both hybrid and auto mode.

### Spec rejection at the approval gate (hybrid only)

If the user says "no" at the spec approval gate:

```
Spec rejected. What next?
  (r) Revise — re-enter brainstorming with feedback
  (a) Abort — clear state, leave spec file as-is
  (e) Edit spec manually — open <path>, I'll re-read when you say "continue"
```

Auto mode never reaches this gate.

### Branch already exists

If `--new-branch <name>` is requested and `<name>` already exists:

```
Cannot create branch: <name> already exists.
  Choose a different name with --new-branch <other-name>, or omit --new-branch to stay on the current branch.
```

### Non-git repository

If `git rev-parse --show-toplevel` fails at preflight:

```
Cannot start: this directory is not inside a git repository.
  pair-with-codex requires git. Initialize a repo first with `git init`.
```

---

## 11. Auto Mode Adaptations

In `--auto` mode, these specific behaviors differ from hybrid:

| Hybrid | Auto |
|---|---|
| Print resolved flag set → prompt "Proceed? (y/n/edit)" | Print resolved flag set → proceed immediately (no prompt) |
| Spec approval gate: prompt y/n/edit | Auto-approve; commit spec and continue |
| Implement→cleanup gate: prompt y/n/diff | Auto-continue |
| Cleanup→review gate: prompt y/n | Auto-continue |
| Between-rounds gate (N < max): prompt y/n/stop | Skip entirely; always continue |
| Codex stall (10min): prompt W/C/A | Wait up to 30min, cancel-retry once, then fail |
| Codex empty diff: prompt C/R/A | Write `failed` state and stop |
| Lint/test fails after 3 attempts: stop + message | Write `failed` state and stop |
| Spec rejection gate: show options r/a/e | Never reached (auto-approves spec) |

On any failure in auto mode: write `{ "phase": "failed", "error": "<description>" }` to state, then stop. The user wakes up to a `failed` state they can inspect, manually fix, and resume with `:resume`.

On success: produce the `last-run-summary.md` file in the session archive directory so the user has a record of what ran overnight.

---

## 12. Done Phase

When the loop exits (any `exit_reason`) or `start`/`polish` reaches completion:

1. Update state: `{ "phase": "done" }`.
2. Compute the archive directory: `~/.claude/pair-with-codex/sessions/archive/`.
3. Write `last-run-summary.md` alongside the archived state file. Contents:
   - Task description
   - Timing: `started_at`, completion time, total elapsed
   - Spec path (if applicable)
   - All commits made: sha + message, one per line
   - Final diff stats (`git diff <first-commit-sha>..HEAD --stat`)
   - `exit_reason`: `clean` | `max_rounds` | `user_stopped`
   - If `exit_reason == max_rounds`: the unresolved findings from the last review, so the user can decide whether to resume or ship as-is
4. Run `node "$STATE_SCRIPT" archive "$REPO"` to move the state file to `archive/`.
5. Print the summary to the user in the terminal.

Example summary format:

```
pair-with-codex complete
  Task:    add JWT auth
  Mode:    hybrid
  Started: 2026-04-13 22:15 UTC
  Elapsed: 47 minutes
  Spec:    docs/superpowers/specs/2026-04-13-jwt-auth-design.md
  Commits: 4 (spec + implement + cleanup + review 1)
  Result:  clean (no unresolved findings)
  Archive: ~/.claude/pair-with-codex/sessions/archive/<timestamp>-<hash>.json
```

---

## 13. Status and Abort Commands

### Status (`ENTRY_POINT: status`)

Read-only. Do not modify state.

1. Compute `REPO=$(git rev-parse --show-toplevel)`.
2. Read state: `node "$STATE_SCRIPT" get "$REPO"`.
3. If state is `{}`: "No active session for this repo."
4. Otherwise print:

```
pair-with-codex status
  Task:         <task_description>
  Phase:        <phase>
  Mode:         <mode>
  Iteration:    <iteration> / <flags.max_review_rounds>
  Commits:      <count> (<list of phases committed>)
  Codex job:    <status> (<job_id>) | none
  Started:      <started_at>
  Elapsed:      <computed from started_at to now>
  State file:   ~/.claude/pair-with-codex/sessions/<hash>.json
```

### Abort (`ENTRY_POINT: abort`)

1. Compute `REPO=$(git rev-parse --show-toplevel)`.
2. Read state for a summary before clearing.
3. Run `node "$STATE_SCRIPT" clear "$REPO"` — this deletes the state file only. Git is not touched: any commits already made remain on the branch.
4. Print:

```
Session aborted.
  Task:    <task_description>
  Phase at abort: <phase>
  Commits made (still on branch):
    <sha>  <message>
    ...
  State file cleared. Run /pair-with-codex:start for a fresh session.
```

---

## Critical Constraints Summary

These rules are non-negotiable. Violating any of them is a bug in the skill execution.

- **Never** call `/codex:rescue` without `--write` in Phase 3. Codex must be write-capable to implement.
- **Never** silently proceed if Codex returns an empty diff. Always ask (hybrid) or fail (auto).
- **Always** use the exact commit message formats: `spec: <title>`, `implement: <title>`, `cleanup: <title>`, `review <N>: <summary>`.
- **Refuse** on a dirty tree unless `--allow-dirty` is explicitly set (except `polish`, which inverts this).
- **Never** create a branch unless `--new-branch` or `--new-worktree` is explicitly set.
- **Skip** the between-rounds hybrid gate on the final iteration (`N == max_review_rounds`). There is nothing left to decide.
- **Persist every phase transition** to state via `session-state.mjs update` before continuing. A crash must leave state pointing at the last completed phase, not a partial one.
- **The state file is keyed by sha1 of `git rev-parse --show-toplevel`**. Use `node "$STATE_SCRIPT" hash "$REPO"` if you need the hash; the script handles the hashing — do not compute it by hand.
- **Pre-existing simple/isolated fixes ARE in scope** during the review loop. Do not dismiss findings as "out of scope" unless they require a large refactor.
