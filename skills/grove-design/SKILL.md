---
name: grove-design
description: Decide where a feature is going, surfacing every one-way-door decision for explicit human choice with full sight of consequences (phase 3 of the grove workflow); in standard flow it continues in the same session to outline the slices, for one combined review. Load when the human wants to run the design phase on a feature with existing research, or to grill them on a design.
license: MIT
---

# grove-design

## Purpose

Phase 3 of grove. Decide **where we're going**: the desired end state, every
one-way-door decision made explicitly by the human with real trade-offs shown,
and two-way-door decisions made by the agent and shown for a one-pass veto.

In **`standard` flow** (`feature.md` `flow`), the same session then outlines
the slices (`04-structure.md`) and ends with one combined review and one
approval covering both files. In **`full` flow**, it stops after the
design.

## When to use / not use

- Use after `02-research.md` exists (soft gate — see Preconditions).
- Use again in revise mode: if `03-design.md` exists, read it plus feedback
  and update the affected sections rather than restarting the whole grill.
- Do not use to plan file-by-file steps — that's `grove-implement`.
- Not part of `small` flow. If `flow: small`, say so and offer to switch to
  `standard` (logged in `feature.md`'s `## Flow log`), which also needs
  research first.

## Inputs

`feature.md` (`flow`, `appetite`), `00-ticket.md`,
`01-questions.md`, `02-research.md`, `CONTEXT.md`, ADRs, `grove.config.json`
(for `limits.maxOneWayDecisions`,
`limits.designMaxLines`, and — in `standard` flow — `limits.maxSlices` and
`commands.*`).

## Preconditions & gates

Soft gate: if `02-research.md` is not `status: approved`, warn and proceed. If
`02-research.md` doesn't exist, stop and tell the human to run `grove-research`
first (`grove-start`, or `grove-research` if questions already exist).

## Process

1. **Desired state.** Write 5–10 lines describing the end result. Confirm
   with the human before continuing.
2. **Decision map.** Before asking anything, enumerate every decision the
   feature requires. Classify each:
   - **One-way door** (expensive to reverse): persisted data shape/schema,
     public or cross-team API contracts, module boundaries and ownership, new
     dependencies or infrastructure, cross-cutting patterns other code will
     copy, security/auth model.
   - **Two-way door**: everything else.
   Order by dependency (system design before program design). Show the human
   the full map before asking about any single decision. If one-way doors
   exceed `limits.maxOneWayDecisions`),
   stop and propose a split instead of proceeding.
3. **Two-way doors.** Decide these yourself, guided by `## Existing patterns
   to reuse` from research. Present as a table for a single-pass veto; don't
   grill on these individually.
4. **Grilling loop — one one-way decision per turn.** For each, in order:
   - **Why it matters** (≤ 3 lines)
   - **2–3 options**, one of which is always the simplest viable option
     (reuse an existing pattern, or build less). For each: what changes vs.
     current architecture, what it makes easier/harder later, complexity cost
     (new concepts/files/deps), reversibility, fit with existing patterns.
     Any option adding an abstraction/layer/dependency must justify itself
     against the simplest option (YAGNI).
   - **Recommendation** and why.
   - If the human asks to "show me", render a diagram of that option via
     `grove-render` conventions (don't wait until the final render pass).
   - Keep the decision open until the human gives a clear answer. Write the
     decision into `03-design.md` immediately after each answer — never defer
     write-up to the end of the session.
5. **Layering.** Settle system design (contracts, schemas, queries, data
   flow) before program design (call paths, file tree, types/signatures, test
   boundaries).
6. **Durable knowledge.** For each one-way decision that is hard to reverse,
   would surprise a newcomer, and involved a real trade-off: draft an ADR in
   `adrDir` with `Status: Proposed` (format: `references/adr-template.md`,
   copied from grove-setup's convention). Add any new domain terms to `CONTEXT.md`.
7. **Write `03-design.md`** (≤ `limits.designMaxLines`), headings in order:
   - `## Desired state`
   - `## Non-goals`
   - `## System design` — contracts, schemas, key queries
   - `## Program design` — call-path diff, file-tree diff with
     NEW/MODIFIED/DELETED markers, key types and signatures
   - `## One-way decisions` — chosen option, rejected options (one line
     each), link to the ADR
   - `## Two-way decisions` (table)
   - `## Risks`
   - `## Open questions`
8. Invoke `grove-render` for `03-design.html`: current-vs-proposed diagrams
   side by side, a decision card per one-way decision (all options, chosen
   one highlighted), and the file-tree diff.
9. **`standard` flow only — the slices.** Say *"Decisions done, now the
   slices"* and follow `references/structure-process.md` in this same
   session, against the `03-design.md` just written: outline, review with
   the human, write `04-structure.md`, render `04-structure.html`. If the
   structure step finds the design must change, update `03-design.md` first
   (it's still `draft`) and keep both consistent.
10. **Summary.** `full`: the design summary. `standard`: one combined
   summary — the one-way decisions with their chosen options, the two-way
   table's notable entries, the slice list (outcome + verification, one line
   each)  Give the paths to both `.html` files.
11. **Inline approval.** Follow `references/approve.md`: unit `design` in
   `full` flow; unit `design+structure` in `standard` flow —
   atomic, both or neither. Ask *"Approve now? (yes / not yet)"*. Only an
   explicit yes approves. On "not yet" with feedback, revise the affected
   file(s) here and ask again; never approve the design alone in `standard`
   flow.

## Output

`03-design.md` + `03-design.html`, plus any new/updated ADRs and `CONTEXT.md`
entries.

## Stop conditions

- Stop immediately if one-way doors exceed the applicable limit — propose a
  split before asking a single grilling question.
- Stop at the inline approval (step 11). Never approve without the human's
  explicit yes; on "not yet", the artifacts stay `draft`.

## Rules

- Ask the human only through the question tool (`AskUserQuestion` in Claude, the equivalent in other agents), one question at a time, with the background and your recommendation; never as plain chat text. This includes approval prompts (offer *yes* and *not yet* as options).
- One one-way decision per turn, always. Never batch multiple one-way
  decisions into a single question.
- Never ask about something the research or codebase already answers.
- Editing an approved `03-design.md` resets it to `draft` and marks
  `04-structure.md` onward `stale` (per `references/contract.md`) — warn the
  human this will happen before making the edit if the design is approved.
  In `standard` flow, revise the structure to match in the same session and
  re-approve as `design+structure`.
- No subagents for the design or structure conversation — it stays in this
  session with the human.
- End the session telling the human: the artifact path(s) (and `.html`),
  the approval state, and the exact next command:
  - `full` flow, approved: `grove-structure <slug>` — continuing in
    this same session is fine (the design context helps the slices).
  - `standard` flow, approved: `grove-implement <slug>`, in a fresh session.
  - not approved yet: `grove-approve <slug> <unit>` once they're happy.
  Then follow `references/next-session.md`: offer to start that command in a
  new grove session — asking *"Continue here, or start `grove-structure` in a
  new session?"* for the `full`-flow case, and a plain yes/no offer
  for the rest.
