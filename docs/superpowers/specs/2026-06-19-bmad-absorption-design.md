# BMAD Absorption — Unified Planning OS Design

**Date:** 2026-06-19
**Status:** Approved (brainstorming complete; ready for writing-plans)
**Fork:** `DaRealLebron/superpowers` (fork of `obra/superpowers`)

## Context

The operator wanted BMAD to handle new-project discovery, PRDs, architecture, and major
reevaluations while Superpowers handled day-to-day planning, implementation, testing, and
review — and asked for a "skill router" so agents know which skill to use when, what signals
trigger it, what artifact it reads/writes, and how skills hand off without duplicating work.

Two earlier framings were explored and dropped during brainstorming:

1. A **runtime-agnostic handoff contract** (router between two tools).
2. A **unified state machine** with a shared `project-state.yml` both tools read/write.

Both were superseded by a cleaner decision: **do not connect two systems — absorb BMAD's
effective parts into the fork as native skills.** If there is only one system there is no
second tool to keep honest, no cross-tool ledger, and no drift. "Feels like one cohesive
operating system" is best served by literally being one bundle.

This design was grounded in read-only research of the real tool (not training memory). Key
findings that shaped scope:

- BMAD's current line is **v6.8** (May 2026), installed via `npx bmad-method install`, running
  as `/bmad-*` skills inside Claude Code. Four phases: Analysis → Planning → Solutioning →
  Implementation.
- **Every practitioner source names solo developers as BMAD's single worst fit** ("12+ personas
  are overhead for solo devs," full method ~6 days vs 1–2 for competitors, ~$800–2000/mo,
  "overkill for anything under three files"). This is decisive: **take the signal, hard-reject
  the ceremony.**
- The fork is the *better* home because it already does several things BMAD is criticized for
  getting wrong (it forbids review-issue quotas; it avoids persona sprawl; it is proportional).

## Goals

1. Give the fork the **project-altitude** layer it lacks — discovery → product brief → PRD →
   durable architecture document → implementation-readiness gate — as native skills.
2. Add a **scale-adaptive router** so the heavy upper altitude only engages when the work earns
   it; trivial work still drops straight to the existing shell-first lane.
3. Define a **consumption contract** so the existing feature-altitude pipeline reads the project
   artifacts (epics, acceptance criteria, architecture) instead of re-deriving them.
4. Add a **reevaluation / course-correct** flow for major changes that supersedes completed work
   rather than rewriting it.
5. Graft the **advanced-elicitation menu** into discovery and brainstorming.
6. Fold in **Finding A** (oracle-strengthening test guidance) as a rider, reinforced by BMAD's
   Test-Architect discipline (determinism, isolation, explicit assertions, risk-tiered ACs,
   AC→test traceability).
7. Guard every new behavior with the fork's deterministic `grep -qF` structural lint.

## Non-Goals — what we deliberately reject

Disqualified by the solo-operator constraint and the fork's existing strengths, not scored:

- **Personas** (Mary/John/Winston/…) — the fork's skills already cover the roles; persona sprawl
  is BMAD's loudest solo-operator complaint.
- **Document sharding** — BMAD itself deprecates it; a context-window workaround, not value.
- **Context-rich self-contained story files as a new mechanic** — `writing-plans` already embeds
  full code/context per task.
- **"Party Mode" multi-perspective debate** — already covered by the multi-lens adversarial
  review panel (customization #7).
- **Forced "3–10 issues per review" quota** — an anti-pattern the fork already forbids
  (no pre-judging severity, no telling a reviewer what not to flag).
- **Sprint machinery** (`sprint-status.yaml`, agile ceremony) — single-operator, no sprints.
- **The TEA enterprise test module wholesale** — only its assertion-strength and risk-tiering
  ideas are extracted, into Finding A.
- **Behavioral verification of the new skills** — the lint proves the skill *text* is present, not
  that an agent obeys it. A `testing-skills-with-subagents` drill is recorded as a known
  follow-up, not built this round (consistent with the prior round's deferral).
- **Any live BMAD interop** — this design absorbs, it does not integrate. BMAD need not be
  installed.

## North Star Alignment

- **NS2 (proportional effort):** the scale-adaptive router is the centerpiece; the upper altitude
  engages only when work earns it, directly inoculating against BMAD's #1 documented failure.
- **NS3 (observability):** durable brief/PRD/architecture/ADR artifacts make project reasoning
  legible and persistent ("documentation is the contract, not the latest chat message").
- **NS4 (graduated gates feed one model):** the implementation-readiness gate reuses the existing
  adversarial review rather than creating a parallel pass/fail system.
- **NS5 (model diversity):** unchanged — the existing best-effort Codex/Gemini reviewers carry
  into the readiness gate.
- **NS6 (override):** every gate (readiness, reevaluation) is advisory with an explicit operator
  override.
- **NS7 (reuse before new infra):** the readiness gate, the review panel, the brainstorming
  dialogue, and the escalation path are all reused, not reinvented. New surface is skill text +
  one shared reference file + lint markers; no standing infrastructure.
- **NS8 (testable without live LLM):** every new behavior is covered by a deterministic, no-LLM
  grep marker.

## Architecture — two altitudes, one bundle

```
                    ┌──── skill-router (scale-adaptive) ────┐
   work arrives ───►│   signals → which altitude engages?    │
                    └──────────────────┬─────────────────────┘
       ┌───────────────────────────────┼────────────────────────────────┐
  trivial                         single feature,                  new product / greenfield
  (≤~3 files, mechanical,         architecture known               / cross-cutting / major
   no design decision)                                               architecture change
       │                               │                                  │
  shell-first lane (#11)        FEATURE ALTITUDE (existing)        PROJECT ALTITUDE (new)
  skip both altitudes           brainstorming? → writing-plans     discovery → PRD → architecture
                                → subagent-driven → review          → implementation-readiness gate
                                       ▲                            → reevaluation re-enters here
                                       │                                  │
                                       └──── reads PRD + architecture ◄────┘
                                            (never re-derives them = anti-duplication seam)
```

- **Project altitude** is the migrated BMAD layer. It runs once per product (greenfield) or on
  major reevaluation, then its artifacts persist and are referenced by every feature.
- **Feature altitude** is the existing pipeline, unchanged. It consumes the project artifacts.
- **The router** is a decision rule over signals (file count, "does this introduce or change an
  architectural decision?", greenfield vs. brownfield, cross-feature ripple) — not a state file
  anyone must keep honest. It lives in a new `skill-router` skill, referenced from
  `using-hyperpowers` so every session sees it.

## The new skills

Artifact homes sit under the existing `docs/superpowers/` tree: `product/` and `architecture/`.

### `skill-router`

The scale-adaptive connective tissue. Documents the three routing outcomes (trivial → shell-first
lane; single feature → feature altitude; new product / major architecture change → project
altitude) and the deterministic signals that select among them. Referenced from
`using-hyperpowers`.

### `product-discovery` — discovery → brief → PRD

- **Trigger (from router):** new product / greenfield, or a body of work spanning multiple
  features with no PRD yet.
- **Reads:** the operator's idea; existing repo state first if brownfield (a lightweight
  "document the current system before planning" pass).
- **Writes:** `docs/superpowers/product/brief.md` (vision, audience, value, scope), then
  `docs/superpowers/product/prd.md` (functional requirements, non-functional requirements, epics,
  success metrics, MVP). Acceptance criteria are **risk-tiered (P0–P3) Gherkin** — strong,
  testable ACs at the source (Finding A starts here).
- **Core mechanic:** a scale-adaptive discovery dialogue plus the advanced-elicitation menu, and a
  fix for BMAD's documented brainstorm→PRD rework bug: **discovery findings flow straight into the
  PRD; re-eliciting what the brief already captured is forbidden** (carry forward, never
  re-derive).
- **Reuses:** `brainstorming`'s one-question-at-a-time dialogue; the multi-lens panel may review
  the PRD.

### `architecture-design` — PRD → durable architecture + readiness gate

- **Trigger:** PRD approved, or a real architectural decision is needed.
- **Reads:** `prd.md`; the existing codebase/architecture.
- **Writes:** `docs/superpowers/architecture/architecture.md` (components, interfaces, data model,
  tech choices) + `docs/superpowers/architecture/adr/NNN-<slug>.md` (one ADR per significant
  decision: context / decision / consequences) + a recorded **implementation-readiness verdict
  (PASS / CONCERNS / FAIL)**.
- **Core mechanic:** the readiness gate is the existing **adversarial multi-lens review panel
  (#7) repointed at PRD + architecture** — not a new gate. CONCERNS/FAIL loops or the operator
  overrides (NS6).

### `reevaluation` — major course-correct (the fixed version)

- **Trigger (from router or upward escalation):** a major change to an existing product —
  architecture-invalidating, cross-cutting, or scope-expanding — or a feature-altitude agent
  hitting an architectural surprise and escalating up.
- **Writes:** new ADR(s) recording why; a changelog appended to `prd.md`/`architecture.md`; delta
  epics.
- **Core mechanic — fixes BMAD's known Agile-violating bug:** completed work is **immutable**.
  Mark it `superseded by <new>` and create new delta stories rather than editing finished
  acceptance criteria.
- **Reuses:** the fork's existing "stop and ask" / escalation discipline for the upward path.

### `skills/product-discovery/elicitation-methods.md` (shared reference)

The named-reasoning-methods menu — pre-mortem, first-principles, inversion, red/blue-team,
Socratic questioning, constraint removal, stakeholder mapping, analogical reasoning, tree-of-
thoughts. It lives with `product-discovery` and is referenced cross-skill from `brainstorming`
(as `../product-discovery/elicitation-methods.md`) — the same pattern
`subagent-driven-development` uses to reference `requesting-code-review`'s reviewer file (DRY,
single source of truth).

## Consumption contract — the anti-duplication seam

How the feature altitude reads project artifacts without re-deriving them:

1. **Epic → feature unit.** Each PRD epic is a unit of feature work. The router decides per epic:
   design needed (`brainstorming`) or specific enough to go straight to `writing-plans`.
2. **Acceptance criteria → Verification Artifacts.** The PRD's risk-tiered Gherkin ACs map
   directly onto `writing-plans`' `## Verification Artifacts`. This is the convergence point of
   BMAD's AC, the fork's observable-delta rule (#4), and Finding A: each AC becomes a VA bullet
   with an observable delta; P0/P1 ACs require behaviorally-independent assertions.
3. **`architecture.md` → plan constraints.** Feature plans cite `architecture.md` / relevant ADRs
   in their existing Global Constraints / Interfaces blocks instead of re-deriving architecture.
   The plan references the ADR; it does not re-decide it.
4. **No-re-spec rule.** When an epic + architecture already specify a feature, the feature altitude
   does not re-run `product-discovery` or re-author PRD-level content; `brainstorming` (if used)
   produces only the feature-level delta, citing the PRD.
5. **Upward escalation.** Feature work that reveals the architecture is wrong escalates to
   `reevaluation`, not a quiet in-plan redesign. A named signal in `writing-plans` /
   `subagent-driven-development` triggers it.

## Grafts (text + markers, no new skills)

- **Advanced-elicitation menu:** `brainstorming` and `product-discovery` each get a pointer to
  `elicitation-methods.md` plus "offer a named method when an answer is shallow or high-stakes."
- **Scale-adaptive depth:** lives in `skill-router`, cross-referenced from `writing-plans`
  Task Right-Sizing (next to #11), naming the routing signals.
- **Finding A (oracle-strengthening):** into `writing-plans` (P0/P1 ACs need independent
  assertions; propose a property / invariant test for logic-heavy ACs; AC→test traceability;
  mutation testing when feasible) and `test-driven-development` (the same assertion-strength
  discipline at test-writing time).

## Safety — do not overwrite hand-maintained docs

Every writer skill (`product-discovery`, `architecture-design`, `reevaluation`) must **not
overwrite a hand-maintained architecture/PRD doc**. It detects an existing one and appends /
cross-links instead. This mirrors the operator's own standing rule ("do not overwrite
hand-maintained `CLAUDE.md`/`TODO.md`") and matters the moment `architecture-design` runs in a
repo like CCC that already has `docs/architecture.md`.

## Verification & Testing

- `scripts/lint-fork-customizations.sh` gains a presence marker per new skill plus one per graft
  (~24 → ~34 `grep -qF` checks) and stays green. Each marker is a verbatim, single physical line,
  case-sensitive substring of the skill text it guards — consistent with the existing checks. Exact
  marker wording is finalized in the plan, paired with the text it must match.
- No behavioral/LLM tests are added (see Non-Goals). The lint header's existing caveat — "checks
  STRUCTURE only … does NOT verify that an agent actually obeys" — already covers this honestly.

## Surface Summary

Files created: `skills/skill-router/SKILL.md`, `skills/product-discovery/SKILL.md`,
`skills/architecture-design/SKILL.md`, `skills/reevaluation/SKILL.md`, and the shared
`skills/product-discovery/elicitation-methods.md` reference (cross-referenced from
`brainstorming`).

Files modified: `skills/brainstorming/SKILL.md`, `skills/writing-plans/SKILL.md`,
`skills/test-driven-development/SKILL.md`, `skills/using-hyperpowers/SKILL.md`,
`scripts/lint-fork-customizations.sh`, plus `README.md` / `RELEASE-NOTES.md` in the mandatory final
documentation task.

Customization count: **11 → ~15**. The operator chose to build all three waves (grafts; core
upper-altitude skills; router + reevaluation) as **one implementation plan**, not sequenced.
Publish path: feature branch `feat/bmad-absorption` → PR against the fork's own `main` (main is
protected; direct push is blocked).

## Resolved Scope Decisions (from brainstorming)

- Connect-two-tools vs. absorb: **absorb BMAD into the fork** (one bundle).
- Cohesion mechanism: a scale-adaptive **router among unified skills**, not a cross-tool state
  machine (the `project-state.yml` ledger idea was explored and dropped).
- Grounding: **researched the real BMAD v6.8** before deciding.
- Migration approach: **M1 (absorb the delta) + two in-place grafts**, not M2 (faithful port).
- Migration set: **all four deltas** — upper-altitude track, advanced-elicitation menu,
  scale-adaptive depth, reevaluation/correct-course — plus Finding A as the rider.
- Build order: **all three waves as one implementation plan**.

## Known Follow-Up (deferred, not in scope)

- **Behavioral methodology tests** for the new skills via `testing-skills-with-subagents` — proving
  an agent obeys the router, the no-re-spec rule, and the supersede-don't-rewrite rule, not merely
  that the text is present. This closes the "does the agent obey?" gap for the new customizations
  alongside the existing eleven.
- Deeper TEA-style risk-tiering / traceability matrices, if a project ever demands enterprise test
  governance.
