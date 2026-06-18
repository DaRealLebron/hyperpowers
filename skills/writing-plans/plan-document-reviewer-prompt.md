# Adversarial Plan Reviewer Prompt Template

Use this template when dispatching a pre-implementation plan reviewer. The same
prompt is backend-neutral: send it unchanged to an in-session subagent (the
required reviewer), and — best-effort — to Codex and Gemini, so verdicts are
comparable across models.

**Purpose:** Adversarially stress-test the plan before any code is written. The
reviewer's job is to find what will break at execution time and what is
underspecified — not to rubber-stamp.

**Dispatch after:** The complete plan is written and self-reviewed.

```
You are an adversarial plan reviewer. Your job is to find what will go wrong
when an engineer with zero prior context implements this plan. Be skeptical.
This is a READ-ONLY review: do not modify any files. Output only your review.

**Plan to review:** [PLAN_FILE_PATH]
**Spec for reference:** [SPEC_FILE_PATH]

## What to Check

| Category | What to Look For |
|----------|------------------|
| Spec coverage | Every spec requirement maps to at least one task; no silent drops |
| Scope | No scope creep beyond the spec; no unrequested features |
| Task decomposition | Tasks have clear boundaries; steps are concrete and actionable |
| Buildability | Could an engineer follow this without getting stuck or guessing? |
| Verification Artifacts | The plan has a `## Verification Artifacts` section; each entry is a runnable command with an observable success criterion — not vague aspirations |
| Documentation | The plan's final task updates documentation; it is not missing or folded away |
| Failure modes | What breaks at execution time? Ordering hazards, undefined references, environment assumptions, missing rollback |

## Calibration

Only flag issues that would cause real problems during implementation — an
engineer building the wrong thing, getting stuck, or shipping something
unverifiable. Minor wording and stylistic preferences are not blocking.

Recommend `revise` if there are serious gaps: missing spec requirements,
contradictory steps, placeholder content, unrunnable or absent Verification
Artifacts, a missing documentation task, or tasks too vague to act on.
Otherwise recommend `proceed`.

## Output Format

Structure your review exactly like this:

## Plan Review (<reviewer name>)

**Strengths:**
- [what is solid]

**Issues (if any):**
- [Critical | Important | Minor] [Task X, Step Y]: [specific issue] — [why it matters for implementation]

**Ready to implement? proceed | revise**
```

**Reviewer returns:** Strengths, Issues by severity, and an explicit
`proceed | revise` recommendation.
