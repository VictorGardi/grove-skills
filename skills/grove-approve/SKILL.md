---
name: grove-approve
description: The explicit human approval gate for a grove artifact (questions/research/design/structure/plan). Only load this when the human explicitly types the approve command or explicitly asks to approve a specific artifact — never load it on your own initiative, and never treat any other signal as a request to approve.
disable-model-invocation: true
license: MIT
---

# grove-approve

## Purpose

The single place that sets `status: approved` on a grove artifact. This is
the human-gate of the whole workflow: every hard gate downstream
(`grove-structure`, `grove-plan`, `grove-implement`) checks for approval
written by this skill and only this skill.

## When to use / not use

- Use **only** when the human explicitly runs `grove-approve <slug> <phase>`
  or unambiguously says "approve the design for X" in their own words.
- **Never** load or run this skill on your own initiative, as a side effect of
  finishing another skill, or because an artifact "looks ready." Other
  skills end by *telling* the human to run this — they never run it for them.
  `disable-model-invocation: true` enforces this in Claude Code; OpenCode has
  no equivalent field, so this rule is the enforcement there — treat it as a
  hard constraint regardless of host.
- Do not use to approve anything other than a grove artifact (ticket
  snapshots are never approved; they have no frontmatter).

## Inputs

- The feature slug and phase name (`questions|research|design|structure|plan`)
  the human wants to approve.
- The artifact file itself and, for design approval, its draft ADRs.
- `feature.md` (for `kind`/`children`/`parent`/`order`) — needed to tell an
  epic structure approval (creates child folders) from a normal one, and to
  find a child's siblings when targeting stale marking.

## Preconditions & gates

None beyond the content gates below — approval is the mechanism that
*produces* gate-satisfying state, so it can't itself be gated on approval.

## Process

1. **Validate the artifact** against `references/gates.md`'s content gates,
   re-checking yourself rather than trusting the authoring skill's self-report:
   - frontmatter is complete (all required keys present)
   - `## Open questions` is empty
   - no literal `TODO` or `TBD` anywhere in the file
   - size limits respected (`designMaxLines` for design; structure ≤ ~2 pages)
   - for structure: every slice has a verification step (epic mode: every
     child entry has a slug, goal, outcome, scope, and size estimate)
   If any check fails, stop, list exactly what's failing, and do not approve.
   `--force <reason>` overrides a failing check but still gets recorded in
   `forced` — confirm with the human before using it even if they passed
   `--force` up front, since approval is explicit-consent-always (Rules).
2. **Show a 5-line summary** of what's being approved and ask for explicit
   confirmation ("yes" or equivalent). Never proceed on an ambiguous reply.
3. On confirmation: set `status: approved` and `approved_at` (today, ISO
   date) in the artifact's frontmatter.
   - **Normal feature or child, any phase other than epic structure:** mark
     every existing downstream artifact's `status` as `stale` (e.g. approving
     design marks an existing structure/plan/implementation stale, if
     present) — wholesale, as always.
   - **Epic design, re-approval after a revision:** mark children stale
     *targeted*, not wholesale — only a child whose `03-design.md` or
     `04-structure.md` scope lists a changed `E-D` id, or every child if the
     revision changed the epic's `## Problem`/`## Non-goals`/`## Appetite`
     (per `references/gates.md`). A child's first read of a never-revised
     epic design is not a staleness event.
   - **Epic structure (`04-structure.md`), first approval:** create each
     listed child's folder: `<artifactRoot>/<child-slug>/feature.md`
     (`kind: feature`, `parent: <epic-slug>`, `order`, `created`) with a body
     stating the child's goal, outcome, scope, and dependencies from the
     structure entry. The child starts in the backlog (no `01-questions.md`
     yet). Write the resulting slugs, in order, into the epic's `feature.md`
     `children:` list.
   - **Epic structure, re-approval after a revision:** create folders only
     for children newly added to the list since the last approval. A child
     removed from the list is **flagged, never deleted** — leave its folder
     and any artifacts in place, and tell the human it's no longer in the
     epic's `children:` list so they can decide what to do with it by hand.
4. **Design-specific:** flip any ADR this design drafted from `Status:
   Proposed` to `Status: Accepted`.
5. If `tracker.type: "linear"` and `tracker.postComments: true`, optionally
   post a comment with the artifact path and phase — ask the human first if
   it's not obvious they want it.

## Output

The artifact with updated frontmatter, any flipped ADR statuses, an optional
tracker comment, and — for an epic structure approval — the new child
folders and the epic's updated `children:` list.

## Stop conditions

- Stop without writing anything if the human's confirmation is unclear.
- Stop and report exactly which content-gate check failed if validation
  doesn't pass and no `--force` was given.

## Rules

- Never self-invoke, under any framing. If you find yourself about to call
  this skill without the human having just explicitly asked for it in this
  turn, don't — go back and ask them instead.
- Approval always requires an explicit "yes" from the human in this session,
  even if they pre-authorized `--force`.
- Record every `--force` override's reason in `forced`, never silently.
