# Grove approval procedure

Single source of truth for approving a grove artifact. It is copied verbatim
into `references/approve.md` of `grove-approve` and of every gated skill that
ends with the inline approval step, by `scripts/sync-shared.sh` (see
`shared/MANIFEST`). Do not edit the copies — edit this file and re-run the
script.

## When this runs

Only in two places:

1. **Inline**, as the last step of a gated skill (`grove-start`,
   `grove-questions`, `grove-research`, `grove-design`, `grove-structure`),
   right after the artifact is written.
2. **`grove-approve`**, invoked directly by the human to approve later.

Never anywhere else, and never on the model's own initiative: not as a side
effect of another step, not because an artifact "looks ready", and not when
resuming a session. A skill may *offer* approval only at its own inline step.

## What counts as approval

Only an explicit **"yes"** or **"approve"** (e.g. "yes", "approve",
"approve both") from the human, in reply to the prompt, in this session.

Everything else means **not yet**: silence, "looks good", "ok", "sure",
"fine", "yes but change X", feedback, a question, or a new instruction. When
in doubt, it's not yet. `--force` never stands in for the yes.

## Approval units

A unit is what one "yes" approves. **Every file in a unit is validated first;
if any file fails, nothing in the unit is approved.**

| Unit | Files | Used when |
|---|---|---|
| `questions` | `01-questions.md` | `grove-questions`; `grove-start` in `small` flow |
| `research` | `02-research.md` | `grove-research` |
| `questions+research` | `01-questions.md`, `02-research.md` | end of `grove-start` (`full`/`standard`) |
| `design` | `03-design.md` | `full` flow and epics only |
| `structure` | `04-structure.md` | `full` flow; `standard` flow only when `03-design.md` is already `approved` (a structure revised after the combined approval) |
| `design+structure` | `03-design.md`, `04-structure.md` | `standard` flow — atomic |
| `implementation` | `06-implementation.md` | after the last slice, all flows; never on an epic — approving it marks the feature done |

Rules:

- **`standard` flow never approves the design alone.** A request to approve
  `design` in `standard` flow is treated as `design+structure`. If
  `04-structure.md` doesn't exist yet, say so and stop — the design session
  writes it before asking. If the human wants the design locked before the
  slices exist, that's a switch to `full` flow (see `references/contract.md`,
  "Changing the flow").
- **`questions+research`** is a convenience pairing, not an invariant: if
  `02-research.md` fails validation but `01-questions.md` passes, list the
  research failures and offer the `questions` unit alone instead.
- A feature without `flow` is treated as `full`.

## Procedure

1. **Validate** every file in the unit against the content gates in
   `references/gates.md`, re-checking yourself — never trust the authoring
   step's self-report:
   - frontmatter complete (every required key present)
   - `## Open questions` empty
   - no literal `TODO` or `TBD` anywhere in the file
   - size limits (`limits.designMaxLines` for design; structure ≤ ~2 pages)
   - structure: every slice has a verification step (epic: every child entry
     has a slug, goal, outcome, scope, and size estimate)
   - design: every one-way decision has a chosen option
   - questions in `small` flow: `## Size verdict` is S
   - implementation: every slice in `04-structure.md` (`small` flow: every
     slice in `05-plan.md`) has a `## Slice N` section in `05-plan.md`, and
     `05-plan.md` has no `- [ ]` left
   If any check fails, list exactly what fails and stop — do not ask for
   approval. `--force <reason>` may override a failing check; record the
   reason in that file's `forced` array, and still ask for the yes.
2. **Summarise**: at most 5 lines per file — what it says, what approving it
   unlocks next (e.g. "unlocks `grove-implement`"), and anything that will be
   marked `stale` as a result.
3. **Ask exactly:** *"Approve now? (yes / not yet)"*. For `questions+research`
   you may add a third answer, *"questions only"*. Then wait.
4. **On not yet** (anything other than an explicit yes/approve): write
   nothing approval-related. Every file in the unit stays `draft`. Tell the
   human the command to approve later: `grove-approve <slug> <unit>`. If they
   gave feedback, apply it in revise mode (`references/contract.md` rule 4)
   and ask again at the end.
5. **On yes**, for every file in the unit:
   - set `status: approved` and `approved_at: <today, ISO date>`
   - leave `version` unchanged (approval is not an edit)
6. **Stale marking.** Mark every existing artifact *downstream of the unit's
   last file* `status: stale` — e.g. approving `design+structure` marks an
   existing `05-plan.md` and `06-implementation.md` stale; approving `design`
   in `full` flow marks `04-structure.md` onward stale. `implementation` is
   the last artifact, so it marks nothing stale. Wholesale per feature,
   except:
   - **Epic design, re-approval after a revision:** targeted stale marking on
     children, per `references/gates.md` ("Targeted stale marking"). An
     epic design's first approval marks no child stale.
7. **Design files:** flip every ADR this design drafted from
   `Status: Proposed` to `Status: Accepted`.
8. **Epic structure (`04-structure.md` of a `kind: epic`):**
   - **First approval:** create each listed child's folder,
     `<artifactRoot>/<child-slug>/feature.md` (`<child-slug>` carries the
     child's two-digit order per the epic-child slug rule in
     `references/contract.md`; fix the slug if the structure entry lacks it),
     with frontmatter `kind: feature`, `parent: <epic-slug>`, `order`,
     `flow: standard`, `created`, and a body stating the child's goal,
     outcome, scope, and dependencies from the structure entry, ending with
     `## Flow log` and the line `- <today>: standard (default for an epic
     child)` — the child's `grove-start` confirms or changes it. The child
     starts in the backlog (no `01-questions.md`). Write the slugs, in order,
     into the epic's `feature.md` `children:` list.
   - **Re-approval after a revision:** create folders only for children newly
     added to the list. A child removed from the list is **flagged, never
     deleted**: leave its folder and artifacts in place, write a `FLAGGED.md`
     in it saying why, and tell the human so they decide what to do by hand.
9. **Tracker:** if `tracker.type: "linear"` and `tracker.postComments: true`,
   offer to post a comment with the artifact path(s) and unit — ask first
   unless the human has clearly said they want it.
10. **Report** what was approved, what went stale, which ADRs flipped, any
    child folders created or flagged, and the next command.

## Revising after approval

Editing an approved artifact resets it to `draft` and marks everything
downstream `stale` (`references/contract.md` rule 2). Re-approval goes
through this same procedure. In `standard` flow: a revised design is
re-approved as `design+structure` (the design session revises the structure
to match first); a structure revised on its own, with the design still
approved, is re-approved as `structure`.
