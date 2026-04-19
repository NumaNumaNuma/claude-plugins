---
description: "Pick relevant Dream Team agents to collaboratively plan a feature"
argument-hint: "Feature to plan (e.g., 'user notifications system')"
---

# Dream Plan: $ARGUMENTS

Plan this feature using the Dream Team methodology — selective specialist agents in parallel, then synthesise. The goal is a plan sharp enough to implement directly, with edge cases and risks surfaced early while they're cheap to address.

## Agent Selection

Read `references/agent-roster.md` for the roster, fallback prompts, and per-agent inclusion criteria. Planning is the one phase where **Code Quality Engineer is active** — `/simplify` replaces it during implementation and review.

Decide which agents to activate. State each inclusion/exclusion in one sentence before launching. For genuinely trivial changes (one-line fix, typo, obvious rename), skip the whole process and just make the change — spinning up five specialists for a typo is how the workflow earns a bad reputation.

## Workflow

### 1. Select agents
State which agents you're activating and why (one sentence each). State which you're skipping and why. Decisive exclusions matter as much as inclusions — a pure migration doesn't need UI/UX.

### 2. Launch in parallel
Spawn all selected agents in a single turn with `run_in_background: true`. Each prompt includes:
- The feature description: "$ARGUMENTS"
- Their specialist focus and explicit anti-focus (another agent owns X, Y)
- "Explore the codebase and read relevant CLAUDE.md + docs first. Output a plan/analysis only, no code. Report only your findings — no preamble, no summaries of what you checked, no restating the task."

### 3. Synthesise
When agents return, combine their findings into a unified plan that surfaces:
- **Agreement** — where specialists converge, you have high confidence
- **Tensions** — where they conflict, the user needs to weigh in (or you make an explicit tradeoff)
- **Open questions** — gaps that need user input before implementation

Never paste raw agent output. Synthesise into tight, decision-ready prose.

### 4. Devil's Advocate pass
Resume the Devil's Advocate with the synthesis and ask for a final challenge. Address every objection — either incorporate it or explain why it's dismissed. A dismissed objection without reasoning is a skipped objection.

### 5. Edge case sweep
Walk the plan with a specific lens: what breaks this? For each component, think through:
- First use (empty states, no data, brand new user)
- Scale (many items, concurrent users, large payloads)
- Failure (network down, timeout, partial write, auth expired)
- Bad input (empty, null, duplicate, special characters, wrong type)
- Ordering (race conditions, double-submit, stale data, back nav)
- Context (small screens, offline, backgrounded, returning from deep link)

Add newly discovered edge cases to the plan. If an edge case needs its own task, add it. If it's a risk worth tracking, add it to the risks table.

### 6. Create the sprint directory
Save the plan into the project:

```
planning/sprints/sprint-N-name/
├── plan.md         — Architecture decisions (use templates/sprint-plan.md)
├── tasks.md        — Implementation tasks (use templates/tasks.md)
├── progress.md     — Initialised checkpoint (use templates/progress.md)
└── test-plan.md    — What to test (if Test Engineer was activated)
```

### 7. Present the plan
Show the user the consolidated plan: architecture decisions with rationale, files to create/modify, database changes, implementation sequence, edge cases, risks, open questions. Ask if they'd like to proceed with implementation.

## Sprint Rules

Read `references/sprint-rules.md` for the full sprint rules. Planning-specific: plan lives in `planning/sprints/`, `test-plan.md` is written during planning (not deferred), `tasks.md` always includes a Bug Fix Phase.
