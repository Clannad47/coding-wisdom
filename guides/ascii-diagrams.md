# ASCII Diagram Guide

Use this guide when an entry involves architecture, data flow, ownership boundaries, lifecycles, queues, state transitions, or layered responsibility.

## Rule

Diagrams must be self-contained in markdown. Do not depend on Excalidraw links, image hosts, SVG files, or screenshots.

Prefer box-drawing characters over improvised punctuation:

```text
┌─┐ │ └─┘ ├─ ┬ ┴ ┼ ▼ ▶
```

## Good Diagram Targets

Draw a diagram when it helps clarify:

- Producer/consumer boundaries.
- Ownership and responsibility splits.
- Before/after architecture.
- State transitions.
- Data contracts across steps.
- Backpressure or lifecycle flow.

## Quality Bar

A useful diagram should let the reader understand the structure in about 30 seconds.

Keep diagrams small. Split complex architecture into multiple simple diagrams instead of one dense map.

## Example

```text
┌────────────┐     ┌────────────┐     ┌────────────┐
│  Capture   │ --> │  Distill   │ --> │  Reference │
└────────────┘     └────────────┘     └────────────┘
       ^                                      │
       └────────────── reuse signal ─────────┘
```

## Anti-Pattern

```markdown
[Architecture diagram](https://excalidraw.com/#json=...)
```

Links can expire, hide text, require network access, or fail to render in terminal workflows.
