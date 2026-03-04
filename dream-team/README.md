# Dream Team Plugin

Multi-agent collaborative workflow for planning, implementing, and reviewing features with autonomous sprint execution.

## Install

### From marketplace

```bash
# Register the marketplace (one-time)
claude plugin marketplace add github.com/NumaNumaNuma/claude-plugins

# Install the plugin
claude plugin install dream-team@numa-plugins
```

### Local development

```bash
claude --plugin-dir /path/to/claude-plugins/dream-team
```

## Required Setup

**Enable agent teams** — Dream Team launches multiple subagents in parallel, which requires the experimental agent teams feature. Add this to your `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Without this, the Task tool won't be able to launch subagents and the commands will fail.

## Recommended Companion Plugins

For best results, install these official Anthropic plugins:

- **feature-dev** — Provides `code-architect`, `code-reviewer`, `code-explorer` agents
- **pr-review-toolkit** — Provides `silent-failure-hunter`, `type-design-analyzer`, `pr-test-analyzer` agents

Without these, Dream Team falls back to `general-purpose` agents with specialist prompts. The results are good but the dedicated agents are better.

## Usage

### Plan a feature

```
/dream-plan user notifications system
```

Launches specialist agents in parallel to collaboratively design an implementation plan. Includes architecture, security, performance, UX, and devil's advocate perspectives.

### Implement a feature

```
/dream-implement sprint 5
```

Reads an existing sprint plan, launches architects for a quick scan, implements step by step, then runs post-implementation review agents.

### Review code

```
/dream-review current changes
/dream-review PR #42
```

Launches review agents to examine code for quality, security, performance, and edge cases. Produces a unified review with severity classifications.

### Autonomous Sprint Runner

For hands-off execution of sprint tasks:

```bash
./scripts/run-task.sh planning/sprints/sprint-5-feature-name
./scripts/run-task.sh planning/sprints/sprint-5-feature-name --max-iterations 20
./scripts/run-task.sh planning/sprints/sprint-5-feature-name --dry-run
./scripts/run-task.sh planning/sprints/sprint-5-feature-name --model opus
./scripts/run-task.sh planning/sprints/sprint-5-feature-name --quiet
```

The runner streams Claude's output to the terminal in real-time so you can follow progress. Logs are also saved to `runner-logs/`. Use `--quiet` to suppress terminal output and only write to log files (old behavior).

## Sprint Templates

Copy from `templates/` to set up a new sprint:

```bash
SPRINT_DIR=planning/sprints/sprint-5-feature-name
mkdir -p $SPRINT_DIR
cp templates/sprint-plan.md $SPRINT_DIR/plan.md
cp templates/tasks.md $SPRINT_DIR/tasks.md
cp templates/progress.md $SPRINT_DIR/progress.md
```

## Agent Roster

| Role | Preferred Agent | Always? |
|------|----------------|---------|
| Code Architect | `feature-dev:code-architect` | Almost always |
| Code Quality Engineer | `feature-dev:code-reviewer` | When touching existing patterns |
| Performance Analyst | `feature-dev:code-explorer` | When scaling/perf concerns |
| Security Reviewer | `pr-review-toolkit:silent-failure-hunter` | When auth/data/input involved |
| UI/UX Designer | `general-purpose` | When user-facing |
| Devil's Advocate | `general-purpose` | Always |
| Database Architect | `general-purpose` | When DB changes needed |
| Test Engineer | `general-purpose` | When tests needed |
