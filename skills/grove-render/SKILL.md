---
name: grove-render
description: Generate a self-contained HTML companion for a grove markdown artifact (research, design, or structure), from this repo's template — never hand-edited, always regeneratable. Load when another grove-* skill needs to render an artifact, or when the human asks to re-render one after editing the markdown.
license: MIT
---

# grove-render

## Purpose

Turn a grove markdown artifact into a self-contained, readable HTML companion.
Markdown is canonical; HTML is always derived and disposable.

## When to use / not use

- Use whenever `grove-research`, `grove-design`, or `grove-structure` finishes
  writing its markdown artifact, or when the human asks to re-render one by
  hand (e.g. after editing the markdown directly, or after a template update).
- Not used for `00-ticket.md`, `01-questions.md`, `05-plan.md`, or
  `06-implementation.md` — those don't get HTML companions.

## Inputs

- The markdown artifact to render (path + version).
- `assets/template.html` and `references/components.md` from this skill's own
  directory (not the target repo — render always uses its own bundled
  template).

## Preconditions & gates

None — render has no approval gate; it's pure presentation.

## Process

1. Read the markdown file and note its `version` from frontmatter.
2. Read `assets/template.html` and `references/components.md`.
3. **Map headings to components**, never inventing content:
   - `## Current architecture` / any Mermaid fenced block → Mermaid diagram
     component (raw source kept in a `<details>` fallback).
   - A system design or program design section that names both a current and
     a proposed shape → current-vs-proposed two-column block.
   - `## One-way decisions` → one decision card per decision: question,
     options as cards (pros/cons/reversibility/cost), chosen option
     highlighted. An `E-D<n>` id prefix (epic design) renders as a small tag
     on the card.
   - `## Inherited decisions` (child design) → inherited-decisions block: one
     read-only row per `E-D` id and its chosen option, visually distinct from
     this child's own decision cards (no veto/options UI — it's a summary).
   - `## Appetite` / `## Appetite check` → appetite callout: the budget and,
     if present, the fit verdict and proposed cuts.
   - A file-tree diff with NEW/MODIFIED/DELETED markers → file-tree diff
     component with matching badges.
   - A list of slices with dependencies → slice timeline component.
   - A list of child features with dependencies (epic structure) → child
     dependency graph component (Mermaid graph, one node per child slug,
     edges from the dependencies each child lists).
   - Any `> [!risk]`, `> [!open-question]`, `> [!deferred]` style callouts →
     the matching callout component.
   - Everything else renders as plain prose inside the sidebar-ToC layout.
4. Write `<same-name>.html` next to the markdown (e.g. `03-design.md` →
   `03-design.html`).
5. Add a banner at the top of the rendered page: "Generated from
   `<filename>.md` v`<version>`. Do not edit — re-run grove-render instead."
   If the source's `feature.md` has `kind: epic`, add an "Epic" badge next to
   it. If it has `parent` set, add a link back to the epic's own rendered
   artifact of the same phase, if one exists (e.g. a child's `03-design.html`
   links to the epic's `03-design.html`).
6. If `grove.config.json` has `commitHtml: false` (default), remind whoever
   invoked this that the `.html` is gitignored and local-only.

## Output

`<same-name>.html` next to the source markdown.

## Stop conditions

- Stop and ask if the markdown doesn't follow the expected headings from
  `references/contract.md` closely enough to map confidently — never guess at
  structure the template doesn't recognize.

## Rules

- Never hand-edit a rendered `.html` file, and never invent content not
  present in the markdown — the renderer is a pure mapping.
- Template v0 is deliberately minimal (see `assets/template.html` and
  `references/components.md`); iterate on it only when the human asks.
