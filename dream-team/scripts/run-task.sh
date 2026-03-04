#!/bin/bash
# Autonomous task runner for Claude Code
# Reads checkpoint from sprint progress.md, runs Claude with fresh context each iteration.
#
# Usage:
#   ./scripts/run-task.sh <sprint-dir> [--max-iterations N] [--dry-run] [--model MODEL] [--quiet]
#   ./scripts/run-task.sh planning/sprints/sprint-7-broadcast-migration
#   ./scripts/run-task.sh planning/sprints/sprint-7-broadcast-migration --max-iterations 10
#   ./scripts/run-task.sh planning/sprints/sprint-7-broadcast-migration --dry-run

set -euo pipefail

# ---------------------------------------------------------------------------
# Args
# ---------------------------------------------------------------------------
SPRINT_DIR="${1:?Usage: run-task.sh <sprint-dir> [--max-iterations N] [--dry-run]}"
MAX_ITERATIONS=50
DRY_RUN=false
MODEL=""
QUIET=false

shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-iterations) MAX_ITERATIONS="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --model) MODEL="$2"; shift 2 ;;
    --quiet) QUIET=true; shift ;;
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
  echo "ERROR: $PROGRESS_FILE not found. Create it from planning/templates/progress.md"
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
PROMPT_TEMPLATE="$PLUGIN_DIR/skills/sprint-runner/references/runner-prompt.md"
FILTER="$SCRIPT_DIR/stream-filter.sh"

if [[ ! -f "$PROMPT_TEMPLATE" ]]; then
  echo "ERROR: Prompt template not found at $PROMPT_TEMPLATE"
  exit 1
fi

if [[ ! -f "$FILTER" ]]; then
  echo "ERROR: Stream filter not found at $FILTER"
  exit 1
fi

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

  # Dry run — test the Claude pipe and exit (bypass phase checks)
  if $DRY_RUN; then
    CLAUDE_ARGS=(
      --print
      --verbose
      --output-format stream-json
      --dangerously-skip-permissions
      --disallowedTools "AskUserQuestion"
    )
    if [[ -n "$MODEL" ]]; then
      CLAUDE_ARGS+=(--model "$MODEL")
    fi
    echo "[DRY RUN] Testing Claude pipe with hello prompt..."
    DRY_LOG="$LOG_DIR/dry-run.log"
    > "$DRY_LOG"
    claude "${CLAUDE_ARGS[@]}" <<< "Say 'Hello from dry run!' and stop." 2>&1 | "$FILTER" "$DRY_LOG"
    echo ""
    echo "[DRY RUN] Done. Log: $DRY_LOG"
    exit 0
  fi

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

  # Check if awaiting manual testing
  if [[ "$PHASE" == "awaiting-manual-testing" ]]; then
    echo "============================================"
    echo "  Sprint awaiting manual device testing."
    echo "  Add bugs to the Bug Fix Phase in tasks.md,"
    echo "  then set phase to 'bug-fix' to continue."
    echo "============================================"
    exit 0
  fi

  # Build the prompt from template (strip markdown header, substitute variables)
  export SPRINT_NUM SPRINT_NAME PLAN_FILE TASKS_FILE PROGRESS_FILE
  export ACTIVE_TASK LAST_COMPLETED NEXT_STEP BLOCKERS
  PROMPT=$(sed -n '/^---$/,$ { /^---$/d; p; }' "$PROMPT_TEMPLATE" | envsubst)

  # Run Claude Code
  echo "Running Claude Code... (logging to $ITER_LOG)"

  CLAUDE_ARGS=(
    --print
    --verbose
    --output-format stream-json
    --dangerously-skip-permissions
    --disallowedTools "AskUserQuestion"
  )
  if [[ -n "$MODEL" ]]; then
    CLAUDE_ARGS+=(--model "$MODEL")
  fi

  set +e
  if $QUIET; then
    claude "${CLAUDE_ARGS[@]}" <<< "$PROMPT" > "$ITER_LOG" 2>&1
  else
    claude "${CLAUDE_ARGS[@]}" <<< "$PROMPT" 2>&1 | "$FILTER" "$ITER_LOG"
  fi
  EXIT_CODE=${PIPESTATUS[0]}
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
