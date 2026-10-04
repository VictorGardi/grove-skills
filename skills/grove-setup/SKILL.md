---
name: grove-setup
description: Prepare a repo to use the grove workflow (Questions, Research, Design, Structure, Plan, Implement, Approve, Render). Run once per repo, before any other grove-* skill, to create grove.config.json, docs/adr/, CONTEXT.md, and the AGENTS.md block. Load when the human asks to set up or initialize grove in a repo, or when another grove-* skill reports grove.config.json is missing.
license: MIT
---

# grove-setup

## Purpose

One-time per-repo setup for the grove workflow: a phased, human-gated
Questions → Research → Design → Structure → Plan → Implement sequence with
explicit approval gates. This skill creates the per-repo config and durable
knowledge scaffolding that every other `grove-*` skill depends on.

## When to use / not use

- Use once, the first time grove is used in a repo.
- Use again only to update stack commands or tracker config — it never
  overwrites existing `CONTEXT.md`, ADRs, or artifacts.
- Do not use for anything feature-specific — that starts with `grove-questions`.

## Inputs

- The target repo's existing files (package manifests, CI config, etc.) to
  infer test/lint/build commands.
- Human answers about the tracker and stack commands.

## Preconditions & gates

None. This is the entry point.

## Process

1. **Detect the stack.** Look for manifest files (`package.json`, `pyproject.toml`,
   `Cargo.toml`, `go.mod`, etc.) and CI config (`.github/workflows/*`) to propose
   `commands.test`, `commands.typecheck`, `commands.lint`, `commands.build`.
   Show the proposal and ask the human to confirm or correct it — one message,
   not one question per command.
2. **Ask about the tracker.** Offer `none` or `linear`, and state plainly what
   each means: `none` means every feature's source-of-truth ticket is the
   local `00-ticket.md` snapshot `grove-questions` writes — no external
   tracker is read or written, which is fully supported and the default.
   `linear` additionally reads tickets by ID/URL via the Linear MCP server and
   can post status comments back. If `linear`, check
   whether a Linear MCP server is already available in this agent session. If
   not, tell the human how to add one and continue with `tracker: { type: "linear", ... }`
   anyway — a missing MCP server at setup time is not a blocker, only a
   runtime warning for skills that need it later.
3. **Create files, never overwriting existing ones:**
   - `grove.config.json` at the repo root — see `references/config.schema.json`.
   - `docs/adr/` with `docs/adr/0000-template.md` (see `references/adr-template.md`).
   - `CONTEXT.md` at the repo root, if missing (empty glossary skeleton — see
     `references/context-template.md`).
4. **Update `AGENTS.md`.** Add or replace the content between
   `<!-- grove:start -->` and `<!-- grove:end -->` markers (create the file if
   missing) describing: the workflow phases, artifact locations
   (`<artifactRoot>/<feature-slug>/`), and the gate rules (see
   `references/gates.md`). Never touch content outside the markers.
5. **`CLAUDE.md` pointer.** If `CLAUDE.md` exists and does not already
   reference `AGENTS.md`, append a short pointer line (e.g. `See AGENTS.md for
   the grove workflow.`). Do not create `CLAUDE.md` if it doesn't exist.
6. **`.gitignore`.** If `commitHtml` is `false` (the default), ensure
   `<artifactRoot>/**/*.html` is in `.gitignore`, adding it if absent.

## Output

- `grove.config.json`, `docs/adr/0000-template.md`, `CONTEXT.md` (if new),
  updated `AGENTS.md`, possibly updated `CLAUDE.md` and `.gitignore`.
- A summary of what was created vs. left alone.

## Stop conditions

- Stop and ask if stack detection is ambiguous (e.g. a monorepo with multiple
  test commands) rather than guessing.
- Never overwrite an existing `grove.config.json`, `CONTEXT.md`, or ADR file —
  report that it already exists and move on.

## Rules

- Idempotent: running this twice must not duplicate the `AGENTS.md` block or
  recreate existing files.
- This skill never touches feature artifacts.
