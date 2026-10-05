# Grove artifact contract

This is the single source of truth for artifact structure. It is copied
verbatim into every skill's `references/contract.md` by `scripts/sync-shared.sh`.
Do not edit the copies directly — edit this file and re-run the script.

## Feature folder

Every feature lives at `<artifactRoot>/<feature-slug>/` in the target repo
(default `artifactRoot`: `docs/work`). Epics use exactly the same layout —
an epic is a feature folder with `kind: epic`, living flat alongside its
children's folders, never nesting them.

**Feature slug:**
- `<TICKET-ID>-<kebab-name>` when a tracker ticket exists (e.g. `ENG-123-retry-queue`)
- `<YYYY-MM-DD>-<kebab-name>` otherwise (e.g. `2026-10-04-retry-queue`)

## Kind: epic vs feature

Every `feature.md` has `kind: feature` (the default — existing manifests
without `kind` count as features) or `kind: epic`.

- Only a `kind: feature` manifest may set `parent`. Epics never have a
  `parent` and never nest: an epic's children are always `kind: feature`,
  flat.
- An epic runs **Questions → Research → Design → Structure** only, at
  *system level*. `grove-plan` and `grove-implement` refuse to run on a
  `kind: epic` feature — see each skill's own doc.
- A child (`parent` set) runs the full normal phase sequence. It is a
  `kind: feature` feature in every other respect: same files, same gates,
  same approval mechanics. The only differences are that its research and
  design read the epic's artifacts first and work only on the gaps (see
  "Inheritance" below), and that its folder sits flat next to the epic's,
  not nested under it — feature resolution (find a slug → find its folder)
  is an unchanged flat scan of `<artifactRoot>/*/feature.md`.
- Status is never duplicated onto the epic. The epic's `feature.md` lists
  its children by slug only (`children:`); an epic's progress is always
  worked out by reading the children's own files (see `grove-epic-status`).

## Files per feature

| File | Written by | Human review |
|---|---|---|
| `feature.md` | grove-questions (approve updates it for epics) | — (identity, not reviewed) |
| `00-ticket.md` | grove-questions | — (source snapshot) |
| `01-questions.md` | grove-questions | 2 min |
| `02-research.md` (+ `.html`) | grove-research | skim, correct facts |
| `03-design.md` (+ `.html`) | grove-design | careful, ≤ ~200 lines |
| `04-structure.md` (+ `.html`) | grove-structure | careful, ≤ ~2 pages |
| `05-plan.md` | grove-plan | light (epics: not produced) |
| `06-implementation.md` | grove-implement | per slice (epics: not produced) |

`.html` companions are generated only by `grove-render` and are never hand-edited.
`feature.md` is not a phase artifact: it has no `phase`/`status`/`version`
lifecycle of its own and is never approved or marked stale. It holds only the
static facts that identify the feature and, for a child, locate its epic.

## `feature.md` frontmatter

Written by `grove-questions` when the feature folder is created; updated only
where noted.

```yaml
---
kind: feature             # epic | feature (default: feature)
parent: ""                # feature only, child of an epic: the epic's slug
children: []               # epic only: ordered list of child slugs, written by grove-approve
appetite: ""               # epic: required. feature: optional free-text time budget
order: 0                   # child only: position in the epic's order (1 = walking skeleton)
created: 2026-10-04
---
```

Existing features created before this field existed have no `feature.md`;
treat a missing file as `kind: feature`, no `parent`.

### Shaping section (epic `feature.md` body only)

An epic's `feature.md` body must contain these headings, in order, checked
and filled in by `grove-questions`:

`## Problem`, `## Who it's for`, `## Success looks like`, `## Non-goals`,
`## Appetite`.

## Frontmatter (every phase artifact except `00-ticket.md` and `feature.md`)

```yaml
---
feature: ENG-123-retry-queue
phase: design            # questions|research|design|structure|plan|implementation
status: draft            # draft|approved|stale
version: 3               # bump on every substantive edit
created: 2026-10-04
updated: 2026-10-04
approved_at:             # set only by grove-approve
based_on:                # upstream artifacts and the versions read
  - 01-questions.md@2
  - 02-research.md@1
  - parent:02-research.md@3   # child only: the epic's artifact and version read
  - parent:03-design.md@2
forced: []               # reasons, if a gate was overridden with --force
repo_heads:              # 02-research.md only: VCS ref(s) read, e.g. git rev-parse HEAD per repo
  - abc1234
---
```

## Decision ids

Every one-way decision an **epic** design makes gets a stable id (`E-D1`,
`E-D2`, …), assigned once in `03-design.md` and never reused or renumbered —
a later revision only ever appends the next id. A child's `04-structure.md`
scope and `03-design.md` lists which `E-D` ids it depends on, so stale
marking can target the children actually affected by a changed decision
(see "Inheritance" below). Decisions inside a normal (non-epic) design, and
a child's own decisions, are not ided — only epic-level decisions need a
stable cross-file reference.

## Inheritance (child of an epic)

- A child's `02-research.md` and `03-design.md` list the epic's artifacts
  they read in `based_on` as `parent:02-research.md@<version>` and
  `parent:03-design.md@<version>`.
- Epic-level decisions are **read-only** from inside a child: a child's
  research and design work only the gaps the epic didn't cover, and never
  re-decide or override an `E-D` id.
- If a child finds an epic decision wrong or missing, it stops — the issue
  goes into the epic's `03-design.md` `## Open questions`, the epic design
  goes back to `draft`, and staleness propagates to the affected children
  (see `shared/gates.md`). A child never silently overrides the epic.
- The same version-compare staleness rule (below) applies across the
  parent–child link: if a `parent:*` entry's version is behind the epic
  artifact's current version, the child skill must stop and warn before
  proceeding.

## Rules

1. **Precedence.** Later artifacts take precedence over earlier ones when they
   disagree. The current code is always the source of truth for *current*
   behavior — research describes what the code does today, not what any
   earlier artifact assumed.
2. **Edits invalidate downstream artifacts.** Editing an approved artifact
   resets its own `status` to `draft` and marks every downstream artifact's
   `status` as `stale`.
3. **Staleness warning.** Any skill whose input artifact has a version newer
   than what is recorded in `based_on` must warn the human and offer to
   revise before proceeding.
4. **Revise mode.** Every skill that writes an artifact supports revise mode:
   if the artifact already exists, read it plus any feedback (CLI arguments,
   or inline markers `> [!feedback] ...` or `<!-- feedback: ... -->` in the
   file) and update it in place rather than starting over. Bump `version`.
5. **Nothing lives only in chat.** Before ending any session, every decision
   made in that session must be written into the artifact.
6. **Open questions.** Every artifact ends with a `## Open questions` heading.
   It must be empty for the artifact to be approved.
7. **No placeholders in approved artifacts.** `TODO` and `TBD` block approval.

## Per-repo config

Created by `grove-setup` at `<PREFIX>.config.json` (i.e. `grove.config.json`)
in the target repo root. See `shared/config.schema.json` for the schema.
