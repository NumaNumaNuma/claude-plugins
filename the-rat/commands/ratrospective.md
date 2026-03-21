---
description: "Score shipped features retroactively — was the costume worth it? Did we over-build or under-build?"
argument-hint: "Feature, commit range, repos, or Jira epic (e.g., 'since abc123', 'repos: go-sense, jig-web', 'JIG-5870', 'this repo')"
---

# Ratrospective: $ARGUMENTS

Look back at a shipped feature and evaluate it through the Rat lens. The goal is to build institutional memory: learn which costume items actually mattered and which were waste — and surface any rat debt whose comeback triggers have fired.

## Workflow

1. **Identify the scope**: Determine what to evaluate from `$ARGUMENTS`.

   **Commit range** — if the user references commits, branches, or time ranges:
   - `since <hash>` or `changes since <hash>` → `git log <hash>..HEAD`, `git diff --stat <hash>..HEAD`
   - `last N commits` → `git log -N`, `git diff --stat HEAD~N..HEAD`
   - `between <A> and <B>` → `git log <A>..<B>`, `git diff --stat <A>..<B>`
   - `since last release` or `since last tag` → find latest tag with `git describe --tags --abbrev=0`, then diff from there
   - `branch <name>` → `git log main..<name>`, `git diff --stat main..<name>`
   - For commit ranges, read the actual changed files (`git diff <range> -- '*.go' '*.ts' ...`) to understand what was built, not just commit messages

   **Multiple repos** — if the user lists repos or the feature spans multiple repos:
   - `repos: go-sense, jig-web, jig-api` or `go-sense and jig-web since last week`
   - For each repo, resolve the path. Try these in order:
     1. Sibling directories of the current working directory (e.g., `../go-sense`)
     2. Common parent directories (e.g., `~/repos/go-sense`, `~/JigSpace/Repos/go-sense`)
     3. Ask the user for the path if not found
   - Run git analysis on each repo independently, then combine into a single cross-repo report
   - The report hero should list all repos analyzed
   - Component breakdown should tag each component with which repo it belongs to
   - Commit hashes in the footer should show per-repo: `go-sense: abc123 · jig-web: def456`
   - Apply the same commit range / time filter across all repos if specified (e.g., `repos: go-sense, jig-web since 2026-03-01`)

   **Jira epic** — if the user provides a Jira issue key (e.g., `JIG-5870`):
   - Fetch the epic and its child tasks using the Jira MCP
   - Extract repo/branch/PR references from the child tasks
   - Resolve those repos locally (same path resolution as above)
   - Use the Jira tasks as a guide for what was planned vs what was built — this gives extra context for the classification ("was this item in the original plan or did it creep in?")
   - Fall back to asking the user for repo paths if Jira data doesn't contain them

   **Feature or area** — if the user names a feature or system:
   - Find the relevant code, planning docs, and git history

   **Sprints** — if the user references sprints:
   - Read the sprint plans from `planning/sprints/`

   **Whole repo** — if the user asks about the repo as a whole:
   - Evaluate the entire codebase structure and history

   **Empty** — if no arguments:
   - Look at the last 1-3 completed sprints or ask the user

2. **Capture the snapshot**: Before analysis, capture:
   - Run `git log -1 --format="%H %h %ci"` in each repo to get commit hashes and dates
   - Run `date +"%Y-%m-%d"` for the report date
   - If reviewing a commit range, also note the range boundaries (e.g., "abc123..def456")
   - For multi-repo: capture the commit hash from each repo separately
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

5. **Surface rat debt**: For every costume/fancy item that was cut or identified as waste, check if its comeback trigger has fired. This replaces separate debt tracking files — the ratrospective IS the debt review. Categorize each:
   - **Triggered — time to build**: Evidence shows users need this now. Include as a recommended task.
   - **Still watching**: No evidence yet. Keep it on the list.
   - **Retired**: 6+ months with no trigger. Nobody needs it. Remove from future reports.

6. **Extract lessons**: What should the team remember for next time?
   - Which "essential" items turned out to be costume?
   - Which "nice-to-haves" turned out to be critical?
   - Did the team's intuition about what users want improve or worsen?

## Output: HTML Report

**CRITICAL: All ratrospective reports MUST be output as styled HTML files.**

Read the template at `templates/retrospective-report.html` (relative to `${CLAUDE_PLUGIN_ROOT}`) for the exact CSS, structure, and visual style to follow. This is the canonical reference — match it precisely.

### Report structure (8 sections):

1. **Hero** — Project name in `<em>`, subtitle describing what was reviewed, 4-6 key stats in hero-meta
2. **Verdict banner** — One-paragraph overall assessment in the amber gradient box
3. **At a Glance** — Stat cards + effort distribution donut chart (SVG) + legend
4. **Component Breakdown** — Cards grouped by classification:
   - Subway Rats (`.badge-subway`, green) — essential, delivered
   - Costume Worth It (`.badge-costume-worth`, blue) — nice-to-have that paid off
   - Borderline Costume (`.badge-costume-borderline`, purple) — jury's out
   - Waste items get their own section with `.waste-card` (red gradient)
5. **Missing Subway Rats** — `.missing-card` with orange left border, impact levels (HIGH/MEDIUM/LOW)
6. **Rat Debt Status** — For each previously cut item, show its comeback trigger and current status:
   - **Triggered** (`.badge-triggered`, green border) — evidence shows it's time to build this. Include a concrete task recommendation.
   - **Watching** (`.badge-watching`, dim/muted) — no evidence yet, keep monitoring
   - **Retired** (`.badge-retired`, strikethrough) — 6+ months, no trigger, nobody needs it
   - If previous ratrospective reports exist in `rat-report/`, check them for debt items to track continuity
7. **Lessons** — Drop-cap numbered lessons (`.lesson-number`), bold takeaway in each
8. **Calibration** — Pattern summary + concrete rule recommendation in `.rule-box`

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
  <p>Ratrospective &middot; {{PROJECT_NAME}} &middot; {{FULL_DATE}}</p>
  <!-- Single repo -->
  <p style="margin-top: 4px;">Commit: <code>{{SHORT_COMMIT_HASH}}</code></p>
  <!-- Multi-repo: show each repo's commit -->
  <p style="margin-top: 4px;">{{REPO_A}}: <code>{{HASH_A}}</code> &middot; {{REPO_B}}: <code>{{HASH_B}}</code></p>
  <!-- If reviewing a commit range, add the range -->
  <p style="margin-top: 4px;">Range: <code>{{START_HASH}}..{{END_HASH}}</code> ({{N}} commits)</p>
  <p style="margin-top: 8px; color: #52525b;">Generated by <a href="#">The Rat</a> &middot; Claude Code plugin</p>
</footer>
```

## Saving the Report

### Location
Reports are saved to `rat-report/` in the repository root. Create the directory if it doesn't exist. For multi-repo ratrospectives, save to `rat-report/` in the current working directory (or the first listed repo if CWD isn't one of the repos).

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
