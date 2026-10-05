---
feature: 2026-10-01-standard-feature
phase: structure
status: approved
version: 1
created: 2026-10-02
updated: 2026-10-02
approved_at: 2026-10-02
based_on:
  - 03-design.md@1
forced: []
---

## Slices

### Slice 1 — outcome 1

- Outcome: observable outcome 1.
- Files: `src/f1.ts`.
- Verification: `npm test -- f1.test.ts`.
- Dependencies: none.

### Slice 2 — outcome 2

- Outcome: observable outcome 2.
- Files: `src/f2.ts`.
- Verification: `npm test -- f2.test.ts`.
- Dependencies: slice 1.

## Deferred

Nothing.

## Open questions
