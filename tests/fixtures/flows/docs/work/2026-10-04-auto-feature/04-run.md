---
feature: 2026-10-04-auto-feature
phase: run
status: draft
version: 1
created: 2026-10-04
updated: 2026-10-04
approved_at:
based_on:
  - 03-plan.md@1
forced: []
---

# Run: Add a dark-mode toggle to settings

Profile: inherit
Branch: run/2026-10-04-auto-feature-inherit
Plan commit: 7c1e9a47d3b25f08a6e1c94b0d2f7385ae61c9d0
Roles:
- cto: claude, inherit
- researcher: claude, inherit
- planner: claude, inherit
- reviewer: claude, inherit
- implementer: claude, inherit

## Slice 1

Session: auto-feature-slice-1
Status: done
Commit: this commit (see git log)

### Slice plan

Found in the code: the settings page renders boolean switches from the settings API; `user_settings` has no theme column.

Implementer 1:
- [x] Add the `theme` column in a `user_settings` migration
- [x] Accept `theme` in the settings API handler
- [x] Add the "Dark mode" switch to the settings page and flip `data-theme` on change

Models passed: reviewer: inherit, implementer: inherit

### Review rounds

Round 1: 0 blocking, nothing to fix, approved.

approved, 0 blocking, 0 fix rounds. Non-blocking left: none

### Deviations

None.

### Verification

Flipped the switch and reloaded: the theme persisted. The API test for the setting passes. Models requested: reviewer inherit, implementer inherit.

### Left for the human

None.

## Slice 2

Session: auto-feature-slice-2
Status: done
Commit: this commit (see git log)

### Slice plan

Found in the code: the page layout template renders the root element without a theme attribute.

Implementer 1:
- [x] Read the saved theme at render time and emit `data-theme` on the root element in the layout template

Models passed: reviewer: inherit, implementer: inherit

### Review rounds

Round 1: 0 blocking, nothing to fix, approved.

approved, 0 blocking, 0 fix rounds. Non-blocking left: none

### Deviations

None.

### Verification

Loaded the page with the setting on: the first HTML response already carries `data-theme="dark"`. Models requested: reviewer inherit, implementer inherit.

### Left for the human

Look at the page on a slow connection to confirm there is no flash (not run here).

## Final summary

- Slice 1: `Dark mode toggle saves and applies the theme`: the switch writes the setting through the API and flips `data-theme`. Review: approved, 0 fix rounds. Deviations: none.
- Slice 2: `Render the saved theme on first paint`: the layout template emits `data-theme` from the saved setting. Review: approved, 0 fix rounds. Deviations: none.

### Left for the human

Check the first paint on a slow connection for a theme flash.

### PR description

Add a dark-mode toggle to settings

Slice 1 adds a `theme` setting (migration, API, settings-page switch) that applies immediately and persists. Slice 2 renders the saved theme on the server so reloading shows no flash. Verified by reloading after flipping the switch, the API test, and checking the first HTML response carries `data-theme="dark"`. Left for the human: a slow-connection check for a flash.

## Open questions
