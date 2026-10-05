---
feature: retry-epic-child-1
phase: structure
status: approved
version: 1
created: 2026-09-07
updated: 2026-09-07
approved_at: 2026-09-07
based_on:
  - 03-design.md@1
forced: []
---

## Slices

### Slice 1 — enqueue and run one retry end to end (tracer bullet)

- Outcome: calling `RetryQueue.enqueue` persists a row; the worker picks it
  up and runs the handler once.
- Files: `src/retry/queue.ts` (NEW), `src/retry/worker.ts` (NEW).
- Key signatures: `RetryQueue.enqueue(payload, idempotencyKey)`.
- Verification: `npm test -- retry/queue.test.ts`.
- Dependencies: none.

## Deferred

Backoff/jitter tuning (follow-up, not required for the walking skeleton).

## Open questions
