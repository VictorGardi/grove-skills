---
feature: 2026-10-04-auto-feature
phase: outcome
status: approved
version: 1
created: 2026-10-04
updated: 2026-10-04
approved_at: 2026-10-04
based_on: []
forced: []
---

## Summary

Users can switch the app between light and dark mode from the settings page,
and the choice sticks across sessions.

## What the human sees and does

A "Dark mode" switch on the settings page. Flipping it changes the theme
immediately; reloading the page or signing in on another device keeps it.

## Non-goals

- No automatic "follow the system theme" option.
- No per-page or scheduled themes.

## How I'll know it works

- Flip the switch: the whole app changes theme without a reload.
- Reload and sign in elsewhere: the theme is the same.

## Interview log

- Q: Should the choice follow the user across devices? A: Yes.

## Open questions
