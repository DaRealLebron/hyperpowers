---
name: architecture-design
description: Use after a PRD is approved (or when a real architectural decision is needed) — writes the durable architecture doc and ADRs, then runs the readiness gate
---

# Architecture Design

Turn an approved PRD into a durable architecture the whole project references, then gate
implementation readiness. Project altitude; runs once per product or on reevaluation.

## Artifacts

- `docs/hyperpowers/architecture/architecture.md` — components, interfaces, data model, tech choices.
- `docs/hyperpowers/architecture/adr/NNN-<slug>.md` — one ADR per significant decision: context,
  decision, consequences.

## Implementation-Readiness Gate

Before any feature work starts, gate the PRD + architecture with a verdict: **PASS / CONCERNS / FAIL**.

- Reuse the multi-lens panel — run the same adversarial review the plan stage uses (`writing-plans`
  → Adversarial Plan Review, `plan-document-reviewer-prompt.md`), pointed at the PRD and
  architecture instead of a plan. Do not build a second gate (NS4/NS7).
- PASS → proceed to the feature altitude. CONCERNS/FAIL → revise, or the operator overrides
  explicitly (NS6). The verdict is advisory, never a hard stop.

## Do not overwrite hand-maintained docs

If the repo already has a hand-maintained architecture doc (e.g. `docs/architecture.md`), detect it
and append/cross-link — never clobber it.
