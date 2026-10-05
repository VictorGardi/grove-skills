# Grove gate rules

Single source of truth, copied into every skill's `references/gates.md` by
`scripts/sync-shared.sh`.

## Hard gates (block unless `--force`)

- `grove-structure` requires `03-design.md` to have `status: approved`.
- `grove-plan` requires `04-structure.md` to have `status: approved`.
- `grove-implement` requires `04-structure.md` approved **and** `05-plan.md`
  to exist with `status: approved`.

A hard gate that is bypassed with `--force <reason>` must record the reason
in the new artifact's `forced` frontmatter array, e.g. `forced: ["skipped design review, trivial rename"]`.
Never bypass silently.

## Epic gate (always refuses, no `--force`)

- `grove-plan` and `grove-implement` refuse outright on `kind: epic`
  (there is nothing to force — an epic has no slices to plan or implement).
  Report which child is next: the lowest-`order` child that is not yet
  `implementation`, or "all children started" if none.

## Rolling-wave warning (soft, by default)

- `grove-questions` starting on a child (`parent` set) warns, but allows
  continuing, if an earlier child in the epic's `order` has not yet reached
  `phase: implementation`. This is always a soft warning — there is no
  `--force` needed and no config flag to make it hard.

## Soft gates (warn, allow continue)

- `grove-research` running without an approved `01-questions.md` — warn, proceed.
- `grove-design` running without an approved `02-research.md` — warn, proceed.

## Content gates (always enforced, independent of approval status)

A phase refuses to **write an artifact as approvable, or let `grove-approve`
approve it**, if:

- it has any non-empty content under `## Open questions`
- it contains the literal strings `TODO` or `TBD`
- (structure only) any slice is missing a verification step
- (design only) frontmatter, `## Desired state`, or any one-way decision is
  missing its chosen option

`grove-approve` is the only skill that may set `status: approved`. It must
re-run these checks itself immediately before writing — never trust an
earlier skill's self-report.

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

Approval is always an explicit human action via `grove-approve`, invoked
directly by the human (slash command or explicit request). No other skill
may set `status: approved`, and `grove-approve` must never be invoked by a
model on its own initiative.
