---
name: grove-run
description: Build an approved auto-flow plan one slice at a time, each slice in its own child Grove session in a shared worktree, with a continue-or-stop gate after every slice (execution half of the grove auto flow). Load when the human wants to run, continue or resume an approved auto plan.
license: MIT
---

# grove-run

## Purpose

Execution half of the `auto` flow. The parent (this skill, run from the main
checkout) starts one child Grove session per slice in a worktree on branch
`run/<slug>-<profile>` (profile `inherit` when none is active), starts it and
ends its turn until it reports, checks the result in git, and asks the human
whether to continue. A profile (`--profile P` or the config's `profile`) sets
the model per role (`references/roles.md`); the child is launched with the
`planner` model. With `--slice N` the skill is the child: load
`references/slice-mode.md` and follow only it.

## When to use / not use

- Use after `grove-approve <slug> plan`. Re-invoking resumes: finished slices
  are found from `04-run.md` in the worktree.
- Do not use to change the plan, and do not run it without the Grove app.

## Inputs

`<slug> [--profile P]` (parent mode) or `<slug> --slice N [--profile P]` (child
mode). `grove.config.json` (`artifactRoot`, `profile`, `profiles`).

## Preconditions & gates

Child mode: skip this section; follow `references/slice-mode.md`.

Parent mode, all required (`--force` is not available here):

- `grove.config.json` exists, is tracked (`git ls-files --error-unmatch grove.config.json`
  ok) and unchanged (`git status --porcelain -- grove.config.json` empty).
- `<artifactRoot>/<slug>/feature.md` has `flow: auto`.
- `01-outcome.md`, `02-research.md`, `03-plan.md` are all `status: approved`;
  otherwise stop and name `grove-approve <slug> plan`.
- `git status --porcelain -- <artifactRoot>/<slug>/ grove.config.json` is empty.
  If not, ask through the question tool whether to commit the folder and config
  together as `<slug>: approved plan`;
  commit on yes, stop on no.
- You are inside a Grove session: `grove ls --json` lists `$GROVE_SESSION_ID`.
  Otherwise stop: grove-run needs the Grove app.

## Process

1. **Resolve.** Resolve the roles per `references/roles.md` (`--profile P`, else
   the config's `profile`, else `inherit`); an unknown profile or an
   unsupported agent stops the skill. Plan commit =
   `git log -1 --format=%H -- <artifactRoot>/<slug>/03-plan.md`. Branch =
   `run/<slug>-<profile>`; on resume `--profile` selects which run's branch
   (without it, the config's active profile, else `inherit`). **Resume** = a worktree
   for that branch already exists (`git worktree list --porcelain`) and has a
   slice not done. Use the `-2`, `-3` suffix only when all slices on the
   existing branch are done, or the branch exists with no worktree. Slices = the
   `### Slice N.` headings in `03-plan.md`. A slice is done when
   `git -C <worktree> show HEAD:<artifactRoot>/<slug>/04-run.md` has
   `## Slice N` with `Status: done` and a non-empty `Commit:` line, confirmed
   by a git log subject `<slug>: slice N — <outcome>` on the branch. Next = the
   first slice not done.
2. **Start the slice.** Label = `<branch>-slice-<n>-a<k>`, where k = 1 plus the
   number of sessions in `grove ls --all --json` whose label starts with
   `<branch>-slice-<n>-a`. Child prompt: "Load the grove-run skill and follow
   it exactly. Arguments: <slug> --slice <N> --profile <P>" plus the lines `Label: <label>`,
   `Parent: <id>` and
   `Roles: cto=<m|inherit> researcher=<m|inherit> planner=<m|inherit> reviewer=<m|inherit> implementer=<m|inherit>`
   (resolved, one token per role, in that order), where id is the current value of `$GROVE_SESSION_ID` (expanded, no angle brackets or variable name in the prompt). Start the child without `--wait`.
   - No worktree yet (slice 1): `grove new claude --child --worktree --branch <branch> --base <plan-commit> --label <label> [--model <planner model>] --prompt "<child prompt>"`
   - Whenever the worktree exists (later slices, and every slice on resume,
     slice 1 included): the same without `--worktree`, `--branch`, `--base`,
     and with `--cwd <worktree>`. In both forms `--model <planner model>` is
     added only when the `planner` role has a model; omit it when it inherits.
   - After the first child creates the worktree, the parent finds its path as
     the `git worktree list --porcelain` entry for `<branch>` and uses it for
     later slices and `git -C <worktree>`.
3. **End the turn.** Final line: "Started slice N in <label>; it will report
   here". No `grove wait` loop. The parent wakes when a message
   `SLICE n: done|halted — <one line>` arrives from the child. `halted`: stop
   as in step 4.
   - Silence: a child that never reports (crash, or a permission prompt, shown
     as waiting in the sidebar) is seen by the human via the label. When the
     human says "continue" here, check `git -C <worktree> log -1 --format=%s`,
     `04-run.md` and `grove ls` first: slice finished but report lost, go to
     step 4; child still waiting, tell the human to answer in that child and
     start nothing; child still working: say so, start nothing, end the turn;
     child gone with no matching commit: stop as in the git check. Never `send` into a child waiting on a prompt; never start a
     later slice without a report or a git-confirmed finish.
4. **Check in git.** `git -C <worktree> log -1 --format=%s` must equal
   `<slug>: slice N — <outcome>` (the message alone is never trusted). If not,
   or if the report was `halted`, stop with "Slice N did not finish: see
   <worktree>/<artifactRoot>/<slug>/04-run.md"; leave the child running; the
   human decides. No retries.
5. **Gate.** Show a short summary: what was built, the commit subject, and
   where to see the diff (the worktree project in the app). Remind the human
   that the run uses their own Claude permission settings. Ask through the
   question tool: continue or stop, after every slice except the last (no question there:
   `grove kill <label>` and go to step 6). On continue, `grove kill <label>`
   the finished child (only now), then go to step 2 for the next slice and end the turn again (step 3). On
   stop, `grove kill <label>`, print where things are (worktree, branch,
   `04-run.md`) and end.
6. **After the last slice.** Print the worktree path and branch, say that
   `04-run.md` lives there, and that approving the run is not available yet.

## Output

Commits on `run/<slug>-<profile>` in the worktree: one per slice, including
`04-run.md`. The parent writes no files.

## Stop conditions

Failed precondition, an unfinished slice, the human choosing stop,
or the last slice done.

## Rules

- Ask the human only through the question tool (`AskUserQuestion` in Claude, the equivalent in other agents), one question at a time, with the background and your recommendation; never as plain chat text. This includes approval prompts (offer *yes* and *not yet* as options).
- The parent asks only the commit-first question and the per-slice continue question.
- The parent never edits files in the worktree.
- Never start a later slice on a broken base.
- Never kill a child before its gate is answered; never `send` into a child waiting on a prompt.
- Name roles only; never model names.
- Only `grove-approve`, invoked by the human, approves. This skill approves nothing.
