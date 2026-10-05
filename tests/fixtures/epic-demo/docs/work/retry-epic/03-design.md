---
feature: retry-epic
phase: design
status: approved
version: 2
created: 2026-09-03
updated: 2026-09-10
approved_at: 2026-09-10
based_on:
  - 02-research.md@1
forced: []
---

## Desired state

A shared `retry_queue` table and worker process that persists every retry
attempt, survives a restart, and guarantees at-least-once (not
duplicate-triggering) redelivery via a per-attempt idempotency key.

## Non-goals

Exactly-once delivery. Cross-region replication.

## System design

- `retry_queue` table: `id`, `payload`, `attempt`, `idempotency_key`,
  `run_after`, `locked_by`, `locked_at`.
- Contract: any consumer enqueues via `RetryQueue.enqueue(payload, key)`;
  the worker calls the consumer's registered handler at `run_after` and
  marks the row done only after the handler returns successfully.

## One-way decisions

- **E-D1** — Retry storage: a new `retry_queue` table (chosen) vs. reusing
  the existing job-scheduler table (rejected: that table's rows are deleted
  on completion, which would lose attempt history needed for idempotency
  keys). ADR: `docs/adr/0001-retry-queue-table.md`.
- **E-D2** — Idempotency key shape: `sha256(consumer_id + payload_hash)`
  (chosen) vs. a human-supplied key per call site (rejected: inconsistent
  adoption risk, some call sites would skip it). ADR:
  `docs/adr/0002-idempotency-key-shape.md`.

## Two-way decisions

| Decision | Choice |
|---|---|
| Worker poll interval | 500ms |

## Risks

Lock contention under high retry volume if poll interval is too aggressive.

## Appetite check

Fits the 3-week appetite: the queue table/worker is ~1 week, each of
payments/webhooks adoption is ~1 week.

## Open questions
