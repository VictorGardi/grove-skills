# Grove gate rules

Single source of truth, copied into every skill's `references/gates.md` by
`scripts/sync-shared.sh`.

Read `flow` from `feature.md` first: gates depend on it. A missing `flow`
(or missing `feature.md`) means `full`.

## Hard gates (block unless `--force`)

- `grove-structure` requires `03-design.md` to have `status: approved`
  (`full` flow). In `standard` flow `grove-structure` is only for revising an
  existing `04-structure.md`; the first structure is written by
  `grove-design` in the same session, before any approval.
- `grove-implement` requires, by flow:

  | Flow | Required before implement |
  |---|---|
  | `full` | `04-structure.md` approved (which itself required `03-design.md` approved) |
  | `standard` | `03-design.md` **and** `04-structure.md` approved |
  | `small` | `01-questions.md` approved, with `## Size verdict` S |

  `05-plan.md` is **not** a gate: `grove-implement` writes it, one slice at
  a time. A legacy `05-plan.md` written up front is used, not required.

A hard gate that is bypassed with `--force <reason>` must record the reason
in the new artifact's `forced` frontmatter array (for `grove-implement`:
`05-plan.md`'s), e.g. `forced: ["skipped design review, trivial rename"]`.
Never bypass silently.

## Epic gate (always refuses, no `--force`)

- `grove-implement` refuses outright on `kind: epic` (there is nothing to
  force — an epic has no slices to implement). Report which child is next:
  the lowest-`order` child that is not yet `implementation`, or "all
  children started" if none.

## Rolling-wave warning (soft, by default)

- Starting a child (`parent` set) with `grove-start` or `grove-questions`
  warns, but allows continuing, if an earlier child in the epic's `order`
  has not yet reached `phase: implementation`. This is always a soft
  warning — there is no `--force` needed and no config flag to make it hard.

## Soft gates (warn, allow continue)

- `grove-research` running without an approved `01-questions.md` — warn, proceed.
- `grove-design` running without an approved `02-research.md` — warn, proceed.

`small` flow has no research or design, so neither soft gate applies to it.

## Content gates (always enforced, independent of approval status)

A phase refuses to **offer an artifact for approval, or approve it**, if:

- it has any non-empty content under `## Open questions`
- it contains the literal strings `TODO` or `TBD`
- (structure only) any slice is missing a verification step
- (design only) frontmatter, `## Desired state`, or any one-way decision is
  missing its chosen option
- (questions, `small` flow only) the size verdict is not S

The approval procedure (`references/approve.md`) re-runs these checks itself
immediately before writing — never trust an earlier step's self-report.

## Staleness

If an input artifact's current `version` is higher than the version recorded
in `based_on` by the artifact being read, the consuming skill must stop and
tell the human, offering to re-read and revise rather than silently
proceeding on stale input. This applies identically to a `parent:*` entry in
a child's `based_on` (see `shared/contract.md`).

### Targeted stale marking (epic → children)

Approving a **changed** epic design (i.e. re-approving after a revision, not
the first approval) does not mark every child stale wholesale. Instead:

- A child goes `stale` only if its own `03-design.md` or `04-structure.md`
  lists, in its scope, an `E-D` id whose decision changed in this revision.
- If the revision changed the epic's `## Problem`, `## Non-goals`, or
  `## Appetite` (in `feature.md` or `03-design.md`'s appetite check) rather
  than a specific `E-D` decision, every child is marked stale — those
  changes affect the epic's shape as a whole, not one decision.
- A child not yet past `grove-questions` (no `03-design.md` of its own yet)
  cannot be marked stale; it simply inherits the new epic state next time it
  reads it.

This is the only place staleness is targeted rather than wholesale — every
other propagation rule in this file and in `shared/contract.md` stays
all-or-nothing per phase.

## Approval

`status: approved` is set only by the approval procedure in
`shared/approve.md` (each skill's `references/approve.md`), and only on an
explicit "yes" or "approve" from the human in reply to its prompt. It runs
in exactly two places: inline at the end of a gated skill (`grove-start`,
`grove-questions`, `grove-research`, `grove-design`, `grove-structure`), and
in `grove-approve` when the human invokes it directly. No skill may run it
on its own initiative, and anything other than an explicit yes leaves the
artifact `draft`.

The one exception is `05-plan.md`, which `grove-implement` self-approves
after its mechanical checks (see `shared/contract.md`) — it is never a human
gate.

In `standard` flow, `03-design.md` and `04-structure.md` are approved
together, atomically: both or neither (`design+structure` unit).
