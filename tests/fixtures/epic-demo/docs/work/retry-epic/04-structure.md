---
feature: retry-epic
phase: structure
status: approved
version: 1
created: 2026-09-04
updated: 2026-09-04
approved_at: 2026-09-04
based_on:
  - 03-design.md@1
forced: []
---

## Children

### retry-epic-child-1 — walking skeleton: queue table + worker loop

- Outcome: a retry can be enqueued, persisted, and executed once by the
  worker, surviving a worker restart.
- Scope: `E-D1`. Implements the `retry_queue` table and worker poll loop
  from `## System design`.
- Dependencies: none.
- Repos: n/a (single repo).
- Size: fits `maxSlices`/`maxOneWayDecisions`.

### retry-epic-child-2 — idempotency keys

- Outcome: redelivery of the same retry never re-triggers the consumer's
  side effect.
- Scope: `E-D2`. Implements the idempotency-key contract from
  `## System design`.
- Dependencies: `retry-epic-child-1` (needs the queue table to store the key on).
- Size: fits `maxSlices`/`maxOneWayDecisions`.

### retry-epic-child-3 — payments adoption

- Outcome: the payments retry path is migrated onto the shared queue.
- Scope: consumer-side adoption only; no `E-D` decisions of its own.
- Dependencies: `retry-epic-child-1`, `retry-epic-child-2`.
- Size: fits `maxSlices`/`maxOneWayDecisions`.

## Appetite check

Three children, each ~1 week, fits the 3-week appetite.

## Deferred

Webhooks adoption (a follow-on epic once payments proves the pattern).

## Open questions
