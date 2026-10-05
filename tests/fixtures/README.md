# Fixtures

Hand-written artifact trees exercising epic support, checked structurally by
`scripts/validate-fixtures.sh`. These are illustrative snapshots, not a full
grove session — not every file a real session would write is present (e.g.
`00-ticket.md`, `.html` companions are omitted where they don't affect what's
being demonstrated).

## `epic-demo/`

One epic, `retry-epic` (appetite "3 weeks"), with three children:

- `retry-epic-child-1` — `order: 1`, the walking skeleton, fully
  implemented (`06-implementation.md` present, all artifacts `approved`).
- `retry-epic-child-2` — `order: 2`, in design. Its `03-design.md` is
  deliberately `status: stale`: the epic's `03-design.md` was revised after
  this child read it (see `retry-epic/03-design.md`'s `## Open questions` /
  decision `E-D2`, now at a newer version than this child's
  `parent:03-design.md@` entry), demonstrating **targeted** stale marking —
  `retry-epic-child-3` is untouched by the same revision because its scope
  doesn't reference `E-D2`.
- `retry-epic-child-3` — `order: 3`, still in the backlog (`feature.md`
  only).

## `epic-approve/`

Demonstrates child-folder creation on `grove-approve <epic> structure`,
across two structure versions, for `launch-epic`:

- v1 approval listed `[launch-epic-child-a, launch-epic-child-b, launch-epic-child-c]`
  → all three folders were created.
- v2 (this fixture's current state) revised the child list to
  `[launch-epic-child-a, launch-epic-child-c, launch-epic-child-d]`: `-b` was
  dropped, `-d` was added. Re-approval creates only `launch-epic-child-d`'s
  folder; `launch-epic-child-b`'s folder is **kept, not deleted**, and
  carries a `FLAGGED.md` marker explaining it's no longer in the epic's
  `children:` list.
