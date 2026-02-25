# Lean Docs Plugin

Set up agent-legible documentation for any codebase. Based on the [harness engineering approach](https://openai.com/index/introducing-codex/) — a slim CLAUDE.md entry point linking to hierarchical topic docs, subdirectory rules, and lint-encoded taste.

## Install

### From marketplace

```bash
claude plugin marketplace add github.com/NumaNumaNuma/claude-plugins
claude plugin install lean-docs@numa-plugins
```

### Local development

```bash
claude --plugin-dir /path/to/claude-plugins/lean-docs
```

## Usage

### Set up docs for a project

```
/lean-docs
```

Audits your current project and walks you through the 9-step setup:

1. Slim down CLAUDE.md to an 80-120 line index
2. Create `docs/` with topic files
3. Add subdirectory CLAUDE.md files
4. Write design docs & core beliefs
5. Set up execution plan structure
6. Create golden principles with GC cadence
7. Generate auto-docs (schema dumps, API routes)
8. Write LLM-readable reference docs
9. Encode taste as lint rules

### Audit existing docs

```
/lean-docs audit
```

Checks your current doc structure against the playbook and flags gaps.

## Pairs Well With

- **dream-team** — Sprint planning, multi-agent implementation, and autonomous runner. Lean-docs handles the documentation layer; dream-team handles the workflow layer.
