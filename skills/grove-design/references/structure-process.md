# Grove structure process

Single source of truth for producing `04-structure.md`. Copied into
`references/structure-process.md` of `grove-structure` (`full` flow, or
revising) and `grove-design` (`standard` flow, which continues straight into
it) by `scripts/sync-shared.sh` (see `shared/MANIFEST`). Do not edit the
copies.

## Inputs

`03-design.md`, `feature.md` (`kind`, `appetite`, `flow`),
`grove.config.json` (`limits.maxSlices`, `limits.epicMaxChildren`,
`commands.*`). Child mode (`parent` set): also the epic's `04-structure.md`
entry for this child, to keep slices inside its scope.

## Steps

0. **Epic mode** (`kind: epic`): skip steps 1–3 and instead list ≤
   `limits.epicMaxChildren` **child features**. For each child:
   - a slug suggestion, numbered in list order per the epic-child slug rule
     in `references/contract.md` (`<prefix>-<NN>-<kebab-name>`)
   - a one-line goal
   - an observable outcome
   - its scope: the `E-D` ids it depends on and the `03-design.md` sections
     it implements
   - dependencies on other children
   - a rough size, which must fit the normal feature limits
     (`limits.maxOneWayDecisions`, `limits.maxSlices`) — if a child won't
     fit, split it into two children rather than writing an oversized one
   Child 1 is always the **walking skeleton**: the thinnest end-to-end
   version of the whole epic. Add `## Appetite check` (does the child list
   fit `feature.md`'s `appetite`? propose cuts if not) and `## Deferred`.
   Then go to step 4 and step 6 (render as a child dependency graph).
1. **Slices.** Break the design into ≤ `limits.maxSlices` **vertical**
   slices — never horizontal layers (never "slice 1: all the models, slice 2:
   all the endpoints"). Slice 1 is a tracer bullet: the thinnest end-to-end
   path that runs. Child mode: every slice stays inside the scope (`E-D`
   ids, design sections) the epic's structure gave this child — flag
   anything outside it for the human rather than absorbing it.
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
   never triggers implementation, or child-folder creation.
5. **Write `04-structure.md`** (≤ ~2 pages): `phase: structure`,
   `based_on: ["03-design.md@<version>"]`, `## Slices` (epic: `## Children`),
   then `## Appetite check` (epic, or child with an appetite), `## Deferred`,
   `## Rollout / migration` (if any), `## Open questions`. Revise mode: bump
   `version`.
6. **Render**: invoke `grove-render` for `04-structure.html` — a slice
   timeline for a feature or child, a child dependency graph for an epic.

## Stop conditions

- **Content gate:** every slice has a verification step before the artifact
  is offered for approval — fix any gap in this session, never hand it off.
- **Too big:** if more than `limits.maxSlices` slices (epic:
  `limits.epicMaxChildren` children) are needed, stop and propose instead:
  - normal feature: a split into smaller features
  - epic: fewer, larger children (or a split epic)
  - epic child: **propose** switching this child to `full` flow, or
    escalating a split to the epic's structure. Never switch or split on
    your own — the human chooses, and the choice and reason go in
    `feature.md`'s `## Flow log`.

## Rules

- Slices are vertical (observable outcomes), not layers.
- Never write implementation code here. Epic mode: never create child
  folders here — that happens only on approval (`references/approve.md`).
- Child mode: anything outside the scope the epic gave this child is
  flagged for the human, never silently absorbed.
