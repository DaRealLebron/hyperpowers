---
name: product-discovery
description: Use for a new product, greenfield effort, or multi-feature scope with no PRD yet — runs discovery and writes the product brief and PRD
---

# Product Discovery

The project altitude's front door. Turn an idea into a durable product brief and PRD that every
later feature reads. Engage only when the work is project-sized (see skill-router); a single
feature uses `brainstorming` instead.

## Discovery to PRD

1. If the repo already exists (brownfield), document the current state briefly first — do not plan
   against assumptions.
2. Run a discovery dialogue, one question at a time (like `brainstorming`). For a shallow or
   high-stakes answer, offer a named method from
   [elicitation-methods.md](elicitation-methods.md).
3. Write `docs/superpowers/product/brief.md` — vision, audience, value, scope.
4. Write `docs/superpowers/product/prd.md` — functional requirements, non-functional requirements,
   epics, success metrics, MVP.

Carry findings forward — never re-elicit. Everything the brief established flows into the PRD by
reference; re-asking what the brief already answered is the documented rework trap. Discovery and
the PRD are one continuous pass, not two from-scratch passes.

## Acceptance criteria

Write each epic's acceptance criteria as Gherkin (Given/When/Then) and **risk-tier them P0–P3**.
These ACs are the source the feature altitude turns into Verification Artifacts, so make them
testable and outcome-shaped (what becomes true), not implementation instructions.

## Do not overwrite hand-maintained docs

If a hand-maintained brief/PRD already exists, detect it and append/cross-link — never clobber it.

## Reuse

Reuse `brainstorming`'s one-question dialogue; the multi-lens panel (`writing-plans` → Adversarial
Plan Review) may review the PRD before architecture begins.
