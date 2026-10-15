---
name: grove-auto
description: Turn a ticket into an approved-ready outcome brief, a short research note, and a decision-and-slice plan through a short outcome-only interview (planning half of the grove auto flow). Load when the human wants to plan a feature for automatic execution, or revise such a plan.
license: MIT
---

# grove-auto

## Purpose

Planning half of the `auto` flow. Two `researcher` subagents map the code, a
`cto` subagent interviews the human about the *outcome* only, the planner
(you) writes `01-outcome.md`, `02-research.md` and `03-plan.md`, a `reviewer`
and a `cto` check it, and the human reviews every decision. The human then
approves the plan unit; `grove-run` builds it slice by slice. Templates,
prompts and the round-log format: `references/plan-process.md`.

## When to use / not use

- Use to plan a ticket or idea for automatic execution.
- Use again in **revise mode** if `<artifactRoot>/<slug>/` already exists with
  `03-plan.md` (step 10).
- Do not use to execute the plan; that is `grove-run`.

## Inputs

`<ticket text or ticket path/ID>` with an optional `--profile P`, and
`grove.config.json` (`artifactRoot`, `limits`, `commands`, `profile`,
`profiles`). If it is missing, tell the human to run `grove-setup`
and stop.

## Preconditions & gates

None beyond the config. Nothing here is approved by this skill.

## Process

Resolve the roles per `references/roles.md` (`--profile P` if given); an unknown profile or an unsupported agent stops the skill. The planner is this session: no relaunch. Pass each role's resolved `model` on every Agent call, omitted when the role inherits.

If `<artifactRoot>/<slug>/03-plan.md` exists, go to step 10.

1. **Set up.** Derive the slug per `references/contract.md`, create
   `<artifactRoot>/<slug>/`, write `feature.md` (`flow: auto`, `created`, and a
   `## Flow log` with `- <date>: auto (chosen by running grove-auto)`) and
   `00-ticket.md` with the ticket verbatim.
2. **Research.** Spawn two general-purpose subagents in the `researcher`
   role in parallel, read-only, facts only, split by the areas the ticket touches (for
   example one per repo or area; if it touches one area, split it by layer).
   Each returns a short code map of its area and how to run the project's
   commands (`grove.config.json` `commands`, README). They cannot reach the
   human and never ask. Merge both into `02-research.md` with frontmatter
   `feature`, `phase: research`, `status: draft`, `version: 1`, `created`,
   `updated`, `approved_at:` (empty), `based_on: []`, `forced: []`,
   `repo_heads: [<git rev-parse HEAD>]`, and an empty `## Open questions`. This
   happens before the first question.
3. **Interview through a stateless `cto` relay.** First create `01-outcome.md`
   with the frontmatter from step 4, an empty `## Interview log` and an empty
   `## Open questions` (the brief sections come later). Give a fresh
   general-purpose subagent in the `cto` role the ticket, the code map and the
   `## Interview log` so far. Its prompt allows outcome questions only: what
   the human sees or does, scope, non-goals, how they will know it works; never
   technical choices. It returns exactly one of: `NEXT_QUESTION` (background in
   plain words, 2-4 options each with what it does to the outcome, a
   recommendation) or the finished Outcome Brief. The prompt ends "you cannot
   reach the human; return findings, never ask". Ask the human the question
   verbatim through the question tool, one at a time, append question and
   answer to `## Interview log` in `01-outcome.md`, repeat. Soft cap: 8
   questions, then the brief.
4. **Outcome Brief** in `01-outcome.md`, headings in order: `## Summary`,
   `## What the human sees and does`, `## Non-goals`,
   `## How I'll know it works`, `## Interview log`, `## Open questions`
   (empty at the end). Frontmatter: `feature`, `phase: outcome`,
   `status: draft`, `version: 1`, `created`, `updated`, `approved_at:` empty,
   `based_on: []`, `forced: []`. Fill the brief sections in order, keeping
   the log.
5. **Play back.** Tell the human the brief in plain words, then ask a
   question-tool question: confirm or correct. On correct, update the brief
   and play back again. Do not plan before confirmation.
6. **Draft `03-plan.md` as the `planner`.** Use the template in
   `references/plan-process.md`: decisions (at most `limits.maxOneWayDecisions`,
   only real one-way doors), slices (at most `limits.maxSlices`), slice 1 thin
   end-to-end with its `**Thin end-to-end:**` line, a Verification on every
   slice, the deviations and risks sections, empty `## Open questions`.
   Frontmatter `based_on: [01-outcome.md@<version>, 02-research.md@<version>]`.
7. **Reviewer loop.** Up to 3 rounds, prompt and log format in
   `references/plan-process.md`. Each round a fresh general-purpose subagent in
   the `reviewer` role critiques the draft against the brief and returns
   blocking and non-blocking findings. Fix every blocking finding and append
   one compact entry to `## Reviewer round log`. Stop on a round with no
   blocking finding. An item still contested after round 3 is flagged on its
   decision as `**Agents disagree:**` with both sides' options, pros and cons,
   and no `Pick:` until the human answers.
8. **CTO check.** A fresh `cto` subagent checks the plan against the Outcome
   Brief point by point ("How I'll know it works" and the walkthrough) and
   returns ok or blocking per point; outcome only, never technical choices.
   Fix blocking points and log them as `CTO check`.
9. **Human review.** Every question through the question tool, one at a time,
   with background and your recommendation. Record each answer in
   `03-plan.md` as it arrives.
   - **Show.** Print every decision in full (context, options with pros and
     cons and outcome impact, the pick) and the ordered slices.
   - **Disagreements.** Each `Agents disagree` item is its own question with
     both sides' options and pros and cons. Write the answer as
     `**Human pick:**` and set `**Pick:**` to the same choice.
   - **Veto.** Ask which decisions to veto, in pages: each page lists up to
     three decisions plus a "None on this page" option (continue to the next
     page; "None" on the last page ends the loop). Single choice, one veto per
     question. For a vetoed decision re-ask it with its options through the
     question tool, then revise per step 10 (re-run the reviewer on the changed
     decision), bump `version` and `updated`, refresh `based_on`, add the log
     line `Veto: D<n>`, and ask the veto question again. Repeat until no veto.
10. **Revise mode** (`03-plan.md` already exists). Read the human's feedback;
    if none was given, ask through the question tool what to change. Update the
    files in place and bump `version` and `updated`, refreshing `based_on`.
    Re-run the reviewer on the changed parts, and the CTO check if the outcome
    changed. Redo the human review (step 9) for changed decisions only. An edit
    to an approved artifact makes it draft per `references/contract.md`; never
    approve.
11. **Close.** Report the paths. Tell the human to run
    `grove-approve <slug> plan` themselves, then `grove-run <slug>`.

## Output

`feature.md`, `00-ticket.md`, `01-outcome.md`, `02-research.md`, `03-plan.md`
in `<artifactRoot>/<slug>/`.

## Stop conditions

- Config missing.
- Stop after step 11; never run `grove-approve` and never start `grove-run`.

## Rules

- Ask the human only through the question tool (`AskUserQuestion` in Claude, the equivalent in other agents), one question at a time, with the background and your recommendation; never as plain chat text. This includes approval prompts (offer *yes* and *not yet* as options).
- Nothing lives only in chat: every answer is written to a file as it arrives.
- Name roles only (`cto`, `researcher`, `planner`, `reviewer`, `implementer`); never model names. Every `researcher`, `cto` and `reviewer` spawn passes the role's resolved `model` on the Agent call (omit it when the role inherits).
- Subagents cannot reach the human; the planner relays every question. Every subagent prompt ends "you cannot reach the human; return findings, never ask".
- No placeholder markers anywhere in the artifacts; `## Open questions` ends empty.
- Only `grove-approve`, invoked by the human, approves. This skill approves nothing.
