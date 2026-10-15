# grove-run: slice mode (child)

You are a child session started by `grove-run` with `<slug> --slice N --profile P`. Your
cwd is the run worktree. Follow only this file.

## Rules

- Never ask the human, not even through the question tool (`AskUserQuestion`): a question in a child stops the run. If you are unsure, stop, write a short note under `## Slice N` and end your turn uncommitted, after sending the halted report (see Report).
- Implement the slice yourself; no subagents.
- One commit per slice. Never end your turn before the commit exists and the report is sent, except when stopping unsure as above.
- Name roles only; never model names. Approve nothing.

## Steps

1. Read `<artifactRoot>/<slug>/03-plan.md`, `01-outcome.md`, and `04-run.md` if
   it exists. The label is on the `Label:` line and the parent id on the `Parent:` line of your prompt.
2. **Slice 1 only:** create `04-run.md` with frontmatter `feature`,
   `phase: run`, `status: draft`, `version: 1`, `created`, `updated`,
   `approved_at:` empty, `based_on: [03-plan.md@<version>]`, `forced: []`, and a
   header: profile (the `--profile` value of your prompt, `inherit` if none),
   branch (`git branch --show-current`), plan commit (`git rev-parse HEAD`),
   roles (the `Roles:` line of your prompt is `role=model`; record it as
   `role: model` entries, a role that inherits written `inherit`). Use ONLY
   the `Roles:` line for models; never re-resolve the profile from config. End the file with
   `## Open questions`. If the project has no `node_modules` or similar and a
   documented install command exists (README, AGENTS.md), run it; if you cannot
   tell, continue.
3. Append `## Slice N` (above `## Open questions`) with lines
   `Session: <label>`, `Status: in progress`, `Commit: this commit (see git log)`, then `### Slice plan`:
   a checkbox list of concrete steps and files against the real code.
4. Implement the slice. Run the slice's **Verification** from `03-plan.md`.
   Add `### Verification` with what you ran and the result. Tick the boxes and
   set `Status: done`. If the Verification fails and you cannot fix it, stop unsure: write the note and send the halted report; never set `Status: done`.
5. Commit the source and new files plus `04-run.md` (`## Open questions` last); never commit dependency or build directories (check `git status` first) with
   subject exactly `<slug>: slice N — <outcome>`, where outcome is the text
   after `### Slice N.` in `03-plan.md`.
6. **Report.** Last action, only after the commit exists:
   `grove send <parent-id> "SLICE <N>: done — <one line what was built>"`, then
   end your turn. If stopping unsure (note written, uncommitted):
   `grove send <parent-id> "SLICE <N>: halted — <one line why>"` after the note,
   then end. Never send before the commit (or the note) exists.
