---
name: grove-approve
description: Standalone command to approve a grove artifact later (questions, research, design, structure, or design+structure together). Only load this when the human explicitly types the approve command or explicitly asks to approve a specific artifact — never load it on your own initiative, and never treat any other signal as a request to approve.
disable-model-invocation: true
license: MIT
---

# grove-approve

## Purpose

Approve a grove artifact outside the session that wrote it. Gated skills
already offer approval inline at their end; this is for approving later —
after reading the rendered HTML, after a break, or after editing by hand.
All approval logic lives in `references/approve.md`; this skill only
resolves what to approve and runs that procedure.

## When to use / not use

- Use **only** when the human explicitly runs `grove-approve <slug> <unit>`
  or unambiguously asks, in their own words, to approve a specific artifact.
- **Never** load or run this skill on your own initiative, as a side effect
  of finishing another skill, or because an artifact "looks ready".
  `disable-model-invocation: true` enforces this in Claude Code; OpenCode
  has no equivalent field, so this rule is the enforcement there.
- Ticket snapshots and `05-plan.md` are never approved here (the plan is
  self-approved per slice by `grove-implement`).

## Inputs

- The feature slug and the unit: `questions`, `research`,
  `questions+research`, `design`, `structure`, `design+structure`, or
  `implementation` (after the last slice; marks the feature done).
  If the unit is omitted, propose the one that's pending (e.g. in `standard`
  flow with both drafts present: `design+structure`) and confirm it.
- `feature.md` (`flow`, `kind`, `children`, `parent`, `order`), the
  artifact file(s), and for design its draft ADRs.

## Preconditions & gates

None beyond the content gates — approval is the mechanism that produces
gate-satisfying state. The unit rules in `references/approve.md` apply: in
`standard` flow, `design` means `design+structure`.

## Process

1. Resolve the feature folder and the unit (above).
2. Follow `references/approve.md` from "Procedure" step 1 to the end:
   validate, summarise, ask *"Approve now? (yes / not yet)"*, and on an
   explicit yes apply every effect (frontmatter, stale marking, ADR flips,
   epic child folders, tracker comment).

## Output

As `references/approve.md` describes: updated frontmatter, stale marks,
flipped ADRs, and for an epic structure the child folders and `children:`.

## Stop conditions

- Unclear confirmation: write nothing.
- A failing content gate without `--force`: report it and write nothing.

## Rules

- Never self-invoke, under any framing.
- Approval always requires an explicit "yes" or "approve" from the human in
  this session, even if they pre-authorized `--force`.
