---
feature: retry-epic
phase: questions
status: approved
version: 1
created: 2026-09-01
updated: 2026-09-01
approved_at: 2026-09-01
based_on: []
forced: []
---

## Goal

Replace ad-hoc, in-process retry logic with a shared, crash-safe retry queue.

## Out of scope

Exactly-once delivery; a retry-state UI.

## Research questions

- How are retries currently scheduled, persisted, and recovered after a
  worker restart, across the payments and webhook code paths?
- What mechanisms already exist in this codebase for durable queues or
  scheduled work?
- What idempotency guarantees, if any, do today's retry consumers assume?

## Product questions for the human

- Which team's retry path should the walking skeleton target first?

> payments — it has the clearest duplicate-side-effect incidents on record.

## Size verdict

L — spans payments, webhooks, and a new shared queue component; epic mode
chosen over a plain split.

## Open questions
