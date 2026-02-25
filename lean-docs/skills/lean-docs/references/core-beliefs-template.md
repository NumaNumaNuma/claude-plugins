# Core Beliefs Template

5-10 operating principles that explain the "why" behind your project's rules.
For the mechanical "what" (enforceable rules), see golden-principles.md.

```markdown
# Core Beliefs

1. **[Principle Name]** — [One sentence explaining why this matters for the project]
2. **[Principle Name]** — [One sentence explaining why this matters for the project]
...
```

## Example Beliefs (pick what fits your project)

- **One Concurrency Model** — A single async pattern eliminates an entire class of bugs. Mixed paradigms create gaps where errors hide.
- **Optimistic Updates First** — User actions should feel instant. Mutate local state immediately, reconcile with the server async.
- **The Database Is the Authority** — Server-side access policies are the real access control layer, not client-side checks.
- **Repository Is the Single Source of Knowledge** — If it's not in the repo, it doesn't exist for agents. Architectural decisions and gotchas must be captured in docs/.
- **Separate Concerns by Layer** — Services own business logic and must never know about UI frameworks. Views own presentation and observe services.
- **Prefer Boring Technology** — Use well-documented, stable APIs that agents can reason about from training data. Three similar lines of code is better than a premature abstraction.
- **Small Files, Clear Boundaries** — Large files are expensive for agents to load and reason about. Splitting by responsibility keeps each file focused.
- **Encode Taste as Rules, Not Comments** — If a pattern matters enough to care about, encode it as a lint rule. Comments are suggestions; lint rules are constraints.
