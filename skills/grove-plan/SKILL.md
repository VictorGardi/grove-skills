---
name: grove-plan
description: Turn an approved structure into a detailed, agent-facing execution plan a fresh agent could follow cold (phase 5 of the grove workflow). Load when the human wants to run the plan phase on a feature whose structure is approved.
license: MIT
---

# grove-plan

## Purpose

Phase 5 of grove. Produce a detailed execution plan the human won't read
closely but a fresh agent can execute from a cold start, slice by slice.

## When to use / not use

- Use only after `04-structure.md` has `status: approved` (hard gate).
- Use again in revise mode if `05-plan.md` exists and needs adjusting — but
  see the "no new decisions" rule below first.
- Do not use to make design or structural decisions — if one is missing, stop
  (see Process step 3).

## Inputs

`03-design.md` (approved), `04-structure.md` (approved), `grove.config.json`
(`commands.*`).

## Preconditions & gates

**Hard gate:** `04-structure.md` must be `status: approved`. If not, stop
and tell the human to run `grove-approve <slug> structure` first, unless
`--force <reason>` is given — record in `forced`.

## Process

1. For each slice in `04-structure.md`, write ordered steps as checkboxes:
   exact file paths, tests to write first (where the structure implies
   test-first), and verification commands taken verbatim from
   `commands.test`/`typecheck`/`lint`/`build`.
2. **Zero-context test.** Before finishing, re-read the plan as if you were a
   fresh agent with only `05-plan.md` and `03-design.md` open — no chat
   history, no structure doc. If a step requires knowledge not in those two
   files, add it inline rather than assuming it's known.
3. **No new decisions.** If writing the plan reveals a decision the design
   didn't make, or a contradiction with the design: stop, add it to
   `03-design.md`'s `## Open questions`, set `03-design.md`'s `status` to
   `draft`, tell the human exactly what's missing and why, and do not
   continue planning around it. Never improvise a design decision here.
4. Write `05-plan.md`.
5. Run the content-gate self-checks from `references/gates.md` (no Open
   questions content, no TODO/TBD, every slice has a verification command
   present in the plan). If they pass, set `status: approved` directly in the
   frontmatter and note in the body that this approval was automatic
   (self-checked, not human-reviewed) — this is the one artifact that
   auto-approves, since §1.4/§7.6 treat the plan as mechanical once structure
   is locked.

## Output

`05-plan.md`.

## Stop conditions

- Stop entirely (do not produce a partial plan silently) if step 3 fires —
  surface the gap to the human first.
- Stop if the zero-context test fails for a step and can't be fixed by adding
  more detail inline (e.g. it actually requires a missing design decision —
  fall back to step 3).

## Rules

- Steps must be mechanical: no "decide whether to..." language should survive
  into the final plan — that's a sign a decision got deferred into here.
- End the session telling the human: the artifact path, that it's agent-facing
  (a light skim is enough), the exact next command (`grove-implement <slug>`),
  and to start a fresh session.
