# grove-render components (template v0)

Each component below is an HTML snippet grove-render inserts into
`<!-- GROVE:CONTENT -->` in `assets/template.html`, plus when to use it. The
renderer only uses a component when the markdown heading/shape in
`shared/contract.md` calls for it — never invent content.

## Mermaid diagram

Use for: `## Current architecture`, any fenced ` ```mermaid ` block.

```html
<div class="diagram-block">
  <pre class="mermaid">graph TD; A-->B;</pre>
  <details class="diagram-fallback">
    <summary>Diagram source</summary>
    <pre><code><!-- raw mermaid source, escaped --></code></pre>
  </details>
</div>
```

## Current vs. proposed

Use for: a design section presenting both the current and proposed shape of
the same thing (architecture, schema, call path).

```html
<div class="compare">
  <div><h4>Current</h4><!-- content --></div>
  <div><h4>Proposed</h4><!-- content --></div>
</div>
```

## Decision card

Use for: each entry under `## One-way decisions`.

```html
<div class="decision-card">
  <h4><!-- the decision's question --></h4>
  <div class="options">
    <div class="option chosen">
      <h5>Option A (chosen)</h5>
      <p><!-- what changes --></p>
      <p class="meta">Reversibility: ... · Cost: ...</p>
    </div>
    <div class="option">
      <h5>Option B</h5>
      <p><!-- one-line reason rejected --></p>
    </div>
  </div>
  <p><a href="<!-- adr path -->">ADR</a></p>
</div>
```

## File-tree diff

Use for: file-tree diffs in `## Program design` with NEW/MODIFIED/DELETED markers.

```html
<pre class="filetree">
src/
  retry/
    <span class="new">queue.ts <span class="badge new">NEW</span></span>
    <span class="modified">worker.ts <span class="badge modified">MODIFIED</span></span>
  legacy/
    <span class="deleted">retry-timer.ts <span class="badge deleted">DELETED</span></span>
</pre>
```

## Slice timeline

Use for: the ordered slice list in `04-structure.md`.

```html
<div class="timeline">
  <div class="slice">
    <h4>Slice 1 — <!-- outcome --></h4>
    <p><!-- verification step --></p>
  </div>
</div>
```

## Callouts

Use for: risks, open questions, deferred items.

```html
<div class="callout risk">⚠ <!-- risk text --></div>
<div class="callout open-question">? <!-- open question --></div>
<div class="callout deferred">⏸ <!-- deferred item --></div>
```

## Table of contents

Populate `<!-- GROVE:TOC -->` with one `<a href="#slug">Heading</a>` per `##`
heading in document order, using the same slug as the matching heading `id`.
