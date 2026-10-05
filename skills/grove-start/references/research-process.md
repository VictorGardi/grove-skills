# Grove research process

Single source of truth for producing `02-research.md`. Copied into
`references/research-process.md` of `grove-research` and `grove-start` by
`scripts/sync-shared.sh` (see `shared/MANIFEST`). Do not edit the copies.

## Blindness rule

Research must not be biased toward the ticket's assumed solution. Whoever
gathers facts or writes `02-research.md` must never see `00-ticket.md`, the
`## Goal`, `## Out of scope` or `## Product questions for the human` sections
of `01-questions.md`, `feature.md`'s body, or the tracker.

- **Fact-gathering subagents** get only: their cluster's literal question
  text, `CONTEXT.md`, and the instructions in step 2. Child mode adds the
  epic's research for their area (that's epic research, not the ticket).
- **The writer of `02-research.md`** must be equally blind:
  - In `grove-research` the session itself is blind (it never reads the
    ticket or goal), so it writes the synthesis.
  - In `grove-start` the session has read the ticket and run the product
    questions, so it **must not write the synthesis itself**: hand the
    question text, the cluster answers, and step 3's headings to one
    **synthesis subagent**, which writes the file. The session then only
    runs step 4's checks and renders.
- If any subagent's output references the ticket or a proposed solution,
  discard it and re-run with just the question text.

## Steps

1. **Inputs.** The `## Research questions` section of `01-questions.md`,
   `CONTEXT.md`, and the ADRs in `adrDir` relevant to the area. Child mode
   (`feature.md` has `parent`): also read the epic's `02-research.md` in full
   first — its `## Summary` and the sections for each cluster's area are what
   subagents get as "already established".
2. **Cluster and dispatch.** Group the questions into 2–5 clusters by area of
   the system. Run one subagent per cluster with the environment's
   subagent/task tool (fall back to doing clusters sequentially yourself if
   none is available — in `grove-start`, that fallback means the session
   must not have the ticket in mind: say so to the human and suggest running
   `grove-research` in a fresh session instead). Instruct each subagent to:
   - cite `path:line` for every claim
   - write "Could not determine" plus what would resolve it, rather than
     guess
   - describe what exists — never "should", "we could", or proposed designs
   - child mode: answer only the gap the epic's research left, and re-check
     (not re-ask) any fact the child relies on if the repo has moved since
     the epic's `repo_heads`
3. **Synthesise** the answers into `02-research.md` (≤ ~300 lines), headings
   in order:
   - `## Summary` (≤ 10 lines)
   - child mode only: `## Inherited from epic` — the epic research sections
     this child relies on, by heading
   - `## Answers` — one subsection per research question (child mode: delta
     questions only), every claim cited `path:line`
   - `## Current architecture` — a Mermaid diagram of the components, data
     flow, and boundaries involved
   - `## Existing patterns to reuse` — how similar problems are already
     solved in this codebase
   - `## Constraints & invariants`
   - `## Test landscape` — what covers this area today and how to run it
   - `## Relevant ADRs`
   - `## Unknowns`
   - `## Spikes` (optional — only once `grove-spike` has added a finding;
     never written by this process)
   - `## Open questions`
4. **Check and set frontmatter.** Zero recommendations anywhere: rewrite any
   sentence with "should", "we could", or similar as a fact, or remove it.
   Set `phase: research`, `based_on: ["01-questions.md@<version read>"]`
   (child mode: also `"parent:02-research.md@<epic version read>"`), and
   `repo_heads` (the VCS ref(s) read, e.g. `git rev-parse HEAD`). Revise
   mode: bump `version`.
5. **Render**: invoke `grove-render` on `02-research.md` to produce
   `02-research.html`.

## Stop conditions

- Stop and warn if `01-questions.md`'s version is newer than the `based_on`
  of an existing `02-research.md` (staleness, `references/gates.md`).
- Child mode: if the epic's `02-research.md` has moved past this child's
  recorded `parent:02-research.md@`, warn and offer to re-read first.
- Never fabricate: an unanswerable question goes to `## Unknowns`.
