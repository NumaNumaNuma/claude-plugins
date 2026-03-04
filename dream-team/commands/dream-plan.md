---
description: "Pick relevant Dream Team agents to collaboratively plan a feature"
argument-hint: "Feature to plan (e.g., 'user notifications system')"
---

# Dream Plan: $ARGUMENTS

You are planning the feature described above using the Dream Team methodology, but with **selective agent activation** — only launch agents that are relevant to this specific feature.

## Agent Selection

Read `references/agent-roster.md` for the full roster with preferred agents, fallback prompts, and inclusion criteria. **Planning uses all agents including Code Quality Engineer** (the only phase where it's active — `/simplify` replaces it during implementation and review).

Review the feature and decide which agents to activate. **Justify each inclusion/exclusion in a brief sentence before launching.** For trivial changes (single-line fixes, typo corrections), skip the full dream-team process and just make the change directly.

## Workflow

1. **Select agents**: State which agents you're activating and why (1-2 sentences each). State which you're skipping and why.

2. **Launch in parallel**: Launch all selected agents simultaneously using the Task tool with `run_in_background: true`. Each agent receives the full feature description and is told to focus on **planning only** — no implementation.

   Each agent prompt must include:
   - The feature description: "$ARGUMENTS"
   - Instruction to explore the codebase and produce a planning analysis from their specialist perspective
   - Reminder to read relevant existing code, docs, and CLAUDE.md files before making recommendations
   - Explicit instruction: "Output a plan/analysis only. Do not write any code."
   - "Report only your findings. No preamble, no summaries of what you checked, no restating the task."

3. **Synthesize**: After all agents return, combine their findings into a unified plan. Highlight:
   - Points of agreement across agents
   - Conflicts or tensions between recommendations
   - Open questions that need user input

4. **Devil's Advocate pass**: Resume the Devil's Advocate agent with the synthesis for a final challenge. Address every objection — either incorporate it or explain why it's dismissed.

5. **Edge case sweep**: Review the plan yourself with fresh eyes and specifically hunt for missed edge cases. For each component in the plan, ask:
   - What happens on first use? (empty states, no data, new user)
   - What happens at scale? (1000+ items, concurrent users, large payloads)
   - What happens on failure? (network down, timeout, partial write, auth expired)
   - What happens with bad input? (empty strings, nulls, duplicates, special characters)
   - What happens out of order? (race conditions, double-taps, stale data, back navigation)
   - What happens on different devices/contexts? (small screens, offline, background/foreground transitions)

   Add any newly discovered edge cases to the plan. If an edge case would require a new task, add it. If it's a risk, add it to the risks table.

6. **Create sprint directory**: Save the plan to the project's planning directory:
   ```
   planning/sprints/sprint-N-name/
   ├── plan.md         — Copy from templates/sprint-plan.md, fill in architecture decisions
   ├── tasks.md        — Copy from templates/tasks.md, fill in implementation tasks
   ├── progress.md     — Copy from templates/progress.md, initialize checkpoint
   └── test-plan.md    — What to test (if Test Engineer was activated)
   ```
   Use the templates from this plugin's `templates/` directory as starting points.

7. **Final plan**: Present the consolidated implementation plan with:
   - Architecture decisions (with rationale)
   - Files to create/modify
   - Database changes (if any)
   - Implementation sequence (what to build first)
   - Edge cases and risks identified
   - Open questions for the user

Present the final plan clearly and ask the user if they'd like to proceed with implementation.

## Sprint Rules

Read `references/sprint-rules.md` for the full non-negotiable sprint rules. Key planning-specific rules:
- Record plans in `planning/sprints/sprint-N-name/`
- Create `test-plan.md` during planning if the sprint has testable features
- Always include a Bug Fix Phase in tasks.md (left empty until manual testing)
