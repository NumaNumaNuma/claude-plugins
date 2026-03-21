# The Rat Philosophy

## The Metaphor

A dirty subway rat (the left) can absolutely deliver a decent pizza (very MVP version of a feature delivered quickly).

We never know if people will like our pizza before it is delivered, so we must be the subway rat and deliver it as quickly as we can. No time to dress up.

If we spend weeks making the best rat costume (polishing a feature or code too much before releasing it) and later find out that people are not hungry, or hate the pizza, we have wasted a lot of precious time and money.

**Building the right thing at the wrong time is building the wrong thing.**

By focusing too much on dressing up, we run the risk of not even delivering the pizza at all! (See: Very fancy rat on the right — doesn't even have a pizza.)

Once we know people like our pizza, we can decide to come back next time, dressed up like a good boy.

As a startup we can't afford fancy rat suits. We are subway rats (most of the time). We must deliver the pizza quickly. No one pays us for how fancy we dress, as long as a pizza gets delivered.

## The Rat Spectrum

```
SUBWAY RAT -------- GOOD BOY -------- FANCY RAT
  (ships)          (balanced)        (no pizza)
    [+]               [~]               [-]
```

- **Subway Rat** (score 1-3): Raw, dirty, but the pizza is delivered. Might have bugs, might not scale, might look rough. But users can try it NOW.
- **Good Boy** (score 4-6): Cleaned up, presentable, pizza is warm and on a plate. Reasonable quality, handles the common cases. Good balance.
- **Fancy Rat** (score 7-10): Beautiful costume, perfect manners, but where's the pizza? Over-engineered, over-polished, possibly never ships.

## The Diagnostic Questions

1. **Essential or nice-to-have?** — Is this required to release and validate that people want this feature?
2. **Would users notice?** — If I skip this, will enough end users care, notice, complain, or uninstall?
3. **My money test** — If this was your own money, would you pay someone to build it?
4. **Cool vs needed** — Am I building this because the business needs it, or because it's technically interesting?
5. **Team friction** — Fresh install to running in under 30 minutes. Existing setup to testing a change in a few minutes. If not, something is overengineered.
6. **Spectrum check** — Am I straying too much toward the goodboy rat or the fancy rat?

## Real-World Rat Successes

### At Jig
- **Submission system**: Done in 1 sprint. No database, no counting submissions, no emails, no duplicate tracking. Good enough to see if people want to submit Jigs.
- **Version API**: For a year+, used Postman to create versions. Perfectly fine for few releases. Built dashboard later when frequency increased.
- **Undo-Redo**: Works ~20% of the time. Written in a day or two in 2016. No one has ever mentioned it.
- **Sound in Jig**: Hosted on website instead of building a whole API. Worked great for 3-4 years. Built proper API later when every Jig needed sound.

### In the Industry
- **Apple (iOS email)**: Couldn't attach images to emails until iOS 4. Rat solution: select photo, share as email, start typing from there.
- **Unity (mesh limits)**: No 32-bit integers until 2019, so 65K vertex limit. Rat solution: auto-split large models on import.
- **Slack (text formatting)**: No bold/italic/underline buttons until 2020. Rat solution: keyboard shortcuts.
- **League of Legends (Jarvan's R)**: Engine couldn't do round hitboxes efficiently. Rat solution: 16 transparent monsters arranged in a circle for collision.

## The Dirty Implementation Principle

Rat solutions should be intentionally unsustainable. If a solution would make a senior engineer uncomfortable, it's probably the right level for validating an idea. Sustainable = expensive. Unsustainable = cheap. You want cheap until you know people want it.

- A text file on disk is a database
- A Google Sheet is a CMS
- SSH + grep is monitoring
- Postman is an admin panel
- A hardcoded boolean is a feature flag
- `console.log` is logging
- A manually-edited JSON file on the server is a settings panel
- A shared password is authentication
- A cron job that runs a bash script is a background job queue
- You clicking through the feature manually is a test suite
- A Supabase project is your database while you figure out the schema
- Vercel/Fly.io/Render is your hosting even if the company uses AWS
- Production is your staging environment when the feature has no existing users
- Five Jira tasks under an epic is your project plan

These aren't tech debt — they're correct engineering for unvalidated ideas. Tech debt is when you *know* something needs to scale and you build it to not scale. Rat implementations are when you *don't know* if it needs to exist at all.

## Buy Before You Build

Engineers love building things. That's the problem. Before writing a single line of code, ask: does someone already sell this?

A dedicated team working 24/7 on that exact feature will always build something better than a single developer can on the side. Even if it costs money — your time costs money too, and usually more of it. Auth, document parsing, file management, PDF extraction, payments, email — these are solved problems. Use the existing solution.

Build your own only when:
- Nothing suitable exists
- It's genuinely too expensive for the current stage
- It's a tiny utility where the dependency overhead isn't worth it (small glue code is fine — better than managing 45 open-source repos)

You can always replace the off-the-shelf solution later with your own if the feature is validated and the economics make sense.

## Skip the Ceremony for New Features

If the feature is new and no existing users are at risk, skip the process:
- No feature branches — commit to main
- No mock databases — use the real thing (or a quick Supabase instance)
- No staging environment — deploy to prod
- No heavyweight infra setup — use whatever deploys fastest, even if the company standard is something else

The fastest path to user feedback is the one with the fewest gates between you and production. Non-prod environments exist to protect things people already rely on — not to slow down validation of things nobody has seen yet.

**On company infra vs quick-deploy platforms:** A new Vercel project takes about 10 minutes — that's the bar. If the company's existing infra can match that, use it. Some companies have great tooling where spinning up a new service is genuinely quick and you get monitoring/auth/networking for free. But if "using company infra" means filing a ticket, waiting for a VM, writing Terraform, and setting up a CI pipeline, that's costume. The point isn't "always use Vercel" — it's "always pick the fastest path to deployed and running."

## Don't Over-Spec the Plan

A handful of well-defined tasks under an epic is plenty. Each task should cover a real chunk of work, not an individual input field. Over-speccing creates admin overhead that slows everyone down — managing 20 tickets takes time away from building the pizza.

Write enough detail that someone could pick up the task and know what to do. Don't write so many tasks that managing the board becomes a job in itself.

## Testing at the Rat Stage

At the rat stage, YOU are the test suite. Run it yourself. Click through the happy path. If it works, ship it.

Writing unit tests for unvalidated features is like buying insurance on a pizza you haven't tasted yet. You don't even know if you'll keep selling it. Tests are costume until the pizza is proven.

When to bring tests back:
- The feature is validated — users want it, it's staying
- Breakage becomes frequent during development (something keeps breaking the same way)
- The team grows and manual testing can't keep up
- The feature handles money, auth, or data that can't be wrong

Until then, a developer doing a manual end-to-end test IS the test.

## Anti-Patterns (Signs You're Becoming a Fancy Rat)

- Building an admin dashboard before anyone uses the feature
- Adding pagination before there's enough data to paginate
- Writing a generic abstraction for one use case
- Building a microservice when a function would do
- Adding feature flags before you have users to flag
- Writing migration scripts before the schema is validated
- Spending more time on error handling than on the happy path
- Making it configurable when you don't know the config yet
- Building the "proper" API before validating with a hardcoded prototype
- Optimizing performance before measuring performance
- Writing unit tests before the feature is validated
- A local setup that requires a README to get running
- Custom internal tools that need their own docs
- Abstractions that force new devs to read docs before contributing
- Deploy processes only one person on the team understands
- Building something yourself when a paid service does it better
- Setting up staging/non-prod for a feature nobody uses yet
- Creating 20 Jira tasks when 5 would do
- Using heavyweight company infra when a quick deploy platform would validate faster
