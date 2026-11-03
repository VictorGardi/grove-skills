# Workspace app changes for flows

This repo's skills support per-feature **flows** (see README's "The three flows").
This file is a note for the separate workspace app that
reads `docs/work/` — nothing in *this* repo calls or depends on that app;
these are suggested changes for it, to keep it accurate.

## New facts on disk

- `<artifactRoot>/<slug>/feature.md` — a new file per feature, not a phase
  artifact (no `status`/`version`/`approved_at`). Relevant fields:
  - `appetite: "<free text>"` (optional)
  - `flow: full | standard | small` — which stages the feature has (see
    "Flows decide the stages" below). Missing = `full`.
  - `created: <date>`
  - Body: a `## Flow log` section, one dated line per flow choice or change
    (e.g. `- 2026-10-09: standard → full — needs 10 slices`).
  - A missing `feature.md` means `flow: full` (features created before
    this file existed).

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
