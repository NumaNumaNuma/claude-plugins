# The Rat Plugin

Deliver the pizza first, dress up later. The Rat is a coding philosophy for startups that prioritizes shipping over polish.

## Mandatory Ratification

**Every plan must be ratified by Ratman.** This is non-negotiable.

- After any plan is produced (dream-team `/dream-plan`, manual planning, architecture proposals), run the Ratman agent to check if the plan passes the rat test.
- Always state "Ratman has ratified this plan" or "Ratman has NOT ratified this plan" in the final output.
- If Ratman has NOT been run on a plan, always propose a high-level rat version of the plan to the user as an alternative. Say something like: "This plan hasn't been ratified yet. Here's what the subway rat version would look like: [stripped-down version]"

## Dream Team Integration

When the dream-team plugin is installed, **Ratman is a team agent**. Include Ratman in the agent roster for `/dream-plan`, `/dream-review`, and `/dream-implement`:

- **During planning**: Ratman runs after the Devil's Advocate pass. It reviews the synthesized plan and proposes a stripped-down rat alternative if the plan is over-engineered.
- **During review**: Ratman checks if the implementation stayed lean or if scope crept.
- **During implementation**: Ratman validates each phase hasn't drifted toward fancy-rat territory.

Ratman is NOT a replacement for the Devil's Advocate. Devil's Advocate challenges assumptions and finds flaws. Ratman challenges scope and finds waste.

## Commands

- **`/ratify [plan]`** — Run Ratman on a plan, feature, or approach. The core command.
- **`/rat-retrospective [feature]`** — Score shipped features retroactively. Was the costume worth it? Did we under-build? Outputs a styled HTML report.

## Templates

- **`templates/retrospective-report.html`** — The canonical HTML template for `/rat-retrospective` reports. Magazine-style dark theme with Playfair Display, Inter, and JetBrains Mono. All reports MUST follow this exact visual style. Read this file before generating any retrospective report.
- **`templates/rat-debt.md`** — Copy to `planning/rat-debt.md` to track cut items and their comeback triggers. Review monthly.
- **`templates/pizza-receipt.md`** — Fill in when shipping a rat-version feature. Documents what was cut and why.

## Retrospective Reports

All `/rat-retrospective` output MUST be saved as styled HTML reports:

- **Location**: `rat-report/` directory in the repository root
- **Filename**: `YYYY-MM-DD-<short-commit-hash>.html` (e.g., `rat-report/2026-03-20-1f030aa.html`)
- **Never overwrite**: If filename exists, append `-2`, `-3`, etc.
- **Must include**: Current commit hash and exact date in the footer
- **Open in browser**: Always open the report after saving
- **Historical**: Multiple reports build a timeline of the team's rat intuition evolution

## Rat Debt Tracking

When Ratman cuts items from a plan, add them to `planning/rat-debt.md` (create from template if it doesn't exist). This prevents deferred items from being forgotten. Monthly review: promote triggered items, retire untriggered items after 6 months.

## When to Activate

- User says "ratify", "rat check", "rat version", "is this too fancy"
- User runs `/ratify` or `/rat-retrospective`
- Any plan is produced (automatic)
- Dream team workflows (as team agent)
- User asks "should we build this?", "is this MVP enough?", "what should we cut?"
- After shipping a feature (prompt for pizza delivery receipt)

## The Core Questions

When in doubt, these questions guide everything:

1. Is this essential for releasing and validating that people want this, or is it "nice to have"?
2. If I don't do this, will enough end users care? notice? complain? uninstall?
3. If this was my money, would I want my team to spend time on this?
4. Am I building this because users need it, or because it's technically cool?
5. Am I straying toward the goodboy rat or the fancy rat?
