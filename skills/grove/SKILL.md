---
name: grove
description: Start, message and read other Grove tabs with the `grove` command. Use whenever the human asks for another session, tab, agent or helper ("new session", "in the same space", "spin up a claude/copilot", "in a worktree", "run this in parallel", "have another agent do X", "use grove to ...") or wants to list spaces and tabs, send a tab a message, read its screen, wait for it, focus or kill it.
license: MIT
---

# grove

`grove` talks to the running Grove app (the spaces-and-tabs window). Inside a
Grove tab it is on `PATH` when the app's "grove command" install has been
run, otherwise run `bin/grove` from the Grove repo. `GROVE_TAB` names your own
tab. If the app's core is not reachable, a command exits 3.

Vocabulary: a **space** is a folder; a **tab** is one terminal session in a
space, optionally running an agent. A worktree space nests under its main
checkout's space.

A `<ref>` names a tab: its full id, a unique id prefix of at least 4
characters, or its exact label. An unknown or ambiguous ref is an error
(exit 1). `--space REF` names a space: its id, a unique id prefix of at least
4 characters, or the heading `grove ls` prints for it (its path, or `path#2`
for a second space on one folder).

## What the human says, what you run

Defaults inside a Grove tab: the new tab goes in **your own space** and runs
**your own agent kind**. Say less, not more.

| The human says | You run |
|---|---|
| "new session / another tab to do X" | `grove new --prompt "X" --label <name>` |
| "same space" | the default; add `--here` only to be explicit |
| "a copilot / claude / opencode for X" | `grove new copilot --prompt "X" --label <name>` |
| "in a worktree" / "in parallel, separate checkout" | `grove new --worktree <branch> --prompt "X" --label <branch>` |
| "branch it off main/<ref>" | add `--base <ref>` (new branch only; default is this space's HEAD) |
| "in the other space <path>" | `grove new --space <path> --prompt "X"` |
| "and tell me what it finds" / "report back" | add `--wait`, then `grove read <label> --lines 60` |
| "ask that tab ..." | `grove send <label> "..."` (add `--wait` to hear back) |

Fire and forget is the default: start the tab, tell the human its label, and
stop. Use `--wait` only when they ask for the result. Do not `kill` the tab
when it finishes; the human may want to read or resume it.

A shell tab has no agent kind to copy, so from one name the kind. Do not run
`grove ls` first to find your space; the default already uses it.

## Commands

```
grove ls [--json]                    spaces, each with its tabs (id, kind, state, label, alive)
grove space add [path]               add a folder as a space (default: the caller folder)
grove space ls                       same listing as ls
grove new [terminal|claude|opencode|copilot] [--here | --cwd DIR | --space REF]
          [--worktree BRANCH [--base REF]] [--label L]
          [--prompt TEXT|-] [--wait] [--timeout S] [--json]
                                     start a tab; prints its id. In a tab: your space and
                                     kind by default
grove send <ref> <TEXT|-> [--no-enter] [--wait] [--timeout S]
                                     paste text into a tab and submit it
grove wait <ref> [--timeout S]       block until the agent stops working
grove read <ref> [--lines N]         the last N lines of the tab's screen (default 100)
grove focus <ref>                    show the tab in the app and raise the window
grove kill <ref>                     end the tab and remove it
grove config path                    print the config folder
grove skill                          install the grove-config skill (how to change Grove's settings)
grove integration install claude | uninstall <claude|copilot>
                                     add or remove the hooks that report hand-typed agents
```

`-` as the text or prompt reads stdin. Inside a Grove tab `new` targets your own
space; outside one, `--cwd` defaults to the folder you run from and must already
be a space: a folder that is not one fails with `not a space`, and
`grove space add <path>` fixes that. `--here`, `--cwd` and `--space` cannot be
combined; `--here` fails outside a Grove tab.

`--worktree BRANCH` opens BRANCH as a worktree space of the target's repo and
starts the tab in it. A branch that is already a space is reused (stderr says
`reusing <path>`); one that exists but is not a space is checked out; a new one
starts at `--base` (any git ref), else the target's HEAD. `--base` with a branch
that exists is an error. It cannot be combined with `--cwd`. Two spaces may share a folder; `--cwd` uses the first.
`--wait` needs an agent: a shell tab has no state to wait on.

A tab's `state` in `ls` is `working`, `needs-you`, `finished`, `idle`,
`unknown`, or `-` for a shell. `unknown` means the agent has reported nothing
(too old, or it never sends status) or the tab is gone.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | done; for `wait` and `--wait`, the turn finished |
| 1 | error, one line on stderr |
| 2 | usage error |
| 3 | the core or holder is not reachable |
| 5 | the tab is gone (it ended) |
| 124 | timed out (default 600 s) |

## Patterns

Hand work to a helper and wait for it:

```
id=$(grove new --space ~/git/other --label helper --prompt "run the tests and summarise failures" --wait)
code=$?
grove read "$id" --lines 60
```

`new` prints the id first and then waits; with `--json` the output is a
single JSON object, so `$id` above is only the id without `--json`.

Ask a running tab something:

```
grove send helper "which files did you change?" --wait && grove read helper --lines 40
```

## Orchestrating

- One step per tab. Start the next only after reading the last one's result,
  and never start a step the human has not approved when the work has a gate.
- Give each tab a self-contained `--prompt`: it does not see your context.
- Name each with `--label`: two to four lowercase words, at most about 28
  characters, no timestamps, with what tells siblings apart first.
- Do small read-only fan-out inside your own session with subagents. A tab is
  for work the human may want to watch, review or resume.
- To keep two tabs from touching the same files, give each its own checkout:
  `grove new --worktree <branch>`. Name the branch from the task in short
  kebab-case, no prefix or date, and use it as the `--label` too, unless the
  human named one. Worktrees stay after `kill`: never delete a worktree space or
  checkout yourself; that is the human's call.

## Notes

- `wait` follows Claude, OpenCode and Copilot tabs. A shell tab fails with
  `a shell, it has no agent state to wait on`; use `read` to look at it.
- A tab that needs a permission or a question keeps `wait` waiting: that is for
  the human. Never `send` into a tab that is waiting on a prompt, and never kill
  it to get past one.
- An agent that reports no state (`unknown`) also keeps `wait` waiting until
  the timeout; `read` it to see what it is doing.
- `--wait` first gives the turn up to 30 s to start, then waits for it to end.
- `send` types into the tab even if the human is looking at it, and restarts a
  gone agent tab first (a gone shell tab is an error).
- `kill` ends any tab, including your own. Kill only tabs you started, unless
  asked.
- A new Claude tab in a never-trusted folder shows its trust dialog first; the
  prompt waits behind it.
