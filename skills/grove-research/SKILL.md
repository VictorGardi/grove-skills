---
name: grove-research
description: Document how the system works today, facts only, answering the research questions from the grove-questions phase (phase 2 of the grove workflow). Load when the human wants to run the research phase on an existing feature's 01-questions.md.
license: MIT
---

# grove-research

## Purpose

Phase 2 of grove. Answer `01-questions.md`'s research questions with cited,
factual evidence about the system **as it exists today**. No proposals, no
recommendations.

## When to use / not use

- Use after `01-questions.md` exists for a feature slug.
- Use again in revise mode if `02-research.md` already exists and the human
  has corrections (they review for factual accuracy, not opinions).
- Do not use to evaluate or propose solutions — that's `grove-design`.

## Inputs

- Only the `## Research questions` section of `01-questions.md`.
- `CONTEXT.md` and the ADRs in `adrDir`.

## Preconditions & gates

Soft gate: if `01-questions.md` is not `status: approved`, warn and proceed
(per `references/gates.md`). If `01-questions.md` doesn't exist, stop and
tell the human to run `grove-questions` first.

## Blindness rule

**Never read `00-ticket.md` or the `## Goal` section of `01-questions.md`, and
never call the tracker.** Pass only the literal question text to any
subagents. This is deliberate: research must not be biased toward the
ticket's assumed solution. If a subagent's output references the ticket or
a proposed solution, discard and re-run it with just the question text.

## Process

1. Read `## Research questions` from `01-questions.md`, `CONTEXT.md`, and ADR
   titles/content relevant to the area.
2. **Group questions into 2–5 clusters** by area of the system. Run one
   subagent per cluster (use the environment's subagent/task tool; fall back
   to doing clusters sequentially yourself if none is available). Give each
   subagent only its cluster's question text, `CONTEXT.md`, and instructions
   to cite `path:line` for every claim and write "Could not determine" rather
   than guess — never "should" or proposed designs.
3. Synthesize the subagent answers into `02-research.md` (≤ ~300 lines):
   - `## Summary` (≤ 10 lines)
   - `## Answers` — one subsection per research question, each claim cited
     `path:line`
   - `## Current architecture` — a Mermaid diagram of the components, data
     flow, and boundaries involved
   - `## Existing patterns to reuse` — how similar problems are already
     solved in this codebase
   - `## Constraints & invariants`
   - `## Test landscape` — what covers this area today and how to run it
   - `## Relevant ADRs`
   - `## Unknowns`
   - `## Open questions`
4. Set frontmatter: `phase: research`, `based_on: ["01-questions.md@<version read>"]`.
5. Invoke `grove-render` on `02-research.md` to produce `02-research.html`.

## Output

`02-research.md` + `02-research.html` in the feature folder.

## Stop conditions

- Stop and warn if `01-questions.md`'s version is newer than any prior
  `based_on` recorded in an earlier research draft (staleness, per
  `references/gates.md`).
- Never fabricate an answer — "Could not determine" plus what would resolve it
  belongs in `## Unknowns`, not a guess.

## Rules

- Zero recommendations anywhere in this artifact. If a sentence contains
  "should", "we could", or similar, rewrite it as a fact or move it out.
- End the session telling the human: the artifact path (and its `.html`), to
  skim and correct any wrong facts (not opinions), the next command
  (`grove-design <slug>`), and to start a fresh session.
