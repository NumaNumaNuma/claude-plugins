#!/bin/bash
# Autonomous task runner for Claude Code
# Reads checkpoint from sprint progress.md, runs Claude with fresh context each iteration.
#
# Usage:
#   ./scripts/run-task.sh planning/sprints/sprint-5-feature-name
#   ./scripts/run-task.sh planning/sprints/sprint-5-feature-name --max-iterations 10
#   ./scripts/run-task.sh planning/sprints/sprint-5-feature-name --dry-run
#   ./scripts/run-task.sh planning/sprints/sprint-5-feature-name --model opus

set -euo pipefail

# ---------------------------------------------------------------------------
# Args
# ---------------------------------------------------------------------------
SPRINT_DIR="${1:?Usage: run-task.sh <sprint-dir> [--max-iterations N] [--dry-run] [--model MODEL]}"
MAX_ITERATIONS=50
DRY_RUN=false
MODEL=""

shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-iterations) MAX_ITERATIONS="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --model) MODEL="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
PROGRESS_FILE="$SPRINT_DIR/progress.md"
TASKS_FILE="$SPRINT_DIR/tasks.md"
PLAN_FILE="$SPRINT_DIR/plan.md"
LOG_DIR="$SPRINT_DIR/runner-logs"

if [[ ! -f "$PROGRESS_FILE" ]]; then
  echo "ERROR: $PROGRESS_FILE not found. Create it from the dream-team plugin templates/progress.md"
  exit 1
fi

if [[ ! -f "$TASKS_FILE" ]]; then
  echo "ERROR: $TASKS_FILE not found."
  exit 1
fi

if [[ ! -f "$PLAN_FILE" ]]; then
  echo "ERROR: $PLAN_FILE not found."
  exit 1
fi

mkdir -p "$LOG_DIR"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
parse_checkpoint() {
  # Extract fields from the CHECKPOINT HTML comment block
  local file="$1"
  local field="$2"
  # Match: field: value (inside <!-- CHECKPOINT ... -->)
  sed -n '/<!-- CHECKPOINT/,/-->/p' "$file" \
    | grep "^${field}:" \
    | sed "s/^${field}: *//" \
    | sed 's/^"//' | sed 's/"$//'
}

timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------
echo "============================================"
echo "  Autonomous Task Runner"
echo "  Sprint: $SPRINT_DIR"
echo "  Max iterations: $MAX_ITERATIONS"
echo "  Started: $(timestamp)"
echo "============================================"
echo ""

ITERATION=0
CONSECUTIVE_FAILURES=0
MAX_CONSECUTIVE_FAILURES=3

while [[ $ITERATION -lt $MAX_ITERATIONS ]]; do
  ITERATION=$((ITERATION + 1))
  ITER_LOG="$LOG_DIR/iteration-$(printf '%03d' $ITERATION).log"

  # Read checkpoint
  PHASE=$(parse_checkpoint "$PROGRESS_FILE" "phase")
  ACTIVE_TASK=$(parse_checkpoint "$PROGRESS_FILE" "active_task")
  LAST_COMPLETED=$(parse_checkpoint "$PROGRESS_FILE" "last_completed")
  NEXT_STEP=$(parse_checkpoint "$PROGRESS_FILE" "next_step")
  BLOCKERS=$(parse_checkpoint "$PROGRESS_FILE" "blockers")
  SPRINT_NUM=$(parse_checkpoint "$PROGRESS_FILE" "sprint")
  SPRINT_NAME=$(parse_checkpoint "$PROGRESS_FILE" "sprint_name")

  echo "--- Iteration $ITERATION / $MAX_ITERATIONS ---"
  echo "Phase: $PHASE"
  echo "Active task: $ACTIVE_TASK"
  echo "Next step: $NEXT_STEP"
  echo ""

  # Check if done
  if [[ "$PHASE" == "done" ]]; then
    echo "============================================"
    echo "  Sprint complete!"
    echo "  Finished at: $(timestamp) after $ITERATION iterations."
    echo "============================================"
    echo ""
    # Print manual testing checklist if present
    CHECKLIST=$(sed -n '/^## Manual Testing Checklist/,$p' "$PROGRESS_FILE")
    if [[ -n "$CHECKLIST" ]]; then
      echo "$CHECKLIST"
    else
      echo "(No manual testing checklist found in $PROGRESS_FILE)"
    fi
    exit 0
  fi

  # Check if blocked
  if [[ "$PHASE" == "blocked" ]]; then
    echo "Sprint is BLOCKED: $BLOCKERS"
    echo "Human intervention needed. Exiting."
    exit 2
  fi

  # Build the prompt
  PROMPT="You are continuing work on Sprint $SPRINT_NUM ($SPRINT_NAME).

Read these files to understand the full context:
- $PLAN_FILE (sprint plan with approach and phases)
- $TASKS_FILE (task checklist — update checkboxes as you complete work)
- $PROGRESS_FILE (checkpoint and progress log)

CURRENT STATE from checkpoint:
- Active task: $ACTIVE_TASK
- Last completed: $LAST_COMPLETED
- Next step: $NEXT_STEP
- Blockers: $BLOCKERS

YOUR INSTRUCTIONS:
1. Read the plan and tasks files to understand the full context
2. Execute the 'next_step' described above
3. VERIFY your work:
   a. If you wrote code: build it using the project's build system and fix any compile errors before moving on
   b. If tests exist for what you changed: run them and fix failures
   c. If the task has acceptance criteria: verify each one is met
   d. If you can't verify (e.g., needs device testing), note it in the progress log
4. After completing AND verifying a task, update these files:
   a. $TASKS_FILE — check off completed tasks ([x]), mark current as in-progress ([~])
   b. $PROGRESS_FILE — update the CHECKPOINT block (active_task, last_completed, next_step, files_modified) AND append a timestamped log entry
5. KEEP GOING — move on to the next task immediately. Do NOT exit after a single task.
   Continue working through tasks until you have completed an entire phase (or sub-phase).
   Checkpoint after each task so progress is saved, but keep working in the same session.
6. If you complete the entire sprint, do a FINAL VERIFICATION:
   a. Run the full test suite
   b. Build the project
   c. Only set phase to 'done' if everything passes
   d. If tests fail, set next_step to describe what needs fixing
7. If you hit a blocker you can't resolve, set phase to 'blocked' and describe the blocker
8. Only stop when you have finished a full phase, the sprint is done, or you are blocked

BUG FIX PHASE (when active_task contains 'Bug Fix' or 'BF-'):
For each bug, follow this TDD workflow:
1. REPRODUCE FIRST: Write a failing test that reproduces the bug. Run it and confirm it fails for the right reason.
2. FIX: Implement a proper, clean fix — not a minimal patch. Follow the same code quality standards as feature work.
   - If the proper fix requires a large refactor (touching many files or changing architecture), do NOT attempt it. Instead set phase to 'blocked' and describe what refactor is needed so the human can decide how to proceed.
3. VERIFY: Run the test again — only mark the bug as done when the test passes.
4. If the bug CANNOT be reproduced as an automated test (e.g., purely visual, gesture-based, or requires device interaction), note why in the progress log, apply your best-effort fix, and mark it. The next manual testing round will catch regressions.

IMPORTANT:
- Work through as many tasks as you can per session — do NOT stop after a single task
- Checkpoint after EACH task (update progress.md + tasks.md) so progress survives crashes, then continue to the next task
- Stop only when: you finish a full phase, the sprint is done, or you are blocked
- NEVER cut, skip, or defer tasks. Every task in tasks.md is committed scope. Complete all of them.
- NEVER mark a task as done ([x]) if the build is broken or tests are failing
- If a test fails, try to fix it. If you can't fix it after a solid attempt, checkpoint with next_step describing the failure and what you tried — a fresh context in the next iteration may help
- Keep files_modified accurate — list every file you created or modified this session
- RECORD LEARNINGS: If you hit a non-obvious issue (surprising API behavior, config gotcha, debugging dead end), add it to docs/gotchas.md (or the relevant topic file under docs/gotchas/ if the project uses split gotchas). Format: ## Title / Symptom / Cause / Fix. Check for duplicates first.

WHEN SETTING PHASE TO DONE:
Before setting phase to 'done', append a '## Manual Testing Checklist' section to the progress log. Scan tasks.md for ALL items that could not be verified automatically (device testing, multi-device sync, UI interactions, visual checks, etc.) and list them as a complete, actionable checklist. Include specific steps to reproduce, not just feature names. This is the handoff to the human tester."

  if $DRY_RUN; then
    echo "[DRY RUN] Would send prompt:"
    echo "$PROMPT"
    echo ""
    echo "[DRY RUN] Exiting after first iteration."
    exit 0
  fi

  # Run Claude Code
  echo "Running Claude Code... (logging to $ITER_LOG)"
  MODEL_FLAG=""
  if [[ -n "$MODEL" ]]; then
    MODEL_FLAG="--model $MODEL"
  fi

  set +e
  claude --print --dangerously-skip-permissions $MODEL_FLAG "$PROMPT" > "$ITER_LOG" 2>&1
  EXIT_CODE=$?
  set -e

  if [[ $EXIT_CODE -ne 0 ]]; then
    CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
    echo "WARNING: Claude exited with code $EXIT_CODE (failure $CONSECUTIVE_FAILURES/$MAX_CONSECUTIVE_FAILURES)"

    if [[ $CONSECUTIVE_FAILURES -ge $MAX_CONSECUTIVE_FAILURES ]]; then
      echo "ERROR: $MAX_CONSECUTIVE_FAILURES consecutive failures. Stopping."
      echo "Check $ITER_LOG for details."
      exit 1
    fi

    echo "Retrying in 30 seconds..."
    sleep 30
    continue
  fi

  # Success — reset failure counter
  CONSECUTIVE_FAILURES=0

  # Brief pause between iterations to avoid rate limits
  echo "Iteration $ITERATION complete. Pausing 5s before next..."
  echo ""
  sleep 5
done

echo "WARNING: Reached max iterations ($MAX_ITERATIONS) without completing."
echo "Check $PROGRESS_FILE for current state."
exit 1
