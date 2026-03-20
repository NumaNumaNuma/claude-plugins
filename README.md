# Claude Plugins

Custom Claude Code plugins for agent-first development workflows.

## Install

```bash
# Register the marketplace (one-time)
/plugin marketplace add NumaNumaNuma/claude-plugins

# Install plugins
/plugin install dream-team@numa-plugins
/plugin install lean-docs@numa-plugins
/plugin install the-rat@numa-plugins
```

## Setup

**dream-team** requires the experimental agent teams feature. Add to `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

## Plugins

### dream-team

Multi-agent collaborative workflow for planning, implementing, and reviewing features.

- `/dream-plan` — Launch specialist agents to collaboratively design an implementation plan
- `/dream-implement` — Architect scan, implement step-by-step, post-implementation review
- `/dream-review` — Multi-agent code review with severity classification
- `/sprint-runner` — Autonomous sprint execution with checkpoint-based progress tracking
- `scripts/run-task.sh` — Headless runner for overnight/unattended sprints

Uses official `feature-dev` and `pr-review-toolkit` agents when available, falls back to `general-purpose` with specialist prompts.

### lean-docs

Set up and maintain agent-legible documentation for any codebase.

- `/lean-docs` — Guided 9-step setup for a new project
- `/lean-docs audit` — Check existing docs against the playbook
- **Passive rules** — Automatically enforced when the agent writes or updates docs: slim CLAUDE.md, hierarchical `docs/`, subdirectory CLAUDE.md files, link-don't-duplicate

### the-rat

Deliver the pizza first, dress up later. The Rat is a coding philosophy for startups that prioritizes shipping over polish.

<p align="center">
  <img src="the-rat/assets/feature-dev-tiers.png" alt="Feature dev tiers: Subway rat (MVP with pizza), Costume rat (dressed up with pizza), Fancy rat (full costume, no pizza)" width="600" />
</p>

- `/ratify` — Run the Ratman agent on any plan to check if it's lean enough to ship
- `/rat-retrospective` — Score shipped features retroactively: was the costume worth it?
- **Ratman agent** — Classifies every item as Subway Rat (essential), Costume Rat (needed but find the cheapest version), or Fancy Rat (cut it). Proposes subway-rat alternatives with time-to-pizza estimates.
- **Dream-team integration** — Ratman is a non-negotiable team agent, runs after Devil's Advocate to challenge scope
- **Rat debt tracker** — Track deferred items with measurable comeback triggers

## Recommended Companion Plugins

For best dream-team results, also install:

- **feature-dev** — Provides `code-architect`, `code-reviewer`, `code-explorer` agents
- **pr-review-toolkit** — Provides `silent-failure-hunter`, `type-design-analyzer`, `pr-test-analyzer` agents
