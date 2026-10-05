# 0001. Retry queue storage

Date: 2026-09-03

## Status

Accepted

## Context

Retries need to survive a worker restart; the existing job-scheduler table
deletes rows on completion, losing the attempt history idempotency keys need.

## Decision

Add a new `retry_queue` table dedicated to retry attempts (decision `E-D1`
in `retry-epic`'s design).

## Consequences

A second queue-like table to operate, but attempt history is preserved.
Rejected: reusing the job-scheduler table (loses history on completion).
