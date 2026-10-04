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
proceeding on stale input.

## Approval

Approval is always an explicit human action via `grove-approve`, invoked
directly by the human (slash command or explicit request). No other skill
may set `status: approved`, and `grove-approve` must never be invoked by a
model on its own initiative.
