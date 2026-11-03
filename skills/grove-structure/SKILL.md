---
name: grove-structure
description: Break an approved design into ordered, verifiable vertical slices (phase 4 of the grove workflow) — used directly in full flow, or to revise a structure; in standard flow grove-design writes the structure itself. Load when the human wants to run or revise the structure phase on a feature whose design is approved.
license: MIT
---

# grove-structure

## Purpose

Phase 4 of grove. Decide **how we get there**: an ordered list of vertical
slices, each independently verifiable, starting with a tracer bullet.

## When to use / not use

- **`full` flow:** use after `03-design.md` is approved (hard
  gate). Continuing in the same session as `grove-design` is fine.
- **`standard` flow:** `grove-design` writes the first structure itself, in
  the same session. Use this skill only to revise an existing
  `04-structure.md`.
- **`small` flow:** not used.
- Revise mode: if `04-structure.md` exists and the human has feedback —
  feedback changes the outline, never starts implementation.
- Do not use to write code or detailed steps — that's `grove-implement`.

## Inputs

As listed in `references/structure-process.md`: `03-design.md`, `feature.md`
(`appetite`, `flow`), `grove.config.json`.

## Preconditions & gates

**Hard gate (`full` flow):** `03-design.md` must be
`status: approved`. If not, stop and tell the human to approve it
(`grove-approve <slug> design`) first, unless they pass `--force <reason>` —
record the reason in `forced` and proceed.

**`standard` flow:** if `04-structure.md` doesn't exist yet, stop and point
the human at `grove-design <slug>`, which writes design and structure
together.

If `03-design.md`'s version is newer than the `based_on` recorded in an
existing `04-structure.md`, warn about staleness and offer to revise.

## Process

1. Follow `references/structure-process.md` (slices, review,
   write, render).
2. **Inline approval.** Follow `references/approve.md`: unit `structure`
   (`full` flow, or `standard` flow with the design already
   approved); in `standard` flow with the design still `draft`, unit
   `design+structure`. Ask *"Approve now? (yes / not yet)"*. Only an
   explicit yes approves.

## Output

`04-structure.md` + `04-structure.html`.

## Stop conditions

Those in `references/structure-process.md` (verification content gate, too
many slices).

## Rules

- Ask the human only through the question tool (`AskUserQuestion` in Claude, the equivalent in other agents), one question at a time, with the background and your recommendation; never as plain chat text. This includes approval prompts (offer *yes* and *not yet* as options).
- Never begin writing implementation code from this skill.
- End the session telling the human: the artifact path (and `.html`), its
  approval state, and the exact next command — `grove-implement <slug>` in a
  fresh session, or `grove-approve <slug> <unit>` if not approved yet. Then follow
  `references/next-session.md` and offer to start that command in a new grove
  session.
