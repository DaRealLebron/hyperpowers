# Adversarial Plan Review + Mandatory Docs Gate — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use hyperpowers:subagent-driven-development (recommended) or hyperpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an advisory pre-implementation adversarial plan review, a mandatory documentation task, and a required `## Verification Artifacts` section to the Hyperpowers planning skills in this fork.

**Architecture:** Three skill-file edits plus a behavioral verification pass. `writing-plans/SKILL.md` gains a Verification Artifacts template block, a mandatory final documentation task, an Adversarial Plan Review step, and two Self-Review checks. The orphaned `writing-plans/plan-document-reviewer-prompt.md` is repurposed into a backend-neutral adversarial reviewer wired into that step. `verification-before-completion/SKILL.md` gains a docs-updated completion check. All gates are advisory with an explicit override; the in-session reviewer is required, Codex and Gemini are best-effort.

**Tech Stack:** Markdown skill files. No code/unit tests — skills are verified with Hyperpowers' own `testing-skills-with-subagents` methodology (dispatch fresh subagents through the modified skills and observe behavior), plus deterministic `grep` structural checks per edit.

## Global Constraints

- Spec: `docs/hyperpowers/specs/2026-06-17-plan-review-and-docs-gate-design.md` (this fork).
- Repo root for all paths below: `/root/projects/hyperpowers` (the fork). Work on branch `feat/plan-review-and-docs-gate`.
- Edits touch ONLY: `skills/writing-plans/SKILL.md`, `skills/writing-plans/plan-document-reviewer-prompt.md`, `skills/verification-before-completion/SKILL.md`, plus this fork's docs in the final task.
- Gates are **advisory**: refuse to *claim* ready/done, but allow an explicit operator override note. Never hard-block.
- Required reviewer = in-session `general-purpose` subagent. Codex/Gemini are best-effort: absent or erroring backends are reported "skipped (unavailable: <name>)" and never block.
- Reviewer output is freeform prose ending in `Ready to implement? proceed | revise`.
- Preserve existing wording/formatting conventions of each file; insert, don't rewrite, except where a task says "replace the file."

## Note on TDD for skill edits

Strict red-green TDD does not map to prose instruction edits. Each edit task is verified two ways: (1) an immediate deterministic `grep` proving the exact content landed, and (2) a consolidated behavioral subagent test in Task 5 that proves the *behavior* fires. This mirrors `skills/writing-skills/testing-skills-with-subagents.md`.

---

### Task 1: Repurpose the orphaned reviewer prompt into a backend-neutral adversarial reviewer

**Files:**
- Modify (full replace): `skills/writing-plans/plan-document-reviewer-prompt.md`

**Why first:** Task 3 wires `writing-plans` to this prompt, so it must exist in final form first.

- [ ] **Step 1: Replace the file contents**

Replace the ENTIRE contents of `skills/writing-plans/plan-document-reviewer-prompt.md` with:

````markdown
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

## Plan Review (<reviewer name>)

**Strengths:**
- [what is solid]

**Issues:**
- [Critical | Important | Minor] [Task X, Step Y]: [specific issue] — [why it matters for implementation]

**Ready to implement? proceed | revise**
```

**Reviewer returns:** Strengths, Issues by severity, and an explicit
`proceed | revise` recommendation.
````

- [ ] **Step 2: Verify the new content landed**

Run: `grep -c "proceed | revise" skills/writing-plans/plan-document-reviewer-prompt.md`
Expected: `2` (the prompt's recommendation line and the "Reviewer returns" line)

Run: `grep -E "Verification Artifacts|adversarial plan reviewer|READ-ONLY" skills/writing-plans/plan-document-reviewer-prompt.md`
Expected: matches for all three (adversarial framing, Verification Artifacts check, read-only guard present)

- [ ] **Step 3: Commit**

```bash
git add skills/writing-plans/plan-document-reviewer-prompt.md
git commit -m "feat(writing-plans): repurpose reviewer prompt as backend-neutral adversarial reviewer"
```

---

### Task 2: Add Verification Artifacts template, mandatory docs task, and Self-Review checks to writing-plans

**Files:**
- Modify: `skills/writing-plans/SKILL.md`

**Interfaces:**
- Produces: the `## Verification Artifacts` section and the mandatory final documentation task that Task 1's reviewer (Verification Artifacts + Documentation checks) and Task 5's behavioral test assert on.

- [ ] **Step 1: Add `## Verification Artifacts` to the Plan Document Header template**

In `skills/writing-plans/SKILL.md`, find this block inside the "## Plan Document Header" section:

```markdown
## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

---
```

Replace it with:

```markdown
## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

## Verification Artifacts

[How we'll know each part works. Each bullet is `<command>` — <success
criterion>. Commands must be runnable; criteria must be observable. This
section is REQUIRED in every plan.]
- `<command>` — <observable success criterion>

---
```

- [ ] **Step 2: Add the mandatory final documentation task**

In `skills/writing-plans/SKILL.md`, find the line `## No Placeholders` and insert this new section immediately BEFORE it (leave a blank line on each side):

````markdown
## Mandatory Final Task: Update Documentation

Every plan's LAST task is "Update documentation." It is never optional and is
never folded into another task — it is the terminal deliverable of the plan, so
docs cannot be silently dropped. The task must name the specific docs to check
and update (README, per-area docs, CHANGELOG/RELEASE-NOTES, and any usage/skill
docs the change affects), and end with a commit step.

```markdown
### Task N (final): Update documentation

**Files:**
- Modify: `<exact doc paths the change affects>`

- [ ] **Step 1: Update the docs** — reflect the new/changed behavior in each file above.
- [ ] **Step 2: Verify** — `grep` the changed docs for the new terms, or re-read to confirm accuracy.
- [ ] **Step 3: Commit** — `git commit -m "docs: document <feature>"`
```

````

- [ ] **Step 3: Add two checks to the Self-Review section**

In `skills/writing-plans/SKILL.md`, find this line in the "## Self-Review" section:

```markdown
If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.
```

Insert these two items immediately BEFORE that line (after the existing "**3. Type consistency:**" paragraph):

```markdown
**4. Verification Artifacts:** The plan has a `## Verification Artifacts` section, and every bullet is a runnable command with an observable success criterion. No vague aspirations.

**5. Documentation task:** The final task is "Update documentation" and names the specific docs it touches.

```

- [ ] **Step 4: Verify all three edits landed**

Run: `grep -c "^## Verification Artifacts$" skills/writing-plans/SKILL.md`
Expected: `1` (anchored to the heading line; Self-Review item 4's inline mention is excluded)

Run: `grep -c "Mandatory Final Task: Update Documentation" skills/writing-plans/SKILL.md`
Expected: `1`

Run: `grep -E "^\*\*4\. Verification Artifacts|^\*\*5\. Documentation task" skills/writing-plans/SKILL.md`
Expected: both lines match

- [ ] **Step 5: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "feat(writing-plans): require Verification Artifacts section and mandatory final docs task"
```

---

### Task 3: Add the Adversarial Plan Review step to writing-plans

**Files:**
- Modify: `skills/writing-plans/SKILL.md`

**Interfaces:**
- Consumes: the reviewer prompt at `skills/writing-plans/plan-document-reviewer-prompt.md` (Task 1).

- [ ] **Step 1: Insert the Adversarial Plan Review section before Execution Handoff**

In `skills/writing-plans/SKILL.md`, find the line `## Execution Handoff` and insert this new section immediately BEFORE it (blank line on each side):

````markdown
## Adversarial Plan Review

After Self-Review and before Execution Handoff, get an independent adversarial
review of the plan. This is **advisory**: it refuses to let you *claim* the plan
is ready without a review, but you may override (see below).

Use the prompt template at `plan-document-reviewer-prompt.md`, filling
`[PLAN_FILE_PATH]` and `[SPEC_FILE_PATH]`.

**1. Required — in-session reviewer (current model):**
Dispatch a fresh `general-purpose` subagent with the filled prompt. This
reviewer always runs.

**2. Best-effort — model diversity (NS5):**
Additionally send the SAME filled prompt to other model backends if they are
available in this environment. Each is optional: if the backend is missing or
errors, report `skipped (unavailable: <name>)` and continue. Never block on an
external model. Write the filled prompt to a temp file first, e.g.
`/tmp/plan-review-prompt.md`.

- Codex:
  ```bash
  if command -v codex >/dev/null 2>&1; then
    codex exec - < /tmp/plan-review-prompt.md
  else
    echo "skipped (unavailable: codex)"
  fi
  ```
- Gemini (operator's `claude-or` wrapper, or any local Gemini CLI):
  ```bash
  if command -v claude-or >/dev/null 2>&1; then
    claude-or -p "$(cat /tmp/plan-review-prompt.md)" || echo "skipped (unavailable: gemini)"
  else
    echo "skipped (unavailable: gemini)"
  fi
  ```

**3. Summarize verdicts:** Present every verdict that returned, attributed by
reviewer (e.g. "Claude: proceed", "Codex: revise — Task 3 ordering", "Gemini:
skipped (unavailable)"). Do not collapse them into a single pass/fail.

**4. Act on the verdicts:**
- If all returned reviewers say `proceed`: continue to Execution Handoff.
- If any reviewer says `revise`: strongly recommend revising the plan first.
  Proceeding anyway is allowed, but you MUST state explicitly that you are
  overriding the review and why.

````

- [ ] **Step 2: Verify**

Run: `grep -c "## Adversarial Plan Review" skills/writing-plans/SKILL.md`
Expected: `1`

Run: `grep -E "skipped \(unavailable: codex\)|skipped \(unavailable: gemini\)|plan-document-reviewer-prompt.md" skills/writing-plans/SKILL.md`
Expected: all three match

Run: `grep -n "## Adversarial Plan Review" -n skills/writing-plans/SKILL.md && grep -n "## Execution Handoff" skills/writing-plans/SKILL.md`
Expected: the Adversarial Plan Review line number is LESS than the Execution Handoff line number (review comes first)

- [ ] **Step 3: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "feat(writing-plans): add advisory adversarial plan review step (current model required, Codex/Gemini best-effort)"
```

---

### Task 4: Add a documentation-updated check to verification-before-completion

**Files:**
- Modify: `skills/verification-before-completion/SKILL.md`

- [ ] **Step 1: Add a row to the Common Failures table**

In `skills/verification-before-completion/SKILL.md`, find this row in the "## Common Failures" table:

```markdown
| Requirements met | Line-by-line checklist | Tests passing |
```

Insert this row immediately AFTER it:

```markdown
| Docs updated | VCS diff shows the doc changes | "Code is self-explanatory", "will document later" |
```

- [ ] **Step 2: Add documentation to the When To Apply list**

In `skills/verification-before-completion/SKILL.md`, find this block:

```markdown
**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents
```

Insert this bullet immediately after `- Committing, PR creation, task completion`:

```markdown
- Claiming a task is complete when the plan included a documentation task (verify the docs were actually updated — VCS diff shows them)
```

- [ ] **Step 3: Verify**

Run: `grep -c "Docs updated" skills/verification-before-completion/SKILL.md`
Expected: `1`

Run: `grep -c "included a documentation task" skills/verification-before-completion/SKILL.md`
Expected: `1`

- [ ] **Step 4: Commit**

```bash
git add skills/verification-before-completion/SKILL.md
git commit -m "feat(verification-before-completion): require docs-updated evidence before completion claims"
```

---

### Task 5: Behavioral verification via subagent dispatch

**Files:**
- Test only — no file edits. Creates throwaway artifacts under `/tmp`.

This task uses Hyperpowers' `testing-skills-with-subagents` methodology: dispatch fresh subagents that read the modified skills and observe whether the new behaviors fire.

- [ ] **Step 1: Create a tiny sample spec for the test**

```bash
cat > /tmp/sample-spec.md <<'EOF'
# Sample Spec: add a greet() function
Add a function greet(name) that returns "Hello, <name>!". Must have a unit test.
EOF
```

- [ ] **Step 2: Dispatch a subagent through writing-plans**

Dispatch a `general-purpose` subagent with this prompt:

```
Read the skill at skills/writing-plans/SKILL.md (this repo). Following it
exactly, write an implementation plan for the spec at /tmp/sample-spec.md to
/tmp/sample-plan.md. Then STOP before the Execution Handoff and report: (a) does
your plan contain a "## Verification Artifacts" section with runnable commands?
(b) is the final task "Update documentation"? (c) did you run the Adversarial
Plan Review step, and what did each reviewer return (including any skipped)?
```

- [ ] **Step 3: Verify the behavioral expectations**

Confirm from the subagent's report AND by inspecting `/tmp/sample-plan.md`:

Run: `grep -c "## Verification Artifacts" /tmp/sample-plan.md`
Expected: `1`

Run: `grep -iE "update documentation" /tmp/sample-plan.md | tail -1`
Expected: a final-task heading matches

Expected from report: the in-session reviewer ran; Codex either returned a verdict or `skipped (unavailable: codex)`; Gemini returned a verdict or `skipped (unavailable: gemini)`. The step must NOT have errored out on a missing backend.

- [ ] **Step 4: Dispatch a subagent through verification-before-completion**

Dispatch a `general-purpose` subagent with this prompt:

```
Read skills/verification-before-completion/SKILL.md (this repo). I implemented a
plan whose final task was "Update documentation", but I changed only source
files and no docs. May I claim the task is complete? Answer per the skill.
```

Expected: the subagent refuses to claim completion and names the missing
documentation update as the blocker.

- [ ] **Step 5: Record results**

Append a short result note to the plan file's checklist (this file) under this task — pass/fail per check. No commit needed (test artifacts are throwaway). If any check fails, return to the relevant edit task and fix before proceeding.

---

### Task 6 (final): Update documentation

**Files:**
- Modify: `RELEASE-NOTES.md`
- Modify: `README.md`

This is the mandatory final documentation task — dogfooding the rule this plan adds.

- [ ] **Step 1: Add a RELEASE-NOTES entry**

Add a new top entry to `RELEASE-NOTES.md` describing this fork's changes: advisory pre-implementation adversarial plan review (current model required; Codex/Gemini best-effort), mandatory final documentation task, required `## Verification Artifacts` section in every plan, and the docs-updated completion check.

- [ ] **Step 2: Note the fork's behavior in README**

Add a short subsection to `README.md` (e.g., under an existing "Customizations" or "Differences from upstream" heading; create one if absent) summarizing the same four behaviors and noting they are advisory with an explicit operator override.

- [ ] **Step 3: Verify**

Run: `grep -iE "adversarial plan review|Verification Artifacts" README.md RELEASE-NOTES.md`
Expected: matches in both files

- [ ] **Step 4: Commit**

```bash
git add README.md RELEASE-NOTES.md
git commit -m "docs: document adversarial plan review, mandatory docs task, and verification artifacts"
```

---

## Verification Artifacts

- `grep -c "proceed | revise" skills/writing-plans/plan-document-reviewer-prompt.md` — returns `2`.
- `grep -c "## Adversarial Plan Review" skills/writing-plans/SKILL.md` — returns `1`.
- `grep -c "^## Verification Artifacts$" skills/writing-plans/SKILL.md` — returns `1`.
- `grep -c "Mandatory Final Task: Update Documentation" skills/writing-plans/SKILL.md` — returns `1`.
- `grep -c "Docs updated" skills/verification-before-completion/SKILL.md` — returns `1`.
- `grep -c "## Verification Artifacts" /tmp/sample-plan.md` (Task 5) — returns `1`; subagent-produced plan also ends in an "Update documentation" task.
- `git diff --stat upstream/main --name-only` — changed files are exactly the three skill files plus this fork's spec, plan, README, and RELEASE-NOTES; nothing else.
- `grep -iE "adversarial plan review|Verification Artifacts" README.md RELEASE-NOTES.md` — matches in both.
