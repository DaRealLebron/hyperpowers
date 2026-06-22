---
name: skill-router
description: Use at the start of any build task to route work to the right altitude — trivial, feature, or project — by signal, not by habit
---

# Skill Router

Pick the altitude that fits the work, then enter the matching skill. This is the scale-adaptive
front door of the bundle: the heavy project altitude engages only when the work earns it (NS2).

## Scale-Adaptive Routing

Route by signals, not by habit. Read the work, score the signals, and enter at the lowest altitude
that fits:

- **Trivial** — ≤ ~3 files, mechanical, no design decision (rename, copy tweak, config, codemod).
  → Skip both altitudes. Use the shell-first lane (`writing-plans` → Task Right-Sizing), or just do it.
- **Single feature** — one behavior, architecture already known.
  → Feature altitude: `brainstorming` (only if the design is non-obvious) → `writing-plans` →
    `subagent-driven-development` → review.
- **New product / greenfield / cross-cutting / a new-or-changed architectural decision.**
  → Project altitude: `product-discovery` → `architecture-design` (+ readiness gate) → then, per
    epic, drop to the feature altitude.
- **Major change to an existing product** (architecture-invalidating, scope-expanding).
  → `reevaluation`, then the project altitude.

## Signals

- File count / blast radius — more than a few files → not trivial.
- "Does this introduce or change an architectural decision?" — yes → project altitude.
- Greenfield vs. brownfield — a multi-feature effort with no PRD/architecture → project altitude.
- Cross-feature ripple — a change other features depend on → project altitude.

When signals disagree, prefer the higher altitude only if a wrong call would cost rework the
cheap-but-thorough pass would have caught (NS2). Otherwise take the lower altitude and let the
feature pipeline escalate upward if it hits an architectural surprise.

## Project artifacts are read, not re-derived

Once the project altitude has produced `docs/hyperpowers/product/prd.md` and
`docs/hyperpowers/architecture/architecture.md`, the feature altitude **reads** them — it never
re-runs discovery or re-authors product-level content for a feature an epic already covers.
