# the-rat

**Philosophy:** Deliver the pizza first, dress up later. Ship the dirtiest version that validates demand. Come back and polish only when you know people want it.

## Two commands

**`/ratify`** — Before you build. Feed it any plan (paste it, link a Jira epic, Slack thread, Notion doc, whatever) and it scores how fancy you're being on a 1-10 scale. It'll tell you what to cut, what the subway rat version looks like, and when to bring the cut stuff back.

**`/ratrospective`** — After you ship. Point it at your repo (or multiple repos, or a Jira epic) and it scores what you actually built. Was the costume worth it? Did you over-build? It also tracks "rat debt" — stuff you intentionally cut — and tells you if it's time to build it now.

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

## It runs automatically

Any time a plan is produced (including via dream-team), Ratman reviews it. You don't need to remember to run `/ratify` — it'll flag fancy rats on its own.

## Install

See the [main README](../README.md#the-rat) for install instructions.
