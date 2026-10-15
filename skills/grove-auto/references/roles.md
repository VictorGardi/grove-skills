# Roles and profiles

The auto flow names *roles*, never models. A profile in `grove.config.json`
says which agent and model plays each role.

## Roles

`cto`, `researcher`, `planner`, `reviewer`, `implementer`.

## Config shape

```json
{
  "profile": "default",
  "profiles": {
    "default": {
      "planner": { "agent": "claude", "model": "<alias>" }
    },
    "cheap": {
      "researcher": { "agent": "claude", "model": "<alias>" },
      "reviewer": { "agent": "claude", "model": "<alias>" }
    }
  }
}
```

Both keys are optional. A profile lists only the roles it wants to set.
`model` is a model alias, passed unchanged; this file and the skills never
name one.

## Resolving the roles

Do this once, before the first subagent or child session is started.

1. Active profile = the `--profile X` argument, else the config `profile`,
   else none.
2. No active profile: the profile name is `inherit` and every role inherits.
3. An active profile (from `--profile` or config `profile`) that is not in
   `profiles`, including when there is no `profiles` key: stop and tell the
   human which profiles exist (list the names, or say there are none).
4. A profile may not be called `inherit`, since that name is reserved: stop
   with a message saying so.
5. For each of the five roles: if the active profile has no entry for it, or
   the entry has no `model`, the role inherits. There is no fallback to
   another profile.
6. A role entry whose `agent` is not `claude`: stop with
   `agent <x> is not supported yet`.
7. Otherwise the role's model is its `model` value, unchanged.

**Inherit** means pass no model: the agent runs with the model of the session
that starts it.

## Passing a resolved role

- **Subagent** (`cto`, `researcher`, `reviewer`, `implementer`): pass the
  role's `model` as the Agent tool's `model` parameter; omit the parameter when
  the role inherits.
- **Child session** (the `planner` of a `grove-run` slice): add
  `--model <planner model>` to `grove new claude ...`; omit it when the
  planner inherits.
- **Your own session** (`grove-auto`, the `grove-run` parent) keeps the model
  the human started it with; it never relaunches itself.

The model is requested, not verified: the skill cannot confirm what the
runtime actually used.
