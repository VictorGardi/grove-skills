---
name: grove-spike
description: A time-boxed, throwaway prototype in a scratch worktree that answers one concrete question, with findings written into a feature's research (or an epic's) and the code always deleted afterward. Load when the human wants to spike, prototype, or de-risk an unknown before committing to a design decision.
license: MIT
---

# grove-spike

## Purpose

Answer one concrete question that research alone can't settle — "does this
library actually support X", "is this approach even feasible" — by writing
throwaway code in an isolated worktree, then capture the finding as research
and delete the code. A spike never ships; its *answer* is the deliverable.

## When to use / not use

- Use when `grove-research` or `grove-design` (epic or feature) hits a
  question that needs code run to answer, not just code read.
- Do not use for anything meant to survive — that's a slice, built via
  `grove-implement` once a decision is made.
- Do not use to make a decision for the human — a spike produces evidence
  for the grilling loop in `grove-design`, not a decision itself.

## Inputs

- The feature slug (or epic slug) whose research the finding belongs in.
- One concrete question the spike must answer, agreed with the human before
  any code is written.
- A time box, agreed with the human (default: 30 minutes of work).

## Preconditions & gates

None. Can run at any point research or design needs it, including mid-grill.

## Process

1. **Confirm the question and time box** with the human before touching any
   code. If the question is vague ("see if retries could work better"),
   sharpen it into something answerable yes/no or with a concrete number
   first — don't start a spike on a vague question.
2. **Create a scratch worktree** on branch `spike/<slug>-<name>` (a short
   kebab name for the question). Do all prototyping there — never on the
   feature's own branch or main.
3. **Work the time box.** Write the minimum code needed to answer the
   question. Skip tests, error handling, polish — this code is deleted
   regardless of outcome.
4. **Write the finding** into the target artifact's `## Spikes` section
   (add the heading if missing, just before `## Open questions`) in
   `02-research.md` (or, if research doesn't exist yet, tell the human and
   hold the finding until it does):
   - **Question** — what was being tested
   - **Answer** — what happened, stated as fact
   - **Evidence** — command output, error text, numbers; whatever was
     actually observed
   - **Recommendation** — what this implies for the decision at hand (this
     is the one place a spike may say "should", since it's explicitly
     feeding a design decision, not posing as neutral research)
5. **Offer to delete the worktree and branch.** On confirmation, remove
   both. **Never merge spike code** — if the human wants to keep something
   from it, tell them to reimplement it properly through the normal
   structure/plan/implement sequence instead.

## Output

An updated `## Spikes` section in the target `02-research.md`, bumping its
`version`. No surviving code or branch once cleanup is confirmed.

## Stop conditions

- Stop before writing any code if the question isn't concrete and answerable,
  or the human hasn't agreed to a time box.
- Stop at the time box even if the question isn't fully answered — write
  "inconclusive within the time box" as the answer rather than running over.

## Rules

- Spike code is never merged, never reviewed as if it were real, and never
  left running after the session — confirm deletion explicitly, don't assume.
- The finding must be written into the artifact before the session ends —
  nothing about a spike's outcome lives only in chat.
- A spike never sets `status: approved` on anything — it only adds evidence
  for a decision the human (via `grove-design`) or `grove-approve` still has
  to make.
