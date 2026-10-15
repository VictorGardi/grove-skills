# Plan process (reference for grove-auto)

Templates and rules for the planner (you). Every subagent prompt below ends
with: "you cannot reach the human; return findings, never ask".

## Limits

Read `limits.maxOneWayDecisions` and `limits.maxSlices` from
`grove.config.json`. The plan stays within both. Put them in every reviewer
prompt.

## Thin slice 1 rule

Slice 1 is a thin end-to-end slice: it cuts one narrow path through every layer
the outcome touches, so the whole path runs after slice 1. Later slices widen
it. Slice 1 carries a line:

`**Thin end-to-end:** <path through the layers, e.g. UI -> API -> store>. Deliberately missing: <what is left for later slices>.`

A slice 1 that builds one layer only, or only scaffolding, is a blocking
finding.

## 03-plan.md template

```markdown
---
feature: <slug>
phase: plan
status: draft
version: 1
created: <date>
updated: <date>
approved_at:
based_on: [01-outcome.md@<v>, 02-research.md@<v>]
forced: []
---

# Plan: <title>

## Decisions

### D1. <title>

**Context.** <why this must be decided now, in plain words>

**Options.**
- A. <option>. Pros: <...>. Cons: <...>.
- B. <option>. Pros: <...>. Cons: <...>.

**Agents disagree:** <only when contested after round 3: planner side and
reviewer side, each with its option, pros and cons. Kept once answered.>
**Human pick:** <only after the human answered a disagreement>

**Pick:** <option>

**Outcome impact.** <what the human sees or loses with this pick>

(Only real one-way decisions, at most `limits.maxOneWayDecisions`. For a
trivial ticket write "No one-way decisions.")

## Slices

### Slice 1. <outcome>

**Outcome.** <what works after this slice>
**Thin end-to-end:** <path through the layers>. Deliberately missing: <...>.
**Files.** <paths to add or change>
**Verification.** <a concrete command or observable check>

### Slice 2. <outcome>

**Outcome.** ...
**Files.** ...
**Verification.** ...

## Reviewer round log

<entries in the format below>

## Deviations from the brief the human should know

<each place the plan departs from or narrows the Outcome Brief, or "None.">

## Risks and what is deliberately not done

<risks, and what is out on purpose, tied to the brief's non-goals>

## Open questions
```

Rules: the `**Pick:**` line is exactly that (the approve gate greps for
`Pick:`). A contested decision has `**Agents disagree:**` and no `**Pick:**`
until the human answers; then add `**Human pick:**` and set `**Pick:**` to the
same choice. Every slice has a Verification. `## Open questions` ends empty. No
placeholder markers anywhere.

## Reviewer prompt template

A fresh `reviewer` subagent every round (read-only; pass the role's resolved
`model` on the Agent call, omitted when it inherits):

> You are the `reviewer`. Read `<artifactRoot>/<slug>/01-outcome.md`,
> `02-research.md` and `03-plan.md`. Limits: at most <maxOneWayDecisions>
> decisions and <maxSlices> slices. Critique the plan against the Outcome Brief
> through these lenses: (1) outcome fit: does the plan deliver what the human
> sees and does, and "How I'll know it works"; (2) every one-way decision is
> surfaced with options, pros, cons and a pick, and nothing is decided silently
> in a slice; (3) slice 1 is thin end-to-end with the `**Thin end-to-end:**`
> line; (4) every slice has a concrete verification; (5) limits respected;
> (6) risks are named; (7) nothing contradicts the brief's non-goals or
> constraints. Return two lists, each item one line with where it is and what
> is wrong: `BLOCKING` (the plan is wrong or unsafe without the fix) and
> `NON-BLOCKING` (improvements). Say `BLOCKING: none` when there are none. Do
> not edit files. You cannot reach the human; return findings, never ask.

Round log reviewers get the plan only, never earlier reviews, so each round is
independent.

## CTO check prompt template

A fresh `cto` subagent, outcome only (pass the role's resolved `model` on the
Agent call, omitted when it inherits):

> You are the `cto`. Read `01-outcome.md` and `03-plan.md`. Check the plan
> against the Outcome Brief point by point: each line of "How I'll know it
> works" and each step of "What the human sees and does". For each point
> return `ok` or `blocking` with one line why: would the human get this if the
> slices were built as written? Judge outcomes only; never comment on
> technical choices. Do not edit files. You cannot reach the human; return
> findings, never ask.

## Round log format

Under `## Reviewer round log`, compact, one line per entry:

- `Round n (x blocking, y non-blocking). Blocking: <finding> → fixed by <change>; <finding> → fixed by <change>.`
- `CTO check (z blocking). <point> → fixed by <change>.` (or `CTO check (0 blocking).`)
- `Veto: D<n>. <what the human changed>.`
- `Agents disagree: D<n>. <one line: the two positions>.`

Non-blocking findings are counted, not listed, unless the planner applied one.

## Round cap

At most 3 reviewer rounds. After each round the planner fixes every blocking
finding, then a fresh reviewer re-checks. Stop early on a round with 0
blocking. An item still contested after round 3 (planner and reviewer
genuinely disagree) is not forced: flag it on its decision as
`**Agents disagree:**`, omit `**Pick:**`, and log it. The human answers it in
the human review.
