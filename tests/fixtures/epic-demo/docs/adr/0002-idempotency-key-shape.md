# 0002. Idempotency key shape

Date: 2026-09-10

## Status

Accepted

## Context

Redelivery must never re-trigger a consumer's side effect. The key needs to
be derivable without relying on every call site supplying one correctly.

## Decision

Derive the key as `sha256(consumer_id + payload_hash)` (decision `E-D2` in
`retry-epic`'s design, revised to v2 from an earlier human-supplied-key
draft).

## Consequences

Consistent adoption without relying on call sites; `retry-epic-child-2`
must be revised to match this shape (it was written against the earlier
draft and is currently marked `stale`).
