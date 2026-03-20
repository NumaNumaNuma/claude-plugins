---
description: "Score shipped features retroactively — was the costume worth it? Did we over-build or under-build?"
argument-hint: "Feature or area to review (e.g., 'the billing system', 'last 3 sprints')"
---

# Rat Retrospective: $ARGUMENTS

Look back at a shipped feature and evaluate it through the Rat lens. The goal is to build institutional memory: learn which costume items actually mattered and which were waste.

## Workflow

1. **Identify the feature**: Determine what to evaluate.
   - If `$ARGUMENTS` names a feature, find the relevant code, planning docs, and git history
   - If `$ARGUMENTS` references sprints, read the sprint plans from `planning/sprints/`
   - If empty, look at the last 1-3 completed sprints or ask the user

2. **Gather evidence**: For each component that was built, find:
   - How much effort went into it (git log, file changes, sprint duration)
   - Whether users actually use it (ask the user — they have the data)
   - Whether it caused issues post-launch

3. **Score retroactively**: For each component, classify it as it turned out:
   - **Subway rat that delivered** — Users needed it, glad we built it
   - **Costume rat that saved us** — Not the core feature, but prevented a bad experience
   - **Fancy rat that was worth it** — Nice-to-have that actually moved the needle
   - **Fancy rat that was waste** — Built it, nobody cared
   - **Missing subway rat** — Something we should have built but didn't (users complained or churned)

4. **Extract lessons**: What should the team remember for next time?
   - Which "essential" items turned out to be costume?
   - Which "nice-to-haves" turned out to be critical?
   - Did the team's intuition about what users want improve or worsen?

## Output Format

```markdown
## Rat Retrospective: [Feature Name]

### Overall: Were we the right kind of rat?
[One sentence verdict — too subway, too fancy, or just right?]

### Breakdown
| Component | Original Class | Actual Class | Evidence |
|-----------|---------------|-------------|----------|
| ... | Subway Rat / Costume Rat / Fancy Rat | Delivered / Saved us / Worth it / Waste / Missing | ... |

### Costume That Was Waste
[List with rough effort estimate — this is what we'd cut next time]

### Missing Pizza
[Things we should have built but didn't — this informs future rat decisions]

### Lessons for Next Time
1. ...
2. ...
3. ...

### Updated Rat Intuition
[What should we calibrate? Are we cutting too much? Too little? In the wrong places?]
```

5. **Update rat debt**: If the retrospective reveals deferred items that now have evidence for building, update `planning/rat-debt.md` to reflect the new priority.
