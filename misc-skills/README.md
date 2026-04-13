# misc-skills

Miscellaneous utility slash commands that don't belong to a themed plugin.

## Commands

### `/cleanup [scope]`

A 4-step cleanup pipeline for recent changes:

1. **Simplify** — invoke `/simplify` on the diff.
2. **Audit tests** — load the project's testing conventions from `CLAUDE.md` + linked docs, then add/update tests for every changed source file.
3. **Run only the changed tests** — follow the project's own rules for running individual tests (framework, identifiers, destinations, parallelism).
4. **Update docs** — invoke `/lean-docs:lean-docs`.

Project-agnostic: Steps 2–3 defer all test decisions to the repo's own `CLAUDE.md`. If the project has no tests or no testing guidance, those steps are skipped.

**Scope argument:**
- `3` → last 3 commits (`HEAD~3..HEAD`)
- `abc123..def456` → explicit commit range
- _(omitted)_ → working tree changes

**Dependencies:** expects `/simplify` and `/lean-docs:lean-docs` to be available.
