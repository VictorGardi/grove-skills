---
name: grove-questions
description: Turn a ticket or idea into scope, neutral research questions, a size verdict, and a proposed flow (phase 1 of the grove workflow; usually run inside grove-start). Load when the human wants to run or revise only the questions phase, or start a small feature without research.
license: MIT
---

# grove-questions

## Purpose

Phase 1 of grove. Turn a ticket or idea into: a scoped goal, a set of neutral
factual research questions about the *current* system, product questions only
a human can answer, a size verdict, and a proposed **flow** (`full`,
`standard`, or `small` — see `references/contract.md`, "Flows"). For a large idea, this is also where
**epic mode** starts: shaping the idea and splitting it into child features
instead of writing research questions for the whole thing at once.

## When to use / not use

- Usually runs inside `grove-start`, which loads this skill and then
  continues into research. Use it directly to start a feature you expect to
  be `small` (no research), or to revise.
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
   dependencies). If the child's folder doesn't exist yet, create it and its
   `feature.md` (`kind: feature`, `parent: <epic-slug>`, `order` from the
   structure entry), naming it per the epic-child slug rule in
   `references/contract.md` (`<prefix>-<NN>-<kebab-name>`).
   Write **delta** research questions only — what the epic's research didn't
   cover, plus anything in this child's own area that may have changed since.
   Show the rolling-wave warning if it applies. Then continue at step 4c (the
   size verdict doesn't apply to a child — its size is already bounded by the
   epic's structure — so propose `standard`).
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
     - **S**: clear result, known pattern, ≤ ~3 files, no one-way decision.
       Proposes `small` flow (no research, design, or structure).
     - **M**: the default. Proposes `standard` flow.
     - **L**: likely more one-way decisions than `limits.maxOneWayDecisions`,
       spans more than 2 unfamiliar modules, or has several user-visible
       outcomes. Offer three options: **epic mode** (if picked, rewrite
       `feature.md`'s `kind` to `epic`, delete the `## Research questions`/
       `## Size verdict` framing from this artifact, and continue at step 4b);
       a **split** into sub-features, each with its own slug and one-line goal
       (create no sub-feature folders until the human agrees); or **one
       feature in `full` flow**.
   - `## Open questions`
4b. **Epic mode.** `feature.md` is now `kind: epic`; `appetite` is required.
   Check the epic's `feature.md` body for the shaping headings (`## Problem`,
   `## Who it's for`, `## Success looks like`, `## Non-goals`, `## Appetite`)
   and walk the human through any that are missing or vague, one at a time.
   Then write broad `01-questions.md` research questions covering the whole
   area the epic touches (same neutrality rule as step 4). Skip the S/M/L
   size verdict — an epic is, by definition, already past that. An epic's
   flow is always `full`.
4c. **Propose the flow** per the table in `references/contract.md` ("Flows"):
   epic → `full`, child → `standard`, S → `small`, M → `standard`, L (not an
   epic) → `full`. State it with a one-line reason (e.g. "standard: size M,
   two two-way decisions and one schema change — design and slices fit one
   review"), and let the human confirm or pick another. Write `flow` into
   `feature.md` and append the first `## Flow log` line, e.g.
   `- 2026-10-05: standard (proposed from size M, confirmed)`. If the human
   changes it, log their choice and reason instead.
5. **Walk the product questions one at a time.** Ask each separately, record
   the answer into the artifact immediately, then move to the next.
6. Set frontmatter `phase: questions`, `status: draft`, `version: 1` (or bump
   on revise).
7. **Inline approval** — skip this when running inside `grove-start` (it
   approves at its own end). Otherwise follow `references/approve.md` for the
   `questions` unit: validate, summarise, ask
   *"Approve now? (yes / not yet)"*. Only an explicit yes approves. In `small` flow approval is a hard
   gate for `grove-implement`; otherwise it's optional (research's soft gate).

## Output

`feature.md`, `00-ticket.md`, and `01-questions.md` in
`<artifactRoot>/<feature-slug>/`.

## Stop conditions

- Stop if the size verdict is L and the human hasn't yet agreed to epic mode,
  a split, or one `full`-flow feature.
- Stop once all product/shaping questions are answered and the artifact is
  written — do not proceed into research yourself.

## Rules

- Never ask a question the codebase or ADRs can already answer.
- Research questions must stay neutral — review them yourself for leading
  phrasing before finalizing.
- In child mode, never re-ask or re-decide anything the epic's `feature.md`
  or `03-design.md` already settled — delta questions only.
- The human may change the flow at any time by asking: write the new `flow`
  and a `## Flow log` line with the reason (`references/contract.md`,
  "Changing the flow").
- End the session (when not inside `grove-start`) by telling the human: the
  artifact path, its approval state, and the exact next command —
  `grove-implement <slug>` in `small` flow, otherwise `grove-research <slug>`
  — and to start a fresh session for it.
