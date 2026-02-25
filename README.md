# Claude Plugins

Custom Claude Code plugins for agent-first development workflows.

## Install

```bash
# Register the marketplace (one-time)
/plugin marketplace add NumaNumaNuma/claude-plugins

# Install plugins
/plugin install dream-team@numa-plugins
/plugin install lean-docs@numa-plugins
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

## Recommended Companion Plugins

For best dream-team results, also install:

- **feature-dev** — Provides `code-architect`, `code-reviewer`, `code-explorer` agents
- **pr-review-toolkit** — Provides `silent-failure-hunter`, `type-design-analyzer`, `pr-test-analyzer` agents
