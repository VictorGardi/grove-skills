# Handing off to a new grove session

Single source of truth for the end-of-phase *"start the next phase in a new
session?"* offer. It is copied verbatim into `references/next-session.md` of
every phase skill by `scripts/sync-shared.sh` (see `shared/MANIFEST`). Do not
edit the copies — edit this file and re-run the script.

## When this runs

As the last step of a phase skill — `grove-start`, `grove-questions`,
`grove-research`, `grove-design`, `grove-structure`, `grove-implement` — and
only there. It runs **after** the inline approval step (approval state decides
which command comes next, so it must be settled first) and after the close
report, never instead of it.

Only from a Grove session. `grove` is on `PATH` there and `GROVE_SESSION_ID`
names this session. If `grove ls --json` doesn't list `$GROVE_SESSION_ID` —
not in Grove, app not running, a plain terminal or standalone Claude Code
session — skip the offer entirely and end with the close report as usual.
Never guess which agent to spawn.

## The offer

Ask once, in the skill's own framing:

- **A fresh session is wanted** (start → design, design/structure →
  implement, slice → slice): *"Start `grove-<next>` for `<slug>` in a new
  session? (yes / no)"*, with the recommendation in one clause — why the
  context should be dropped (e.g. "research filled this context with noise the
  design conversation shouldn't carry").
- **Continuing here is just as good** (`grove-design` → `grove-structure` in
  `full` flow): *"Continue here, or start `grove-structure` for `<slug>` in a
  new session?"* — continuing is the first option. Spawn only on an explicit
  request for a new session.

Anything that isn't an explicit yes or no for a new session — silence, "looks
good", a question, feedback — means **no handoff**. Finish the close report and
end. This is not a second approval prompt: approval already happened per
`references/approve.md`, and a "yes" here starts a session, it approves
nothing.

Take extra instructions with the yes. The human may add notes ("use the main
agent as orchestrator, subagents for read/write", "focus only on slice 2",
"start from `main`"): append them verbatim after the command-wrapper line in
the prompt, separated by a blank line.

## The command

Spawn the next command the skill already names in its close report, so the
offer and the report can never disagree. That command is approval-aware: where
the next phase is behind a hard gate and the artifact is still `draft`, it is
`grove-approve <slug> <unit>`, and that is what gets spawned.

```sh
agent=<this session's kind, see below>
grove new "$agent" \
  --cwd "<repo root>" \
  --prompt "Load the <skill> skill with the skill tool and follow it exactly. Arguments: <args>" \
  --label "<skill>-<slug>" \
  --link "<slug>"
```

- **`<skill>` / `<args>`**: the wrapper wording from `commands/<skill>.md` —
  the same text the human types, so the new session loads the skill the same
  way whether or not slash commands are wired up in that agent.
- **`--cwd`**: the target repo root, the directory holding
  `grove.config.json` (walk up from the current directory to find it; fall
  back to `git rev-parse --show-toplevel`). Never the artifact folder, never a
  subdirectory of the repo.
- **`--label <skill>-<slug>`**: readable in `grove ls`, and usable directly as
  a ref for `grove focus` / `grove send`. If a live session already carries
  that label (check `grove ls --json`), append `-2`, `-3`, … until it is free.
- **`--link <slug>`**: pins the session to the feature in the app.

### The agent

Same kind as this session, so a handoff never silently moves the human
between agents: run `grove ls --json`, find the entry whose `id` equals
`$GROVE_SESSION_ID`, take its `kind`. There is no config key for this. If the
kind is `terminal` or anything other than `opencode` / `claude`, skip the
offer.

## Spawning

1. Run the command with `--link`. If it exits non-zero — the app fails and
   creates nothing when it doesn't know the feature yet, which is exactly the
   case right after `grove-start` created one (`grove: no-feature: no such
   feature in that project`) — run the same command once more **without**
   `--link`, and say in the report that it started unlinked.
2. On success, print the returned id and label, plus `grove focus <label>`
   and `grove send <label> "<message>"` as the ways to reach it, then end the
   session. Do **not** pass `--wait`: staying attached to the new session's
   output defeats the context break the handoff exists to create.
3. On failure (exit 3, app not running), say so, print the command for the
   human to run by hand, and end the session. Nothing was created.

## Rules

- The offer is a convenience, never a step of the workflow. A "no", or
  anything ambiguous, changes nothing about the artifacts, their status, or
  the close report.
- Never spawn a session without an explicit yes in reply to the offer.
- One handoff per session end, one phase per new session. Never chain two
  phases into one spawned session.
- Nothing about the handoff is written into an artifact: the artifacts already
  hold everything the next session needs.