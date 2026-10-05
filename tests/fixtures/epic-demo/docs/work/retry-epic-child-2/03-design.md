---
feature: retry-epic-child-2
phase: design
status: stale
version: 1
created: 2026-09-08
updated: 2026-09-08
approved_at:
based_on:
  - parent:03-design.md@1   # epic is now at v2 — E-D2 (this child's own
                            # scope) changed there, so grove-approve's
                            # targeted stale marking flipped this status to
                            # stale. Re-run grove-design to re-read the
                            # epic's current E-D2 and revise.
forced: []
---

## Inherited decisions

- E-D1 — Retry storage: new `retry_queue` table (read for context; not
  this child's own decision).
- E-D2 — Idempotency key shape: `sha256(consumer_id + payload_hash)` — **this
  entry is now behind the epic's current v2**; the epic revised E-D2 after
  this was written (see `retry-epic/03-design.md`). This design has not yet
  been revised to match.

## Desired state

Every retry carries an idempotency key; the worker refuses to re-run a
handler for a key it has already completed.

## Non-goals

Changing the queue table schema beyond adding the key column (that's
`retry-epic-child-1`'s surface).

## System design

Worker checks a `completed_keys` set before invoking the handler.

## Program design

- MODIFIED `src/retry/worker.ts` — add the completed-key check.
- `RetryQueue.isCompleted(key: string): Promise<boolean>`

## One-way decisions

None of this child's own — all inherited (see above, now stale).

## Two-way decisions

| Decision | Choice |
|---|---|
| Completed-key storage | same `retry_queue` table, boolean column |

## Risks

None recorded yet — pending revision.

## Open questions
