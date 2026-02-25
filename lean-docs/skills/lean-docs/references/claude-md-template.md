# CLAUDE.md Template

Target: 80-120 lines. Only what every task needs.

```markdown
# CLAUDE.md

## Build Commands
[build, test, lint commands — exact shell commands or tool instructions]

## Environment
[connection strings location, credentials location, key config]

## Key Rules
[3-5 non-negotiable rules: indent style, async pattern, framework constraints]

## Docs Index

| Doc | Purpose |
|-----|---------|
| [docs/architecture.md](docs/architecture.md) | App structure, patterns, directory layout |
| [docs/database.md](docs/database.md) | Schema, migrations, key queries |
| [docs/api.md](docs/api.md) | Endpoints, auth flow, error handling |
| [docs/testing.md](docs/testing.md) | Test patterns, fixtures, gotchas |
| [docs/quality-grades.md](docs/quality-grades.md) | Per-domain quality ratings |
| [docs/golden-principles.md](docs/golden-principles.md) | Always/never rules, GC cadence |
| [docs/gotchas.md](docs/gotchas.md) | Hard-won lessons |
| [docs/design-docs/core-beliefs.md](docs/design-docs/core-beliefs.md) | Operating principles |

## Subdirectory CLAUDE.md Files
Each source directory has its own CLAUDE.md with domain-specific rules:
`src/services/`, `src/components/`, `src/models/`, `src/utils/`
```
