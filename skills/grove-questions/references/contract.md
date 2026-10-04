# Grove artifact contract

This is the single source of truth for artifact structure. It is copied
verbatim into every skill's `references/contract.md` by `scripts/sync-shared.sh`.
Do not edit the copies directly — edit this file and re-run the script.

## Feature folder

Every feature lives at `<artifactRoot>/<feature-slug>/` in the target repo
(default `artifactRoot`: `docs/work`).

**Feature slug:**
- `<TICKET-ID>-<kebab-name>` when a tracker ticket exists (e.g. `ENG-123-retry-queue`)
- `<YYYY-MM-DD>-<kebab-name>` otherwise (e.g. `2026-10-04-retry-queue`)

## Files per feature

| File | Written by | Human review |
|---|---|---|
| `00-ticket.md` | grove-questions | — (source snapshot) |
| `01-questions.md` | grove-questions | 2 min |
| `02-research.md` (+ `.html`) | grove-research | skim, correct facts |
| `03-design.md` (+ `.html`) | grove-design | careful, ≤ ~200 lines |
| `04-structure.md` (+ `.html`) | grove-structure | careful, ≤ ~2 pages |
| `05-plan.md` | grove-plan | light |
| `06-implementation.md` | grove-implement | per slice |

`.html` companions are generated only by `grove-render` and are never hand-edited.

## Frontmatter (every artifact except `00-ticket.md`)

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
forced: []               # reasons, if a gate was overridden with --force
---
```

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
