---
name: grove-design
description: Decide where a feature is going, surfacing every one-way-door decision for explicit human choice with full sight of consequences (phase 3 of the grove workflow). Load when the human wants to run the design phase on a feature with existing research, or to grill them on a design.
license: MIT
---

# grove-design

## Purpose

Phase 3 of grove. Decide **where we're going**: the desired end state, every
one-way-door decision made explicitly by the human with real trade-offs shown,
and two-way-door decisions made by the agent and shown for a one-pass veto.

## When to use / not use

- Use after `02-research.md` exists (soft gate — see Preconditions).
- Use again in revise mode: if `03-design.md` exists, read it plus feedback
  and update the affected sections rather than restarting the whole grill.
- Do not use to plan file-by-file steps — that's `grove-structure`/`grove-plan`.

## Inputs

`00-ticket.md`, `01-questions.md`, `02-research.md`, `CONTEXT.md`, ADRs,
`grove.config.json` (for `limits.maxOneWayDecisions` and `limits.designMaxLines`).

## Preconditions & gates

Soft gate: if `02-research.md` is not `status: approved`, warn and proceed. If
`02-research.md` doesn't exist, stop and tell the human to run `grove-research`
first (or, for an S-sized feature, confirm they want to skip straight here).

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
   exceed `limits.maxOneWayDecisions`, stop and propose a split instead of
   proceeding.
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
   copied from grove-setup's convention). Add any new domain terms to
   `CONTEXT.md`.
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

## Output

`03-design.md` + `03-design.html`, plus any new/updated ADRs and `CONTEXT.md`
entries.

## Stop conditions

- Stop immediately if one-way doors exceed `limits.maxOneWayDecisions` —
  propose a split before asking a single grilling question.
- Stop and tell the human to review + run `grove-approve <slug> design` once
  the artifact is written. Never self-approve.

## Rules

- One one-way decision per turn, always. Never batch multiple one-way
  decisions into a single question.
- Never ask about something the research or codebase already answers.
- Editing an approved `03-design.md` resets it to `draft` and marks
  `04-structure.md` onward `stale` (per `references/contract.md`) — warn the
  human this will happen before making the edit if the design is approved.
- End the session telling the human: the artifact path (and `.html`), to
  review carefully (it's short by design), the exact next command
  (`grove-approve <slug> design`), and to start a fresh session.
