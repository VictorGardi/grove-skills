---
name: grove-research
description: Document how the system works today, facts only, answering the research questions from the grove-questions phase (phase 2 of the grove workflow; grove-start normally runs it for you). Load when the human wants to run or revise only the research phase on an existing feature's 01-questions.md.
license: MIT
---

# grove-research

## Purpose

Phase 2 of grove. Answer `01-questions.md`'s research questions with cited,
factual evidence about the system **as it exists today**. No proposals, no
recommendations.

## When to use / not use

- `grove-start` normally runs this phase for you, right after questions. Use
  this skill directly when `01-questions.md` exists but research doesn't
  (e.g. `grove-start` had no subagent tool, or a feature switched from
  `small` to `standard`), or in revise mode when `02-research.md` exists and
  the human has factual corrections.
- Do not use to evaluate or propose solutions — that's `grove-design`.

## Inputs

- Only the `## Research questions` section of `01-questions.md`.
- `CONTEXT.md` and the ADRs in `adrDir`.
- Child mode (`feature.md` has `parent` set): also the epic's `02-research.md`.

## Preconditions & gates

Soft gate: if `01-questions.md` is not `status: approved`, warn and proceed
(per `references/gates.md`). If `01-questions.md` doesn't exist, stop and
tell the human to run `grove-start` first.

## Blindness rule

**Never read `00-ticket.md`, the `## Goal` section of `01-questions.md`, or
`feature.md`'s body, and never call the tracker.** This session stays blind,
so it writes the synthesis itself. Full rule: `references/research-process.md`.

## Process

1. Follow `references/research-process.md` (inputs, clusters and
   subagents, synthesis into `02-research.md`, checks, render).
2. **Inline approval.** Follow `references/approve.md` for the `research`
   unit: validate, summarise, ask *"Approve now? (yes / not yet)"*. Only an
   explicit yes approves; anything else leaves it `draft` (design's gate on
   research is soft).

## Output

`02-research.md` + `02-research.html` in the feature folder.

## Stop conditions

Those in `references/research-process.md` (staleness, never fabricating).

## Rules

- Zero recommendations anywhere in this artifact.
- End the session telling the human: the artifact path (and its `.html`),
  to skim and correct any wrong facts (not opinions), its approval state,
  and the next command (`grove-design <slug>`) in a fresh session — offering
  to start that session for them per `references/next-session.md`.
