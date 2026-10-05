---
name: grove-questions
description: Turn a ticket or idea into scope, neutral research questions, and a size verdict (phase 1 of the grove workflow — Questions/Research/Design/Structure/Plan/Implement). Load when the human wants to start a new grove feature, start grove on a ticket, or run the questions phase.
license: MIT
---

# grove-questions

## Purpose

Phase 1 of grove. Turn a ticket or idea into: a scoped goal, a set of neutral
factual research questions about the *current* system, product questions only
a human can answer, and a size verdict. For a large idea, this is also where
**epic mode** starts: shaping the idea and splitting it into child features
instead of writing research questions for the whole thing at once.

## When to use / not use

- Use at the very start of a new feature, before any research or design exists.
- Use again in **revise mode** if `01-questions.md` already exists and the
  human has feedback.
- Do not use mid-feature — later phases have their own skills.

## Inputs

- A ticket ID/URL (read via the Linear MCP server if `grove.config.json` has
  `tracker.type: "linear"`) or pasted text describing the idea.
- `grove.config.json` (if missing, tell the human to run `grove-setup` first
  and stop).
- For child mode: the epic's slug (ask if not given), its `feature.md`,
  `03-design.md`, and `04-structure.md` entry for this child.

## Preconditions & gates

None (entry point of the workflow). If `01-questions.md` already exists,
switch to revise mode per `references/contract.md`.

**Rolling-wave warning (soft):** in child mode, if an earlier child in the
epic's `order` has not yet reached `phase: implementation`, warn and ask
whether to continue anyway — never block (`references/gates.md`).

## Process

0. **Determine mode.** If the human is starting work on one feature inside an
   already-structured epic (they name the epic, or name a child slug from the
   epic's `04-structure.md`), this is **child mode** — skip to step 0b. Normal
   feature or epic-shaping work is **epic/feature mode** — continue below,
   and decide epic vs. feature in step 4's size verdict.
0b. **Child mode.** Read the epic's `feature.md`, `03-design.md`, and the
   matching entry in `04-structure.md` (goal, outcome, scope `E-D` ids,
   dependencies). Create the child's folder and `feature.md`
   (`kind: feature`, `parent: <epic-slug>`, `order` from the structure entry).
   Write **delta** research questions only — what the epic's research didn't
   cover, plus anything in this child's own area that may have changed since.
   Show the rolling-wave warning if it applies. Then continue at step 5 (the
   size verdict doesn't apply to a child — its size is already bounded by the
   epic's structure).
1. **Snapshot the ticket.** Write the ticket text verbatim, unedited, to
   `00-ticket.md` (plain text, no frontmatter — it's a source snapshot).
2. **Shallow orientation only.** Read `CONTEXT.md` and ADR titles in `adrDir`.
   Do a directory listing and a few targeted greps to find where relevant
   code probably lives. Do **not** deep-read files — that's research's job.
3. **Determine the feature slug** per `references/contract.md`, create
   `<artifactRoot>/<feature-slug>/`, and write `feature.md` with
   `kind: feature` (default) and `created`.
4. **Write `01-questions.md`** with these headings, in order:
   - `## Goal` — 1–3 sentences, in the human's words.
   - `## Out of scope`
   - `## Research questions` — 5–12 factual questions about the **current**
     system. Each must be neutral: it must never reveal or imply the intended
     solution, because research must not be biased by the ticket.
     - Bad: "How do we add a shared retry queue?"
     - Good: "How are retries currently scheduled, persisted, and recovered
       after a worker restart?"
   - `## Product questions for the human` — only things the code cannot
     answer (priorities, trade-offs, constraints).
   - `## Size verdict` — S / M / L with reasons:
     - **S**: clear result, known pattern, ≤ ~3 files. Recommend skipping
       research and design, and say why.
     - **M**: default — full phase sequence.
     - **L**: likely more one-way decisions than `limits.maxOneWayDecisions`,
       spans more than 2 unfamiliar modules, or has several user-visible
       outcomes. **Offer epic mode as an alternative to a plain split**: if
       the human picks it, rewrite `feature.md`'s `kind` to `epic`, delete the
       `## Research questions`/`## Size verdict` framing from this artifact,
       and continue at step 4b instead of step 5. If they decline epic mode,
       fall back to the existing behavior: propose a split into sub-features,
       each with its own slug and one-line goal, and do not create any
       sub-feature folders until the human agrees.
   - `## Open questions`
4b. **Epic mode.** `feature.md` is now `kind: epic`; `appetite` is required.
   Check the epic's `feature.md` body for the shaping headings (`## Problem`,
   `## Who it's for`, `## Success looks like`, `## Non-goals`, `## Appetite`)
   and walk the human through any that are missing or vague, one at a time.
   Then write broad `01-questions.md` research questions covering the whole
   area the epic touches (same neutrality rule as step 4). Skip the S/M/L
   size verdict — an epic is, by definition, already past that.
5. **Walk the product questions one at a time.** Ask each separately, record
   the answer into the artifact immediately, then move to the next.
6. Set frontmatter `phase: questions`, `status: draft`, `version: 1` (or bump
   on revise).

## Output

`feature.md`, `00-ticket.md`, and `01-questions.md` in
`<artifactRoot>/<feature-slug>/`.

## Stop conditions

- Stop if the size verdict is L and the human hasn't yet agreed to a split or
  to epic mode.
- Stop once all product/shaping questions are answered and the artifact is
  written — do not proceed into research yourself.

## Rules

- Never ask a question the codebase or ADRs can already answer.
- Research questions must stay neutral — review them yourself for leading
  phrasing before finalizing.
- In child mode, never re-ask or re-decide anything the epic's `feature.md`
  or `03-design.md` already settled — delta questions only.
- End the session by telling the human: the artifact path, what to review (2
  min), and the exact next command (`grove-approve <slug> questions` is
  optional — questions only needs a soft read before `grove-research`, per
  `references/gates.md`), and to start a fresh session for the next phase.
