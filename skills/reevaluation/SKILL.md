---
name: reevaluation
description: Use for a major change to an existing product, or when feature work reveals the architecture is wrong — re-enters the project altitude without rewriting completed work
---

# Reevaluation

Major changes and architectural surprises re-enter the project altitude here. Triggered by
skill-router (a scope-expanding or architecture-invalidating change) or by a feature-altitude agent
escalating upward.

## Supersede, Don't Rewrite

Completed work is immutable. Never edit the acceptance criteria of finished stories to match a new
direction — that erases history and the audit trail.

- Identify the artifacts and completed work the change affects.
- Mark affected completed items `superseded by <new id>` and create **new delta** epics/stories for
  the change.
- Record why in a new ADR; append a changelog to `prd.md` / `architecture.md` rather than rewriting
  them in place.

## Upward escalation

When feature work (`writing-plans` / `subagent-driven-development`) finds the architecture is wrong,
it escalates here instead of quietly redesigning inside a plan. Reuse the existing "stop and ask"
discipline: state the architectural assumption that broke and what it blocks.
