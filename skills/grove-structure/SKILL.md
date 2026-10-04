---
name: grove-structure
description: Break an approved design into ordered, verifiable vertical slices (phase 4 of the grove workflow). Load when the human wants to run the structure phase on a feature whose design is approved.
license: MIT
---

# grove-structure

## Purpose

Phase 4 of grove. Decide **how we get there**: an ordered list of vertical
slices, each independently verifiable, starting with a tracer bullet.

## When to use / not use

- Use only after `03-design.md` has `status: approved` (hard gate).
- Use again in revise mode if `04-structure.md` exists and the human has
  feedback — feedback changes the outline, never starts implementation.
- Do not use to write code or detailed steps — that's `grove-plan`/`grove-implement`.

## Inputs

`03-design.md` (approved), `grove.config.json` (`limits.maxSlices`,
`commands.*`).

## Preconditions & gates

**Hard gate:** `03-design.md` must be `status: approved`. If not, stop and
tell the human to run `grove-approve <slug> design` first, unless they pass
`--force <reason>` — record the reason in `forced` and proceed.

If `03-design.md`'s version is newer than the `based_on` recorded in any
existing `04-structure.md`, warn about staleness and offer to revise.

## Process

1. Break the design into ≤ `limits.maxSlices` **vertical** slices — never
   horizontal layers (e.g. never "slice 1: all the models, slice 2: all the
   endpoints"). Slice 1 is a tracer bullet: the thinnest end-to-end path that
   runs.
2. For each slice, specify:
   - an observable outcome
   - files to add or change
   - key signatures
   - an exact verification step: a command from `commands.*`, a named test, a
     curl call, or a manual UI step — never vague ("test it")
   - dependencies on earlier slices
3. Add `## Deferred` (deliberately not building this round) and
   `## Rollout / migration` if relevant.
4. Review the slice list with the human. Their feedback changes the outline —
   it never triggers implementation from this skill.
5. Write `04-structure.md` (≤ ~2 pages).
6. Invoke `grove-render` for `04-structure.html` as a slice timeline.

## Output

`04-structure.md` + `04-structure.html`.

## Stop conditions

- **Content gate:** every slice must have a verification step before this
  artifact can be marked approvable — if any slice lacks one, fix it before
  ending the session, don't hand it off incomplete.
- If more than `limits.maxSlices` slices are needed, stop and propose a split
  of the feature rather than writing an oversized structure.

## Rules

- Slices are vertical (user/system-observable outcomes), not layers.
- Never begin writing implementation code from this skill, even if the human
  seems eager to — that belongs to `grove-plan` then `grove-implement`.
- End the session telling the human: the artifact path (and `.html`), to
  review carefully (short, but every slice matters), the exact next command
  (`grove-approve <slug> structure`), and to start a fresh session.
