---
feature: retry-epic-child-1
phase: design
status: approved
version: 1
created: 2026-09-06
updated: 2026-09-06
approved_at: 2026-09-06
based_on:
  - parent:03-design.md@1   # epic is now at v2 (E-D2 changed); this child's
                            # scope (E-D1 only) wasn't affected, so targeted
                            # stale marking left it approved despite the
                            # version gap — contrast with child-2 below
forced: []
---

## Inherited decisions

- E-D1 — Retry storage: new `retry_queue` table.
- E-D2 — Idempotency key shape: `sha256(consumer_id + payload_hash)` (not
  implemented by this child; read for context only, since the table schema
  must have a column for it).

## Desired state

A working `retry_queue` table and worker poll loop that enqueues, persists,
and executes a retry once, end to end.

## Non-goals

Idempotency enforcement (that's `retry-epic-child-2`).

## System design

Table and worker loop exactly as specified in the epic's `## System design`.

## Program design

- NEW `src/retry/queue.ts` — `RetryQueue.enqueue`
- NEW `src/retry/worker.ts` — poll loop
- `RetryQueue.enqueue(payload: unknown, idempotencyKey: string): Promise<void>`

## One-way decisions

None of this child's own — all inherited (see above).

## Two-way decisions

| Decision | Choice |
|---|---|
| Table name | `retry_queue` |

## Risks

None beyond what the epic design already names.

## Open questions
