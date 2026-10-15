---
feature: 2026-10-04-auto-feature
phase: research
status: approved
version: 1
created: 2026-10-04
updated: 2026-10-04
approved_at: 2026-10-04
based_on:
  - 01-outcome.md@1
forced: []
repo_heads:
  - 4d5e6f7
---

## Summary

Colors come from CSS variables on the root element. User preferences are
stored server-side in a `user_settings` table behind a small settings API.

## Answers

- Theme tokens are defined once as CSS variables; a `data-theme` attribute on
  the root element would switch them.
- The settings page already renders boolean switches from the settings API.
- Nothing stores a theme today.

## Open questions
