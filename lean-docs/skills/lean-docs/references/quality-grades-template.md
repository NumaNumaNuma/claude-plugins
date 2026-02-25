# Quality Grades Template

Track per-domain quality so agents (and humans) know where the weak spots are.
Update after each sprint or major feature.

```markdown
# Quality Grades

| Domain | Grade | Test Coverage | Key Gaps |
|--------|-------|---------------|----------|
| Auth | B+ | Good | No 2FA tests |
| API | A- | Partial | No rate limit tests |
| UI | B | Minimal | No snapshot tests |
| Data | B+ | Good | No migration rollback tests |
| Notifications | C+ | None | No integration tests |

## Grading Criteria

- **A**: Well-tested, documented, no known gaps
- **B**: Mostly solid, some missing tests or docs
- **C**: Functional but fragile, significant gaps
- **D**: Known issues, needs attention
- **F**: Broken or dangerous
```
