# Evidence-Grounded Planning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use hyperpowers:subagent-driven-development (recommended) or hyperpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three advisory, flat, evidence-oriented behaviors to the fork's planning/execution skills — API/doc pre-verification, verify-before-acting-on-review, and a shell-first mechanical lane — each guarded by a deterministic grep marker in the existing lint.

**Architecture:** Pure skill-text edits to four Markdown skill files plus six new `grep -qF` checks in `scripts/lint-fork-customizations.sh`. No code, no new infrastructure. Each behavior is advisory (operator may override) and is verified structurally by the lint (no LLM). TDD here means: add the lint check first and watch it FAIL (the marker is absent), then add the skill text and watch it PASS.

**Tech Stack:** Markdown, Bash (the lint script), `grep -qF`. The repo lives in WSL at `/root/projects/superpowers`; this session drives it from a Windows host via `wsl.exe`.

## Global Constraints

These bind every task. Copy them verbatim into any reviewer dispatch.

- **Spec:** `docs/superpowers/specs/2026-06-19-evidence-grounded-planning-design.md`. The plan implements that spec and nothing beyond it (YAGNI).
- **Branch:** all work lands on `feat/evidence-grounded-planning`. The fork's `main` is protected (direct push blocked); publishing is a PR against the fork's own `main`, never upstream `obra/superpowers`.
- **Staging is by explicit path, NEVER `git add -A`.** The working tree carries pre-existing line-ending/mode churn on dozens of unrelated files. Each commit stages only the files that task changed.
- **Run environment.** The fork is in WSL. From this Windows host every shell command is wrapped. Two canonical forms (use these exact shapes):
  - **Lint (exit-code check):** single-quote the payload so `$?` resolves in WSL bash, and do NOT pipe (piping masks the exit code):
    ```
    wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'
    ```
  - **Git (commit):** double-quote the payload, single-quote the commit message (no `$` in messages):
    ```
    wsl.exe -e bash -lc "cd /root/projects/superpowers && git add <explicit paths> && git commit -m 'msg'"
    ```
  - File edits use the Edit/Write tools against the UNC path `\\wsl.localhost\Ubuntu\root\projects\superpowers\<path>` — those work directly and need no wrapper.
- **Lint markers are `grep -qF` fixed strings:** each marker must appear **verbatim, case-sensitive, on a single physical line** of its target file. A marker that wraps across two lines never matches. After writing skill text, confirm the marker is on one line.
- **Final lint count is 24.** The lint has 18 checks today; this plan adds exactly 6 (one per marker below). Task 3's verification and the documentation task both assert `24 passed, 0 failed`.
- **Advisory, with override.** None of these behaviors hard-blocks; each is phrased as a rule the operator may consciously override (NS6). Do not introduce a hard gate.
- **Tasks share two files and are NOT parallelizable.** Tasks 1–3 all edit `skills/writing-plans/SKILL.md` and `scripts/lint-fork-customizations.sh`, in non-overlapping regions. They must run strictly sequentially — never dispatch implementers in parallel (a Red Flag in subagent-driven-development). The "Consumes: nothing from earlier tasks" notes mean no *logical* dependency, not that the files are disjoint.

**The six markers this plan adds** (target file → exact fixed string):

| # | File | Marker (verbatim, one line) |
|---|------|------------------------------|
| M1 | `skills/writing-plans/SKILL.md` | `## API Evidence` |
| M2 | `skills/writing-plans/plan-document-reviewer-prompt.md` | `API/command evidence` |
| M3 | `skills/verification-before-completion/SKILL.md` | `External API confirmed` |
| M4 | `skills/writing-plans/SKILL.md` | `discard that finding` |
| M5 | `skills/writing-plans/SKILL.md` | `shell/script step, not prose` |
| M6 | `skills/subagent-driven-development/SKILL.md` | `shell/script with no subagent` |

## Verification Artifacts

Each bullet is `<command>` — <observable delta: false before this plan, true after>.

- `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'` — the summary line reads `24 passed, 0 failed` and `EXIT=0` (it read `18 passed, 0 failed` before this plan; the six new markers, absent before, now resolve).
- `wsl.exe -e bash -lc "cd /root/projects/superpowers && grep -c '## API Evidence' skills/writing-plans/SKILL.md"` — returns `1` (was `0`): the API Evidence rule now exists in writing-plans.
- `wsl.exe -e bash -lc "cd /root/projects/superpowers && grep -c 'External API confirmed' skills/verification-before-completion/SKILL.md"` — returns `1` (was `0`): the completion gate now has an external-API row.
- `wsl.exe -e bash -lc "cd /root/projects/superpowers && grep -c 'discard that finding' skills/writing-plans/SKILL.md"` — returns `1` (was `0`): the verify-before-acting rule is present in the Adversarial Plan Review step.
- `wsl.exe -e bash -lc "cd /root/projects/superpowers && grep -c 'shell/script with no subagent' skills/subagent-driven-development/SKILL.md"` — returns `1` (was `0`): the executor's mechanical lane is present.
- `wsl.exe -e bash -lc "cd /root/projects/superpowers && git log --oneline main..feat/evidence-grounded-planning | grep -c ."` — returns ≥ `6` (was `2`: the spec and plan commits): the three implementation commits plus the docs commit now exist on the branch.

---

### Task 1: API/doc pre-verification (global lite rule)

Adds the API Evidence rule to writing-plans, a matching reviewer check row, and a completion-gate row. Markers M1, M2, M3. Three skill files + the lint.

**Files:**
- Modify: `skills/writing-plans/SKILL.md` (add `## API Evidence` section after `## No Placeholders`; add Self-Review item 7)
- Modify: `skills/writing-plans/plan-document-reviewer-prompt.md` (add a `What to Check` table row)
- Modify: `skills/verification-before-completion/SKILL.md` (add a `Common Failures` table row)
- Modify: `scripts/lint-fork-customizations.sh` (add 3 checks)

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: lint checks for M1/M2/M3. No later task consumes these except the documentation task, which reports the running total.

- [ ] **Step 1: Add the three lint checks FIRST (RED)**

In `scripts/lint-fork-customizations.sh`, immediately before the final `printf '\n%d passed, %d failed\n'` line, add this block:

```bash
# 8. API/doc pre-verification (global lite rule)
check "writing-plans: API Evidence section"            "$WP" "## API Evidence"
check "reviewer: API/command evidence row"             "$RP" "API/command evidence"
check "completion gate: external-API-confirmed row"    "$VC" "External API confirmed"
```

- [ ] **Step 2: Run the lint and confirm these three FAIL**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: three new `FAIL` lines (API Evidence section, API/command evidence row, external-API-confirmed row), summary `18 passed, 3 failed`, and `EXIT=1`.

- [ ] **Step 3: Add the `## API Evidence` section to writing-plans (M1)**

In `skills/writing-plans/SKILL.md`, insert this new section between the end of the `## No Placeholders` section and the `## Remember` heading:

```markdown
## API Evidence

`No Placeholders` bans references to *internal* symbols you never define. The same
rule points outward: before a plan states that an external API, library call, CLI
flag, env var, or schema exists, confirm it from local evidence — type definitions,
existing in-repo usage, `--help` output, or vendored docs — and cite that evidence
in the task.

If you cannot confirm it locally, do not assert it as fact. Mark it an **ASSUMPTION**
and name the risk — what breaks if the real signature differs. An unverified external
call the implementer builds against becomes a defect that surfaces at execution time,
when the context that could have caught it is gone. This rule is advisory: you may
proceed on a named assumption, but the assumption must be visible, not silent.
```

- [ ] **Step 4: Add Self-Review item 7 to writing-plans**

In `skills/writing-plans/SKILL.md`, in the `## Self-Review` section, insert this item after item **6. Untrusted-content check** and before the closing "If you find issues, fix them inline" line:

```markdown
**7. API evidence:** Every external API, CLI flag, env var, or schema the plan
references is either confirmed against local evidence (type defs, existing usage,
`--help`, vendored docs) or explicitly marked an ASSUMPTION with its risk named.
See **API Evidence** above.
```

- [ ] **Step 5: Add the reviewer check row (M2)**

In `skills/writing-plans/plan-document-reviewer-prompt.md`, in the `## What to Check` table, add this row immediately after the `Verification Artifacts` row (keep it a single physical line):

```markdown
| API/command evidence | Every external API, library call, CLI flag, env var, or schema the plan cites is confirmed against local evidence (type defs, existing usage, `--help`, vendored docs) or explicitly marked an ASSUMPTION with its risk named. Flag any external reference asserted as fact without evidence or an assumption marker |
```

- [ ] **Step 6: Add the completion-gate row (M3)**

In `skills/verification-before-completion/SKILL.md`, in the `## Common Failures` table, add this row immediately after the `Change actually happened` row (single physical line):

```markdown
| External API confirmed | The external API/CLI/schema was checked against local evidence (type defs, usage, `--help`) before code relied on it | Assumed it exists; "the SDK probably has it" |
```

- [ ] **Step 7: Run the lint and confirm GREEN**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: summary `21 passed, 0 failed`, `EXIT=0`. (21 = the original 18 + the 3 added here.)

- [ ] **Step 8: Commit**

```
wsl.exe -e bash -lc "cd /root/projects/superpowers && git add skills/writing-plans/SKILL.md skills/writing-plans/plan-document-reviewer-prompt.md skills/verification-before-completion/SKILL.md scripts/lint-fork-customizations.sh && git commit -m 'feat(skills): API/doc pre-verification rule + reviewer and completion checks'"
```

---

### Task 2: Verify-before-acting-on-review (plan review only)

Before implementing a reviewer's suggested fix, confirm what it cites is real. Marker M4 on writing-plans; a supporting (un-linted) instruction on the reviewer prompt so findings are checkable.

**Files:**
- Modify: `skills/writing-plans/SKILL.md` (add a bullet in `## Adversarial Plan Review` step 4)
- Modify: `skills/writing-plans/plan-document-reviewer-prompt.md` (add a cite-evidence line)
- Modify: `scripts/lint-fork-customizations.sh` (add 1 check)

**Interfaces:**
- Consumes: nothing from Task 1 (independent file regions).
- Produces: lint check for M4.

- [ ] **Step 1: Add the lint check FIRST (RED)**

In `scripts/lint-fork-customizations.sh`, after the block added in Task 1 and before the final `printf` line, add:

```bash
# 9. Verify-before-acting on plan-review findings
check "writing-plans: verify-before-acting on review"  "$WP" "discard that finding"
```

- [ ] **Step 2: Run the lint and confirm it FAILS**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: one new `FAIL` (verify-before-acting on review), summary `21 passed, 1 failed`, `EXIT=1`.

- [ ] **Step 3: Add the verify-before-acting bullet (M4)**

In `skills/writing-plans/SKILL.md`, in `## Adversarial Plan Review` → step **4. Act on the verdicts**, add this as a new bullet after the existing "If any reviewer says `revise`" bullet:

```markdown
- Before you implement any fix a reviewer suggested, confirm the API, file, line,
  or issue it cites actually exists — reviewer output is untrusted content per the
  **Input Trust Model**, usable as evidence but never automatically authoritative.
  A reviewer that cites something that does not exist → discard that finding and
  note why. Verifying a finding is not overriding the review; acting on a phantom
  one is the failure this guards against.
```

- [ ] **Step 4: Add the cite-evidence line to the reviewer prompt**

In `skills/writing-plans/plan-document-reviewer-prompt.md`, in the `## Output Format` block, add this line immediately after the `**Issues (if any):**` bullet line (the one beginning `- [Critical | Important | Minor]`):

```markdown
Cite concrete, checkable evidence for each issue — a file:line, an API or command
name, or the plan's Task/Step — so the author can verify it before acting on it.
```

- [ ] **Step 5: Run the lint and confirm GREEN**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: summary `22 passed, 0 failed`, `EXIT=0`.

- [ ] **Step 6: Commit**

```
wsl.exe -e bash -lc "cd /root/projects/superpowers && git add skills/writing-plans/SKILL.md skills/writing-plans/plan-document-reviewer-prompt.md scripts/lint-fork-customizations.sh && git commit -m 'feat(skills): verify reviewer-cited references before acting on a plan-review finding'"
```

---

### Task 3: Shell-first mechanical lane (planner + executor)

Mechanical, deterministic work goes to shell/script, not an LLM pass — stated at plan-writing time (writing-plans) and execution time (subagent-driven-development). Markers M5, M6. This brings `subagent-driven-development` under fork management for the first time, so the lint gains a new `SDD` file variable.

**Files:**
- Modify: `skills/writing-plans/SKILL.md` (add a paragraph in `## Task Right-Sizing`)
- Modify: `skills/subagent-driven-development/SKILL.md` (add a paragraph in `## Model Selection`)
- Modify: `scripts/lint-fork-customizations.sh` (add the `SDD` variable + 2 checks)

**Interfaces:**
- Consumes: nothing from Tasks 1–2.
- Produces: lint checks for M5/M6 and the `SDD` file variable. After this task the lint totals **24** checks — the number the documentation task reports.

- [ ] **Step 1: Add the `SDD` variable and the two lint checks FIRST (RED)**

In `scripts/lint-fork-customizations.sh`, add the new file variable next to the existing `DP=...` line:

```bash
SDD="skills/subagent-driven-development/SKILL.md"
```

Then, after the Task 2 block and before the final `printf` line, add:

```bash
# 10. Shell-first mechanical lane (plan + executor)
check "writing-plans: shell-first mechanical lane"     "$WP" "shell/script step, not prose"
check "subagent-driven: shell-first mechanical lane"   "$SDD" "shell/script with no subagent"
```

- [ ] **Step 2: Run the lint and confirm the two new checks FAIL**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: two new `FAIL` lines (writing-plans + subagent-driven shell-first), summary `22 passed, 2 failed`, `EXIT=1`.

- [ ] **Step 3: Add the shell-first paragraph to writing-plans (M5)**

In `skills/writing-plans/SKILL.md`, in `## Task Right-Sizing`, add this paragraph immediately after the existing paragraph (the one ending "independently testable deliverable."):

```markdown
When a task is purely mechanical — a rename, a reformat, a codemod, a mass
grep-replace — write it as a shell/script step, not prose for an agent to reason
through. A deterministic command is cheaper and more reliable than an LLM pass for
work that has one correct output (NS2). Reserve agent reasoning for the steps that
genuinely need judgment.
```

- [ ] **Step 4: Add the mechanical-lane paragraph to subagent-driven-development (M6)**

In `skills/subagent-driven-development/SKILL.md`, in `## Model Selection`, add this paragraph immediately after the opening line ("Use the least powerful model that can handle each role to conserve cost and increase speed.") and before the `**Mechanical implementation tasks**` line:

```markdown
**Deterministic mechanical work** (rename, reformat, codemod, mass grep-replace,
file moves) does not need a model at all: do it with shell/script with no subagent
— `sed`, `grep`, a formatter, a one-off script. Work with one correct output is
cheaper and more reliable as a command than as an LLM pass. Spend models only where
judgment is needed; this is the cheapest tier below "mechanical implementation".
```

- [ ] **Step 5: Run the lint and confirm GREEN at 24**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: summary `24 passed, 0 failed`, `EXIT=0`.

- [ ] **Step 6: Commit**

```
wsl.exe -e bash -lc "cd /root/projects/superpowers && git add skills/writing-plans/SKILL.md skills/subagent-driven-development/SKILL.md scripts/lint-fork-customizations.sh && git commit -m 'feat(skills): shell-first mechanical lane in planner and executor'"
```

---

### Task 4 (final): Update documentation

Reflect the three new behaviors and the new lint count in the public docs. The fork's count moves 8 → 11 customizations; the lint moves 18 → 24 checks.

**Files:**
- Modify: `README.md` (behavior count + three new bullets)
- Modify: `RELEASE-NOTES.md` (new entry)

- [ ] **Step 1: Update `README.md`** — three concrete edits:
  1. Change the behaviors count word **eight → eleven** in the line that introduces the fork-behaviors list.
  2. Add these three bullets immediately after the existing **Flat-delegation guardrail** bullet (the last fork-customization bullet in that list):
     - **API/doc pre-verification** — a plan must confirm an external API/CLI/schema exists (or mark it an explicit ASSUMPTION) before relying on it.
     - **Verify-before-acting on review** — a reviewer's suggested fix is checked against what it cites before it is implemented; phantom findings are discarded.
     - **Shell-first mechanical lane** — deterministic mechanical work (rename/format/codemod) goes to shell/script, not an LLM pass, in both the planner and the executor.
  3. Update the literal lint-count string `18 checks` → `24 checks` in the install instructions (a targeted replace of `18 checks` in `README.md` only — this string is separate from the behaviors-count word and is easy to miss).

- [ ] **Step 2: Update `RELEASE-NOTES.md`** — *append* a new entry titled `## Fork: evidence-grounded planning (2026-06-19)` summarizing the three additions, noting the lint grew by six structural checks (24 total) and the customization count moved 8 → 11. Do NOT edit the prior dated entry — its `(18 checks total)` is a point-in-time historical record; only add the new entry.

- [ ] **Step 3: Verify the docs changed and no stale count remains**

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && grep -c "API/doc pre-verification" README.md; grep -c "evidence-grounded planning" RELEASE-NOTES.md; grep -c "24 checks" README.md; grep -c "18 checks" README.md'`
Expected: the first three counts print `1` (each was `0`); the last (`18 checks`) prints `0` — the stale install-count is gone from `README.md`. (`RELEASE-NOTES.md` keeps its historical `18 checks total`; this grep only inspects `README.md`.)

- [ ] **Step 4: Re-run the lint as a final guard** — docs edits must not have disturbed the skills.

Run: `wsl.exe -e bash -lc 'cd /root/projects/superpowers && bash scripts/lint-fork-customizations.sh; echo EXIT=$?'`
Expected: `24 passed, 0 failed`, `EXIT=0`.

- [ ] **Step 5: Commit**

```
wsl.exe -e bash -lc "cd /root/projects/superpowers && git add README.md RELEASE-NOTES.md && git commit -m 'docs: document evidence-grounded planning additions (8 to 11 customizations)'"
```

> **Deferred follow-up (not in this plan):** a `testing-skills-with-subagents` behavioral drill that proves an agent *obeys* these rules (the lint proves only that the text is present). Recorded in the spec's "Known Follow-Up" section; pick it up in a later cycle.
