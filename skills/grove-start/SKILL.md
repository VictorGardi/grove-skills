---
name: grove-start
description: Start a grove feature in one session — questions phase, flow choice, then blind research via subagents, ending with a skim summary and an inline approval prompt (phases 1–2 of the grove workflow). Load when the human wants to start a feature, start grove on a ticket or idea, or start a backlog epic child.
license: MIT
---

# grove-start

## Purpose

The first session of every grove feature. It chains the questions phase and
the research phase so the human only stops once, for a skim, instead of
twice across two sessions. It writes exactly what `grove-questions` and
`grove-research` write: `feature.md`, `00-ticket.md`, `01-questions.md`,
`02-research.md` (+ `.html`).

## When to use / not use

- Use to start a new feature (ticket id/URL or pasted idea), an epic, or a
  backlog child of an epic (its folder and `feature.md` already exist).
- Do not use to revise an existing `01-questions.md` or `02-research.md` —
  use `grove-questions` or `grove-research` directly, in revise mode.
- If `01-questions.md` already exists for the slug, stop and point the human
  at those two skills.

## Inputs

One of:
- a feature slug (an existing backlog folder, e.g. an epic child),
- a path to an existing `feature.md`,
- a ticket id/URL (read via the Linear MCP server if `grove.config.json` has
  `tracker.type: "linear"`) or pasted text describing the idea.

Plus `grove.config.json` (if missing, tell the human to run `grove-setup`
first and stop).

## Preconditions & gates

None of its own — it is the entry point. The rolling-wave warning applies
to an epic child, per `references/gates.md`.

## Process

1. **Questions phase.** Load the `grove-questions` skill and follow its
   Process in full — mode detection (feature / epic / child), ticket
   snapshot, shallow orientation, `01-questions.md`, the size verdict, the
   flow proposal, and walking the product (or epic shaping) questions **one
   at a time**. Skip only its end-of-session message and its approval step:
   this skill does both at the end.
2. **Confirm the flow** if `grove-questions` hasn't already recorded the
   human's confirmation in `feature.md`'s `## Flow log`.
3. **`small` flow: stop here** — research isn't needed. Run the inline
   approval (step 7) for the `questions` unit, then close (step 8).
4. **Research, blind.** Follow `references/research-process.md`. This
   session has read the ticket, so:
   - hand fact-gathering subagents **only** their cluster's research
     question text (plus `CONTEXT.md`, and in child mode the epic's research
     for their area) — never the ticket, the goal, the product answers, or
     `feature.md`;
   - hand the synthesis to a separate blind **synthesis subagent** with only
     the question text, the cluster answers, and the heading list;
   - then run the process's checks and render `02-research.html` yourself.
5. **Skim summary.** In ≤ ~15 lines total:
   - questions: the goal, the flow and why, the size verdict, the product
     answers that most constrain design
   - research: the `## Summary`, the most important constraints, every
     `## Unknowns` entry, and anything surprising
   - the paths to `01-questions.md` and `02-research.html`
6. **Corrections.** If the human corrects a fact or a question, apply it in
   revise mode before the approval step (research facts: re-check against
   the code, never just take the correction on faith — say if the code
   disagrees).
7. **Inline approval.** Follow `references/approve.md` for the
   `questions+research` unit (`small` flow: `questions`): validate, summarise,
   ask *"Approve now? (yes / not yet)"* (with *"questions only"* as a third
   answer when research is included). Only an explicit yes approves. "Not
   yet" leaves both `draft` — `grove-design` will still run, with a soft-gate
   warning.
8. **Close.** Tell the human:
   - what was written and its approval state
   - the exact next command: `grove-design <slug>` (`full`/`standard`), or
     `grove-implement <slug>` (`small`)
   - to **start a fresh session** for it — research filled this session's
     context with noise the design conversation shouldn't carry.

## Output

`feature.md`, `00-ticket.md`, `01-questions.md`, and (not in `small` flow)
`02-research.md` + `02-research.html` in `<artifactRoot>/<feature-slug>/`.

## Stop conditions

- Size L, and the human hasn't agreed to epic mode, a split, or continuing
  as one `full`-flow feature: stop after questions (as `grove-questions`
  does) — no research until the scope is settled.
- No subagent tool available: do not write research in this session (it
  isn't blind). Approve questions only if the human says yes, and tell them
  to run `grove-research <slug>` in a fresh session.

## Rules

- Blindness holds even though this session saw the ticket: subagents get
  question text only, and a subagent writes `02-research.md`.
- Never run design or structure from this skill, and never ask design
  questions — product questions only.
- Subagents do mechanical work only (fact-gathering, synthesis). The
  product-question conversation stays in this session with the human.
