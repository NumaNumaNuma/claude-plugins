---
description: "Score shipped features retroactively — was the costume worth it? Did we over-build or under-build?"
argument-hint: "Feature, commit range, or area (e.g., 'since abc123', 'last 10 commits', 'the billing system', 'this repo')"
---

# Rat Retrospective: $ARGUMENTS

Look back at a shipped feature and evaluate it through the Rat lens. The goal is to build institutional memory: learn which costume items actually mattered and which were waste.

## Workflow

1. **Identify the scope**: Determine what to evaluate from `$ARGUMENTS`.

   **Commit range** — if the user references commits, branches, or time ranges:
   - `since <hash>` or `changes since <hash>` → `git log <hash>..HEAD`, `git diff --stat <hash>..HEAD`
   - `last N commits` → `git log -N`, `git diff --stat HEAD~N..HEAD`
   - `between <A> and <B>` → `git log <A>..<B>`, `git diff --stat <A>..<B>`
   - `since last release` or `since last tag` → find latest tag with `git describe --tags --abbrev=0`, then diff from there
   - `branch <name>` → `git log main..<name>`, `git diff --stat main..<name>`
   - For commit ranges, read the actual changed files (`git diff <range> -- '*.go' '*.ts' ...`) to understand what was built, not just commit messages

   **Feature or area** — if the user names a feature or system:
   - Find the relevant code, planning docs, and git history

   **Sprints** — if the user references sprints:
   - Read the sprint plans from `planning/sprints/`

   **Whole repo** — if the user asks about the repo as a whole:
   - Evaluate the entire codebase structure and history

   **Empty** — if no arguments:
   - Look at the last 1-3 completed sprints or ask the user

2. **Capture the snapshot**: Before analysis, capture:
   - Run `git log -1 --format="%H %h %ci"` to get the current commit hash (full + short) and date
   - Run `date +"%Y-%m-%d"` for the report date
   - If reviewing a commit range, also note the range boundaries (e.g., "abc123..def456")
   - These MUST appear in the final report

3. **Gather evidence**: For each component that was built, find:
   - How much effort went into it (git log, file changes, sprint duration)
   - Whether users actually use it (ask the user — they have the data)
   - Whether it caused issues post-launch

4. **Score retroactively**: For each component, classify it as it turned out:
   - **Subway rat that delivered** — Users needed it, glad we built it
   - **Costume rat that was worth it** — Nice-to-have that actually moved the needle
   - **Fancy rat that was worth it** — Nice-to-have that actually moved the needle
   - **Fancy rat that was waste** — Built it, nobody cared
   - **Missing subway rat** — Something we should have built but didn't (users complained or churned)
   - **Team friction** — Something that slowed teammates down (hard to setup, deploy, or iterate on)

   **Important:** Zero test coverage on a component is NOT a negative signal at the rat stage. Do not flag missing tests as a "missing subway rat" or append "ZERO TESTS" badges. At the rat stage, the developer doing a manual e2e test IS the test. Tests come back when the feature is validated and needs hardening. "Missing subway rat" means features users actually needed but didn't get — not engineering niceties like test coverage, error handling, or documentation.

5. **Extract lessons**: What should the team remember for next time?
   - Which "essential" items turned out to be costume?
   - Which "nice-to-haves" turned out to be critical?
   - Did the team's intuition about what users want improve or worsen?

## Output: HTML Report

**CRITICAL: All retrospective reports MUST be output as styled HTML files.**

Read the template at `templates/retrospective-report.html` (relative to `${CLAUDE_PLUGIN_ROOT}`) for the exact CSS, structure, and visual style to follow. This is the canonical reference — match it precisely.

### Report structure (6 sections):

1. **Hero** — Project name in `<em>`, subtitle describing what was reviewed, 4-6 key stats in hero-meta
2. **Verdict banner** — One-paragraph overall assessment in the amber gradient box
3. **At a Glance** — Stat cards + effort distribution donut chart (SVG) + legend
4. **Component Breakdown** — Cards grouped by classification:
   - Subway Rats (`.badge-subway`, green) — essential, delivered
   - Costume Worth It (`.badge-costume-worth`, blue) — nice-to-have that paid off
   - Borderline Costume (`.badge-costume-borderline`, purple) — jury's out
   - Waste items get their own section with `.waste-card` (red gradient)
5. **Missing Subway Rats** — `.missing-card` with orange left border, impact levels (HIGH/MEDIUM/LOW)
6. **Lessons** — Drop-cap numbered lessons (`.lesson-number`), bold takeaway in each
7. **Calibration** — Pattern summary + concrete rule recommendation in `.rule-box`

### Badge classes:
- `.badge-subway` — green, for essential components that delivered
- `.badge-costume-worth` — blue, for nice-to-haves that paid off
- `.badge-costume-borderline` — purple, for jury-is-out items
- `.badge-waste` — red, for items that were waste
- `.badge-missing` — orange, for flags like "TEAM FRICTION" or "SLOWS ONBOARDING"
- Do NOT use badges for missing tests — zero test coverage is expected at the rat stage

### Footer MUST include:
```html
<footer>
  <p>Rat Retrospective &middot; {{PROJECT_NAME}} &middot; {{FULL_DATE}}</p>
  <p style="margin-top: 4px;">Commit: <code>{{SHORT_COMMIT_HASH}}</code></p>
  <!-- If reviewing a commit range, add the range -->
  <p style="margin-top: 4px;">Range: <code>{{START_HASH}}..{{END_HASH}}</code> ({{N}} commits)</p>
  <p style="margin-top: 8px; color: #52525b;">Generated by <a href="#">The Rat</a> &middot; Claude Code plugin</p>
</footer>
```

## Saving the Report

### Location
Reports are saved to `rat-report/` in the repository root. Create the directory if it doesn't exist.

### Filename format
```
rat-report/YYYY-MM-DD-<short-commit-hash>.html
```

Examples:
- `rat-report/2026-03-20-1f030aa.html`
- `rat-report/2026-04-15-a3b8c2d.html`

### Uniqueness rules
- **NEVER overwrite an existing report.** If a file with the same name already exists (same day + same commit), append a sequence number: `rat-report/2026-03-20-1f030aa-2.html`
- Multiple reports over time build a history of how the team's rat intuition evolves.

### After saving
1. Open the report in the browser (`open <path>` on macOS)
2. Tell the user the file path so they can find it later
3. Mention how many previous reports exist in `rat-report/` if any (for historical context)

## Post-report actions

6. **Update rat debt**: If the retrospective reveals deferred items that now have evidence for building, update `planning/rat-debt.md` to reflect the new priority.
