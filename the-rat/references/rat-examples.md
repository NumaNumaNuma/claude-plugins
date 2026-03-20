# Rat Transformation Examples

Real examples of how a fancy plan gets ratified into a subway rat delivery.

## Example 1: User Notifications

### Fancy Rat Plan
- Real-time WebSocket notifications
- In-app notification center with read/unread states
- Email digest system with configurable frequency
- Push notifications for mobile
- Notification preferences per category
- Database table for notification history
- Background job queue for delivery

### Ratified (Subway Rat) Version
- Send an email when something happens. That's it.
- No notification center, no preferences, no history.
- If users want more, they'll tell us.

**Rat score: 2/10** (pizza delivered)

---

## Example 2: Search Feature

### Fancy Rat Plan
- Elasticsearch cluster
- Faceted search with filters
- Autocomplete with fuzzy matching
- Search analytics dashboard
- Relevance tuning
- Indexing pipeline

### Ratified (Subway Rat) Version
- SQL `LIKE '%query%'` on the title column.
- One search box, one results list.
- If it's too slow or people need filters, we'll know.

**Rat score: 1/10** (pure subway rat, pizza delivered)

---

## Example 3: User Onboarding

### Fancy Rat Plan
- Multi-step wizard with progress bar
- Interactive tooltips for each feature
- Personalized recommendations
- Onboarding analytics funnel
- A/B tested flows
- Skip/resume capability

### Ratified (Subway Rat) Version
- A single "Getting Started" page with 3 bullet points and a link to the main feature.
- Maybe a welcome email.
- Watch what users do and iterate.

**Rat score: 2/10** (pizza with a napkin)

---

## The Pattern

Every rat transformation follows the same structure:

1. **Identify the pizza** — What's the one thing the user actually needs?
2. **Strip the costume** — Remove everything that isn't the pizza
3. **Find the dirtiest path** — What's the fastest way to deliver just the pizza?
4. **Define the comeback trigger** — Under what conditions do we dress up? (e.g., "if > 100 users/day", "if anyone complains", "if it breaks in production")
