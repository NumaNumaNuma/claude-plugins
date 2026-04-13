# pair-with-codex — design spec

**Date:** 2026-04-13
**Status:** Approved for planning
**Target repo:** `/Users/numa/JigSpace/Repos/perso/claude-plugins/`

## Purpose

A Claude Code plugin that orchestrates a collaborative workflow between Claude and OpenAI Codex: Claude plans and writes the spec, Codex implements, Claude cleans up, Codex reviews, Claude addresses findings, loop until clean, then commit. Runs in hybrid mode (pauses at phase boundaries for user confirmation) or fully autonomous mode for overnight runs.

## Background and context

The existing ecosystem already provides the individual pieces needed for this workflow:

- `superpowers:brainstorming` and `superpowers:writing-plans` — produce specs and implementation plans
- `codex:codex-rescue` (via `/codex:rescue`) — delegates write-capable coding tasks to Codex
- `codex:adversarial-review` (via `/codex:review`) — Codex adversarial code review
- `simplify` skill — post-implementation cleanup, applies project best practices to changed code
- `/codex:status`, `/codex:result`, `/codex:cancel` — background job control for Codex tasks

What is missing is the orchestration glue that strings these together into a single repeatable flow with state tracking, pause gates, and termination logic. This plugin provides that glue.

## Goals

- Give the user a single entry point to run a full plan-implement-review-simplify loop that leverages both Claude and Codex.
- Support a hybrid default with user confirmation at each phase boundary, and a fully autonomous mode for unattended runs.
- Support an alternative quick-fix entry point that skips planning for small changes already in flight.
- Track progress across phases in a state file so sessions can be resumed after terminal restarts or mid-flow interruptions.
- Allow multiple concurrent runs across different repositories without state contention.
- Commit each phase separately so the user can inspect what happened at each stage.

## Non-goals

- Unit tests for the plugin itself. Smoke tests only.
- Automated test harness for the phase flow. Smoke tests are walked through by hand.
- Automatic git branch management. The harness stays on the current branch unless explicitly asked to create a new branch or worktree.
- Parallel execution of multiple phases within a single run.
- Cross-session background execution that survives terminal close. The user must leave the Claude session open for the duration of the run.

## High-level architecture

### Plugin location

```
/Users/numa/JigSpace/Repos/perso/claude-plugins/pair-with-codex/
```

### File layout

```
pair-with-codex/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── start.md        # /pair-with-codex:start
│   ├── polish.md       # /pair-with-codex:polish
│   ├── resume.md       # /pair-with-codex:resume
│   ├── status.md       # /pair-with-codex:status
│   └── abort.md        # /pair-with-codex:abort
├── skills/
│   └── pair-with-codex-flow/
│       └── SKILL.md
├── scripts/
│   └── session-state.mjs
├── testing/
│   ├── setup-toy-repo.sh
│   └── smoke/
│       ├── happy-path.md
│       ├── dirty-tree-refusal.md
│       ├── concurrent-refusal.md
│       ├── resume-after-kill.md
│       ├── auto-mode.md
│       ├── polish-flow.md
│       ├── lint-failure-recovery.md
│       └── codex-empty-diff.md
└── CLAUDE.md
```

### Responsibility split

- **Command `.md` files:** thin forwarders. Each one parses any positional or flag arguments from `$ARGUMENTS` and invokes the `pair-with-codex-flow` skill with those inputs. Modeled on the pattern used by `/codex:rescue`.
- **`pair-with-codex-flow` skill:** the real brain. Contains the full phase flow, the pause-gate behavior, the auto-mode behavior, error recovery logic, and guidance on how to judge findings as actionable. All five commands route through this skill so the flow logic lives in exactly one place.
- **`session-state.mjs`:** a small Node script with a narrow API for reading, writing, clearing, listing, and archiving per-repo session state. Called from the skill via `Bash`. Implementation stays small and dependency-free so it does not need its own tests.

### External dependencies

- `superpowers` plugin (for `brainstorming`, `writing-plans`, `simplify`)
- `codex` plugin (for `/codex:rescue`, `/codex:review`, `/codex:status`)

These are assumed to be installed. The plugin does not attempt to verify or install them; the skill instructs the user to install them if an invocation fails because they are missing.

## Commands and flags

### `/pair-with-codex:start "task description"`

Starts the full flow: preflight → plan → spec approval → implement → cleanup → review loop → done.

**Arguments:**

- Positional: task description (required unless `--resume-existing-spec <path>`)
- `--auto` — skip all pause gates, run unattended. Spec is still written and committed.
- `--allow-dirty` — do not refuse on a dirty working tree
- `--max-review-rounds N` — override the default of 5
- `--new-branch [name]` — opt in to branch creation. If `name` is omitted, the branch is auto-named from the task (for example `feature/add-jwt-auth`). If the task mentions a Jira ticket (`JIG-\d+`) the branch follows the `feature/JIG-xxxx-<slug>` pattern.
- `--new-worktree` — opt in to worktree creation. Implies `--new-branch`.
- `--resume-existing-spec <path>` — skip brainstorming and start from the implement phase, using the given spec file as input for Codex.

### `/pair-with-codex:polish`

Quick-fix tail. Assumes the working tree already contains changes (made by Claude earlier in the conversation, or by the user by hand). Runs cleanup → review loop → done. Skips planning and implementation.

**Arguments:**

- `--auto`
- `--max-review-rounds N`
- An optional short description to use as the commit message prefix, for example `"fix null pointer in DataProcessor"`. If omitted, a short description is auto-generated from the diff.

Refuses to run if the working tree is clean (nothing to polish).

### `/pair-with-codex:resume`

Reads the current repo's session state, prints the last known phase and recent commits, and asks the user whether to resume. If Codex was running as a background job, the skill reattaches via `/codex:status` before continuing. No arguments.

### `/pair-with-codex:status`

Read-only. Prints the current phase, task description, iteration count, commits made so far, Codex job status if applicable, and elapsed time. No arguments.

### `/pair-with-codex:abort`

Clears the session state file for the current repo. Does not touch git — any commits already made remain on the branch. Prints a summary of what was left behind.

## Invocation paths and flag parsing

The flow skill must produce the same resolved flag set regardless of how it was invoked.

### Path A — explicit slash command with args

```
/pair-with-codex:start "add JWT auth" --auto --new-branch
```

The command `.md` forwards `$ARGUMENTS` to the skill. The skill parses explicit `--flags` from that text.

### Path B — natural conversation

```
You: "Let's pair with codex on adding JWT auth — run it in full auto mode
      and make a new branch for it"
```

Claude recognizes the intent from the skill's description and invokes the skill. The skill's parsing logic maps natural-language hints to flags using the table below.

### Path C — slash command without args, conversational follow-up

```
You: /pair-with-codex:start
Claude: What should I pair with Codex on?
You: "Adding JWT auth, run it overnight"
```

The same parser is applied to the follow-up reply.

### Natural-language phrase mapping

| Phrase | Flag |
|---|---|
| "auto", "autonomous", "overnight", "unattended", "don't wait for me" | `--auto` |
| "ignore the dirty tree", "just proceed", "I know there's uncommitted stuff" | `--allow-dirty` |
| "new branch", "make a branch", "on a branch" | `--new-branch` |
| "new worktree", "isolate it" | `--new-worktree` |
| "up to N rounds", "N reviews max" | `--max-review-rounds N` |

### Confirmation before starting

Regardless of path, the skill echoes back the resolved flag set before doing anything:

```
Starting pair-with-codex:
  Task: add JWT auth
  Mode: autonomous (no pause gates)
  Branch: new (feature/add-jwt-auth)
  Max review rounds: 5
  Working tree: clean ✓
Proceed? (y/n/edit)
```

The `edit` option lets the user tweak any flag without restarting the invocation. In `--auto` mode the resolved flag set is still printed so the user can see what was parsed, but the skill **does not** prompt for a y/n and proceeds immediately. The user can always abort with ESC if they spot a typo.

## State file

### Location

```
~/.claude/pair-with-codex/sessions/<sha1-of-git-root>.json
```

The hash is computed from the absolute path returned by `git rev-parse --show-toplevel`. This scheme means:

- Each repository has its own session file, so multiple repos can run concurrently.
- The same repo always produces the same hash, so `:resume` can find the right file without any user input.
- No files are written inside the target repo itself. No `.gitignore` changes are needed.

On successful completion, the state file is moved to `~/.claude/pair-with-codex/sessions/archive/<timestamp>-<hash>.json`, and a `last-run-summary.md` is written alongside.

### Schema

```json
{
  "version": 1,
  "repo_path": "/Users/numa/JigSpace/Repos/project-x",
  "repo_hash": "a1b2c3...",
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

### Valid phase values

`preflight`, `plan`, `spec_approval`, `implement`, `cleanup`, `review_loop`, `done`, `aborted`, `failed`.

Writes are atomic: the script writes to a `.tmp` file and renames, so a crash mid-write cannot leave a half-written file.

### Script API

`session-state.mjs` exposes these operations via CLI subcommands so the skill can call them from `Bash`:

- `get <repo-path>` — prints the JSON state file contents, or `{}` if none
- `set <repo-path> <json>` — writes the given JSON as the new state
- `update <repo-path> <json-patch>` — merges a partial update into the current state
- `clear <repo-path>` — deletes the state file
- `archive <repo-path>` — moves the state file to `archive/` with a timestamp prefix
- `list` — lists all active session files and their phases
- `hash <repo-path>` — prints the sha1 used for the state file name

## Phase flow (full start)

Running `/pair-with-codex:start "add JWT auth"` in hybrid mode.

### Phase 1 — Preflight

- Verify current directory is inside a git repository. If not, abort with a clear message.
- Run `git status --porcelain`. If non-empty and `--allow-dirty` is not set, abort.
- Run a Codex companion health check. If Codex is missing or unauthenticated, abort and instruct the user to run `/codex:setup`.
- Compute the repo hash and write the initial state file with phase `preflight` transitioning to `plan`.
- If `--new-branch` or `--new-worktree` is set, create the branch or worktree. If the branch already exists, abort and tell the user to pick a different name.

### Phase 2 — Plan

- Invoke `superpowers:brainstorming` with the task description. Let it run its full flow (clarifying questions → propose approaches → present design → spec doc).
- When brainstorming hands off to `superpowers:writing-plans`, let that run as well.
- Once the spec and plan are written, the skill reaches the spec approval gate.
- **Gate (hybrid):** ask "Spec ready at `<path>`. Approve and continue to implementation? (y/n/edit)". The `edit` option opens the spec for manual editing and re-reads it on the user's signal.
- **Gate (auto):** auto-approve.
- Commit the spec file as `spec: <task title>`.
- Update state: `phase = implement`, `spec_path = <path>`.

### Phase 3 — Implement

- Invoke `/codex:rescue --write --background` with a prompt that references the spec file and instructs Codex to implement per the spec.
- Capture the Codex job ID from the rescue output and persist it to state.
- Poll `/codex:status` every 30 seconds. Between polls Claude does nothing else; the session must stay open.
- When Codex reports done, run `git add -A && git commit -m "implement: <task title>"`.
- **Gate (hybrid):** "Codex done. N files changed, +X -Y lines. Continue to cleanup? (y/n/diff)". The `diff` option prints the diff and re-prompts.
- **Gate (auto):** auto-continue.
- Update state: `phase = cleanup`.

### Phase 4 — Cleanup

- Invoke the `simplify` skill, scoped to the diff Codex just produced.
- Let `simplify` review and fix issues inline.
- **Detect** project-local checks from manifest files present in the repo: `package.json` → `npm run lint` and `npm test`, `Package.swift` or `.xcodeproj` → `swift build`, `Cargo.toml` → `cargo check` and `cargo test`, etc. Detection is heuristic and may miss non-standard setups.
- **Run every detected check. Each one is required to pass.** If any check fails, Claude gets up to 3 attempts to fix the failure (read the error, edit files, re-run). If all 3 attempts fail, abort the cleanup phase with state `failed` and do not commit. This applies in both hybrid and auto mode.
- If no checks were detected at all, log a note in state (`checks_detected: []`) and proceed without blocking, but include the missing-checks note in the Done summary so the user knows to verify manually.
- If cleanup produced changes, commit as `cleanup: <task title>`. If nothing changed, record "cleanup: no changes" in state but do not create an empty commit.
- **Gate (hybrid):** "Cleanup done. Continue to review loop? (y/n)".
- **Gate (auto):** auto-continue.
- Update state: `phase = review_loop`, `iteration = 0`.

### Phase 5 — Review loop

For `N` from 1 up to `max_review_rounds`:

1. **Run review.** Invoke `/codex:review`. This is a read-only review and can run in the foreground.
2. **Classify findings.** Parse Codex's review output. Claude determines which findings are actionable:
   - Lean on Codex's own severity ratings if present. Act on anything labeled medium or higher.
   - **Include pre-existing issues if they are simple and isolated fixes.** Do not dismiss findings just because they are "out of scope" — the scope includes easy wins in surrounding code.
   - Skip only findings that would require a large refactor or a significant out-of-scope change.
   - Nit-level style suggestions are not actionable unless Codex explicitly flags them as a problem.
3. **Check clean.** If no actionable findings remain, break out of the loop with `exit_reason = clean` and go to Done.
4. **Address findings.** Claude reads, edits, and re-runs cleanup checks for each actionable finding.
5. **Commit.** `review <N>: <short summary of what was addressed>`.
6. **Update state.** `iteration = N`.
7. **Check ceiling.** If `N == max_review_rounds`, break out of the loop with `exit_reason = max_rounds` and go to Done. (The hybrid gate below is skipped on the last iteration — there is nothing left to decide.)
8. **Gate (hybrid only, N < max):** "Round N done. Codex found M issues, addressed all. Run another review? (y/n/stop)". If the user says no or stop, break with `exit_reason = user_stopped`. In auto mode this step is skipped entirely.
9. Continue to iteration N+1.

When the loop exits with `exit_reason = max_rounds`, the Done phase surfaces the remaining unresolved findings from the last review in the summary so the user can decide whether to resume or ship as-is.

### Phase 6 — Done

- Write `last-run-summary.md` in the session archive dir. Contents:
  - Task description
  - Timing (start, end, total elapsed)
  - Spec path
  - Commits made (with SHAs and messages)
  - Final diff stats
  - Any unresolved review findings (if the loop hit the ceiling)
- Archive the state file.
- Print the summary to the user.

## Polish flow

`/pair-with-codex:polish` starts at Phase 4 (Cleanup) and skips phases 1 through 3.

- Preflight still runs, but the "clean tree" check is **inverted**: `polish` requires a non-empty diff (otherwise there is nothing to polish) and refuses if the tree is clean.
- No spec and no spec commit.
- The first commit is `cleanup: <description>`, where description comes from the polish command's optional argument or is auto-generated from the diff.
- Everything after Phase 4 is identical to the full flow.

## Auto mode

- All pause gates are skipped: spec approval, implement-to-cleanup, cleanup-to-review, and between-rounds within the review loop.
- The resolved-flag-set summary is still printed before the run starts, but auto mode does not prompt for a y/n — the flow starts immediately. The user can abort with ESC if they spot a problem.
- If any phase fails (Codex error, unfixable lint/test, empty Codex diff, unhandled exception), auto mode **stops** and writes state with `phase = failed` including the error details. The user wakes up to a failed-state file they can inspect, manually fix, and resume from.
- On success, the run produces a `last-run-summary.md` file in the session archive dir for the user to read in the morning.

## Error handling and edge cases

### Concurrent invocation in the same repo

If `/pair-with-codex:start` is run and a session state file already exists for this repo (phase not `done`/`aborted`), refuse:

```
Session already in progress for this repo:
  Task: <previous task>
  Phase: <phase>
  Started: <timestamp>
Run /pair-with-codex:status, /pair-with-codex:resume, or /pair-with-codex:abort first.
```

Multi-repo concurrent runs work because state files are keyed by repo hash.

### Spec rejection at the approval gate (hybrid only)

If the user says "no" at the spec approval gate:

```
Spec rejected. What next?
  (r) Revise — re-enter brainstorming with feedback
  (a) Abort — clear state, leave spec file as-is
  (e) Edit spec manually — open <path>, I'll re-read when you say "continue"
```

Auto mode never reaches this gate.

### Codex job errors

Three failure modes are handled:

**a) Codex companion reports an error.** Bubble up the exact error, write state `phase = failed`, and print a clear next-step message to the user (usually `/codex:setup` or retry).

**b) Codex stalls.** No output for 10 or more minutes and no status change. In hybrid mode, print a warning and ask "Codex silent for 10min. Wait longer / cancel and retry / abort?". In auto mode, wait up to 30 minutes total then cancel-and-retry once; if the second attempt also stalls, fail the phase.

**c) Codex returns but the diff is empty or nonsensical.** In hybrid mode, print Codex's output and ask "Codex made no changes. Continue to cleanup / retry with clarification / abort?". In auto mode, fail the phase with `failed: codex produced no changes`. Never silently proceed — that would be a silent failure.

### Lint or test fails in cleanup, Claude cannot fix

Up to 3 attempts. Each attempt reads the error, edits the offending files, re-runs the check. If all 3 attempts fail, abort the cleanup phase, write `phase = failed` with the last error, and do not commit. Both hybrid and auto modes stop here. The user resolves manually and runs `:resume` or `:abort`.

### User hits ESC mid-flow

ESC cancels the current tool call. The skill does not treat this as a clean cancel — state may be partial. Phase transitions are written atomically, so the next `/pair-with-codex:status` always reflects the last persisted phase. The user runs `:resume` to continue or `:abort` to clear.

### Branch already exists

If `--new-branch feature/xyz` is requested and `feature/xyz` already exists, refuse at preflight with a message asking for a different name.

### Large diffs and context pressure

If Codex's implement diff is very large (hundreds of lines across many files), the cleanup phase's `simplify` invocation might exceed context. The skill notes this as a risk and instructs future Claude to chunk `simplify` per-file if necessary. No upfront optimization — only apply if it becomes a real problem.

### Non-git repositories

Refused at preflight with a clear message. The harness is git-dependent and cannot operate without a repo.

## Testing strategy

Smoke tests only. No unit tests. No automated test harness.

### Smoke test layout

Each smoke test is a markdown checklist in `testing/smoke/` that walks a human through a specific scenario and defines what "passing" looks like.

- `happy-path.md` — full flow on a toy repo with a small task, verifying the spec → implement → cleanup → review → done sequence and commit count.
- `dirty-tree-refusal.md` — verify refusal on dirty tree, verify `--allow-dirty` override.
- `concurrent-refusal.md` — two `:start` calls in the same repo, second is refused.
- `resume-after-kill.md` — kill Claude mid-implement, run `:resume` in a new session, verify reattach.
- `auto-mode.md` — trivial task in `--auto` mode, no pauses, clean finish.
- `polish-flow.md` — make local edits, run `:polish`, verify cleanup and review.
- `lint-failure-recovery.md` — Codex prompt that produces lint-failing code, verify Claude's 3-attempt fix loop.
- `codex-empty-diff.md` — trivial task, verify we do not silently proceed on empty Codex output.

### Toy repo

`testing/setup-toy-repo.sh` creates a minimal reproducible fixture with a `package.json`, a simple lint rule, a trivial test, and placeholder code. Smoke tests all start from this baseline.

## Implementation approach

Implementation must use the `skill-creator` skill when building the `pair-with-codex-flow` skill. The command `.md` files are thin forwarders and the `session-state.mjs` script is small utility code, but the skill is where the orchestration logic lives and where it matters most for Claude to be able to follow the instructions reliably across all invocation paths.

The implementation plan (produced by `writing-plans` after this spec is approved) will break the work into sequenced tasks and explicitly call out `skill-creator` as the tool for the skill-authoring step.

## Open questions

None. All decisions have been made during brainstorming.
