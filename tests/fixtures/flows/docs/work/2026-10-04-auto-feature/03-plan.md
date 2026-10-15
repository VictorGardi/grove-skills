---
feature: 2026-10-04-auto-feature
phase: plan
status: approved
version: 1
created: 2026-10-04
updated: 2026-10-04
approved_at: 2026-10-04
based_on:
  - 01-outcome.md@1
  - 02-research.md@1
forced: []
---

## Decisions

### D1. Where the theme setting is stored

**Context.** The choice must follow the user across devices.

**Options.**
- Server-side in `user_settings`: syncs across devices; needs a migration.
- Browser local storage: no migration; does not sync.

**Pick:** Server-side in `user_settings`

**Outcome impact.** The theme follows the user to any device.

### D2. How the theme is applied on first paint

**Context.** The page must not flash the wrong theme on load.

**Options.**
- Render the `data-theme` attribute on the server: no flash; needs the setting at render time.
- Apply it from client script after load: simple; briefly shows the wrong theme.

**Agents disagree:** The planner preferred server rendering to avoid a flash; the reviewer preferred the client script to keep the page cacheable.
**Human pick:** Server-side rendering of `data-theme`
**Pick:** Server-side rendering of `data-theme`

**Outcome impact.** No wrong-theme flash on load.

## Slices

### Slice 1. Toggle saves and applies the theme

**Thin end-to-end:** the switch on the settings page writes the setting through the API and flips `data-theme` on the page.
**Outcome.** Flipping the switch changes the theme and saves it.
**Files.** settings page, settings API handler, `user_settings` migration.
**Verification.** Flip the switch, reload: the theme persists; the API test for the setting passes.

### Slice 2. Server-rendered first paint

**Outcome.** Reloading shows the saved theme with no flash.
**Files.** page layout template.
**Verification.** Load the page with the setting on: the first HTML response already carries `data-theme="dark"`.

## Reviewer round log

- Round 1: 1 blocking (slice 2 lacked a verification) fixed. CTO check: ok. Veto: none.

## Deviations from the brief the human should know

- None.

## Risks and what is deliberately not done

- Cached pages could serve the wrong theme; caching is not changed here.
- System-theme following is not done (non-goal).

## Open questions
