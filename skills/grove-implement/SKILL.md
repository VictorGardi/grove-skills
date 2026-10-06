---
name: grove-implement
description: Plan and execute a grove feature one vertical slice at a time — plan the next slice against the current code, check it against the design, execute, verify, commit — stopping for human review after each slice unless run with --all (final phase of the grove workflow). Load when the human wants to implement, continue, or resume a grove feature.
license: MIT
---

# grove-implement

## Purpose

The final phase of grove. For each slice: write its detailed plan into
`05-plan.md` against the code as it is *now*, check the plan against the
design, execute it test-first where specified, verify, commit, and stop for
human review. Planning just in time means each slice is planned with the
previous slice's real code and deviations in view.

## When to use / not use

- Use once the flow's gate is met (see Preconditions).
- Resume an in-progress feature by re-invoking this skill — in the same
  session or a fresh one. It works from the files alone by design: the next
  slice is found from `05-plan.md`'s checkboxes and `04-structure.md`.
- Do not use to change the design or structure — a new decision, or a
  deviation that touches a one-way decision, stops execution (see Rules).

## Inputs

`feature.md` (`flow`, `kind`), `03-design.md` and `04-structure.md`
(`small` flow: `01-questions.md` instead), `05-plan.md` and
`06-implementation.md` if they exist, `grove.config.json` (`commands.*`,
`tracker`), and the code. Planning rules: `references/slice-plan.md`.

## Preconditions & gates

**Epic gate (always refuses, no `--force`):** if `feature.md` has
`kind: epic`, refuse. Tell the human which child is next (the lowest-`order`
child not yet at `implementation`, per `references/gates.md`) and its next
command (`grove-start <child-slug>` for a backlog child).

**Hard gate, by flow** (missing `flow` = `full`), per `references/gates.md`:

| Flow | Required |
|---|---|
| `full` | `04-structure.md` approved |
| `standard` | `03-design.md` and `04-structure.md` approved |
| `small` | `01-questions.md` approved, with size verdict S |

If not met, stop and name exactly what's missing and the command that
fixes it, unless `--force <reason>` is given — record it in `05-plan.md`'s
`forced`. `05-plan.md` is never a gate: this skill writes it.

**Staleness:** if `03-design.md`, `04-structure.md` (or, `small`,
`01-questions.md`) has a version newer than `05-plan.md`'s `based_on`, or
`05-plan.md` is `status: stale`, stop and warn before touching code. Slices
already done stay done; on the human's OK, unstarted sections written ahead
are drift-checked or re-planned against the new versions.

## Process

Find the **next slice**: the first slice in `04-structure.md` order (`small`
flow: in `05-plan.md`, or slice 1 if there is none) whose `05-plan.md`
section is missing or has an unticked `- [ ]`. Then, for that slice:

1. **Plan it** — per `references/slice-plan.md`, against the current code.
   A subagent may draft the section (give it `references/slice-plan.md`,
   the slice's structure entry, `03-design.md`, `06-implementation.md`, and
   repo access). If the slice already has a section, follow that file's
   resume / drift-check rules instead of re-planning.
2. **Check it against the design** yourself (zero-context test, no new
   decisions). Any new decision: stop and escalate as `slice-plan.md`
   says — to `grove-design` in revise mode, or in `small` flow propose
   switching to `standard`. Do not write or execute the section.
3. **Write it** to `05-plan.md` (self-approved per the contract; update
   `based_on`).
4. **Execute, verify, commit.** Work test-first where the plan says so. Run
   the verification commands exactly as written. Tick checkboxes as steps
   complete. Log small deviations (a different variable name, an extra
   helper) under the slice in `06-implementation.md`. Commit once per slice:
   `<slug>: slice N — <outcome>`.
5. **Stop for review** and report: what changed, files touched, how to
   verify by hand, deviations logged. Continue to the next slice only when
   the human says so (then go back to step 1, in this session), or when
   invoked with `--all` (keep going slice by slice, still planning,
   checking, logging, and committing per slice).

**After the last slice:** run every configured check
(`commands.test/typecheck/lint/build`), write a PR description (summary of
the design, the slices, how to verify) into `06-implementation.md`, and post
a Linear comment if `tracker.postComments` is true. Then tell the human that
the feature is done once they run `grove-approve <slug> implementation`;
never approve it yourself.

## Output

`05-plan.md` growing one slice section at a time, code changes with one
commit per slice, and `06-implementation.md` tracking progress, deviations,
and (at the end) the PR description.

## Stop conditions

- After every slice by default; `--all` chains slices, but a new decision,
  a failed verification you can't fix within the slice's plan, or a
  deviation touching a one-way decision still stops it.
- Stop completely, without writing code, the moment planning or execution
  would need a decision the design didn't make, or would touch a one-way
  decision in `03-design.md` — propose a design revision instead and leave
  the approved design untouched until the human acts.
- `small` flow: any one-way decision at all means stop and propose
  switching to `standard`.

## Rules

- Never silently edit `03-design.md` or `04-structure.md`. The only edit
  this skill makes to the design is the escalation in
  `references/slice-plan.md` (open question + `draft`), and only while
  stopping.
- Subagents only draft slice plans or run checks; executing, the design
  check, and the review stop stay in this session.
- Every decision and deviation goes into `06-implementation.md` before the
  session ends — nothing stays only in chat.
- **Session guidance:** after the human reviews a slice, continuing in the
  same session is fine. Suggest a fresh session when the context is getting
  heavy — roughly after 2–3 slices, or one slice with a large diff or long
  debugging. Resuming is always just `grove-implement <slug>`.
- End each stop telling the human: what to review (the diff), how to
  verify, and that the next slice continues on their go-ahead here or via
  `grove-implement <slug>` in a fresh session.
