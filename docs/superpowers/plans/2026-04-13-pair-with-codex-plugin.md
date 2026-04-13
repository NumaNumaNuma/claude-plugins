# pair-with-codex Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `pair-with-codex` Claude Code plugin that orchestrates a full plan → implement → cleanup → review loop with Claude and OpenAI Codex, in hybrid or autonomous mode.

**Architecture:** Five thin slash-command `.md` forwarders route into a single `pair-with-codex-flow` skill that contains all orchestration logic. A small Node state script (`session-state.mjs`) persists per-repo session state keyed by a hash of the git root path. The skill delegates to existing plugins (`superpowers` for planning and simplify, `codex` for Codex tasks).

**Tech Stack:** Markdown (slash commands, skill prose, CLAUDE.md, smoke tests), Node.js ESM (state script), Bash (toy repo setup script).

**Source of truth:** `docs/superpowers/specs/2026-04-13-pair-with-codex-design.md` (in this same repo). Every task below traces back to a specific section of that spec.

**Working directory for all tasks:** `/Users/numa/JigSpace/Repos/perso/claude-plugins/`. All commands assume you `cd` there first.

**Branch:** Stay on `main`. Do not create a feature branch (follows the user's default behavior preference, consistent with the spec itself being committed to main).

**Global preconditions:**
- Git status is clean before starting each task (commits at the end of each task; do not leave WIP between tasks).
- `node --version` reports ≥ 18 (needed for ESM + built-in `node:crypto`).

---

## File structure (decomposition)

```
pair-with-codex/
├── .claude-plugin/
│   └── plugin.json                             # Task 1
├── CLAUDE.md                                   # Task 1
├── commands/
│   ├── start.md                                # Task 4
│   ├── polish.md                               # Task 4
│   ├── resume.md                               # Task 4
│   ├── status.md                               # Task 4
│   └── abort.md                                # Task 4
├── skills/
│   └── pair-with-codex-flow/
│       └── SKILL.md                            # Task 3
├── scripts/
│   └── session-state.mjs                       # Task 2
└── testing/
    ├── setup-toy-repo.sh                       # Task 5
    └── smoke/
        ├── happy-path.md                       # Task 5
        ├── dirty-tree-refusal.md               # Task 5
        ├── concurrent-refusal.md               # Task 5
        ├── resume-after-kill.md                # Task 5
        ├── auto-mode.md                        # Task 5
        ├── polish-flow.md                      # Task 5
        ├── lint-failure-recovery.md            # Task 5
        └── codex-empty-diff.md                 # Task 5
```

Each file has one clear responsibility. Commands forward arguments. The skill owns all orchestration logic. The state script owns all state file I/O. Smoke tests are reproducible walkthroughs keyed to spec scenarios.

**Build order:** Task 1 → 2 → 3 → 4 → 5 → 6. Task 3 depends on Task 2 (skill calls the state script). Task 4 depends on Task 3 (commands forward to skill). Task 5 can be done after Task 4. Task 6 validates everything.

---

## Task 1: Plugin scaffold and manifest

**Goal:** Create the plugin directory structure, `plugin.json` manifest, and a minimal `CLAUDE.md` overview.

**Files:**
- Create: `pair-with-codex/.claude-plugin/plugin.json`
- Create: `pair-with-codex/CLAUDE.md`
- Create: (empty directories) `pair-with-codex/commands/`, `pair-with-codex/skills/pair-with-codex-flow/`, `pair-with-codex/scripts/`, `pair-with-codex/testing/smoke/`

**Spec references:** "High-level architecture" → "File layout".

- [ ] **Step 1.1: Create directories**

```bash
cd /Users/numa/JigSpace/Repos/perso/claude-plugins
mkdir -p pair-with-codex/.claude-plugin
mkdir -p pair-with-codex/commands
mkdir -p pair-with-codex/skills/pair-with-codex-flow
mkdir -p pair-with-codex/scripts
mkdir -p pair-with-codex/testing/smoke
```

Expected: no output, directories exist.

- [ ] **Step 1.2: Write `plugin.json`**

Create `pair-with-codex/.claude-plugin/plugin.json` with exactly this content:

```json
{
  "name": "pair-with-codex",
  "description": "Orchestrate a Claude + Codex collaborative loop: Claude plans, Codex implements, Claude cleans up, Codex reviews, loop until clean, then commit. Hybrid pauses by default, autonomous mode for overnight runs.",
  "version": "0.1.0",
  "author": {
    "name": "Numa Claude-Codex Flow"
  }
}
```

- [ ] **Step 1.3: Write `CLAUDE.md`**

Create `pair-with-codex/CLAUDE.md` with exactly this content:

```markdown
# pair-with-codex

Plugin that orchestrates a Claude + Codex collaborative workflow.

## What it does

Routes a development task through a repeatable pipeline:

1. **Plan** — Claude runs `superpowers:brainstorming` + `superpowers:writing-plans` to produce a spec and implementation plan
2. **Implement** — Codex is invoked via `/codex:rescue --write --background` to implement per the spec
3. **Cleanup** — Claude runs the `simplify` skill and any detected project checks (lint, test, build) on the Codex diff
4. **Review loop** — `/codex:review` produces findings, Claude addresses them, loop up to 5 rounds or until clean
5. **Done** — archive state, write a summary

## Commands

- `/pair-with-codex:start "task"` — full flow
- `/pair-with-codex:polish` — quick-fix tail (skip planning, start from cleanup)
- `/pair-with-codex:resume` — continue a session after interruption
- `/pair-with-codex:status` — show current phase, commits, timing
- `/pair-with-codex:abort` — clear session state

## Modes

- **Hybrid (default):** pauses at each phase boundary for user confirmation
- **Autonomous (`--auto`):** runs the full flow unattended, stops on failure

## State

Per-repo session state lives in `~/.claude/pair-with-codex/sessions/<hash>.json`, keyed by the sha1 of `git rev-parse --show-toplevel`. Multiple repos run concurrently without contention.

## Dependencies

- `superpowers` plugin (brainstorming, writing-plans, simplify)
- `codex` plugin (codex:rescue, codex:review, codex:status)

See `docs/superpowers/specs/2026-04-13-pair-with-codex-design.md` in the plugin repo for the full design.
```

- [ ] **Step 1.4: Verify plugin structure is valid**

Run: `cat pair-with-codex/.claude-plugin/plugin.json | python3 -m json.tool`

Expected: pretty-printed JSON with no errors.

Run: `ls -la pair-with-codex/`

Expected output shows: `.claude-plugin/`, `CLAUDE.md`, `commands/`, `scripts/`, `skills/`, `testing/`.

- [ ] **Step 1.5: Commit**

```bash
cd /Users/numa/JigSpace/Repos/perso/claude-plugins
git add pair-with-codex/.claude-plugin/plugin.json pair-with-codex/CLAUDE.md
git commit -m "pair-with-codex: scaffold plugin manifest and overview"
```

Note: empty directories are not tracked by git. They will be added automatically when files are created inside them in later tasks.

---

## Task 2: Session state script

**Goal:** Implement `session-state.mjs` — a small Node ESM script that reads, writes, updates, archives, lists, and hashes per-repo session files.

**Files:**
- Create: `pair-with-codex/scripts/session-state.mjs`

**Spec references:** "State file" → "Location", "Schema", "Script API".

- [ ] **Step 2.1: Write the state script**

Create `pair-with-codex/scripts/session-state.mjs` with exactly this content:

```javascript
#!/usr/bin/env node
// session-state.mjs — per-repo session state for pair-with-codex.
// Keyed by sha1 of the git root absolute path. No external dependencies.

import { createHash } from "node:crypto";
import { readFileSync, writeFileSync, renameSync, mkdirSync, existsSync, readdirSync, unlinkSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join, resolve } from "node:path";

const BASE_DIR = join(homedir(), ".claude", "pair-with-codex");
const SESSIONS_DIR = join(BASE_DIR, "sessions");
const ARCHIVE_DIR = join(SESSIONS_DIR, "archive");

function ensureDirs() {
  mkdirSync(SESSIONS_DIR, { recursive: true });
  mkdirSync(ARCHIVE_DIR, { recursive: true });
}

function hashPath(repoPath) {
  const normalized = resolve(repoPath);
  return createHash("sha1").update(normalized).digest("hex");
}

function sessionFile(repoPath) {
  return join(SESSIONS_DIR, `${hashPath(repoPath)}.json`);
}

function readState(repoPath) {
  const file = sessionFile(repoPath);
  if (!existsSync(file)) return null;
  try {
    return JSON.parse(readFileSync(file, "utf8"));
  } catch (err) {
    process.stderr.write(`warning: malformed state file ${file}: ${err.message}\n`);
    return null;
  }
}

function writeStateAtomic(repoPath, state) {
  ensureDirs();
  const file = sessionFile(repoPath);
  const tmp = `${file}.tmp`;
  writeFileSync(tmp, JSON.stringify(state, null, 2));
  renameSync(tmp, file);
}

function mergeState(current, patch) {
  if (current === null) return patch;
  return { ...current, ...patch, updated_at: new Date().toISOString() };
}

function archiveState(repoPath) {
  ensureDirs();
  const file = sessionFile(repoPath);
  if (!existsSync(file)) return null;
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const dest = join(ARCHIVE_DIR, `${timestamp}-${hashPath(repoPath)}.json`);
  renameSync(file, dest);
  return dest;
}

function clearState(repoPath) {
  const file = sessionFile(repoPath);
  if (existsSync(file)) unlinkSync(file);
}

function listSessions() {
  if (!existsSync(SESSIONS_DIR)) return [];
  return readdirSync(SESSIONS_DIR)
    .filter((name) => name.endsWith(".json"))
    .map((name) => {
      try {
        const content = JSON.parse(readFileSync(join(SESSIONS_DIR, name), "utf8"));
        return {
          file: name,
          repo_path: content.repo_path,
          phase: content.phase,
          task_description: content.task_description,
          updated_at: content.updated_at,
        };
      } catch {
        return { file: name, error: "unreadable" };
      }
    });
}

function usage() {
  process.stderr.write(
    "usage:\n" +
    "  session-state.mjs get <repo-path>\n" +
    "  session-state.mjs set <repo-path> <json>\n" +
    "  session-state.mjs update <repo-path> <json-patch>\n" +
    "  session-state.mjs clear <repo-path>\n" +
    "  session-state.mjs archive <repo-path>\n" +
    "  session-state.mjs list\n" +
    "  session-state.mjs hash <repo-path>\n"
  );
}

function main(argv) {
  const [subcmd, ...rest] = argv;
  switch (subcmd) {
    case "get": {
      const state = readState(rest[0]);
      process.stdout.write(state ? JSON.stringify(state, null, 2) : "{}");
      process.stdout.write("\n");
      return 0;
    }
    case "set": {
      const state = JSON.parse(rest[1]);
      writeStateAtomic(rest[0], state);
      return 0;
    }
    case "update": {
      const patch = JSON.parse(rest[1]);
      const current = readState(rest[0]);
      writeStateAtomic(rest[0], mergeState(current, patch));
      return 0;
    }
    case "clear":
      clearState(rest[0]);
      return 0;
    case "archive": {
      const dest = archiveState(rest[0]);
      if (dest) process.stdout.write(`${dest}\n`);
      return 0;
    }
    case "list": {
      process.stdout.write(JSON.stringify(listSessions(), null, 2));
      process.stdout.write("\n");
      return 0;
    }
    case "hash":
      process.stdout.write(`${hashPath(rest[0])}\n`);
      return 0;
    default:
      usage();
      return 1;
  }
}

process.exit(main(process.argv.slice(2)));
```

- [ ] **Step 2.2: Make it executable**

```bash
cd /Users/numa/JigSpace/Repos/perso/claude-plugins
chmod +x pair-with-codex/scripts/session-state.mjs
```

- [ ] **Step 2.3: Smoke-verify the script manually**

These are not unit tests — they are quick manual checks to confirm the script works. Run each and check the output.

```bash
cd /Users/numa/JigSpace/Repos/perso/claude-plugins

# hash: expect a 40-char hex string
node pair-with-codex/scripts/session-state.mjs hash /tmp/fake-repo

# get on nonexistent: expect "{}"
node pair-with-codex/scripts/session-state.mjs get /tmp/fake-repo

# set: write minimal state
node pair-with-codex/scripts/session-state.mjs set /tmp/fake-repo '{"version":1,"phase":"plan","task_description":"test"}'

# get: expect the JSON we just wrote
node pair-with-codex/scripts/session-state.mjs get /tmp/fake-repo

# update: merge phase change
node pair-with-codex/scripts/session-state.mjs update /tmp/fake-repo '{"phase":"implement"}'

# get: expect phase to be "implement" and updated_at to be set
node pair-with-codex/scripts/session-state.mjs get /tmp/fake-repo

# list: expect an array with one entry
node pair-with-codex/scripts/session-state.mjs list

# archive: expect a path printed
node pair-with-codex/scripts/session-state.mjs archive /tmp/fake-repo

# get: expect "{}" again (archived, not in active sessions)
node pair-with-codex/scripts/session-state.mjs get /tmp/fake-repo

# clear on nonexistent: expect silent no-op (exit 0)
node pair-with-codex/scripts/session-state.mjs clear /tmp/fake-repo
echo "exit: $?"
```

Expected: each command behaves as commented. If any step fails, fix the script before proceeding.

- [ ] **Step 2.4: Clean up smoke-check artifacts**

```bash
# Archive from smoke check will be left behind in ~/.claude/pair-with-codex/sessions/archive/.
# Remove it so we do not ship test debris.
ls ~/.claude/pair-with-codex/sessions/archive/
rm ~/.claude/pair-with-codex/sessions/archive/*-$(node /Users/numa/JigSpace/Repos/perso/claude-plugins/pair-with-codex/scripts/session-state.mjs hash /tmp/fake-repo).json 2>/dev/null || true
```

- [ ] **Step 2.5: Commit**

```bash
cd /Users/numa/JigSpace/Repos/perso/claude-plugins
git add pair-with-codex/scripts/session-state.mjs
git commit -m "pair-with-codex: add session-state script"
```

---

## Task 3: pair-with-codex-flow skill (the orchestration brain)

**Goal:** Write `SKILL.md` for the `pair-with-codex-flow` skill. This is the biggest and most critical artifact — it contains all phase logic, gate behavior, flag parsing, error handling, and auto-mode adaptations.

**Files:**
- Create: `pair-with-codex/skills/pair-with-codex-flow/SKILL.md`

**Spec references:** This task implements the entire spec. Relevant sections: "Commands and flags", "Invocation paths and flag parsing", "Phase flow (full start)", "Polish flow", "Auto mode", "Error handling and edge cases".

**Implementation approach:** Use the `skill-creator` skill. The user explicitly requested it, and `skill-creator` is purpose-built for producing high-quality SKILL.md files.

- [ ] **Step 3.1: Invoke `skill-creator`**

Use `Skill({ skill: "skill-creator:skill-creator" })` to begin the skill-authoring flow.

- [ ] **Step 3.2: Provide skill-creator with the following inputs**

When `skill-creator` asks for skill metadata and content, use this:

**Name:** `pair-with-codex-flow`

**Description (the `description:` frontmatter field — this is the trigger text Claude matches on):**

```
Orchestrate a Claude + Codex collaborative development loop. Use when the user asks to pair Claude with Codex, run a plan → implement → review → simplify workflow, kick off an overnight coding session, use /pair-with-codex:start, /pair-with-codex:polish, /pair-with-codex:resume, /pair-with-codex:status, or /pair-with-codex:abort, or describes wanting Codex to implement a spec while Claude reviews and cleans up.
```

**Source of truth for the skill body:** `/Users/numa/JigSpace/Repos/perso/claude-plugins/docs/superpowers/specs/2026-04-13-pair-with-codex-design.md`. The skill-creator should read this spec and use it as the authoritative source for everything the skill needs to tell Claude to do.

**Sections the skill body MUST include, in this order:**

1. **Overview (3-5 sentences)** — what the skill does, when it is triggered, the two modes.
2. **Preconditions** — the user has `superpowers` and `codex` plugins installed; `/codex:setup` has been run; git repository.
3. **Entry point routing** — how to tell which command was invoked based on `$ARGUMENTS`. Maps command names to starting phases.
4. **Flag parsing** — parse explicit `--flags` from `$ARGUMENTS`; map natural-language phrases (table from spec section "Natural-language phrase mapping") to flags when the skill is invoked without the slash command; confirm resolved flag set before starting (per spec section "Confirmation before starting"). In `--auto` mode, print the summary but do not prompt.
5. **State script interface** — how to call `session-state.mjs` via Bash. Include the exact commands for get/set/update/clear/archive/list/hash and what their output means. The script lives at `${CLAUDE_PLUGIN_ROOT}/scripts/session-state.mjs`.
6. **Phase flow — full start** — preflight → plan → spec_approval → implement → cleanup → review_loop → done. For each phase: what Claude does, what commit message to write, what state update to make, what gate to show in hybrid mode, and how auto mode differs. Follow spec section "Phase flow (full start)" exactly.
7. **Phase flow — polish** — starts at cleanup, inverts the dirty-tree check. Follow spec section "Polish flow".
8. **Phase flow — resume** — read state, reattach to Codex if needed, continue from the persisted phase. Follow the implications in spec section "State file" and the `resume` command description.
9. **Review loop — actionable finding classification** — verbatim rules from spec section "Phase 5 — Review loop" step 2, including the critical rule that pre-existing simple/isolated fixes ARE in scope.
10. **Error handling** — dirty tree, concurrent session, Codex errors (three sub-modes), lint/test fix loop (3 attempts), spec rejection, branch exists, empty Codex diff. Follow spec section "Error handling and edge cases".
11. **Auto mode adaptations** — differences from hybrid: no gates, no start prompt, on failure write `failed` state and stop. Follow spec section "Auto mode".
12. **Done phase** — write `last-run-summary.md`, archive state, print summary.
13. **Status and abort commands** — read-only output for status; clear state for abort.

**Critical constraints for the skill author to honor:**

- The skill must **never** call `/codex:rescue` without `--write` in the implement phase (Codex must be write-capable).
- The skill must **never** silently proceed if Codex returns an empty diff.
- The skill must **always** use `git commit -m "<message>"` with the exact commit message formats defined in the spec (`spec:`, `implement:`, `cleanup:`, `review N:`).
- The skill must **refuse** on dirty tree unless `--allow-dirty` is explicitly set.
- The skill must **never** create a branch unless `--new-branch` or `--new-worktree` is explicitly set.
- The between-rounds hybrid gate in the review loop must be **skipped** on the final iteration (when `N == max_review_rounds`).
- Every phase transition must be persisted to state before continuing.

- [ ] **Step 3.3: Review the skill output**

After `skill-creator` produces the SKILL.md, read it in full and verify:

```bash
cat /Users/numa/JigSpace/Repos/perso/claude-plugins/pair-with-codex/skills/pair-with-codex-flow/SKILL.md | head -50
```

Scan for:
- Valid YAML frontmatter (`name`, `description`)
- All 13 sections listed above
- Commit message formats match the spec exactly
- Error handling covers all cases from the spec
- No "TBD" or "TODO"

If anything is missing or wrong, ask `skill-creator` to fix it inline.

- [ ] **Step 3.4: Commit**

```bash
cd /Users/numa/JigSpace/Repos/perso/claude-plugins
git add pair-with-codex/skills/pair-with-codex-flow/SKILL.md
git commit -m "pair-with-codex: add pair-with-codex-flow skill"
```

---

## Task 4: Command forwarders

**Goal:** Create the five slash-command `.md` files. Each one is a thin forwarder that invokes the `pair-with-codex-flow` skill. Modeled on the pattern used by `/codex:rescue` in the codex plugin.

**Files:**
- Create: `pair-with-codex/commands/start.md`
- Create: `pair-with-codex/commands/polish.md`
- Create: `pair-with-codex/commands/resume.md`
- Create: `pair-with-codex/commands/status.md`
- Create: `pair-with-codex/commands/abort.md`

**Spec references:** "Commands and flags" section.

- [ ] **Step 4.1: Write `start.md`**

Create `pair-with-codex/commands/start.md` with exactly this content:

```markdown
---
description: Start the full pair-with-codex flow — brainstorm, spec, Codex implement, cleanup, review loop, done
argument-hint: "[--auto] [--allow-dirty] [--max-review-rounds N] [--new-branch [name]] [--new-worktree] [--implement-existing-spec <path>] \"task description\""
allowed-tools: Bash, Edit, Write, Read, Glob, Grep, Skill
---

Invoke the `pair-with-codex-flow` skill with this command as the entry point and the following raw arguments:

ENTRY_POINT: start
RAW_ARGUMENTS: $ARGUMENTS

The skill parses flags and the task description from RAW_ARGUMENTS and orchestrates the full flow per `docs/superpowers/specs/2026-04-13-pair-with-codex-design.md` in the pair-with-codex plugin repo.

If the user did not supply a task description (RAW_ARGUMENTS is empty or contains only flags), the skill must ask for one before proceeding.
```

- [ ] **Step 4.2: Write `polish.md`**

Create `pair-with-codex/commands/polish.md` with exactly this content:

```markdown
---
description: Quick-fix tail — run cleanup and Codex review loop on existing working-tree changes, skipping planning and implementation
argument-hint: "[--auto] [--max-review-rounds N] [\"short description\"]"
allowed-tools: Bash, Edit, Write, Read, Glob, Grep, Skill
---

Invoke the `pair-with-codex-flow` skill with this command as the entry point and the following raw arguments:

ENTRY_POINT: polish
RAW_ARGUMENTS: $ARGUMENTS

The skill starts at Phase 4 (cleanup), inverts the dirty-tree check (requires a non-empty diff), skips phases 1–3, and then runs the review loop per the spec.
```

- [ ] **Step 4.3: Write `resume.md`**

Create `pair-with-codex/commands/resume.md` with exactly this content:

```markdown
---
description: Resume an interrupted pair-with-codex session from the last persisted phase
allowed-tools: Bash, Edit, Write, Read, Glob, Grep, Skill
---

Invoke the `pair-with-codex-flow` skill with this command as the entry point:

ENTRY_POINT: resume
RAW_ARGUMENTS: $ARGUMENTS

The skill reads session state for the current repo, prints the last known phase and recent commits, reattaches to any running Codex job via `/codex:status`, and continues the flow from that phase.
```

- [ ] **Step 4.4: Write `status.md`**

Create `pair-with-codex/commands/status.md` with exactly this content:

```markdown
---
description: Show the current phase, commits, and Codex job status for the pair-with-codex session in this repo
allowed-tools: Bash, Read, Skill
---

Invoke the `pair-with-codex-flow` skill with this command as the entry point:

ENTRY_POINT: status
RAW_ARGUMENTS: $ARGUMENTS

The skill reads session state for the current repo and prints phase, task description, iteration count, commits made so far, Codex job status if applicable, and elapsed time. Read-only.
```

- [ ] **Step 4.5: Write `abort.md`**

Create `pair-with-codex/commands/abort.md` with exactly this content:

```markdown
---
description: Abort the current pair-with-codex session — clears session state, leaves git commits alone
allowed-tools: Bash, Read, Skill
---

Invoke the `pair-with-codex-flow` skill with this command as the entry point:

ENTRY_POINT: abort
RAW_ARGUMENTS: $ARGUMENTS

The skill clears the session state file for the current repo and prints a summary of what was left behind. Does not touch git.
```

- [ ] **Step 4.6: Validate command file frontmatter**

Run:

```bash
cd /Users/numa/JigSpace/Repos/perso/claude-plugins
for f in pair-with-codex/commands/*.md; do
  echo "=== $f ==="
  head -10 "$f"
done
```

Expected: each file opens with `---`, has a `description:` line, and has a closing `---` within the first 10 lines. No parse errors.

- [ ] **Step 4.7: Commit**

```bash
cd /Users/numa/JigSpace/Repos/perso/claude-plugins
git add pair-with-codex/commands/
git commit -m "pair-with-codex: add slash command forwarders"
```

---

## Task 5: Smoke test infrastructure

**Goal:** Create the toy repo setup script and the eight smoke test checklists defined in the spec. These are manual walkthroughs, not automated tests.

**Files:**
- Create: `pair-with-codex/testing/setup-toy-repo.sh`
- Create: `pair-with-codex/testing/smoke/happy-path.md`
- Create: `pair-with-codex/testing/smoke/dirty-tree-refusal.md`
- Create: `pair-with-codex/testing/smoke/concurrent-refusal.md`
- Create: `pair-with-codex/testing/smoke/resume-after-kill.md`
- Create: `pair-with-codex/testing/smoke/auto-mode.md`
- Create: `pair-with-codex/testing/smoke/polish-flow.md`
- Create: `pair-with-codex/testing/smoke/lint-failure-recovery.md`
- Create: `pair-with-codex/testing/smoke/codex-empty-diff.md`

**Spec references:** "Testing strategy" → "Smoke test layout" and "Toy repo".

- [ ] **Step 5.1: Write `setup-toy-repo.sh`**

Create `pair-with-codex/testing/setup-toy-repo.sh` with exactly this content:

```bash
#!/usr/bin/env bash
# setup-toy-repo.sh — create a minimal reproducible fixture for pair-with-codex smoke tests.
# Usage: ./setup-toy-repo.sh [target-dir]
# Default target: /tmp/pair-with-codex-toy

set -euo pipefail

TARGET="${1:-/tmp/pair-with-codex-toy}"

if [[ -d "$TARGET" ]]; then
  echo "Target $TARGET already exists. Remove it first or choose another path." >&2
  exit 1
fi

mkdir -p "$TARGET"
cd "$TARGET"

git init --quiet --initial-branch=main

cat > package.json <<'JSON'
{
  "name": "pair-with-codex-toy",
  "version": "0.0.1",
  "type": "module",
  "scripts": {
    "lint": "node -e \"import('./src/index.mjs').then(() => console.log('lint ok'))\"",
    "test": "node --test test/"
  }
}
JSON

mkdir -p src test

cat > src/index.mjs <<'JS'
export function greet(name) {
  return `hello, ${name}`;
}
JS

cat > test/greet.test.mjs <<'JS'
import { test } from "node:test";
import assert from "node:assert/strict";
import { greet } from "../src/index.mjs";

test("greet returns a greeting", () => {
  assert.equal(greet("world"), "hello, world");
});
JS

cat > README.md <<'MD'
# pair-with-codex toy repo

A minimal fixture for pair-with-codex smoke tests. Do not use for real work.
MD

git add -A
git commit --quiet -m "initial toy repo"

echo "Toy repo created at $TARGET"
echo "Verify: cd $TARGET && npm run lint && npm test"
```

- [ ] **Step 5.2: Make it executable**

```bash
cd /Users/numa/JigSpace/Repos/perso/claude-plugins
chmod +x pair-with-codex/testing/setup-toy-repo.sh
```

- [ ] **Step 5.3: Smoke-verify the setup script**

```bash
# Run from any directory — script is self-contained.
/Users/numa/JigSpace/Repos/perso/claude-plugins/pair-with-codex/testing/setup-toy-repo.sh /tmp/pair-with-codex-toy-check
cd /tmp/pair-with-codex-toy-check
npm run lint
npm test
cd -
rm -rf /tmp/pair-with-codex-toy-check
```

Expected: lint prints `lint ok`, test prints `1 test passed`.

- [ ] **Step 5.4: Write `happy-path.md`**

Create `pair-with-codex/testing/smoke/happy-path.md` with exactly this content:

```markdown
# Smoke: happy path

Verifies the full `/pair-with-codex:start` flow on a toy repo with a small task.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-happy
cd /tmp/toy-happy
```

## Steps

- [ ] In Claude Code (with `/tmp/toy-happy` as cwd), run: `/pair-with-codex:start "add a farewell() function that returns 'goodbye, <name>'"`
- [ ] Claude prints the resolved flag summary. Confirm: `y`.
- [ ] Claude runs brainstorming and asks clarifying questions. Answer them briefly.
- [ ] Claude writes the spec. Approve at the spec gate.
- [ ] Claude invokes Codex, shows the job id, polls until done.
- [ ] Continue to cleanup at the gate.
- [ ] Claude runs simplify + `npm run lint` + `npm test`. All pass.
- [ ] Continue to review loop at the gate.
- [ ] Codex review runs. If clean, loop breaks immediately. If not, Claude addresses findings, asks to run another round.
- [ ] Loop ends. Done phase prints the summary.

## Expected result

- `git log --oneline` shows (at minimum): `initial toy repo`, `spec: ...`, `implement: ...`, `cleanup: ...`, and possibly one or more `review N: ...` commits.
- `src/index.mjs` now exports a `farewell` function.
- `npm run lint && npm test` passes.
- `~/.claude/pair-with-codex/sessions/` no longer contains an active session file for this repo.
- `~/.claude/pair-with-codex/sessions/archive/` contains a `last-run-summary.md` for the run.

## Teardown

```bash
rm -rf /tmp/toy-happy
```
```

- [ ] **Step 5.5: Write `dirty-tree-refusal.md`**

Create `pair-with-codex/testing/smoke/dirty-tree-refusal.md` with exactly this content:

```markdown
# Smoke: dirty tree refusal

Verifies that `:start` refuses when the working tree is dirty, and that `--allow-dirty` overrides.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-dirty
cd /tmp/toy-dirty
echo "untracked" > untracked.txt
```

## Steps

- [ ] Run: `/pair-with-codex:start "add a docstring to greet"`
- [ ] Expected: Claude refuses with a clear message mentioning the dirty tree and the `--allow-dirty` escape hatch.
- [ ] Run: `/pair-with-codex:start --allow-dirty "add a docstring to greet"`
- [ ] Expected: Claude proceeds past preflight, prints the resolved flag summary including `allow_dirty: true`.
- [ ] Abort with `/pair-with-codex:abort` (we do not need to complete this run).
- [ ] Expected: state is cleared; `untracked.txt` is untouched.

## Teardown

```bash
rm -rf /tmp/toy-dirty
```
```

- [ ] **Step 5.6: Write `concurrent-refusal.md`**

Create `pair-with-codex/testing/smoke/concurrent-refusal.md` with exactly this content:

```markdown
# Smoke: concurrent invocation refusal

Verifies that a second `:start` in the same repo is refused while one session is active, but runs on a different repo work fine.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-concur-a
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-concur-b
```

## Steps

- [ ] In Claude Code session A (cwd = `/tmp/toy-concur-a`), run: `/pair-with-codex:start "add a wave() function"`
- [ ] Proceed through to the implement phase (Codex running).
- [ ] In the same Claude Code session, **also** in `/tmp/toy-concur-a`, run `/pair-with-codex:start "something else"`.
- [ ] Expected: refusal with a message listing the active session (task, phase, started_at) and pointing at `:status`, `:resume`, `:abort`.
- [ ] In a second Claude Code window (cwd = `/tmp/toy-concur-b`), run: `/pair-with-codex:start "add a goodbye() function"`.
- [ ] Expected: starts normally — different repo, different state file.
- [ ] Abort both sessions with `:abort`.

## Teardown

```bash
rm -rf /tmp/toy-concur-a /tmp/toy-concur-b
```
```

- [ ] **Step 5.7: Write `resume-after-kill.md`**

Create `pair-with-codex/testing/smoke/resume-after-kill.md` with exactly this content:

```markdown
# Smoke: resume after kill

Verifies that a session can be resumed from the cleanup phase after a terminal kill.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-resume
cd /tmp/toy-resume
```

## Steps

- [ ] Run: `/pair-with-codex:start "add a wave() function that returns 'wave at <name>'"`
- [ ] Proceed through spec approval and implement. Codex finishes, continue to cleanup.
- [ ] During cleanup, close the terminal / kill the Claude Code process.
- [ ] Verify the state file exists: `ls ~/.claude/pair-with-codex/sessions/`
- [ ] Open a new Claude Code session, cwd = `/tmp/toy-resume`.
- [ ] Run: `/pair-with-codex:resume`
- [ ] Expected: Claude prints the last known phase and recent commits, asks whether to resume, resumes on `y`.
- [ ] The flow continues from cleanup and finishes.

## Expected result

- Final `git log --oneline` shows the full expected sequence of commits.
- No duplicate commits (the resumed session should not redo what was already committed).

## Teardown

```bash
rm -rf /tmp/toy-resume
```
```

- [ ] **Step 5.8: Write `auto-mode.md`**

Create `pair-with-codex/testing/smoke/auto-mode.md` with exactly this content:

```markdown
# Smoke: auto mode

Verifies that `--auto` skips all pause gates on a trivial task.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-auto
cd /tmp/toy-auto
```

## Steps

- [ ] Run: `/pair-with-codex:start --auto "add a wave() function"`
- [ ] Expected: Claude prints the resolved flag summary (no y/n prompt), then runs through the full flow without stopping for any gate.
- [ ] Codex runs, cleanup runs, review loop runs, done.
- [ ] Expected: the run finishes without any user interaction after the initial command.

## Expected result

- Full commit history as in happy-path.
- `last-run-summary.md` exists in the archive dir with the task description, timing, and commit list.

## Teardown

```bash
rm -rf /tmp/toy-auto
```
```

- [ ] **Step 5.9: Write `polish-flow.md`**

Create `pair-with-codex/testing/smoke/polish-flow.md` with exactly this content:

```markdown
# Smoke: polish flow

Verifies that `:polish` runs cleanup + review loop on existing working-tree changes without planning or Codex implementation.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-polish
cd /tmp/toy-polish
cat >> src/index.mjs <<'JS'

export function wave(name) {
return `wave at ${name}`
}
JS
```

Note: the added function has intentionally inconsistent indentation and a missing semicolon — `simplify` and the lint check should notice.

## Steps

- [ ] Run: `/pair-with-codex:polish "add wave function"`
- [ ] Expected: Claude skips planning, starts at cleanup.
- [ ] Cleanup runs simplify, which normalizes the formatting. `npm run lint` and `npm test` pass.
- [ ] Review loop runs. Addresses any findings.
- [ ] Done.

## Expected result

- `git log --oneline` shows: `initial toy repo`, `cleanup: add wave function`, possibly `review N: ...`.
- No `spec:` or `implement:` commits (polish skips these).
- The wave function still works: `node -e "import('./src/index.mjs').then(m => console.log(m.wave('world')))"` prints `wave at world`.

## Teardown

```bash
rm -rf /tmp/toy-polish
```
```

- [ ] **Step 5.10: Write `lint-failure-recovery.md`**

Create `pair-with-codex/testing/smoke/lint-failure-recovery.md` with exactly this content:

```markdown
# Smoke: lint failure recovery

Verifies that Claude's 3-attempt fix loop for failing cleanup checks works.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-lint
cd /tmp/toy-lint
```

Modify `package.json` so `npm run lint` uses a script that will fail on a specific string appearing in the source:

```bash
node -e "
const fs = require('fs');
const p = JSON.parse(fs.readFileSync('package.json', 'utf8'));
p.scripts.lint = \"node -e \\\"const s=require('fs').readFileSync('src/index.mjs','utf8'); if (s.includes('BADTOKEN')) { console.error('lint failure: BADTOKEN found'); process.exit(1) } else { console.log('lint ok') }\\\"\";
fs.writeFileSync('package.json', JSON.stringify(p, null, 2));
"
git add package.json && git commit -m "rig lint to fail on BADTOKEN"
```

## Steps

- [ ] Run: `/pair-with-codex:start "add a function and include a comment with BADTOKEN that should be removed"` (hopefully Codex writes the comment)
- [ ] Proceed through spec, implement, continue to cleanup.
- [ ] In cleanup, `npm run lint` fails with "BADTOKEN found".
- [ ] Expected: Claude reads the error, removes BADTOKEN from the source, reruns lint. Up to 3 attempts.
- [ ] Expected: within 3 attempts, lint passes and cleanup completes.
- [ ] If lint still fails after 3 attempts, Claude writes state `failed` and stops (both outcomes are valid for this test — verify behavior matches one of them).

## Teardown

```bash
rm -rf /tmp/toy-lint
```
```

- [ ] **Step 5.11: Write `codex-empty-diff.md`**

Create `pair-with-codex/testing/smoke/codex-empty-diff.md` with exactly this content:

```markdown
# Smoke: Codex empty diff

Verifies that Claude does NOT silently proceed when Codex produces an empty diff.

## Setup

```bash
./pair-with-codex/testing/setup-toy-repo.sh /tmp/toy-empty
cd /tmp/toy-empty
```

## Steps

- [ ] Run: `/pair-with-codex:start "do nothing, leave the code exactly as it is"`
- [ ] Proceed through spec. The spec may genuinely conclude there is nothing to do.
- [ ] Expected: in the implement phase, after Codex runs, Claude detects the empty diff.
- [ ] Expected (hybrid): Claude prints the Codex output and asks "Codex made no changes. Continue to cleanup / retry with clarification / abort?". Choose `abort`.
- [ ] Expected (auto, if this test is also run in auto mode): Claude writes `failed` state with `failed: codex produced no changes` and stops.

## Teardown

```bash
rm -rf /tmp/toy-empty
```
```

- [ ] **Step 5.12: Commit**

```bash
cd /Users/numa/JigSpace/Repos/perso/claude-plugins
git add pair-with-codex/testing/
git commit -m "pair-with-codex: add smoke test infrastructure"
```

---

## Task 6: Validate and run the happy-path smoke test

**Goal:** Run `plugin-dev:plugin-validator` against the new plugin to catch any structural issues, then walk through the happy-path smoke test manually to verify the plugin actually works end-to-end.

**Files:** None created — this is a verification task.

- [ ] **Step 6.1: Validate the plugin structure**

Invoke the `plugin-dev:plugin-validator` agent on the plugin path:

```
Agent({
  subagent_type: "plugin-dev:plugin-validator",
  description: "Validate pair-with-codex",
  prompt: "Validate the plugin at /Users/numa/JigSpace/Repos/perso/claude-plugins/pair-with-codex/. Check plugin.json, commands, skills, and directory structure. Report any errors or warnings."
})
```

Expected: validator reports no errors. If any are reported, fix them inline, recommit, and rerun.

- [ ] **Step 6.2: Install the plugin locally**

The plugin must be reachable from Claude Code's plugin resolution. If this repo is already listed as a local plugin source in `~/.claude/settings.json`, installation happens automatically. Otherwise:

```bash
# Check if the plugin repo is a local source already
grep -l "claude-plugins" ~/.claude/settings.json 2>/dev/null && echo "linked" || echo "not linked"
```

If not linked, follow your local plugin installation process (outside the scope of this plan — ask the user if unclear).

- [ ] **Step 6.3: Walk through the happy-path smoke test**

Follow `pair-with-codex/testing/smoke/happy-path.md` step by step. Do NOT skip steps.

- [ ] **Step 6.4: If the smoke test fails, debug and fix**

Common causes:
- Skill description not triggering: refine the description field.
- Flag parsing wrong: inspect what `$ARGUMENTS` actually contains and adjust parsing.
- State script path wrong: use `${CLAUDE_PLUGIN_ROOT}/scripts/session-state.mjs` in the skill, not a relative path.
- Codex not write-capable: ensure `--write` is in the `/codex:rescue` call.

Fix inline in the affected files. Commit each fix separately with a clear message (`fix: <what>`). Re-run the smoke test after each fix.

- [ ] **Step 6.5: Final commit**

If the smoke test passed without needing fixes, there is nothing to commit in this task. If fixes were made, they should already be committed in 6.4.

Announce completion:

```
pair-with-codex plugin is implemented and validated.
Installed at: /Users/numa/JigSpace/Repos/perso/claude-plugins/pair-with-codex/
Spec: docs/superpowers/specs/2026-04-13-pair-with-codex-design.md
Plan: docs/superpowers/plans/2026-04-13-pair-with-codex-plugin.md
Happy path smoke test: PASSED
```

---

## Self-review

The following checks were done against the spec after writing this plan:

**Spec coverage:**
- "High-level architecture" / "File layout" → Task 1
- "State file" / "Script API" → Task 2
- "Commands and flags" (five commands) → Task 4
- "Invocation paths and flag parsing" → Task 3 (step 3.2 section 4)
- "Phase flow (full start)" (phases 1–6) → Task 3 (step 3.2 section 6)
- "Polish flow" → Task 3 (step 3.2 section 7)
- "Auto mode" → Task 3 (step 3.2 section 11)
- "Error handling and edge cases" → Task 3 (step 3.2 section 10)
- "Testing strategy" → Task 5 + Task 6
- "Implementation approach" (skill-creator) → Task 3 (step 3.1, 3.2)

**Placeholders:** No "TBD"/"TODO" in the plan. The Task 3 approach of pointing `skill-creator` at the spec rather than writing all the skill prose inline is a deliberate decision (explained at the top of the plan), not a placeholder.

**Type consistency:**
- Commit message formats consistent throughout: `spec:`, `implement:`, `cleanup:`, `review N:` — match spec section "Phase flow (full start)".
- `session-state.mjs` CLI commands consistent across Task 2 (definition) and Task 3.2 section 5 (usage from the skill).
- `${CLAUDE_PLUGIN_ROOT}` path convention used consistently for runtime path resolution inside the skill.
- `ENTRY_POINT` values (`start`, `polish`, `resume`, `status`, `abort`) consistent across all five command forwarders in Task 4.

No gaps found.
