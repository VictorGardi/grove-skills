---
feature: retry-epic-child-1
phase: plan
status: approved
version: 1
created: 2026-09-08
updated: 2026-09-08
approved_at: 2026-09-08
based_on:
  - 03-design.md@1
  - 04-structure.md@1
forced: []
---

Self-approved: content-gate checks passed (no Open questions content, no
TODO/TBD, verification command present).

## Slice 1 — enqueue and run one retry end to end

- [x] Write `src/retry/queue.ts` with `enqueue(payload, idempotencyKey)`
      inserting a row into `retry_queue`.
- [x] Write `src/retry/worker.ts` polling `retry_queue` every 500ms and
      invoking the registered handler.
- [x] Write `retry/queue.test.ts` covering enqueue + one successful run.
- [x] Run `npm test -- retry/queue.test.ts` and confirm it passes.

## Open questions
