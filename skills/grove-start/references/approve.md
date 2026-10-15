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

`grove-auto` and `grove-run` never approve inline: they end by naming
`grove-approve <slug> plan` and `grove-approve <slug> run`. Approval of
`plan` and `run` happens only via `grove-approve`.

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
| `plan` | `01-outcome.md`, `02-research.md`, `03-plan.md` | `auto` flow only — atomic, all-or-none; approving it unlocks `grove-run` |
| `run` | `04-run.md` | `auto` flow only; run from the run worktree (cwd), where the file lives on the run branch `run/<slug>-<profile>`; after the final review; the artifact is read from the worktree, not the main checkout |

Rules:

- **`plan`** and **`run`** are the only units in `auto` flow. For an `auto`
  feature any other unit is refused with a one-line message. `run` is refused
  for a non-`auto` flow, and when the `plan` unit is not approved. `04-run.md`
  is approved only through `run`.
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
   - plan (all three files): complete frontmatter; `## Open questions` empty;
     no literal TODO/TBD
   - plan, `01-outcome.md`: has the four brief sections (`## Summary`,
     `## What the human sees and does`, `## Non-goals`,
     `## How I'll know it works`)
   - plan, `03-plan.md`: decisions count ≤ `limits.maxOneWayDecisions` (a
     plan stating "No one-way decisions." has zero); every decision has at
     least two options and a `Pick:`; a decision carrying `Agents disagree:`
     also has a `Human pick:` and its `Pick:` equals it; slices count ≤
     `limits.maxSlices`; every slice has a `Verification`; slice 1 has the
     `Thin end-to-end:` line; `based_on` lists the current versions of
     `01-outcome.md` and `02-research.md`
   - run (`04-run.md`, read from the current worktree): complete frontmatter;
     `## Open questions` empty; no literal TODO/TBD; every `### Slice N.`
     heading in `03-plan.md` has a `## Slice N` section with `Status: done`
     and a non-empty `Commit:` line; no slice `halted` or `in progress`; a
     `## Final summary` section containing `### PR description`; for every
     slice, a commit on the run branch with subject `<slug>: slice N —
     <outcome>` (`git log --format=%s <plan-commit>..HEAD` in the worktree;
     the `Commit:` line alone proves nothing). Staleness: the CURRENT plan
     is resolved in the MAIN checkout, not the worktree (cwd is the run
     worktree, where the plan always matches the run's base). Main checkout =
     the first entry of `git worktree list --porcelain`; current plan commit =
     `git -C <main checkout> log -1 --format=%H -- <artifactRoot>/<slug>/03-plan.md`;
     current version = the `version` field of
     `<main checkout>/<artifactRoot>/<slug>/03-plan.md`. The header
     `Plan commit:` must equal that commit and `based_on` must list
     `03-plan.md@<that version>`; a mismatch means stale, and a stale run is
     never approved (the human starts a new run with `grove-run`). The stale
     check and the `plan`-approved precondition cannot be overridden with
     `--force`
   If any check fails, list exactly what fails and stop — do not ask for
   approval. `--force <reason>` may override a failing check (never the `run`
   stale check or `plan`-approved precondition); record the
   reason in that file's `forced` array, and still ask for the yes.
2. **Summarise**: at most 5 lines per file — what it says, what approving it
   unlocks next (e.g. "unlocks `grove-implement`"; `run` unlocks nothing
   further: it hands off to commit and merge), and anything that will be
   marked `stale` as a result.
3. **Ask exactly:** *"Approve now? (yes / not yet)"*. For `questions+research`
   you may add a third answer, *"questions only"*. The prompt is a question-tool question (`references/contract.md` rule 9):
   options "Approve now" and "Not yet", the literal `Approve now? (yes / not yet)`
   stays in the question text. Then
   wait.
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
   the last artifact, so it marks nothing stale. `plan` marks nothing stale in
   this version, and `run` (the last artifact) marks nothing stale. Wholesale per feature,
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
    child folders created or flagged, and the next command. For `run`, the
    next step is: commit the approved `04-run.md` on the run branch as
    `<slug>: approve run` (approve does not commit), then merge or open a PR
    using the PR description in `## Final summary`.

## Revising after approval

Editing an approved artifact resets it to `draft` and marks everything
downstream `stale` (`references/contract.md` rule 2). Re-approval goes
through this same procedure. In `standard` flow: a revised design is
re-approved as `design+structure` (the design session revises the structure
to match first); a structure revised on its own, with the design still
approved, is re-approved as `structure`.
