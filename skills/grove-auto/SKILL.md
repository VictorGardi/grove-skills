---
name: grove-auto
description: Turn a ticket into an approved-ready outcome brief, a short research note, and a decision-and-slice plan through a short outcome-only interview (planning half of the grove auto flow). Load when the human wants to plan a feature for automatic execution, or revise such a plan.
license: MIT
---

# grove-auto

## Purpose

Planning half of the `auto` flow. A `researcher` subagent maps the code, a
`cto` subagent interviews the human about the *outcome* only, and the planner
(you) writes `01-outcome.md`, `02-research.md` and `03-plan.md`. The human
approves the plan unit; `grove-run` then builds it slice by slice.

## When to use / not use

- Use to plan a ticket or idea for automatic execution.
- Use again in **revise mode** if `<artifactRoot>/<slug>/` already exists with
  `03-plan.md`: read the human's feedback, update the files in place, bump
  `version`.
- Do not use to execute the plan — that is `grove-run`.

## Inputs

`<ticket text or ticket path/ID>`, and `grove.config.json` (`artifactRoot`,
`limits`, `commands`). If it is missing, tell the human to run `grove-setup`
and stop.

## Preconditions & gates

None beyond the config. Nothing here is approved by this skill.

## Process

1. **Set up.** Derive the slug per `references/contract.md`, create
   `<artifactRoot>/<slug>/`, write `feature.md` (`flow: auto`, `created`, and a
   `## Flow log` with `- <date>: auto (chosen by running grove-auto)`) and
   `00-ticket.md` with the ticket verbatim.
2. **Research.** Spawn one general-purpose subagent in the `researcher` role: read-only, facts only. It
   returns a short code map of the areas the ticket touches and how to run the
   project's commands (`grove.config.json` `commands`, README). It cannot reach
   the human and never asks. Write the result to `02-research.md` with
   frontmatter `feature`, `phase: research`, `status: draft`, `version: 1`,
   `created`, `updated`, `approved_at:` (empty), `based_on: []`, `forced: []`,
   `repo_heads: [<git rev-parse HEAD>]`, and an empty `## Open questions`.
3. **Interview through a stateless `cto` relay.** First create `01-outcome.md`
   with the frontmatter from step 4, an empty `## Interview log` and an empty
   `## Open questions` (the brief sections come later). Give a fresh general-purpose subagent in the `cto` role
   the ticket, the code map and the `## Interview log` so far. Its prompt
   allows outcome questions only: what the human sees or does, scope,
   non-goals, how they will know it works; never technical choices. It returns
   exactly one of: `NEXT_QUESTION` (background in plain words, 2-4 options each
   with what it does to the outcome, a recommendation) or the finished Outcome
   Brief. The prompt ends "you cannot reach the human; return findings, never
   ask". Ask the human the question verbatim through the question tool, one at
   a time, append question and answer to `## Interview log` in `01-outcome.md`,
   repeat. Soft cap: 8 questions, then the brief.
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
6. **Write `03-plan.md` yourself.** Frontmatter `feature`, `phase: plan`,
   `status: draft`, `version: 1`, `created`, `updated`, `approved_at:` (empty),
   `based_on: [01-outcome.md@<current version>, 02-research.md@<current version>]`,
   `forced: []`. In revise mode bump `version` and `updated` and refresh
   `based_on` to the current versions. Sections:
   - `## Decisions`: each `### D<n>. <title>` with Context, Options (2-3, with
     pros and cons), a line exactly `**Pick:** <option>` (the approve gate greps
     for `Pick:`), Outcome impact. Only real one-way decisions, at most
     `limits.maxOneWayDecisions`. For a trivial ticket write "No one-way
     decisions."
   - `## Slices`: each `### Slice N. <outcome>` with **Outcome**, **Files**,
     **Verification** (a concrete command or observable check). At most
     `limits.maxSlices`. Slice 1 is a thin end-to-end slice.
   - `## Open questions`, empty.
7. **Close.** Report the three paths. Tell the human to run
   `grove-approve <slug> plan` themselves, then `grove-run <slug>`.

## Output

`feature.md`, `00-ticket.md`, `01-outcome.md`, `02-research.md`, `03-plan.md`
in `<artifactRoot>/<slug>/`.

## Stop conditions

- Config missing.
- Stop after step 7; never run `grove-approve` and never start `grove-run`.

## Rules

- Ask the human only through the question tool (`AskUserQuestion` in Claude, the equivalent in other agents), one question at a time, with the background and your recommendation; never as plain chat text. This includes approval prompts (offer *yes* and *not yet* as options).
- Nothing lives only in chat: every answer is written to a file as it arrives.
- Name roles only (`cto`, `researcher`, `planner`); never model names.
- Subagents cannot reach the human; the planner relays every question.
- No `TODO` or `TBD` anywhere in the artifacts; `## Open questions` ends empty.
- Only `grove-approve`, invoked by the human, approves. This skill approves nothing.
