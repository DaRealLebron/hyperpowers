# BMAD Absorption — Unified Planning OS Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use hyperpowers:subagent-driven-development (recommended) or hyperpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Absorb BMAD's effective project-altitude capabilities into the fork as native skills — discovery/PRD, durable architecture + readiness gate, reevaluation, a scale-adaptive router — plus the elicitation menu and Finding A, all guarded by the deterministic structural lint.

**Architecture:** Pure advisory skill text + a `grep -qF` structural lint. Four new skills and one shared reference file are created; five existing skills are grafted; the lint grows from 24 to 40 checks. No runtime code. Each behavior is added RED-first (lint check before the text it guards), matching the fork's established TDD-for-lint pattern.

**Tech Stack:** Markdown skill files; Bash structural lint (`scripts/lint-fork-customizations.sh`).

## Global Constraints

- **WSL + quoting.** All shell commands run in WSL via `wsl.exe -e bash -lc '...'`. When a command contains `$?`, `$(...)`, or any `$`-expansion, **single-quote** the payload so the outer Git Bash does not expand it before WSL sees it.
- **Explicit-path staging.** Stage every commit by **explicit path** — never `git add -A`. The fork's working tree carries pre-existing line-ending/mode churn on ~22 unrelated files that must never be swept into a commit.
- **Markers are single-line and case-sensitive.** Every lint marker is a verbatim, single physical line, case-sensitive substring of the text it guards. A wrapped, reflowed, or differently-cased marker never matches — this is the most common failure mode.
- **Final lint count is exactly 40** (24 existing + 16 new). The spec's "~34" was a rough estimate; this plan pins the exact markers.
- **Shared files ⇒ sequential.** Tasks 6, 7, and 8 each modify `skills/writing-plans/SKILL.md`; most tasks modify `scripts/lint-fork-customizations.sh`. Tasks are **NOT parallelizable** — run them in order.
- **Lint insertion point.** Every new check block goes in the **checks region** — immediately before the final `printf '\n%d passed, %d failed\n'` line — never after the `exit 1` block, or the checks will not run. Each task's new block also defines any file-path variable it introduces (`SR`, `US`, `PD`, `EM`, `AD`, `RE`, `BR`, `TDD`); `WP` and `SDD` already exist in the script.
- **Never overwrite hand-maintained docs.** Writer skills (`product-discovery`, `architecture-design`, `reevaluation`) detect an existing hand-maintained brief/PRD/architecture and append/cross-link instead of clobbering.
- **Branch.** Work on `feat/bmad-absorption`. Do not push to `main` (protected).

## Verification Artifacts

- `bash scripts/lint-fork-customizations.sh` — prints `40 passed, 0 failed` and exits 0 (was `24 passed, 0 failed`), proving all 16 new markers are present in the files they guard.
- `ls skills/skill-router/SKILL.md skills/product-discovery/SKILL.md skills/product-discovery/elicitation-methods.md skills/architecture-design/SKILL.md skills/reevaluation/SKILL.md` — all five new files exist; none existed before this plan.
- `grep -c skill-router skills/using-superpowers/SKILL.md` — returns ≥1 (was 0), proving the router is wired into the always-loaded entry skill.
- `grep -F 'acceptance criteria become Verification Artifacts' skills/writing-plans/SKILL.md` — matches (absent before), proving the anti-duplication consumption seam is documented.
- `grep -F 'Completed work is immutable' skills/reevaluation/SKILL.md` — matches, proving the supersede-not-rewrite rule (the fix for BMAD's known bug) is present.
- `grep -F '40 checks' README.md` — matches (the README said `24 checks` before this plan), proving the doc check-count was advanced; and `grep -F 'BMAD absorption' RELEASE-NOTES.md` — matches, proving the release entry was added.

---

### Task 1: `skill-router` skill + wire into `using-superpowers`

**Files:**
- Create: `skills/skill-router/SKILL.md`
- Modify: `skills/using-superpowers/SKILL.md` (insert one subsection after `## Skill Priority`)
- Modify: `scripts/lint-fork-customizations.sh` (append check block)

**Interfaces:**
- Produces: the `skill-router` skill (scale-adaptive altitude routing) that later tasks reference from `writing-plans`, `product-discovery`, and `reevaluation`. The marker strings `## Scale-Adaptive Routing`, `Route by signals, not by habit`, and (in `using-superpowers`) `skill-router`.

- [ ] **Step 1: Add the failing lint checks**

In `scripts/lint-fork-customizations.sh`, after the existing `# 10.` block (the last check, before the final `printf`), add:

```bash
# 11. BMAD absorption — skill-router (scale-adaptive front door)
SR="skills/skill-router/SKILL.md"
US="skills/using-superpowers/SKILL.md"
check "skill-router: scale-adaptive routing section" "$SR" "## Scale-Adaptive Routing"
check "skill-router: route-by-signals wording"       "$SR" "Route by signals, not by habit"
check "using-hyperpowers: routes via skill-router"   "$US" "skill-router"
```

- [ ] **Step 2: Run the lint to verify it fails**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
(single-quoted because of `$?`)
Expected: `24 passed, 3 failed`, `EXIT=1` — the three new markers are missing.

- [ ] **Step 3: Create the `skill-router` skill**

Create `skills/skill-router/SKILL.md`:

```markdown
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

Once the project altitude has produced `docs/superpowers/product/prd.md` and
`docs/superpowers/architecture/architecture.md`, the feature altitude **reads** them — it never
re-runs discovery or re-authors product-level content for a feature an epic already covers.
```

- [ ] **Step 4: Wire the router into `using-superpowers`**

In `skills/using-superpowers/SKILL.md`, immediately after the `## Skill Priority` section (after the line ``"Fix this bug" → systematic-debugging first, then domain-specific skills.``), insert:

```markdown

## Routing Build Work

For build tasks, route altitude first with skill-router (trivial → feature → project), then enter
the matched skill. Don't default every task to the same depth — proportional effort is the point (NS2).
```

- [ ] **Step 5: Run the lint to verify it passes**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `27 passed, 0 failed`, `EXIT=0`.

- [ ] **Step 6: Commit**

```bash
wsl.exe -e bash -lc 'cd /root/projects/superpowers && git add skills/skill-router/SKILL.md skills/using-superpowers/SKILL.md scripts/lint-fork-customizations.sh && git commit -q -m "feat(skills): add scale-adaptive skill-router + wire into using-superpowers"'
```

---

### Task 2: `product-discovery` skill + shared `elicitation-methods.md`

**Files:**
- Create: `skills/product-discovery/SKILL.md`
- Create: `skills/product-discovery/elicitation-methods.md`
- Modify: `scripts/lint-fork-customizations.sh`

**Interfaces:**
- Consumes: `skill-router` (referenced as the gate that decides project altitude).
- Produces: the `product-discovery` skill and the shared `elicitation-methods.md` (referenced by `brainstorming` in Task 5). Markers `## Discovery to PRD`, `Carry findings forward` (dash-free substring of the in-skill sentence, to avoid em-dash fragility), `## Elicitation Methods`. Writes `docs/superpowers/product/{brief,prd}.md` at runtime with risk-tiered Gherkin acceptance criteria.

- [ ] **Step 1: Add the failing lint checks**

Append to `scripts/lint-fork-customizations.sh`:

```bash
# 12. BMAD absorption — product-discovery + elicitation menu
PD="skills/product-discovery/SKILL.md"
EM="skills/product-discovery/elicitation-methods.md"
check "product-discovery: discovery-to-PRD section"  "$PD" "## Discovery to PRD"
check "product-discovery: carry-forward anti-rework" "$PD" "Carry findings forward"
check "elicitation-methods: menu section"            "$EM" "## Elicitation Methods"
```

- [ ] **Step 2: Run the lint to verify it fails**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `27 passed, 3 failed`, `EXIT=1`.

- [ ] **Step 3: Create the `product-discovery` skill**

Create `skills/product-discovery/SKILL.md`:

```markdown
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
```

- [ ] **Step 4: Create the shared elicitation menu**

Create `skills/product-discovery/elicitation-methods.md`:

```markdown
# Elicitation Methods

A menu of named reasoning methods for discovery and design. Offer one when an answer is shallow, an
assumption is load-bearing, or the stakes are high — not on every question (NS2). Referenced by
`brainstorming` and `product-discovery`.

## Elicitation Methods

- **Pre-mortem** — assume this shipped and failed; work backward to the cause.
- **First-principles** — strip to fundamentals and rebuild the requirement.
- **Inversion** — how would we guarantee failure? Then avoid those paths.
- **Red-team / blue-team** — attack the idea, then defend it.
- **Socratic questioning** — ask "why?" until the real constraint surfaces.
- **Constraint removal** — drop a constraint, see what changes, reapply selectively.
- **Stakeholder mapping** — re-evaluate from each stakeholder's view.
- **Analogical reasoning** — find a parallel domain and port its lessons.
- **Tree-of-thoughts** — branch several lines of reasoning, then prune.

Pick the method that fits the gap; name it in the notes so the choice is legible (NS3).
```

- [ ] **Step 5: Run the lint to verify it passes**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `30 passed, 0 failed`, `EXIT=0`.

- [ ] **Step 6: Commit**

```bash
wsl.exe -e bash -lc 'cd /root/projects/superpowers && git add skills/product-discovery/SKILL.md skills/product-discovery/elicitation-methods.md scripts/lint-fork-customizations.sh && git commit -q -m "feat(skills): add product-discovery + shared elicitation menu"'
```

---

### Task 3: `architecture-design` skill + implementation-readiness gate

**Files:**
- Create: `skills/architecture-design/SKILL.md`
- Modify: `scripts/lint-fork-customizations.sh`

**Interfaces:**
- Consumes: the PRD produced by `product-discovery`; the existing `writing-plans` → Adversarial Plan Review panel (reused as the readiness gate).
- Produces: the `architecture-design` skill. Markers `## Implementation-Readiness Gate`, `PASS / CONCERNS / FAIL`. Writes `docs/superpowers/architecture/architecture.md` and `adr/NNN-<slug>.md` at runtime.

- [ ] **Step 1: Add the failing lint checks**

Append to `scripts/lint-fork-customizations.sh`:

```bash
# 13. BMAD absorption — architecture-design + readiness gate
AD="skills/architecture-design/SKILL.md"
check "architecture-design: readiness gate section"  "$AD" "## Implementation-Readiness Gate"
check "architecture-design: PASS/CONCERNS/FAIL verdict" "$AD" "PASS / CONCERNS / FAIL"
```

- [ ] **Step 2: Run the lint to verify it fails**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `30 passed, 2 failed`, `EXIT=1`.

- [ ] **Step 3: Create the `architecture-design` skill**

Create `skills/architecture-design/SKILL.md`:

```markdown
---
name: architecture-design
description: Use after a PRD is approved (or when a real architectural decision is needed) — writes the durable architecture doc and ADRs, then runs the readiness gate
---

# Architecture Design

Turn an approved PRD into a durable architecture the whole project references, then gate
implementation readiness. Project altitude; runs once per product or on reevaluation.

## Artifacts

- `docs/superpowers/architecture/architecture.md` — components, interfaces, data model, tech choices.
- `docs/superpowers/architecture/adr/NNN-<slug>.md` — one ADR per significant decision: context,
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
```

- [ ] **Step 4: Run the lint to verify it passes**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `32 passed, 0 failed`, `EXIT=0`.

- [ ] **Step 5: Commit**

```bash
wsl.exe -e bash -lc 'cd /root/projects/superpowers && git add skills/architecture-design/SKILL.md scripts/lint-fork-customizations.sh && git commit -q -m "feat(skills): add architecture-design + implementation-readiness gate"'
```

---

### Task 4: `reevaluation` skill (supersede, don't rewrite)

**Files:**
- Create: `skills/reevaluation/SKILL.md`
- Modify: `scripts/lint-fork-customizations.sh`

**Interfaces:**
- Consumes: `skill-router` (which routes major changes here) and the upward-escalation signal added to `subagent-driven-development` in Task 8.
- Produces: the `reevaluation` skill. Markers `## Supersede, Don't Rewrite`, `Completed work is immutable`.

**Note (apostrophe):** the marker `## Supersede, Don't Rewrite` contains an apostrophe. Author both the skill heading and the lint `check` line with the Edit/Write tool (direct file edit) — never by echoing the line through a single-quoted `bash -lc '...'` payload, where the `Don't` apostrophe would terminate the payload early. `grep -qF` matches it correctly once it is in the file.

- [ ] **Step 1: Add the failing lint checks**

Append to `scripts/lint-fork-customizations.sh`:

```bash
# 14. BMAD absorption — reevaluation (supersede, don't rewrite)
RE="skills/reevaluation/SKILL.md"
check "reevaluation: supersede-not-rewrite section"  "$RE" "## Supersede, Don't Rewrite"
check "reevaluation: completed-work-immutable rule"  "$RE" "Completed work is immutable"
```

- [ ] **Step 2: Run the lint to verify it fails**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `32 passed, 2 failed`, `EXIT=1`.

- [ ] **Step 3: Create the `reevaluation` skill**

Create `skills/reevaluation/SKILL.md`:

```markdown
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
```

- [ ] **Step 4: Run the lint to verify it passes**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `34 passed, 0 failed`, `EXIT=0`.

- [ ] **Step 5: Commit**

```bash
wsl.exe -e bash -lc 'cd /root/projects/superpowers && git add skills/reevaluation/SKILL.md scripts/lint-fork-customizations.sh && git commit -q -m "feat(skills): add reevaluation (supersede-not-rewrite course-correct)"'
```

---

### Task 5: Graft the elicitation pointer into `brainstorming`

**Files:**
- Modify: `skills/brainstorming/SKILL.md` (add a bullet under "Understanding the idea")
- Modify: `scripts/lint-fork-customizations.sh`

**Interfaces:**
- Consumes: the shared `elicitation-methods.md` created in Task 2.
- Produces: marker `../product-discovery/elicitation-methods.md` in `brainstorming/SKILL.md`.

- [ ] **Step 1: Add the failing lint check**

Append to `scripts/lint-fork-customizations.sh`:

```bash
# 15. BMAD absorption — elicitation menu grafted into brainstorming
BR="skills/brainstorming/SKILL.md"
check "brainstorming: elicitation menu pointer" "$BR" "../product-discovery/elicitation-methods.md"
```

- [ ] **Step 2: Run the lint to verify it fails**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `34 passed, 1 failed`, `EXIT=1`.

- [ ] **Step 3: Graft the pointer**

In `skills/brainstorming/SKILL.md`, under **The Process → Understanding the idea**, after the bullet ``- Focus on understanding: purpose, constraints, success criteria``, add:

```markdown
- When an answer is shallow or an assumption is load-bearing, offer a named method from [elicitation-methods.md](../product-discovery/elicitation-methods.md) (pre-mortem, inversion, first-principles, …). Proportional — not every question (NS2).
```

- [ ] **Step 4: Run the lint to verify it passes**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `35 passed, 0 failed`, `EXIT=0`.

- [ ] **Step 5: Commit**

```bash
wsl.exe -e bash -lc 'cd /root/projects/superpowers && git add skills/brainstorming/SKILL.md scripts/lint-fork-customizations.sh && git commit -q -m "feat(brainstorming): offer the shared elicitation menu"'
```

---

### Task 6: Graft scale-adaptive depth into `writing-plans` Task Right-Sizing

**Files:**
- Modify: `skills/writing-plans/SKILL.md` (`## Task Right-Sizing`)
- Modify: `scripts/lint-fork-customizations.sh`

**Interfaces:**
- Consumes: `skill-router` (cross-referenced).
- Produces: marker `Match planning depth to project size` in `writing-plans/SKILL.md`.

- [ ] **Step 1: Add the failing lint check**

Append to `scripts/lint-fork-customizations.sh`:

```bash
# 16. BMAD absorption — scale-adaptive depth grafted into writing-plans
check "writing-plans: scale-adaptive depth note" "$WP" "Match planning depth to project size"
```

- [ ] **Step 2: Run the lint to verify it fails**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `35 passed, 1 failed`, `EXIT=1`.

- [ ] **Step 3: Graft the note**

In `skills/writing-plans/SKILL.md`, insert at the end of the `## Task Right-Sizing` section —
immediately **before** the next heading `## Bite-Sized Task Granularity`. (Anchor on those two
single-line headings; do not search for the section's closing sentence, which is line-wrapped in the
file.) Add:

```markdown

Match planning depth to project size (see skill-router): a trivial change skips brainstorming and
the project altitude; a new product earns the full discovery → PRD → architecture pass. Spending
the same ceremony on every task is the failure this guards against (NS2).
```

- [ ] **Step 4: Run the lint to verify it passes**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `36 passed, 0 failed`, `EXIT=0`.

- [ ] **Step 5: Commit**

```bash
wsl.exe -e bash -lc 'cd /root/projects/superpowers && git add skills/writing-plans/SKILL.md scripts/lint-fork-customizations.sh && git commit -q -m "feat(writing-plans): scale-adaptive planning depth"'
```

---

### Task 7: Finding A — oracle strength in `writing-plans` and `test-driven-development`

**Files:**
- Modify: `skills/writing-plans/SKILL.md` (new `## Test Oracle Strength` section after `## API Evidence`)
- Modify: `skills/test-driven-development/SKILL.md` (new `## Oracle Strength` section after `## Good Tests`)
- Modify: `scripts/lint-fork-customizations.sh`

**Interfaces:**
- Produces: markers `behaviorally-independent assertions` (writing-plans) and `survive a deliberately wrong implementation` (test-driven-development). Consumed conceptually by Task 8's AC→VA mapping.

- [ ] **Step 1: Add the failing lint checks**

Append to `scripts/lint-fork-customizations.sh`:

```bash
# 17. BMAD absorption — Finding A: oracle-strengthening tests
TDD="skills/test-driven-development/SKILL.md"
check "writing-plans: oracle-strength assertions"   "$WP"  "behaviorally-independent assertions"
check "test-driven-development: oracle-strength rule" "$TDD" "survive a deliberately wrong implementation"
```

- [ ] **Step 2: Run the lint to verify it fails**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `36 passed, 2 failed`, `EXIT=1`.

- [ ] **Step 3: Graft `writing-plans`**

In `skills/writing-plans/SKILL.md`, immediately after the `## API Evidence` section (before `## Remember`), add:

```markdown
## Test Oracle Strength

A Verification Artifact is only as good as the test behind it. Prefer
**behaviorally-independent assertions** — a test that asserts the real observable outcome, not the
shape of the implementation. For logic-heavy acceptance criteria, propose at least one property /
invariant test alongside the example test, and trace each acceptance criterion to the test that
covers it (AC → test). For P0/P1 (highest-risk) criteria, demand assertions strong enough that a
wrong implementation fails them; run mutation testing on the changed module when the toolchain
supports it.

```

- [ ] **Step 4: Graft `test-driven-development`**

In `skills/test-driven-development/SKILL.md`, immediately after the `## Good Tests` section (before `## Why Order Matters`), add:

```markdown
## Oracle Strength

A test that passes is not enough — it must fail when the code is wrong. After GREEN, sanity-check
that your assertion would survive a deliberately wrong implementation: if you broke the code, would
this test catch it? Prefer assertions on real observable behavior over assertions that mirror the
implementation's shape. For logic-heavy code, add a property or invariant test that covers the rule,
not just one example; when the toolchain supports it, a mutation run is the cheapest proof your
tests bite.

```

- [ ] **Step 5: Run the lint to verify it passes**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `38 passed, 0 failed`, `EXIT=0`.

- [ ] **Step 6: Commit**

```bash
wsl.exe -e bash -lc 'cd /root/projects/superpowers && git add skills/writing-plans/SKILL.md skills/test-driven-development/SKILL.md scripts/lint-fork-customizations.sh && git commit -q -m "feat(skills): Finding A — oracle-strengthening test guidance"'
```

---

### Task 8: Consumption contract — the anti-duplication seam

**Files:**
- Modify: `skills/writing-plans/SKILL.md` (new `## Consuming Project Artifacts` section after `## Test Oracle Strength`)
- Modify: `skills/subagent-driven-development/SKILL.md` (add the upward-escalation clause in `## Handling Implementer Status` → BLOCKED)
- Modify: `scripts/lint-fork-customizations.sh`

**Interfaces:**
- Consumes: `product-discovery` (PRD/ACs), `architecture-design` (architecture/ADRs), `reevaluation` (escalation target).
- Produces: markers `acceptance criteria become Verification Artifacts` (writing-plans) and `escalate to reevaluation` (subagent-driven-development).

- [ ] **Step 1: Add the failing lint checks**

Append to `scripts/lint-fork-customizations.sh`:

```bash
# 18. BMAD absorption — consumption contract (anti-duplication seam)
check "writing-plans: AC→VA consumption seam"        "$WP"  "acceptance criteria become Verification Artifacts"
check "subagent-driven: upward escalation to reeval" "$SDD" "escalate to reevaluation"
```

- [ ] **Step 2: Run the lint to verify it fails**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `38 passed, 2 failed`, `EXIT=1`.

- [ ] **Step 3: Graft `writing-plans`**

In `skills/writing-plans/SKILL.md`, immediately after the `## Test Oracle Strength` section added in Task 7 (before `## Remember`), add: (Task 7 must already be applied — `## Test Oracle Strength` is the anchor it creates; if that heading is absent, stop and run Task 7 first.)

```markdown
## Consuming Project Artifacts

When the project altitude has run, a feature plan **reads** its artifacts instead of re-deriving them:

- The PRD epic's acceptance criteria become Verification Artifacts — each Gherkin AC maps to a VA
  bullet with its observable delta (and inherits the oracle-strength rule above).
- Cite `architecture.md` / the relevant ADRs in Global Constraints and Interfaces rather than
  re-deciding architecture in the plan.
- Do not re-run product-discovery or re-author PRD-level content for a feature an epic already
  covers (no-re-spec).
- If planning reveals the architecture is wrong, escalate to `reevaluation` — do not quietly
  redesign inside the plan.

```

- [ ] **Step 4: Graft `subagent-driven-development`**

In `skills/subagent-driven-development/SKILL.md`, inside `## Handling Implementer Status` → **BLOCKED**, after item ``4. If the plan itself is wrong, escalate to the human`` and before the ``**Never** ignore an escalation`` line, add:

```markdown
5. If the blocker is architectural — the plan builds on an architecture decision that turns out wrong — escalate to reevaluation rather than letting the implementer redesign. This is the upward path of the consumption contract.
```

- [ ] **Step 5: Run the lint to verify it passes**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `40 passed, 0 failed`, `EXIT=0`.

- [ ] **Step 6: Commit**

```bash
wsl.exe -e bash -lc 'cd /root/projects/superpowers && git add skills/writing-plans/SKILL.md skills/subagent-driven-development/SKILL.md scripts/lint-fork-customizations.sh && git commit -q -m "feat(skills): consumption contract (AC→VA, architecture cite, upward escalation)"'
```

---

### Task 9 (final): Update documentation

**Files:**
- Modify: `README.md`
- Modify: `RELEASE-NOTES.md`

- [ ] **Step 1: Read the current docs**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && grep -nE "behaviors|24 checks|eleven" README.md'`
Note the exact current count strings (the prior round left README at "eleven behaviors" / "24 checks").

- [ ] **Step 2: Update README counts**

In `README.md`, using the exact strings Step 1 surfaced, change the behavior-count word (currently `eleven`) to `fifteen` (4 new skills: skill-router, product-discovery, architecture-design, reevaluation — the elicitation menu, scale-adaptive depth, Finding A, and the consumption seam are grafts, not separate behaviors), and change the `24 checks` string to `40 checks`. If Step 1 shows different wording than `eleven` / `24 checks` (e.g. a digit, or `24-check`), replace whatever it actually found — do not assume the literals. Add a short bullet block after the existing behavior list:

```markdown
- **Project altitude (BMAD absorption):** `skill-router` routes work by scale (trivial → feature → project); `product-discovery` writes the brief + PRD; `architecture-design` writes the durable architecture + ADRs and runs a PASS/CONCERNS/FAIL readiness gate (reusing the review panel); `reevaluation` handles major change by superseding — not rewriting — completed work.
- **Grafts:** a shared elicitation-methods menu (offered from `brainstorming` and `product-discovery`), scale-adaptive planning depth, and Finding A (oracle-strengthening test assertions). `40 checks`.
```

- [ ] **Step 3: Add a RELEASE-NOTES entry**

Prepend a new entry to `RELEASE-NOTES.md` (above the most recent entry):

```markdown
## Fork: BMAD absorption — unified planning OS (2026-06-19)

Absorbs BMAD's effective project-altitude capabilities into the fork as native skills rather than
integrating a second tool. Adds `skill-router` (scale-adaptive routing), `product-discovery`
(brief + PRD with risk-tiered Gherkin acceptance criteria), `architecture-design` (durable
architecture + ADRs + an implementation-readiness gate that reuses the existing multi-lens review
panel), and `reevaluation` (major course-correct that supersedes completed work instead of
rewriting it — fixing BMAD's known Agile-violating behavior). Grafts: a shared elicitation-methods
menu offered from `brainstorming` and `product-discovery`; scale-adaptive planning depth in
`writing-plans`; and Finding A (oracle-strengthening assertions) in `writing-plans` and
`test-driven-development`. The feature altitude consumes project artifacts (acceptance criteria →
Verification Artifacts; architecture cited in plan constraints) instead of re-deriving them.
Deliberately rejects BMAD's persona sprawl, document sharding, party-mode, review-issue quotas, and
sprint machinery — all poor fits for a solo operator. Structural lint grows 24 → 40 checks.
```

- [ ] **Step 4: Verify**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && grep -F "40 checks" README.md && grep -F "BMAD absorption" RELEASE-NOTES.md && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: both `grep`s match, lint prints `40 passed, 0 failed`, `EXIT=0`.

- [ ] **Step 5: Commit**

```bash
wsl.exe -e bash -lc 'cd /root/projects/superpowers && git add README.md RELEASE-NOTES.md && git commit -q -m "docs: document BMAD absorption (15 behaviors, 40 lint checks)"'
```
