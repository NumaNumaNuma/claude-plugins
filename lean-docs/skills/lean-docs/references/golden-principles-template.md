# Golden Principles Template

Mechanical rules that prevent codebase drift. These are the "always/never" rules.
For the "why" behind them, see core-beliefs.md.

```markdown
# Golden Principles

## File Organization
- Max [N] lines per file (split into extensions/modules beyond that)
- One type per file. Exception: small helper types tightly coupled to the main type.
- File name matches primary type.

## Naming & Style
- [indent rule — e.g., 2-space, 4-space, tabs]
- [naming conventions — e.g., camelCase properties, PascalCase types]

## [Your Framework] Rules
- [always/never rules specific to your stack]
- [e.g., "No deprecated APIs", "Always use parameterized queries"]

## [Your Database] Rules
- [access control rules]
- [query safety rules]
- [migration patterns]

## UI Rules
- [touch target minimums]
- [accessibility requirements]
- [component patterns]

## Doc Gardening (GC Cadence)

Run monthly:
- [ ] Scan for TODOs older than 30 days
- [ ] Verify quality-grades.md is current
- [ ] Check that subdirectory CLAUDE.md files match actual code
- [ ] Archive completed exec-plans
- [ ] Review golden principles — remove any that aren't enforced
- [ ] Check for files exceeding max line limit
- [ ] Remove dead code, unused imports
```
