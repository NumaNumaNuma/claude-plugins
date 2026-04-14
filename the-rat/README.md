# the-rat

**Philosophy:** Deliver the pizza first, dress up later. The Rat is a coding philosophy for startups that prioritizes shipping over polish — ship the dirtiest version that validates demand, come back and polish only when you know people want it.

<p align="center">
  <img src="assets/feature-dev-tiers.png" alt="Feature dev tiers: Subway rat (MVP with pizza), Costume rat (dressed up with pizza), Fancy rat (full costume, no pizza)" width="600" />
</p>

## Commands and features

- **`/ratify`** — Before you build. Feed it any plan (paste it, link a Jira epic, Slack thread, Notion doc, whatever) and the Ratman agent scores how fancy you're being on a 1–10 scale. It tells you what to cut, what the subway rat version looks like, and when to bring the cut stuff back.
- **`/ratrospective`** — After you ship. Point it at your repo (or multiple repos, or a Jira epic) and it scores what you actually built. Was the costume worth it? Did you over-build? Tracks "rat debt" — stuff you intentionally cut — and tells you when it's time to build it.
- **Ratman agent** — Classifies every item as Subway Rat (essential, ship dirty), Costume Rat (nice-to-have, cut it), or Fancy Rat (future-proofing, hard cut). Proposes subway-rat alternatives with time-to-pizza estimates.
- **Dream-team integration** — Ratman is a non-negotiable team agent and runs after Devil's Advocate to challenge scope. Any time a plan is produced (including via dream-team), Ratman reviews it automatically — you don't need to remember to run `/ratify`.

## The scale

```
SUBWAY RAT -------- GOOD BOY -------- FANCY RAT
  (ships)          (balanced)        (no pizza)
 Score 1-3         Score 4-6         Score 7-10
```

## What it checks

1. Is this essential or nice-to-have?
2. Would users notice if we cut it?
3. If this was your own money, would you pay someone to build it?
4. Is this cool or actually needed?
5. Does this slow the rest of the team down? (30min fresh install, minutes to test a change)
6. Is there an off-the-shelf solution?

## Key principles

- **Tests are costume.** You clicking through it IS the test. Write tests when the feature is proven.
- **Buy before you build.** A team working 24/7 on auth will always beat you building auth on the side.
- **Skip the ceremony.** New feature with no users? Deploy to prod. No staging, no feature branches.
- **Use whatever deploys fastest.** Vercel in 10 min beats filing an AWS ticket. Unless your company infra is genuinely that fast.
- **Don't over-spec tasks.** 5 chunky Jira tasks under an epic, not 20 tickets for individual fields.

## Install

See the [main README](../README.md) for marketplace install instructions.
