---
name: grove-implement
description: Execute an approved plan one vertical slice at a time, stopping for human review after each slice unless run with --all (phase 6, final phase of the grove workflow). Load when the human wants to implement, continue, or resume a grove feature whose plan is approved.
license: MIT
---

# grove-implement

## Purpose

Phase 6 of grove. Execute `05-plan.md` one slice at a time, test-first where
specified, stopping for human review after each slice.

## When to use / not use

- Use only after `04-structure.md` and `05-plan.md` are both `status: approved`.
- Resume an in-progress feature by re-invoking this skill — it picks up from
  the first unchecked slice automatically.
- Do not use to change the design or structure — a deviation that touches a
  one-way decision stops execution instead (see Rules).

## Inputs

`03-design.md`, `04-structure.md`, `05-plan.md` (all approved),
`grove.config.json` (`commands.*`).

## Preconditions & gates

**Epic gate (always refuses, no `--force`):** if `feature.md` has
`kind: epic`, refuse to run. Tell the human which child to work on next (the
lowest-`order` child not yet past `grove-questions`, per `references/gates.md`).
An epic has no slices of its own to implement — only its children do.

**Hard gate:** both `04-structure.md` and `05-plan.md` must be
`status: approved`. If not, stop and name which one isn't, unless
`--force <reason>` is given — record in `forced`.

If any upstream artifact's version is newer than what's recorded in
`05-plan.md`'s `based_on`, stop and warn before touching code — the plan may
now be stale.

## Process

1. Resume from the first unchecked slice checkbox in `05-plan.md`.
2. Work test-first where the plan says so. Run the verification commands
   exactly as written in the plan. Tick checkboxes as steps complete.
3. Commit once per slice: `<slug>: slice N — <outcome>`.
4. **Stop after each slice** and report: what changed, files touched, how the
   human can verify by hand, and any deviations logged this slice. Continue
   only when the human says so, or when invoked with `--all` (in which case,
   keep going slice by slice but still log everything per slice).
5. **Deviations.** Small deviations (e.g. a slightly different variable name,
   an extra helper the plan didn't spell out) get logged in
   `06-implementation.md` under the slice. Anything that touches a one-way
   decision in `03-design.md` means: stop, do not implement it, propose a
   design revision to the human instead, and leave the approved design
   untouched until they act on it.
6. **After the last slice:** run every configured check
   (`commands.test/typecheck/lint/build`), write a PR description (summary of
   the design, the slices, how to verify) into `06-implementation.md`, and
   post a Linear comment if `tracker.postComments` is true.

## Output

Code changes, one commit per slice, and `06-implementation.md` tracking
progress, deviations, and (at the end) the PR description.

## Stop conditions

- Stop after every slice by default; only `--all` chains slices automatically,
  and even then, deviations and reports are still written per slice.
- Stop completely, without writing code, the moment a deviation would touch a
  one-way decision — never silently edit an approved design to make
  implementation easier.

## Rules

- Never silently edit `03-design.md` or `04-structure.md` from this skill.
- Every decision and deviation made during implementation goes into
  `06-implementation.md` before the session ends — nothing stays only in chat.
- End each stop telling the human: what to review (the diff), how to verify,
  and that the next invocation of `grove-implement` will resume automatically
  (same session or a fresh one — this skill works from a cold start by design).
