---
name: grove-questions
description: Turn a ticket or idea into scope, neutral research questions, and a size verdict (phase 1 of the grove workflow — Questions/Research/Design/Structure/Plan/Implement). Load when the human wants to start a new grove feature, start grove on a ticket, or run the questions phase.
license: MIT
---

# grove-questions

## Purpose

Phase 1 of grove. Turn a ticket or idea into: a scoped goal, a set of neutral
factual research questions about the *current* system, product questions only
a human can answer, and a size verdict.

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

## Preconditions & gates

None (entry point of the workflow). If `01-questions.md` already exists,
switch to revise mode per `references/contract.md`.

## Process

1. **Snapshot the ticket.** Write the ticket text verbatim, unedited, to
   `00-ticket.md` (plain text, no frontmatter — it's a source snapshot).
2. **Shallow orientation only.** Read `CONTEXT.md` and ADR titles in `adrDir`.
   Do a directory listing and a few targeted greps to find where relevant
   code probably lives. Do **not** deep-read files — that's research's job.
3. **Determine the feature slug** per `references/contract.md` and create
   `<artifactRoot>/<feature-slug>/`.
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
       outcomes. Propose a split into sub-features, each with its own slug
       and one-line goal. **Do not create the sub-feature folders** until the
       human agrees.
   - `## Open questions`
5. **Walk the product questions one at a time.** Ask each separately, record
   the answer into the artifact immediately, then move to the next.
6. Set frontmatter `phase: questions`, `status: draft`, `version: 1` (or bump
   on revise).

## Output

`00-ticket.md` and `01-questions.md` in `<artifactRoot>/<feature-slug>/`.

## Stop conditions

- Stop if the size verdict is L and the human hasn't yet agreed to a split.
- Stop once all product questions are answered and the artifact is written —
  do not proceed into research yourself.

## Rules

- Never ask a question the codebase or ADRs can already answer.
- Research questions must stay neutral — review them yourself for leading
  phrasing before finalizing.
- End the session by telling the human: the artifact path, what to review (2
  min), and the exact next command (`grove-approve <slug> questions` is
  optional — questions only needs a soft read before `grove-research`, per
  `references/gates.md`), and to start a fresh session for the next phase.
