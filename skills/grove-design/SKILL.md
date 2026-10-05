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

`feature.md`, `00-ticket.md`, `01-questions.md`, `02-research.md`,
`CONTEXT.md`, ADRs, `grove.config.json` (for `limits.maxOneWayDecisions`,
`limits.epicMaxOneWayDecisions`, and `limits.designMaxLines`).

Child mode (`feature.md` has `parent` set): also the epic's `03-design.md`
and its `04-structure.md` entry for this child.

## Preconditions & gates

Soft gate: if `02-research.md` is not `status: approved`, warn and proceed. If
`02-research.md` doesn't exist, stop and tell the human to run `grove-research`
first (or, for an S-sized feature, confirm they want to skip straight here).

## Process

0. **Determine mode** from `feature.md`: `kind: epic` → epic mode (step 0e);
   `parent` set → child mode (step 0c); otherwise the normal flow below.

0c. **Child mode — inherited decisions first.** Read the epic's
   `03-design.md` in full. Start this child's `03-design.md` with
   `## Inherited decisions`: one line per relevant `E-D` id and its chosen
   option, **read-only** — never re-grill these. Then run steps 1–8 below for
   only the child's own decisions (mostly program design: call paths, file
   tree, types/signatures). If a needed decision conflicts with or is missing
   from an inherited `E-D`, **escalate instead of deciding it here**: stop,
   add the issue to the epic's `03-design.md` `## Open questions`, set the
   epic's `03-design.md` `status` back to `draft`, tell the human exactly
   what's missing/wrong and why, and do not continue this child's design
   around it.

0e. **Epic mode — system level only.** Steps 1–8 below still apply, with
   these changes:
   - **Scope.** Only decisions that cross child boundaries belong here: data
     model and ownership, contracts between modules (or, within this epic,
     between its future children), the main flows, existing patterns to
     reuse, and cross-cutting rules. **No file trees, no signatures** — that
     is program design and belongs entirely to the children.
   - **Decision ids.** Give every one-way decision a stable `E-D<n>` id (never
     reused or renumbered across revisions) and an ADR per decision, per
     `references/contract.md`. Use `limits.epicMaxOneWayDecisions` in place of
     `limits.maxOneWayDecisions` for the decision-count stop condition.
   - **Appetite check.** Add `## Appetite check` after `## Risks`: does this
     design fit `feature.md`'s `appetite`? If not, propose concrete cuts
     (defer a decision's scope, drop a flow) rather than silently expanding
     the appetite.
   - Skip `## Program design` entirely (no file trees/signatures at this
     level).
   - Render (step 8) shows a system diagram plus a child-map *preview* (the
     likely children, not yet the formal list — that's `grove-structure`'s
     job), never a file tree.
   - End-of-session next command is `grove-approve <slug> design`, same as
     normal, but tell the human the next *skill* after approval is
     `grove-structure` in epic mode (it will produce child features, not
     slices).

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
   exceed `limits.maxOneWayDecisions` (or, in epic mode, `limits.epicMaxOneWayDecisions`),
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
   boundaries). Epic mode skips program design entirely (see step 0e).
6. **Durable knowledge.** For each one-way decision that is hard to reverse,
   would surprise a newcomer, and involved a real trade-off: draft an ADR in
   `adrDir` with `Status: Proposed` (format: `references/adr-template.md`,
   copied from grove-setup's convention). Epic mode: every `E-D` decision gets
   one regardless, per step 0e. Add any new domain terms to `CONTEXT.md`.
7. **Write `03-design.md`** (≤ `limits.designMaxLines`), headings in order:
   - `## Desired state`
   - `## Non-goals`
   - `## System design` — contracts, schemas, key queries
   - `## Program design` — call-path diff, file-tree diff with
     NEW/MODIFIED/DELETED markers, key types and signatures (**omitted in
     epic mode**)
   - `## One-way decisions` — chosen option, rejected options (one line
     each), link to the ADR (epic mode: each entry prefixed with its `E-D` id)
   - `## Two-way decisions` (table)
   - `## Risks`
   - `## Appetite check` (**epic mode only**, see step 0e)
   - `## Open questions`
8. Invoke `grove-render` for `03-design.html`: current-vs-proposed diagrams
   side by side, a decision card per one-way decision (all options, chosen
   one highlighted), and the file-tree diff (epic mode: system diagram + child
   map preview instead of a file-tree diff, per step 0e).

## Output

`03-design.md` + `03-design.html`, plus any new/updated ADRs and `CONTEXT.md`
entries.

## Stop conditions

- Stop immediately if one-way doors exceed the applicable limit — propose a
  split before asking a single grilling question.
- Child mode: stop immediately on an escalation per step 0c — never decide
  around a missing or conflicting epic decision.
- Stop and tell the human to review + run `grove-approve <slug> design` once
  the artifact is written. Never self-approve.

## Rules

- One one-way decision per turn, always. Never batch multiple one-way
  decisions into a single question.
- Never ask about something the research or codebase already answers.
- Child mode: inherited `E-D` decisions are read-only — grill only the
  child's own decisions.
- Editing an approved `03-design.md` resets it to `draft` and marks
  `04-structure.md` onward `stale` (per `references/contract.md`) — warn the
  human this will happen before making the edit if the design is approved.
  Epic mode: re-approving a changed design triggers *targeted* stale marking
  on children per `references/gates.md`, not wholesale.
- End the session telling the human: the artifact path (and `.html`), to
  review carefully (it's short by design), the exact next command
  (`grove-approve <slug> design`), and to start a fresh session.
