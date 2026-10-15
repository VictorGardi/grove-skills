# grove-run: slice mode (child)

You are a child session started by `grove-run` with `<slug> --slice N --profile P`. You
play the `planner` role in your own session. Your cwd is the run worktree. Follow only
this file. The `04-run.md` layout is in `references/run-template.md`.

## Rules

- Never ask the human, not even through the question tool (`AskUserQuestion`): a question in a child stops the run. If you are unsure, stop, write a short note under `## Slice N` and end your turn uncommitted, after sending the halted report (see Report). Tell every subagent the same.
- Plan the slice yourself, build it through `implementer` subagents, review it through a fresh `reviewer` subagent. Subagents never get the parent id and never run `grove send`.
- Never end your turn while a subagent is outstanding: await every one first.
- One commit per slice. Never end your turn before the commit exists and the report is sent, except when stopping unsure as above.
- Name roles only; never model names. Approve nothing.

## Steps

1. Read `<artifactRoot>/<slug>/03-plan.md`, `01-outcome.md`, and `04-run.md` if
   it exists. The label is on the `Label:` line and the parent id on the `Parent:` line of your prompt.
2. **Slice 1 only:** create `04-run.md` from `references/run-template.md`,
   writing only the frontmatter, the header block and `## Open questions`; the
   later sections (`## Slice N`, `## Final summary`) are added when they are
   written, and placeholder text is never copied:
   profile (the `--profile` value of your prompt, `inherit` if none),
   branch (`git branch --show-current`), plan commit (`git rev-parse HEAD`),
   roles (the `Roles:` line of your prompt is `role=model`; record it as
   `role: model` entries, a role that inherits written `inherit`). Use ONLY
   the `Roles:` line for models; never re-resolve the profile from config. End the file with
   `## Open questions`. If the project has no `node_modules` or similar and a
   documented install command exists (README, AGENTS.md), run it; if you cannot
   tell, continue.
3. Append `## Slice N` (above `## Final summary` and `## Open questions`) with lines
   `Session: <label>`, `Status: in progress`, `Commit: this commit (see git log)`.
4. **Plan just in time.** Read the files the slice touches in the real code, then
   write `### Slice plan`: a `Found in the code:` paragraph, then for each
   `implementer` subagent a checkbox list of concrete steps with file paths, then a
   `Models passed:` line (role: model per subagent role you will use, `inherit` where so).
5. **Build.** Delegate each chunk to an `implementer` subagent through the Agent tool
   (general-purpose subagent type; `model` = the implementer's value on the `Roles:`
   line, omitted when it is `inherit`). Run independent chunks in parallel, on disjoint
   files. Each prompt carries the slice plan chunk, the files, the plan's Decisions
   that apply, and ends with "you cannot reach the human; return findings, never ask".
   Await all. Then run the slice's **Verification** from `03-plan.md` yourself. If it
   fails and you cannot fix it (through another implementer if needed), stop unsure.
6. **Review.** Start a FRESH `reviewer` subagent (Agent tool, general-purpose subagent type, `model` = the reviewer's
   value on the `Roles:` line, omitted when `inherit`). Give it the diff, the slice
   plan, the plan's Decisions and `01-outcome.md`; it returns blocking and non-blocking
   findings and cannot ask the human. Blocking findings get up to 2 fix rounds: an
   `implementer` fixes, you re-run Verification, a fresh `reviewer` re-reviews. If it still
   fails, or a fix would change a plan Decision or the outcome, stop unsure (note
   under the slice section, uncommitted, halted report). Non-blocking findings: apply
   the cheap ones, list the rest under `### Review rounds`.
7. **Log** in the slice section: `### Review rounds` (verdict, blocking count, fix
   rounds), `### Deviations` (anything built differently from the plan, or `none`),
   `### Verification` (what ran, the result, and which models were requested for each
   subagent role used), `### Left for the human` (manual or interactive checks from the
   slice text you could not run, or `none`). Tick the boxes, set `Status: done`.
   **Last slice only** (N is the highest `### Slice N.` heading of `03-plan.md`): also
   write `## Final summary` before `## Open questions`.
8. Commit the source and new files plus `04-run.md` (`## Open questions` last); never commit dependency or build directories (check `git status` first) with
   subject exactly `<slug>: slice N — <outcome>`, where outcome is the text
   after `### Slice N.` in `03-plan.md`.
9. **Report.** Last action, only after the commit exists and no subagent is outstanding:
   `grove send <parent-id> "SLICE <N>: done — <one line what was built>"`, then
   end your turn but stay alive for a fix. If stopping unsure (note written, uncommitted):
   `grove send <parent-id> "SLICE <N>: halted — <one line why>"` after the note,
   then end. Never send before the commit (or the note) exists.

## Fix after review

After your report the parent may send `Fix slice N: <comment>`. Apply it through an
`implementer` subagent (same subagent rules), re-run the slice's Verification, then
AMEND the slice commit: same subject, never a new commit, so the slice stays exactly one
commit. In `04-run.md` add a `### Fix after review` entry under the slice (the comment,
what changed, the Verification re-run); on the last slice keep `## Final summary` current.
If the fix would change a plan Decision or the outcome, or you are unsure, change nothing
and send `grove send <parent-id> "SLICE <N>: halted — <one line why>"`; the reason
says that the slice commit is unchanged and why nothing was changed (the parent treats
this as an answer to the fix, not a failed slice). Otherwise report
`grove send <parent-id> "SLICE <N>: done — fixed: <one line>"` and end your turn.
