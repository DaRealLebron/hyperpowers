# Adversarial Plan Review + Mandatory Docs Gate — Design

**Date:** 2026-06-17
**Status:** Approved (design); pending implementation plan
**Repo:** `DaRealLebron/hyperpowers` (fork of `obra/superpowers`, branched from v6.0.2)

## Motivation

This fork customizes the Hyperpowers workflow skills for a single operator who
wants two failure modes closed before a plan reaches implementation:

1. **Plans get implemented without an adversarial second opinion.** Today
   `writing-plans` ends with a *self-review* that is, in its own words, "a
   checklist you run yourself — **not** a subagent dispatch." The repo ships a
   `plan-document-reviewer-prompt.md`, but it is orphaned: no skill's flow
   dispatches it. So a plan can go straight from authoring to execution with
   only the author's own eyes on it.
2. **Documentation gets left out.** Nothing in the plan template forces a
   documentation step, and `verification-before-completion` never checks that
   docs were updated. Docs are the step most likely to be silently dropped.

A third, supporting gap: plans have no required, machine-checkable success
criteria. Adding a `## Verification Artifacts` section makes "did this work?"
objective rather than narrative, and gives both the reviewer and the
completion gate something concrete to check.

## North-Star Alignment

These map onto the operator's existing evaluation criteria (carried over from
the Consulting Command Center north-stars), which we adopt as design
constraints:

- **Model diversity in review (NS5):** at least one non-Claude reviewer when
  available.
- **Human override on every gate (NS6):** every gate is advisory — it refuses
  to *claim* readiness/completion, but the operator can always proceed with an
  explicit override note.
- **Planning effort proportional to averted downstream cost (NS2):** the review
  happens at plan time, when context is cheapest, to avert execution-time
  rescue work.
- **Observability of reasoning (NS3):** each reviewer's verdict is surfaced to
  the operator, not collapsed into a pass/fail.
- **Reuse before new infrastructure (NS7):** edit existing skills and repurpose
  the orphaned reviewer prompt rather than add a new top-level skill.
- **Testable without live LLM calls (NS8):** the only *required* reviewer is an
  in-session subagent; external models are best-effort and degrade silently, so
  the skills work in any environment.

## Goals

- Every plan, before implementation, gets an adversarial review by at least the
  current model; Codex and Gemini are additionally consulted when reachable.
- Every plan template carries a mandatory final **documentation** task and a
  required **`## Verification Artifacts`** section.
- The documentation requirement is also enforced at the finish line, so it can't
  be dropped after planning.
- All gates are advisory (strong nudge + explicit override), never hard blocks.

## Non-Goals (explicitly out of scope)

- Structured/scored review rubric — the operator chose freeform prose output.
- Hard-blocking enforcement via hooks — gates are advisory.
- Spec→task traceability gate, definition-of-done cleanup step, and a
  run-the-artifacts completion gate — considered and deliberately not selected.
- Any change to how plans are *executed* (`subagent-driven-development`,
  `executing-plans`) beyond what the docs/artifacts requirements imply.

## Settled Decisions

| Decision | Choice |
|---|---|
| Additional scope beyond the two asks | `## Verification Artifacts` section required in every plan |
| Required reviewer | Current model (in-session subagent) — always runs |
| Best-effort reviewers | Codex and Gemini — run if reachable, skipped silently otherwise |
| Gate strength | Advisory: refuse to claim ready/done; explicit override allowed |
| Review output | Freeform prose (strengths / issues by severity / `proceed \| revise`) |
| Placement | Edit existing skills; repurpose the orphaned reviewer prompt |

## Design

Three touch points. No new top-level skill.

### 1. `skills/writing-plans/SKILL.md`

**(a) Required `## Verification Artifacts` section in the plan template.**
Add to the *Plan Document Header* block a required section:

```markdown
## Verification Artifacts

[How we'll know each part works. Each bullet is `<command>` — <success
criterion>. Commands must be runnable; criteria must be observable.]
- `npm test` — all suites green, 0 failures
- `npm run lint` — exit 0
```

**(b) Mandatory final documentation task.** The plan template gains a fixed,
always-last task: **"Update documentation."** It is not optional and not folded
into another task — it is the terminal deliverable of every plan. The task
names which docs to check (README, per-area docs, CHANGELOG/RELEASE-NOTES, any
skill/usage docs the change affects).

**(c) Adversarial Plan Review step**, inserted *before* "Execution Handoff":

- Always dispatch an in-session subagent (current model) using the repurposed
  reviewer prompt (see §2). This reviewer is required.
- Additionally attempt Codex and Gemini with the *same* prompt. Each is
  best-effort: if the backend is not configured or errors, note "skipped
  (unavailable)" and continue. Never block on a missing external model.
- Summarize every verdict that returned, attributed by reviewer, to the
  operator (NS3).
- If any reviewer says `revise`, strongly recommend revising the plan before
  handoff. The operator may proceed anyway, but doing so requires an explicit
  override note stating that they are overriding and why (NS6).

**(d) Self-Review additions.** Extend the existing Self-Review checklist with
two items: (1) the plan contains a `## Verification Artifacts` section with
runnable commands, and (2) the final task is the documentation task. These are
author-side self-checks; the adversarial step in (c) is the independent gate.

### 2. `skills/writing-plans/plan-document-reviewer-prompt.md` (repurposed)

Enhance the existing orphaned prompt in place (rather than adding a
near-duplicate file) so there is exactly one reviewer prompt, now wired into the
flow by §1(c):

- Keep its freeform prose output shape (`Status: Approved | Issues Found`,
  Issues, Recommendations) — already prose, matching the chosen output style.
- Add to "What to Check": whether the `## Verification Artifacts` are real and
  runnable, and whether the mandatory documentation task is present.
- Frame it adversarially: the reviewer's job is to find what breaks at
  execution time and what is underspecified, not to rubber-stamp.
- Make it backend-neutral: the identical prompt is used whether the reviewer is
  the in-session Claude subagent, Codex, or Gemini, so verdicts are comparable.
- End with an explicit one-line recommendation: `Ready to implement? proceed |
  revise`.

### 3. `skills/verification-before-completion/SKILL.md`

Add documentation to the completion gate so the docs step survives past
planning into the finish line:

- Add a row to the "Common Failures" table: `Docs updated` → requires the
  documentation changes to exist in the VCS diff → not sufficient: "code is
  self-explanatory."
- Add documentation to the "When To Apply" / gate list so claiming completion
  without updated docs trips the same Iron Law as claiming tests pass without
  running them.

## Multi-Model Best-Effort Dispatch

- **Current model:** in-session subagent dispatch (the Task/Agent mechanism).
  Always available; this is the hard requirement.
- **Codex:** consulted via the locally-installed Codex path when present.
- **Gemini:** consulted via the locally-installed `claude-or`/Gemini path when
  present.
- **Degradation:** any external reviewer that is not configured or returns an
  error is reported as skipped and does not affect whether the step completes.

The *exact* invocation commands for Codex and Gemini are intentionally deferred
to the implementation plan (so we verify the real CLI calls in this environment
rather than baking in a guess), and they must be written so the skill degrades
cleanly on any machine where those tools are absent.

## Verification / How We'll Know It Works

Verification uses Hyperpowers' own `writing-skills` →
`testing-skills-with-subagents` approach: dispatch fresh subagents through the
modified skills and confirm the new behaviors fire.

## Verification Artifacts

- Dispatch a subagent through `writing-plans` on a sample spec — produced plan
  contains a `## Verification Artifacts` section and a final documentation task.
- Dispatch the same path — the Adversarial Plan Review step runs an in-session
  reviewer and surfaces an attributed verdict before Execution Handoff.
- Run the review step in an environment with Codex/Gemini absent — step reports
  them "skipped (unavailable)" and still completes.
- Dispatch a subagent through `verification-before-completion` on work with no
  doc changes — it refuses to claim completion and names the missing docs.
- `git diff --stat upstream/main` — touches only `skills/writing-plans/SKILL.md`,
  `skills/writing-plans/plan-document-reviewer-prompt.md`, and
  `skills/verification-before-completion/SKILL.md` (plus this spec and the plan).

## Open Questions for Planning

1. Exact Codex and Gemini invocation commands in this environment, and the
   graceful-skip detection for each.
2. Whether the Adversarial Plan Review step should also run inside
   `subagent-driven-development`'s final review, or only at plan authoring time
   (current design: plan authoring time only).
3. Whether to bump `package.json` version / add a RELEASE-NOTES entry for the
   fork (dogfooding the docs requirement).
