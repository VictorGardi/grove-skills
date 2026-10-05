# Workspace app changes for epics and flows

This repo's skills support `kind: epic` features (see README's "Big
features: epics") and three per-feature **flows** (see README's "The three
flows"). This file is a note for the separate workspace app that
reads `docs/work/` — nothing in *this* repo calls or depends on that app;
these are suggested changes for it, to keep it accurate once epics show up
on disk.

## New facts on disk

- `<artifactRoot>/<slug>/feature.md` — a new file per feature, not a phase
  artifact (no `status`/`version`/`approved_at`). Relevant fields:
  - `kind: feature | epic`
  - `parent: <epic-slug>` (feature only, when it's a child)
  - `children: [<slug>, ...]` (epic only, ordered)
  - `appetite: "<free text>"` (epic: always set; feature: optional)
  - `order: <int>` (child only)
  - `flow: full | standard | small` — which stages the feature has (see
    "Flows decide the stages" below). Missing = `full`.
  - `created: <date>`
  - Body: a `## Flow log` section, one dated line per flow choice or change
    (e.g. `- 2026-10-09: standard → full — needs 10 slices`).
  - A missing `feature.md` means `kind: feature`, no `parent` (pre-epic
    features created before this field existed).

## Epic features show a child progress row

For a `kind: epic` feature, add a progress row/badge derived by reading its
children — never read from the epic's own files, since the epic never
duplicates child status:

1. Read `children:` from the epic's `feature.md`.
2. For each child slug, read that child's own `feature.md` and whichever
   phase artifacts exist, in the same order the `grove-epic-status` skill
   uses: backlog → questions → research → design → structure →
   implementation → done (done = `06-implementation.md` has a PR
   description). A `05-plan.md` now means `implementation` — the plan is
   written one slice at a time inside it, not as its own stage.
3. Render something like `3/5 children → implementation` or a per-child
   stage chip row (each chip showing the child's flow too), plus an "N stale" badge if any child artifact has
   `status: stale`.
4. Appetite: show elapsed time since `feature.md`'s `created` vs. `appetite`
   as plain text (e.g. "9 days of a 3-week appetite") — no percent-complete
   or ETA estimate; the skills never compute one, so don't invent one in
   the app either.

This is exactly what `/grove-epic-status <slug>` already computes for a
terminal session — if the app can shell out to it, reuse its logic rather
than reimplementing the stage-inference rules twice.

## Children show their parent

For a `kind: feature` feature with `parent` set, show a breadcrumb/link back
to the epic (e.g. "Part of epic: retry-epic") using the parent slug to
resolve the epic's folder the same flat way any other slug resolves today —
child folders are siblings of the epic's, never nested, so no new path
logic is needed beyond reading `parent` and `order`.

## Flows decide the stages

Read `flow` from each feature's `feature.md` (missing = `full`) and show
only that flow's stages. Plan is no longer a separate stage anywhere:
`grove-plan` was removed, and `grove-implement` writes `05-plan.md` one
slice at a time. Re-read `flow` on every refresh — it can change mid-feature
(the `## Flow log` says when and why), and a change never alters any
artifact's status, only which stages remain.

Suggested `workflow.yaml` (or equivalent), keyed by flow, with
`grove-start` as every feature's first action:

```yaml
flows:
  full:
    stages:
      - id: start          # questions + research, one session
        artifacts: [01-questions.md, 02-research.md]
        action: grove-start
      - id: design
        artifacts: [03-design.md]
        action: grove-design
      - id: structure
        artifacts: [04-structure.md]
        action: grove-structure
      - id: implement      # 05-plan.md is written per slice inside this stage
        artifacts: [05-plan.md, 06-implementation.md]
        action: grove-implement
  standard:
    stages:
      - id: start
        artifacts: [01-questions.md, 02-research.md]
        action: grove-start
      - id: design-structure   # one session, one approval for both files
        artifacts: [03-design.md, 04-structure.md]
        action: grove-design
      - id: implement
        artifacts: [05-plan.md, 06-implementation.md]
        action: grove-implement
  small:
    stages:
      - id: questions
        artifacts: [01-questions.md]
        action: grove-start
      - id: implement
        artifacts: [05-plan.md, 06-implementation.md]
        action: grove-implement

# An epic is always flow: full but stops after structure — grove-implement
# refuses on kind: epic; implementation happens in each child's own flow.
epic:
  stages: [start, design, structure]
```

Stage state, for display:

- A stage is **approved** when every artifact it lists that's gated is
  `status: approved` (`05-plan.md` is self-approved and never a human gate;
  `implement` is done when `06-implementation.md` has a `## PR description`).
- `standard`'s `design-structure` stage is approved only when **both** files
  are — they're approved together, atomically, so a half-approved state
  shouldn't appear (if it does, after a structure-only revision, show the
  structure as the pending part).
- The `start` stage can be `draft` while the next stage runs: research is a
  soft gate. Show it as "not approved" rather than blocking.

Next-action button per feature: the first stage whose artifacts are missing
or not approved, run as `<action> <slug>` from the repo root — except that a
`draft` `start` stage doesn't block offering `grove-design`.
