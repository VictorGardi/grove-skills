---
name: grove-structure
description: Break an approved design into ordered, verifiable vertical slices (phase 4 of the grove workflow). Load when the human wants to run the structure phase on a feature whose design is approved.
license: MIT
---

# grove-structure

## Purpose

Phase 4 of grove. Decide **how we get there**. For a normal feature or a
child: an ordered list of vertical slices, each independently verifiable,
starting with a tracer bullet. For an epic: an ordered list of child
features instead — this is the phase where an epic's child folders get
their shape (`grove-approve` creates the folders once this is approved).

## When to use / not use

- Use only after `03-design.md` has `status: approved` (hard gate).
- Use again in revise mode if `04-structure.md` exists and the human has
  feedback — feedback changes the outline, never starts implementation.
- Do not use to write code or detailed steps — that's `grove-plan`/`grove-implement`.

## Inputs

`03-design.md` (approved), `feature.md` (for `kind`/`appetite`),
`grove.config.json` (`limits.maxSlices`, `limits.epicMaxChildren`,
`commands.*`).

Child mode (`feature.md` has `parent` set): also the epic's
`04-structure.md` entry for this child, to keep slices within its scope.

## Preconditions & gates

**Hard gate:** `03-design.md` must be `status: approved`. If not, stop and
tell the human to run `grove-approve <slug> design` first, unless they pass
`--force <reason>` — record the reason in `forced` and proceed.

If `03-design.md`'s version is newer than the `based_on` recorded in any
existing `04-structure.md`, warn about staleness and offer to revise.

## Process

0. **Epic mode** (`feature.md` has `kind: epic`): skip steps 1–3 below and
   instead produce a list of ≤ `limits.epicMaxChildren` **child features**.
   For each child, specify:
   - a slug suggestion
   - a one-line goal
   - an observable outcome
   - its scope: the `E-D` ids it depends on and the `03-design.md` sections
     it implements
   - dependencies on other children
   - a rough size, which must fit the normal feature limits
     (`limits.maxOneWayDecisions`, `limits.maxSlices`) — if a child looks like
     it won't fit, split it into two children instead of writing an oversized
     one.
   Child 1 is always the **walking skeleton**: the thinnest end-to-end
   version of the whole epic. Add `## Appetite check` (does this child list
   still fit `feature.md`'s `appetite`? propose cuts if not) and `##
   Deferred`. Then skip to step 4 (review) and step 6 (render as a child
   dependency graph, not a slice timeline) — steps 1–3, 5 don't apply.
1. Break the design into ≤ `limits.maxSlices` **vertical** slices — never
   horizontal layers (e.g. never "slice 1: all the models, slice 2: all the
   endpoints"). Slice 1 is a tracer bullet: the thinnest end-to-end path that
   runs. Child mode: every slice must stay inside the scope (`E-D` ids /
   design sections) this child was given in the epic's `04-structure.md` —
   flag anything that doesn't fit, rather than silently expanding scope.
2. For each slice, specify:
   - an observable outcome
   - files to add or change
   - key signatures
   - an exact verification step: a command from `commands.*`, a named test, a
     curl call, or a manual UI step — never vague ("test it")
   - dependencies on earlier slices
3. Add `## Deferred` (deliberately not building this round) and
   `## Rollout / migration` if relevant.
4. Review the slice (or child) list with the human. Their feedback changes
   the outline — it never triggers implementation, or child-folder creation,
   from this skill.
5. Write `04-structure.md` (≤ ~2 pages).
6. Invoke `grove-render` for `04-structure.html`: a slice timeline for a
   normal feature or child, or a child dependency graph for an epic.

## Output

`04-structure.md` + `04-structure.html`.

## Stop conditions

- **Content gate:** every slice must have a verification step before this
  artifact can be marked approvable — if any slice lacks one, fix it before
  ending the session, don't hand it off incomplete.
- If more than `limits.maxSlices` slices (or, epic mode, `limits.epicMaxChildren`
  children) are needed, stop and propose a split of the feature (or
  reorganizing into fewer, larger children) rather than writing an oversized
  structure.

## Rules

- Slices are vertical (user/system-observable outcomes), not layers.
- Never begin writing implementation code from this skill, even if the human
  seems eager to — that belongs to `grove-plan` then `grove-implement`. Epic
  mode: never create child folders from this skill either — that's
  `grove-approve`'s job, only once the human approves this structure.
- Child mode: anything outside the scope the epic's structure gave this
  child gets flagged for the human, not silently absorbed.
- End the session telling the human: the artifact path (and `.html`), to
  review carefully (short, but every slice/child matters), the exact next
  command (`grove-approve <slug> structure`), and to start a fresh session.
  Epic mode: also tell them that approving this structure creates the child
  folders, and that `grove-plan`/`grove-implement` refuse on the epic itself —
  the next work happens inside child 1.
