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
3. **My money test** — If this was my money, would I want my team spending time on this right now?
4. **Cool vs needed** — Am I building this because the business needs it, or because it's technically interesting?
5. **Spectrum check** — Am I straying too much toward the goodboy rat or the fancy rat?

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

These aren't tech debt — they're correct engineering for unvalidated ideas. Tech debt is when you *know* something needs to scale and you build it to not scale. Rat implementations are when you *don't know* if it needs to exist at all.

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
