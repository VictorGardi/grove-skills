# Workspace app changes for epic support

This repo's skills now support `kind: epic` features (see README's "Big
features: epics"). This file is a note for the separate workspace app that
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
  - `created: <date>`
  - A missing `feature.md` means `kind: feature`, no `parent` (pre-epic
    features created before this field existed).

## Epic features show a child progress row

For a `kind: epic` feature, add a progress row/badge derived by reading its
children — never read from the epic's own files, since the epic never
duplicates child status:

1. Read `children:` from the epic's `feature.md`.
2. For each child slug, read that child's own `feature.md` and whichever
   phase artifacts exist, in the same order the `grove-epic-status` skill
   uses: backlog → questions → research → design → structure → plan →
   implementation → done (done = `06-implementation.md` has a PR
   description).
3. Render something like `3/5 children → implementation` or a per-child
   stage chip row, plus an "N stale" badge if any child artifact has
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

## The epic `workflow.yaml` has no plan or implement stages

If the app models each feature's workflow stages from a `workflow.yaml` (or
equivalent) per feature kind, an epic's should list only the first four
stages — suggested YAML:

```yaml
kind: epic
stages:
  - questions
  - research
  - design
  - structure
# no plan, no implement — grove-plan/grove-implement refuse on kind: epic;
# that work happens in each child's own (full) stage list instead.
```

A `kind: feature` feature (with or without `parent`) keeps the existing
full six-stage list unchanged.
