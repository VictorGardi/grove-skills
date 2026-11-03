# Fixtures

Hand-written artifact trees exercising flows, checked
structurally by `scripts/validate-fixtures.sh`. These are illustrative snapshots, not a full
grove session — not every file a real session would write is present (e.g.
`00-ticket.md`, `.html` companions are omitted where they don't affect what's
being demonstrated).

## `flows/`

One feature per flow, a legacy feature, and the cases where a gate must stay
closed. `validate-fixtures.sh` asserts, for every fixture feature, that
implementation only started with its flow's gate open, that `standard` flow
never approves the design alone, and that a set `flow` has a `## Flow log`;
plus these specific outcomes:

| Feature | Flow | Shows | Implement gate | Resumes at |
|---|---|---|---|---|
| `2026-10-01-full-feature` | `full` | design and structure approved on different days; `05-plan.md` has slices 1–2 only (planned just in time) | open | slice 2, partly ticked → resume |
| `2026-10-01-standard-feature` | `standard` | questions/research left `draft` at start ("not yet", soft gate); design+structure approved together (same `approved_at`) | open | slice 1, no section → plan it |
| `2026-10-01-small-feature` | `small` | approved questions with size S, no research/design/structure, one minimal slice | open | done |
| `2026-09-20-legacy-feature` | none (= `full`) | a full `05-plan.md` written up front by the old plan phase | open | slice 2, written ahead → drift check |
| `2026-10-02-not-yet` | `standard` | the combined prompt was answered "not yet": both files `draft`, no `approved_at` | closed | — |
| `2026-10-03-small-size-m` | `small` | flow switched to `small` (logged) but size verdict is M | closed | — |
| `2026-10-03-full-structure-draft` | `full` | design approved, structure still `draft` | closed | — |
| `2026-10-04-auto-feature` | `auto` | approved plan bundle (outcome + research + plan, same `approved_at`); one agents-disagree decision with a recorded human pick; `04-run.md` is a finished-run snapshot (`draft`, both slices done; in real use it lives in the run worktree on the run branch); no design/structure/plan files | n/a (`grove-run` gate open) | — |

`validate-fixtures.sh` also mutates a temporary copy of the `auto` fixture
(drops a `Pick:`, the `Thin end-to-end:` line or a `Human pick:`, fills
`## Open questions`, makes `based_on` stale) and checks that the plan gates
refuse each time. It does the same for the run gates on `04-run.md` (a halted
slice, a missing `## Slice N`, no `## Final summary`, filled
`## Open questions`, stale `based_on`).
