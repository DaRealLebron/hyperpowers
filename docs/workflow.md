# Fork Workflow — Happy Path

This fork customizes the Hyperpowers planning/execution pipeline. The diagrams below
show the **happy path** (everything passes, no `revise` loops) for upstream Hyperpowers
and for this fork, with the fork's additions highlighted.

In the fork chart: **green = new in this fork**, **amber = changed from upstream**,
default-styled nodes are the unchanged backbone.

> Rendering: view this file in a Mermaid-aware viewer (GitHub, mermaid.live, VS Code
> Mermaid preview) to see the colored boxes. Raw text won't show color.

## 1. Original Hyperpowers — happy path

```mermaid
flowchart TD
    A["brainstorming → spec<br/>(operator approves)"] --> B["using-git-worktrees<br/>(isolated workspace)"]
    B --> C["writing-plans:<br/>Scope Check · File Structure<br/>bite-sized tasks"]
    C --> D["Self-Review<br/>(3 items: spec coverage,<br/>placeholders, type consistency)"]
    D --> E["Execution Handoff"]
    E --> F["subagent-driven-development<br/>per task (single writer)"]
    F --> G["implementer:<br/>RED → GREEN → commit"]
    G --> VBC["verification-before-completion<br/>(evidence before claims)"]
    VBC --> H["spec-compliance review ✓"]
    H --> I["code-quality review ✓"]
    I --> J{"more tasks?"}
    J -- yes --> G
    J -- no --> K["final whole-impl review"]
    K --> L["finishing-a-development-branch<br/>tests pass → merge → cleanup"]
    L --> M(["✔ done"])
```

## 2. This fork — happy path (green = new, amber = changed)

```mermaid
flowchart TD
    A["brainstorming → spec<br/>(operator approves)"] --> B["using-git-worktrees<br/>(isolated workspace)"]
    B --> C["writing-plans"]
    C --> RF["Research Fan-Out (optional · NS2)<br/>parallel read-only investigators<br/>→ controller synthesizes"]:::new
    RF --> ITM["Input Trust Model<br/>(trusted vs untrusted inputs)"]:::new
    ITM --> P["File Structure · tasks · Global Constraints"]
    P --> VA["Verification Artifacts<br/>(observable delta, not 'exit 0')"]:::new
    VA --> DOC["Mandatory final<br/>'Update documentation' task"]:::new
    DOC --> SR["Self-Review<br/>(6 items: adds VA, docs,<br/>untrusted-content checks)"]:::changed
    SR --> APR["Adversarial Plan Review<br/>flat multi-lens panel (parallel)<br/>→ all PROCEED"]:::new
    APR --> F["subagent-driven-development<br/>per task (single writer)"]
    F --> G["implementer:<br/>RED → GREEN → commit"]
    G --> VBC["verification-before-completion<br/>+ outcome delta + docs-updated<br/>+ untrusted-data red flag"]:::changed
    VBC --> H["spec-compliance review ✓"]
    H --> I["code-quality review ✓"]
    I --> J{"more tasks?"}
    J -- yes --> G
    J -- no --> K["final whole-impl review<br/>(runs Verification Artifacts)"]:::changed
    K --> L["finishing-a-development-branch<br/>tests pass → merge → cleanup"]
    L --> M(["✔ done"])

    GUARD["flat-delegation guardrail<br/>every fan-out is depth-2;<br/>workers never spawn workers"]:::new
    GUARD -.applies to.-> RF
    GUARD -.applies to.-> APR
    GUARD -.applies to.-> F

    subgraph Legend
        L1["NEW in fork"]:::new
        L2["CHANGED from upstream"]:::changed
    end

    classDef new fill:#c6f6d5,stroke:#2f855a,stroke-width:2px,color:#1a202c
    classDef changed fill:#fde9c8,stroke:#c05621,stroke-width:2px,color:#1a202c
```

## The diff at a glance

- **New** (green): Research Fan-Out · Input Trust Model · Verification Artifacts ·
  Mandatory docs task · Adversarial Plan Review (multi-lens panel) · flat-delegation guardrail
- **Changed** (amber): Self-Review (3 → 6 items) · verification-before-completion
  (adds outcome-delta, docs-updated, untrusted-data red flag) · final review now executes
  the Verification Artifacts
- **Unchanged backbone:** brainstorming → using-git-worktrees → writing-plans →
  subagent-driven-development (implementer + two-stage review loop) → finishing-a-development-branch

All fork additions are **advisory** (operator may override any gate) and **flat depth-2,
read-only** where they fan out — matching the research finding that parallel read/review
fan-out helps while nested subagents-calling-subagents does not. The deterministic structural
lint `scripts/lint-fork-customizations.sh` (no LLM, 55 checks) guards these behaviors.

## Two newer arcs (layered on the pipeline above)

The charts above are the day-to-day **feature** pipeline. Two later arcs extend it:

- **Project altitude (BMAD absorption).** Larger work is first routed by `skill-router`: greenfield
  / cross-cutting work runs `product-discovery` → `architecture-design` → an
  implementation-readiness gate, then drops per-epic into the feature pipeline above, which *reads*
  those project artifacts instead of re-deriving them. Full diagram and "what came from where":
  [`docs/hyperpowers/bmad-absorption-happy-path.md`](hyperpowers/bmad-absorption-happy-path.md).
- **Project-memory curation.** At completion, `finishing-a-development-branch` runs a
  `curating-project-memory` pass that drifts the project's `CLAUDE.md` (canonical) / generated
  `AGENTS.md` / scoped `.claude/rules/` / `docs/` toward an optimal, well-linked state;
  `writing-plans`' final documentation task now names `CLAUDE.md` / `AGENTS.md`, and
  `verification-before-completion` checks that project memory is current. Design:
  [`docs/hyperpowers/specs/2026-06-22-project-memory-curation-design.md`](hyperpowers/specs/2026-06-22-project-memory-curation-design.md).
