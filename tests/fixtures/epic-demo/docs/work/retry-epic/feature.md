---
kind: epic
parent: ""
children:
  - retry-epic-child-1
  - retry-epic-child-2
  - retry-epic-child-3
appetite: "3 weeks"
order: 0
created: 2026-09-01
---

## Problem

Retries today are scheduled in-process and lost on worker restart, causing
duplicate side effects when a retry fires twice after a crash-recovery replay.

## Who it's for

Any team whose job can fail transiently (payments, webhooks, email) and
currently has to hand-roll its own retry logic.

## Success looks like

A shared retry queue that survives a worker restart, with at-least-once but
not duplicate-triggering delivery, adopted by the payments and webhook teams
within the appetite.

## Non-goals

Exactly-once delivery. A UI for inspecting retry state (CLI/API only for v1).

## Appetite

3 weeks, one engineer.
