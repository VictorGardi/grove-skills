---
name: grove-epic-status
description: Read-only status table for an epic's children — order, flow, stage, artifact statuses, blocking dependencies, next action, and progress against the appetite. Load when the human asks for an epic's status, progress, or "what's next" across its children.
license: MIT
---

# grove-epic-status

## Purpose

A read-only report on a `kind: epic` feature's children. Never writes
anything — status is never duplicated onto the epic itself (per
`references/contract.md`), so this skill always works it out fresh by
reading each child's own files.

## When to use / not use

- Use whenever the human asks about an epic's progress, which child to work
  on next, or whether anything is stale or blocked.
- Do not use for a normal feature or a single child — there's nothing to
  aggregate; just read that feature's own artifacts.
- Never writes to any artifact. If the human wants to act on what's found
  (e.g. revise a stale child), tell them the right skill to run next instead
  of running it yourself.

## Inputs

- The epic's slug.
- The epic's `feature.md` (`children:`, `appetite`, `created`) and
  `03-design.md` (for `E-D` ids).
- Each child's `feature.md` (`order`, `flow`) and whatever phase artifacts exist for it.

## Preconditions & gates

None — read-only, no gate to satisfy.

## Process

1. Read the epic's `feature.md`. If `kind` isn't `epic`, stop and say so.
2. For each slug in `children:`, read its `feature.md` and whichever phase
   artifacts exist, in order, to determine:
   - its flow (`full` / `standard` / `small`; missing = `full`), and
     whether its `## Flow log` shows a change since creation
   - current stage (backlog / questions / research / design / structure /
     implementation / done). A `05-plan.md` or `06-implementation.md` means
     `implementation` (plan is written per slice inside it); "done" means
     `06-implementation.md`'s final PR description is written. The stages a
     child passes through depend on its flow: `small` skips research,
     design, and structure.
   - each artifact's `status` (`draft`/`approved`/`stale`) present so far
   - blocking dependencies (from the epic's `04-structure.md` entry for this
     child: which other children it depends on, and whether those are done)
3. Flag any child that is `stale` at any artifact, or whose scope references
   an `E-D` id that the epic's current `03-design.md` no longer lists
   unchanged (a sign the epic moved since this child last read it).
4. Compute appetite progress: elapsed time since `feature.md`'s `created`
   date vs. `appetite` — **just elapsed vs. budget, no estimation or
   percent-complete guessing**.
5. Determine the next action: the lowest-`order` child not yet at
   `implementation`, respecting dependencies (don't suggest a child whose
   dependency isn't done yet — name the blocking dependency instead). The
   command depends on the child's stage and flow — e.g. backlog →
   `grove-start <slug>`; `standard` with research done → `grove-design`;
   approved structure → `grove-implement`.
6. Print a table: order, slug, flow, stage, artifact statuses, blocking
   dependencies, next action. Then a short section for flagged
   stale/conflicting children, and the appetite line.

## Output

A status report printed to the session — no files written.

## Stop conditions

- Stop and say so if the slug given isn't `kind: epic`.
- Stop and name the missing file if a child listed in `children:` has no
  `feature.md` (folder likely removed or slug typo) — don't guess its state.

## Rules

- Never write or modify any artifact, including the epic's own `feature.md`.
- Never approve, revise, or otherwise act on a finding — only report it and
  name the skill that would act on it (e.g. "child-2 is stale — re-run
  grove-design child-2 to revise").
- Appetite progress is elapsed-time-vs-budget only, never a completion
  percentage or ETA guess.
