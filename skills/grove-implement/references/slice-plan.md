# Planning one slice

How `grove-implement` writes the plan for the next slice into `05-plan.md`,
just before executing it. Hand this file to a subagent if one drafts the
plan. The rules are the same whoever drafts it; the implementing session
always does the design check itself.

## Inputs

- The slice's entry in `04-structure.md` (outcome, files, signatures,
  verification, dependencies). `small` flow: the `## Goal` and
  `## Out of scope` of `01-questions.md` instead — there is no structure.
- `03-design.md` (`small` flow: none).
- `06-implementation.md` — deviations logged in earlier slices.
- **The code as it is now**, after the previous slice's commit. Plan against
  what is actually there, not what the structure assumed.
- `grove.config.json` `commands.*`.

## The section

Append one section to `05-plan.md` (create the file with the contract's
frontmatter, `phase: plan`, if it doesn't exist):

```markdown
## Slice N — <outcome from the structure>

- [ ] Write failing test `<path>` covering <behaviour>   (if test-first applies)
- [ ] <exact change in exact file path>
- [ ] ...
- [ ] Run `<verification command, verbatim from the structure / commands.*>`
```

- Exact file paths; tests first where the structure implies test-first;
  verification commands verbatim from the structure entry and
  `commands.test`/`typecheck`/`lint`/`build`.
- **Mechanical steps only.** No "decide whether to…" or "choose…" may
  survive: that's a decision deferred into the plan.
- **`small` flow:** a minimal plan — usually 2–6 checkboxes — but still with
  exact paths and a verification command. Slices come from the goal: one
  slice unless the change splits naturally into independently verifiable
  steps.

## Checks before writing (the implementing session runs these)

1. **Zero-context test.** Re-read the section as a fresh agent with only
   `05-plan.md` and `03-design.md` open (`small` flow: `01-questions.md`) —
   no chat, no structure doc. Any step needing knowledge not in those files
   gets that knowledge inline.
2. **No new decisions.** Compare the section against `03-design.md`. If
   planning reveals a decision the design didn't make, or a contradiction
   with it: **stop**. Add it to `03-design.md`'s `## Open questions`, set
   `03-design.md` `status: draft`, tell the human exactly what's missing and
   why, and do not plan or implement around it — the next step is
   `grove-design <slug>` in revise mode. In `small` flow (no design): stop
   and **propose switching to `standard`**, logging the human's choice in
   `feature.md`'s `## Flow log`. A subagent's draft that makes a decision is
   rejected, not edited into shape.
3. **Self-checks:** no `TODO`/`TBD`, a verification command is present, no
   content under `## Open questions`.

When all pass: write the section, update `based_on`
(`03-design.md@<v>`, `04-structure.md@<v>`; `small`: `01-questions.md@<v>`)
and `updated`, set `status: approved`, and keep a one-line body note at the
top: "Self-approved per slice by grove-implement: mechanical checks passed,
not human-reviewed."

## A slice that already has a section (resume, or a legacy full plan)

- **Partly ticked** (some `[x]`): resume at the first `[ ]` as written. Only
  re-plan the remaining steps if they plainly no longer match the code, and
  log that in `06-implementation.md`.
- **Unstarted, written ahead** (a legacy `05-plan.md` planned in full by the
  old plan phase): run a **drift check** against the current code — do the
  paths exist (or are they meant to be created), do signatures and names
  match, does anything logged in `06-implementation.md` for earlier slices
  change it? If it still holds, execute it as-is. If it drifted, re-plan the
  section in place with the rules above and log "re-planned: <why>" under
  the slice in `06-implementation.md`.
