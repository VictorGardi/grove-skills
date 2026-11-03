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
`standard`, or `small` — see `references/contract.md`, "Flows").

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

## Preconditions & gates

None (entry point of the workflow). If `01-questions.md` already exists,
switch to revise mode per `references/contract.md`.

## Process

1. **Snapshot the ticket.** Write the ticket text verbatim, unedited, to
   `00-ticket.md` (plain text, no frontmatter — it's a source snapshot).
2. **Shallow orientation only.** Read `CONTEXT.md` and ADR titles in `adrDir`.
   Do a directory listing and a few targeted greps to find where relevant
   code probably lives. Do **not** deep-read files — that's research's job.
3. **Determine the feature slug** per `references/contract.md`, create
   `<artifactRoot>/<feature-slug>/`, and write `feature.md` with
   `created`.
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
       outcomes. Offer two options: a **split** into
       separate features, each with its own slug and one-line goal (create no
       other feature folders until the human agrees); or **one feature in
       `full` flow**.
   - `## Open questions`
4b. **Propose the flow** per the table in `references/contract.md` ("Flows"):
   S → `small`, M → `standard`, L → `full`. State it with a one-line reason (e.g. "standard: size M,
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
8. **Close, then offer the next session.** Report the artifact path and its
   approval state, then follow `references/next-session.md` to spawn the next
   command — `grove-research <slug>` outside `small` flow,
   `grove-implement <slug>` in `small` flow with the questions approved,
   `grove-approve <slug> questions` otherwise — in a new grove session if the
   human says yes.

## Output

`feature.md`, `00-ticket.md`, and `01-questions.md` in
`<artifactRoot>/<feature-slug>/`.

## Stop conditions

- Stop if the size verdict is L and the human hasn't yet agreed to a split or
  one `full`-flow feature.
- Stop once all product questions are answered and the artifact is
  written — do not proceed into research yourself.

## Rules

- Ask the human only through the question tool (`AskUserQuestion` in Claude, the equivalent in other agents), one question at a time, with the background and your recommendation; never as plain chat text. This includes approval prompts (offer *yes* and *not yet* as options).
- Never ask a question the codebase or ADRs can already answer.
- Research questions must stay neutral — review them yourself for leading
  phrasing before finalizing.
- The human may change the flow at any time by asking: write the new `flow`
  and a `## Flow log` line with the reason (`references/contract.md`,
  "Changing the flow").
- End the session (when not inside `grove-start`) by telling the human: the
  artifact path, its approval state, and the exact next command —
  `grove-implement <slug>` in `small` flow, otherwise `grove-research <slug>`
  — and to start a fresh session for it, offering to start it for them per
  `references/next-session.md`.
