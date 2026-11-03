# Grove structure process

Single source of truth for producing `04-structure.md`. Copied into
`references/structure-process.md` of `grove-structure` (`full` flow, or
revising) and `grove-design` (`standard` flow, which continues straight into
it) by `scripts/sync-shared.sh` (see `shared/MANIFEST`). Do not edit the
copies.

## Inputs

`03-design.md`, `feature.md` (`appetite`, `flow`),
`grove.config.json` (`limits.maxSlices`, `commands.*`).

## Steps

1. **Slices.** Break the design into ≤ `limits.maxSlices` **vertical**
   slices — never horizontal layers (never "slice 1: all the models, slice 2:
   all the endpoints"). Slice 1 is a tracer bullet: the thinnest end-to-end
   path that runs.
2. For each slice, specify:
   - an observable outcome
   - files to add or change
   - key signatures
   - an exact verification step: a command from `commands.*`, a named test,
     a curl call, or a manual UI step — never vague ("test it")
   - dependencies on earlier slices
3. Add `## Deferred` (deliberately not built this round) and
   `## Rollout / migration` if relevant.
4. **Review the outline with the human.** Feedback changes the outline — it
   never triggers implementation.
5. **Write `04-structure.md`** (≤ ~2 pages): `phase: structure`,
   `based_on: ["03-design.md@<version>"]`, `## Slices`,
   then `## Appetite check` (if `feature.md` has an appetite), `## Deferred`,
   `## Rollout / migration` (if any), `## Open questions`. Revise mode: bump
   `version`.
6. **Render**: invoke `grove-render` for `04-structure.html` — a slice
   timeline.

## Stop conditions

- **Content gate:** every slice has a verification step before the artifact
  is offered for approval — fix any gap in this session, never hand it off.
- **Too big:** if more than `limits.maxSlices` slices are needed, stop and
  propose a split into smaller features. Never split on your own — the
  human chooses.

## Rules

- Slices are vertical (observable outcomes), not layers.
- Never write implementation code here.
