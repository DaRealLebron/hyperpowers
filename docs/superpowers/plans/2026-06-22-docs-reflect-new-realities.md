# Docs Reflect New Realities — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use hyperpowers:subagent-driven-development (recommended) or hyperpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update this repo's living docs to reflect two shipped arcs (BMAD project-altitude absorption + project-memory curation), and dogfood the new `curating-project-memory` model on the repo's own memory files (`CLAUDE.md` / `AGENTS.md` / `GEMINI.md`).

**Architecture:** Pure documentation + memory-file edits — no skill text, no new lint marker. `docs/workflow.md` and `docs/superpowers/bmad-absorption-happy-path.md` are brought current (the stale `18 checks` → `49 checks`, the project altitude cross-linked, the curation checkpoint added). The repo's own `CLAUDE.md` gains the two missing 3-layer sections (`## Context`, `## Documentation index`) **additively** — its tuned contributor-rule content is preserved verbatim — and `AGENTS.md` is regenerated as a real full mirror of `CLAUDE.md` (it is currently a useless 1-line stub). The structural lint must remain `49 passed` (regression only).

**Tech Stack:** Markdown docs; Bash via the Bash tool (verification greps + `cp` for the mirror).

## Global Constraints

- **Environment.** Commands run via the Bash tool; `bash` works on this Windows host directly. The lint runs as plain `bash scripts/lint-fork-customizations.sh` (no WSL).
- **Explicit-path staging.** Stage every commit by **explicit path** — never `git add -A`.
- **No new lint marker.** This is a docs/dogfood change. The structural lint stays at **49 checks**; every task (and the final gate) re-runs it only as a **regression check** (`49 passed, 0 failed`).
- **Do NOT touch frozen records.** Never edit anything under `docs/superpowers/plans/` or `docs/superpowers/specs/` (except this plan file). Those are point-in-time records and their old counts (`18`, `24`, `40`) are historical and correct.
- **`CLAUDE.md` edits are additive only.** Preserve every existing section and its exact wording (the contributor guidelines are deliberately tuned). Only *add* the two new sections. Changes to `CLAUDE.md` should be shown as a diff for operator approval before committing (per the repo's own curation autonomy: structural changes are confirmed first).
- **`AGENTS.md` is generated, never hand-written.** It is a verbatim `cp` of the finalized `CLAUDE.md`. Task 4 must run **after** Task 3 so the mirror is current.
- **No `RELEASE-NOTES.md` entry.** This is doc reconciliation + repo hygiene, not a new user-facing behavior; the curation feature already has its release entry.
- **Branch.** Work on `feat/docs-reflect-new-realities` in a global worktree under `~/.config/superpowers/worktrees/hyperpowers/` (the operator's confirmed worktree location). Integrate later via `finishing-a-development-branch`.

## Verification Artifacts

Each is an observable delta (false before this plan, true after):

- `grep -c '49 checks' docs/workflow.md` → `1`, and `grep -c '18 checks' docs/workflow.md` → `0` (the stale count is gone).
- `grep -F 'Two newer arcs' docs/workflow.md` matches, and `grep -F 'superpowers/bmad-absorption-happy-path.md' docs/workflow.md` matches (the project altitude is narrated and cross-linked, not duplicated).
- `grep -F 'curate project memory' docs/superpowers/bmad-absorption-happy-path.md` matches (the merge node now shows the curation pass).
- `grep -c '## Context' CLAUDE.md` → `1` and `grep -c '## Documentation index' CLAUDE.md` → `1` (the two missing layers added), while `grep -F '## What We Will Not Accept' CLAUDE.md` still matches (existing tuned content preserved).
- `diff -q CLAUDE.md AGENTS.md` prints nothing and exits 0 (AGENTS.md is now an exact mirror — it was a 1-line stub before), and `grep -F '## Pull Request Requirements' AGENTS.md` matches.
- `grep -F '@./CLAUDE.md' GEMINI.md` matches (Gemini now loads the guidelines too).
- `bash scripts/lint-fork-customizations.sh` still prints `49 passed, 0 failed` (no regression).

---

### Task 1: Bring `docs/workflow.md` current (count + project altitude + curation)

**Files:**
- Modify: `docs/workflow.md`

**Interfaces:** Adds a `## Two newer arcs` section that cross-links `docs/superpowers/bmad-absorption-happy-path.md` (consumed by readers; not by code).

- [ ] **Step 1: Fix the stale lint count**

In `docs/workflow.md`, replace the exact string:

`lint \`scripts/lint-fork-customizations.sh\` (no LLM, 18 checks) guards these behaviors.`

with:

`lint \`scripts/lint-fork-customizations.sh\` (no LLM, 49 checks) guards these behaviors.`

- [ ] **Step 2: Append the "Two newer arcs" section**

Append the following at the very END of `docs/workflow.md` (after the final paragraph that ends `…guards these behaviors.`), leaving one blank line before it:

```markdown
## Two newer arcs (layered on the pipeline above)

The charts above are the day-to-day **feature** pipeline. Two later arcs extend it:

- **Project altitude (BMAD absorption).** Larger work is first routed by `skill-router`: greenfield
  / cross-cutting work runs `product-discovery` → `architecture-design` → an
  implementation-readiness gate, then drops per-epic into the feature pipeline above, which *reads*
  those project artifacts instead of re-deriving them. Full diagram and "what came from where":
  [`docs/superpowers/bmad-absorption-happy-path.md`](superpowers/bmad-absorption-happy-path.md).
- **Project-memory curation.** At completion, `finishing-a-development-branch` runs a
  `curating-project-memory` pass that drifts the project's `CLAUDE.md` (canonical) / generated
  `AGENTS.md` / scoped `.claude/rules/` / `docs/` toward an optimal, well-linked state;
  `writing-plans`' final documentation task now names `CLAUDE.md` / `AGENTS.md`, and
  `verification-before-completion` checks that project memory is current. Design:
  [`docs/superpowers/specs/2026-06-22-project-memory-curation-design.md`](superpowers/specs/2026-06-22-project-memory-curation-design.md).
```

- [ ] **Step 3: Verify the deltas**

Run:
```
cd /c/Users/12026/.config/superpowers/worktrees/hyperpowers/feat-docs-reflect-new-realities
echo "49:$(grep -c '49 checks' docs/workflow.md) 18:$(grep -c '18 checks' docs/workflow.md)"
grep -F 'Two newer arcs' docs/workflow.md >/dev/null && grep -F 'superpowers/bmad-absorption-happy-path.md' docs/workflow.md >/dev/null && echo LINKS_OK
```
Expected: `49:1 18:0` and `LINKS_OK`.

- [ ] **Step 4: Commit**

```bash
cd /c/Users/12026/.config/superpowers/worktrees/hyperpowers/feat-docs-reflect-new-realities
git add docs/workflow.md
git commit -m "docs(workflow): refresh count, add project altitude + memory curation arcs"
```

---

### Task 2: Add the curation checkpoint to `bmad-absorption-happy-path.md`

**Files:**
- Modify: `docs/superpowers/bmad-absorption-happy-path.md`

- [ ] **Step 1: Show curation on the merge node**

In `docs/superpowers/bmad-absorption-happy-path.md`, replace the exact string:

`Finish(["finishing-a-development-branch → merge"])`

with:

`Finish(["finishing-a-development-branch<br/>+ curate project memory → merge"])`

- [ ] **Step 2: Add the explanatory sentence**

In the same file, find this exact text (end of the legend paragraph, immediately before the `## What came from where` heading):

```
re-enters the project altitude through `reevaluation`.
```

Replace it with:

```
re-enters the project altitude through `reevaluation`.

Since 2026-06-22 the merge step also runs a `curating-project-memory` pass: project memory
(`CLAUDE.md` canonical → generated `AGENTS.md`, scoped `.claude/rules/`, and `docs/`) drifts toward
an optimal, well-linked state as a side effect of finishing work. Design:
`docs/superpowers/specs/2026-06-22-project-memory-curation-design.md`.
```

(If the exact string is not found verbatim, STOP and report NEEDS_CONTEXT with what you see — do not guess.)

- [ ] **Step 3: Verify the deltas**

Run:
```
cd /c/Users/12026/.config/superpowers/worktrees/hyperpowers/feat-docs-reflect-new-realities
grep -F 'curate project memory' docs/superpowers/bmad-absorption-happy-path.md >/dev/null && grep -F 'curating-project-memory` pass' docs/superpowers/bmad-absorption-happy-path.md >/dev/null && echo CURATION_OK
```
Expected: `CURATION_OK`.

- [ ] **Step 4: Commit**

```bash
cd /c/Users/12026/.config/superpowers/worktrees/hyperpowers/feat-docs-reflect-new-realities
git add docs/superpowers/bmad-absorption-happy-path.md
git commit -m "docs(happy-path): note the curating-project-memory pass at merge"
```

---

### Task 3: Dogfood the repo's `CLAUDE.md` (additive `## Context` + `## Documentation index`)

**Files:**
- Modify: `CLAUDE.md` (additive only — preserve all existing content)

**Note:** Show the diff to the operator for approval before committing (the contributor guidelines are tuned content).

- [ ] **Step 1: Add the `## Context` section after the title**

In `CLAUDE.md`, replace this exact text (the title and the first heading, lines 1–3):

```
# Superpowers — Contributor Guidelines

## If You Are an AI Agent
```

with:

```
# Superpowers — Contributor Guidelines

## Context

Superpowers is a zero-dependency, multi-harness skills plugin: one skill library projected to
Claude Code, Codex, Cursor, Kimi, OpenCode, Pi, Gemini, and more. Layout: skills in
`skills/<name>/SKILL.md`; per-harness manifests in `.claude-plugin/`, `.codex-plugin/`,
`.cursor-plugin/`, …; docs in `docs/`; plugin-infrastructure tests in `tests/`. This fork layers
advisory customizations on upstream, guarded by a deterministic structural lint.

`CLAUDE.md` is the canonical project memory for this repo; `AGENTS.md` is a generated full mirror
(regenerate with `cp CLAUDE.md AGENTS.md`) so Codex and other AGENTS.md-native tools get the same
guidelines.

- **Verify the fork customizations:** `bash scripts/lint-fork-customizations.sh` (no LLM; structure
  only — currently 49 checks).
- **Orientation & workflow:** see the Documentation index at the end of this file.

## If You Are an AI Agent
```

- [ ] **Step 2: Add the `## Documentation index` at the end**

In `CLAUDE.md`, find this exact line (the last bullet of the `## General` section, at the end of the file):

```
- Describe the problem you solved, not just what you changed
```

Replace it with:

```
- Describe the problem you solved, not just what you changed

## Documentation index

- [`docs/workflow.md`](docs/workflow.md) — the fork's happy-path pipeline (upstream vs. this fork).
- [`docs/superpowers/bmad-absorption-happy-path.md`](docs/superpowers/bmad-absorption-happy-path.md) — the unified planning-OS altitude routing (Superpowers + absorbed BMAD).
- [`docs/testing.md`](docs/testing.md) — how the plugin and skills are tested.
- [`docs/porting-to-a-new-harness.md`](docs/porting-to-a-new-harness.md) — integrating a new harness.
- `docs/superpowers/specs/` and `docs/superpowers/plans/` — dated design specs and implementation plans (point-in-time records).
```

(If either exact anchor is not found verbatim, STOP and report NEEDS_CONTEXT — do not guess.)

- [ ] **Step 3: Verify additive (new sections present, old content intact)**

Run:
```
cd /c/Users/12026/.config/superpowers/worktrees/hyperpowers/feat-docs-reflect-new-realities
echo "Context:$(grep -c '## Context' CLAUDE.md) DocIndex:$(grep -c '## Documentation index' CLAUDE.md)"
for s in '## If You Are an AI Agent' '## Pull Request Requirements' '## What We Will Not Accept' '## New Harness Support' '## General'; do grep -qF "$s" CLAUDE.md && echo "KEPT: $s" || echo "LOST: $s"; done
```
Expected: `Context:1 DocIndex:1` and all five `KEPT:` lines (no `LOST:`).

- [ ] **Step 4: Commit**

```bash
cd /c/Users/12026/.config/superpowers/worktrees/hyperpowers/feat-docs-reflect-new-realities
git add CLAUDE.md
git commit -m "docs: dogfood 3-layer memory on CLAUDE.md (add Context + Documentation index)"
```

---

### Task 4: Regenerate `AGENTS.md` mirror + wire `GEMINI.md`

**Files:**
- Modify: `AGENTS.md` (regenerate as a verbatim mirror of `CLAUDE.md`)
- Modify: `GEMINI.md` (append a `@./CLAUDE.md` import)

**Depends on:** Task 3 (CLAUDE.md must be final first).

- [ ] **Step 1: Confirm the stale stub before overwriting**

Run:
```
cd /c/Users/12026/.config/superpowers/worktrees/hyperpowers/feat-docs-reflect-new-realities
echo "AGENTS.md before:" && cat AGENTS.md && echo "---(end)---"
```
Expected: it currently contains only the literal text `CLAUDE.md` (the useless stub).

- [ ] **Step 2: Regenerate the mirror**

Run:
```
cd /c/Users/12026/.config/superpowers/worktrees/hyperpowers/feat-docs-reflect-new-realities
cp CLAUDE.md AGENTS.md
diff -q CLAUDE.md AGENTS.md && echo MIRROR_OK
```
Expected: `diff -q` prints nothing (identical) and `MIRROR_OK`.

- [ ] **Step 3: Append the CLAUDE.md import to `GEMINI.md`**

In `GEMINI.md`, replace this exact line:

`@./skills/using-hyperpowers/references/gemini-tools.md`

with:

```
@./skills/using-hyperpowers/references/gemini-tools.md
@./CLAUDE.md
```

- [ ] **Step 4: Verify**

Run:
```
cd /c/Users/12026/.config/superpowers/worktrees/hyperpowers/feat-docs-reflect-new-realities
diff -q CLAUDE.md AGENTS.md && grep -F '## Pull Request Requirements' AGENTS.md >/dev/null && echo AGENTS_OK
grep -F '@./CLAUDE.md' GEMINI.md >/dev/null && echo GEMINI_OK
```
Expected: `AGENTS_OK` and `GEMINI_OK`.

- [ ] **Step 5: Commit**

```bash
cd /c/Users/12026/.config/superpowers/worktrees/hyperpowers/feat-docs-reflect-new-realities
git add AGENTS.md GEMINI.md
git commit -m "docs: regenerate AGENTS.md as a real CLAUDE.md mirror; load guidelines in GEMINI.md"
```

---

### Task 5 (final): Whole-change verification gate

No separate "Update documentation" task applies — the entire plan *is* the documentation update. This final task is the verification gate (no new file changes, no commit).

- [ ] **Step 1: Re-run every Verification Artifact**

Run:
```
cd /c/Users/12026/.config/superpowers/worktrees/hyperpowers/feat-docs-reflect-new-realities
echo "== workflow ==" && echo "49:$(grep -c '49 checks' docs/workflow.md) 18:$(grep -c '18 checks' docs/workflow.md)" && grep -F 'superpowers/bmad-absorption-happy-path.md' docs/workflow.md >/dev/null && echo xref_ok
echo "== happy-path ==" && grep -F 'curate project memory' docs/superpowers/bmad-absorption-happy-path.md >/dev/null && echo curation_ok
echo "== CLAUDE.md ==" && echo "Context:$(grep -c '## Context' CLAUDE.md) DocIndex:$(grep -c '## Documentation index' CLAUDE.md)" && grep -qF '## What We Will Not Accept' CLAUDE.md && echo preserved_ok
echo "== AGENTS mirror ==" && diff -q CLAUDE.md AGENTS.md && echo mirror_ok
echo "== GEMINI ==" && grep -F '@./CLAUDE.md' GEMINI.md >/dev/null && echo gemini_ok
echo "== lint regression ==" && bash scripts/lint-fork-customizations.sh | tail -1
```
Expected: `49:1 18:0`, `xref_ok`, `curation_ok`, `Context:1 DocIndex:1`, `preserved_ok`, `mirror_ok` (diff prints nothing), `gemini_ok`, and `49 passed, 0 failed`.

- [ ] **Step 2: Confirm the commit set**

Run:
```
cd /c/Users/12026/.config/superpowers/worktrees/hyperpowers/feat-docs-reflect-new-realities
git log --oneline main..HEAD
git status --short && echo "(clean if blank)"
```
Expected: 4 commits (Tasks 1–4), working tree clean.
