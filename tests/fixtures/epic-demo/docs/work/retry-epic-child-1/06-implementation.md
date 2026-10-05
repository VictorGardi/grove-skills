---
feature: retry-epic-child-1
phase: implementation
status: approved
version: 1
created: 2026-09-09
updated: 2026-09-09
based_on:
  - 05-plan.md@1
forced: []
---

## Slice 1 — enqueue and run one retry end to end

Implemented as planned, no deviations. Commit: `retry-epic-child-1: slice 1
— enqueue and run one retry end to end`.

## PR description

Adds the shared `retry_queue` table and worker poll loop (E-D1). Enables
`retry-epic-child-2` (idempotency keys) and `retry-epic-child-3` (payments
adoption) to build on it.

Verify: `npm test -- retry/queue.test.ts`.
