# Evidence-Grounded Planning — Design

**Date:** 2026-06-19
**Status:** Approved (brainstorming complete; ready for writing-plans)
**Fork:** `DaRealLebron/superpowers` (fork of `obra/superpowers`)

## Context

A research note (`superpowers_fork_findings_summary.md`) surveyed public Superpowers
forks for methodology ideas worth borrowing. Reconciled against this fork's **existing**
eight customizations, most of its "borrow" list was already shipped here (untrusted-input
quarantine, observable-delta verification, multi-model reviewer adapters, ambient
injection). Three genuinely-new, low-footprint behaviors survived that filter and are the
subject of this design.

All three share one theme: **ground planning and execution in real evidence, and spend
LLM effort in proportion to the task.** None adds standing infrastructure (NS7); each is
advisory with operator override (NS6) and guarded by a deterministic grep marker in
`scripts/lint-fork-customizations.sh`, matching how the fork already protects its
customizations.

### Already in the fork (not re-done here)

- Untrusted-input quarantine (Input Trust Model + Self-Review item 6 + reviewer row +
  completion-gate red flag).
- Observable-delta Verification Artifacts.
- Codex/Gemini reviewer adapters in Adversarial Plan Review.
- Optional read-only research fan-out + multi-lens review panel + flat-delegation guardrail.

## Goals

1. A plan must not reference an external API, CLI flag, env var, or schema it has not
   confirmed exists — or must mark it explicitly as an assumption with the risk named.
2. A reviewer's suggested fix must not be implemented before confirming what it cites is
   real (reviewer output is untrusted content).
3. Purely mechanical work (rename, format, codemod, mass grep-replace) should be done with
   shell/script, not an LLM reasoning pass — both when the plan is *written* and when a task
   is *executed*.

## Non-Goals

- **Behavioral verification.** The lint proves the skill *text* is present; it does NOT
  prove an agent *obeys* it. A `testing-skills-with-subagents` behavioral drill was
  explicitly deferred this round and is recorded below as a known follow-up. We will not
  imply behavioral coverage we do not have.
- **Per-task API Evidence block.** Considered and rejected as disproportionate (NS2); the
  rule is global/lite, not a required per-task section.
- **Extending verify-before-acting to the post-implementation code-review stages.** Kept to
  the plan-review stage only this round, to bound the customization surface.
- The deferred findings (progress.yml/resumability, ReasoningBank memory, oracle-type menu,
  domain overlays, token dashboards, reviewer-disagreement matrix) are out of scope.

## North Star Alignment

- **NS2 (proportional effort):** API pre-verification and the mechanical lane both spend
  cheap evidence-gathering up front to avert expensive downstream rework / wasted tokens.
- **NS3 (observability):** "mark it an ASSUMPTION + name the risk" makes unverified
  dependencies legible instead of silent.
- **NS5 (model diversity):** unchanged; the existing best-effort Codex/Gemini reviewers stay.
- **NS6 (override):** all three behaviors are advisory; the operator may proceed anyway.
- **NS7 (reuse before new infra):** zero new files of standing infrastructure; only skill
  text + grep markers in the existing lint.
- **NS8 (testable without live LLM):** every behavior is covered by a deterministic,
  no-LLM grep check.

## The Three Additions

### Addition 1 — API/doc pre-verification (global lite rule)

**Behavior:** Before a plan references an out-of-repo API, CLI flag, env var, or schema,
confirm it exists via local evidence — type defs, existing in-repo usage, `--help` output,
or vendored docs. If it cannot be confirmed, the plan marks it an **ASSUMPTION** and names
the risk (what breaks if the real signature differs).

**Touch points:**

- `skills/writing-plans/SKILL.md` — new subsection `## API Evidence`, placed immediately
  after `## No Placeholders`. No Placeholders already bans referencing *internal* undefined
  symbols; this extends the same discipline to *external* ones. Also add **Self-Review item
  7** ("API evidence") to the Self-Review checklist.
- `skills/writing-plans/plan-document-reviewer-prompt.md` — one new check row in the
  reviewer's "what to check" list: flag any external API/command/schema the plan cites with
  no local evidence and no assumption marker.
- `skills/verification-before-completion/SKILL.md` — one new failure row: a completion claim
  that depends on an external API/command must have confirmed it exists (or flagged the
  assumption) before the claim is made.

**Rationale:** Hallucinated API calls in a plan are a real, expensive failure mode — the
implementer faithfully builds against an API that does not exist, and the cost surfaces at
execution time when context is gone (NS1/NS2). The lite form keeps plan-writing friction
low while still feeding the reviewer and completion gates.

### Addition 2 — Verify-before-acting-on-review (plan review only)

**Behavior:** Before implementing any change a plan reviewer suggested, confirm any API,
file, line, or issue the finding cites actually exists. A reviewer that cites something
nonexistent → discard that finding and note it. This makes explicit what the Input Trust
Model already implies: reviewer/subagent output is untrusted content, usable as evidence
but never automatically authoritative.

**Touch points:**

- `skills/writing-plans/SKILL.md` — inside `## Adversarial Plan Review`, step **4. Act on
  the verdicts**: add the verify-before-acting instruction.
- `skills/writing-plans/plan-document-reviewer-prompt.md` — a light instruction that
  findings must cite concrete, checkable evidence (so they *can* be verified before action).

**Rationale:** LLM reviewers (and cross-model reviewers especially) hallucinate fixes that
cite nonexistent APIs or files. Acting on them blindly injects the very errors the review
was meant to catch. Cheap to state; complements both the untrusted-input model and
Addition 1.

### Addition 3 — Shell-first mechanical lane (both skills)

**Behavior:** Purely mechanical, deterministic work is handled with shell/script rather than
LLM reasoning — at plan-writing time (write it as a shell step) and at execution time
(reach for shell with no subagent).

**Touch points:**

- `skills/writing-plans/SKILL.md` — a note in `## Task Right-Sizing`: when a task is purely
  mechanical (rename, format, codemod, mass grep-replace), write it as a shell/script step,
  not prose for an agent to reason through.
- `skills/subagent-driven-development/SKILL.md` — a note in `## Model Selection` (a "Tier 0
  / mechanical" lane): for deterministic mechanical work, reach for shell/script with no
  subagent at all, rather than an LLM reasoning pass. **This brings
  `subagent-driven-development` under fork management for the first time.**

**Rationale:** Spending a reasoning pass (or a whole subagent) on a `sed`/`grep` job wastes
tokens and is *less* reliable than a deterministic command (NS2). Naming the lane in both
the planner and the executor keeps the two consistent.

## Verification & Testing

- `scripts/lint-fork-customizations.sh` gains ~6 new `grep -qF` markers (≈18 → ≈24), and
  stays green. Each marker is a verbatim single-line substring of the skill text it guards,
  consistent with the existing checks. (Marker wording is finalized in the plan, where each
  is paired with the exact text it must match — case-sensitive, single physical line.)
- No behavioral/LLM tests are added (see Non-Goals). The lint header's existing caveat —
  "checks STRUCTURE only … does NOT verify that an agent actually obeys" — already covers
  this honestly and needs no change.

## Surface Summary

Files modified: `skills/writing-plans/SKILL.md`,
`skills/writing-plans/plan-document-reviewer-prompt.md`,
`skills/verification-before-completion/SKILL.md`,
`skills/subagent-driven-development/SKILL.md` (new to fork),
`scripts/lint-fork-customizations.sh`, plus `README.md` / `RELEASE-NOTES.md` in the
mandatory final documentation task.

Customization count: **8 → 11**. Publish path: feature branch
`feat/evidence-grounded-planning` → PR against the fork's own `main` (main is
protected; direct push is blocked).

## Known Follow-Up (deferred, not in scope)

- **Behavioral methodology tests** — fixture-based plan checks + a mock prompt-injection
  drill proving an agent *ignores* embedded instructions, via
  `testing-skills-with-subagents`. This is the natural next layer over the structural lint
  and would close the "does the agent obey?" gap for all eleven customizations at once.

## Resolved Scope Decisions (from brainstorming)

- Addition 1 weight: **global lite rule** (not per-task block, not hybrid).
- Addition 1 unverifiable case: **mark as ASSUMPTION + name risk** (do not hard-block).
- Addition 2 reach: **plan review only** (not code-review stages).
- Addition 3 home: **both** writing-plans and subagent-driven-development.
- Reviewer-adjudication-rules and behavioral methodology tests: **out** this round.
