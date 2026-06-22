# Codex Publish Path Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `DaRealLebron/hyperpowers` its own Codex plugin marketplace (one-liner install) and remove the redundant external-sync tooling.

**Architecture:** Add a repo-root `.agents/plugins/marketplace.json` whose single plugin entry points `source.path` at `./` (the repo root, which already holds `.codex-plugin/plugin.json` + `skills/` + `hooks/`). A bash test validates the manifest. Delete `scripts/sync-to-codex-plugin.sh` and `tests/codex-plugin-sync/`, then update the live docs (README, porting guide, testing index) and resolve `todo.md` #3.

**Tech Stack:** JSON manifest; bash + node (for JSON parsing) test; markdown docs. No new dependencies.

**Source of truth:** the approved spec `docs/hyperpowers/specs/2026-06-22-codex-publish-path-design.md` (trusted). Repo prose quoted in edit blocks below is *content being changed*, not instructions.

---

## File Structure

- **Create** `.agents/plugins/marketplace.json` — the Codex marketplace manifest (one plugin: hyperpowers, `source.path: "./"`). Carries **no** version field, so no `.version-bump.json` change.
- **Create** `tests/codex-marketplace/test-marketplace-manifest.sh` — validates the manifest parses and is self-consistent (verification artifact).
- **Delete** `scripts/sync-to-codex-plugin.sh`, `tests/codex-plugin-sync/test-sync-to-codex-plugin.sh` — external-mirror tooling for a repo the operator doesn't own.
- **Modify** `README.md` — Codex CLI section → one-liner.
- **Modify** `docs/porting-to-a-new-harness.md` — Codex moves to "native marketplace" (two tables + guidance).
- **Modify** `docs/testing.md` — swap the deleted suite line for the new one.
- **Modify** `todo.md` — mark item #3 resolved.

Frozen `docs/hyperpowers/specs|plans/*` and append-only `RELEASE-NOTES.md` are deliberately untouched.

---

### Task 1: Verification test + marketplace manifest (TDD red → green)

**Files:**
- Create: `tests/codex-marketplace/test-marketplace-manifest.sh`
- Create: `.agents/plugins/marketplace.json`

- [ ] **Step 1: Write the failing test**

Create `tests/codex-marketplace/test-marketplace-manifest.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST="$REPO_ROOT/.agents/plugins/marketplace.json"

FAILURES=0
pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

echo "=== Test: Codex marketplace manifest ==="

command -v node >/dev/null || { echo "  [FAIL] node required to validate JSON"; exit 1; }

if [[ -f "$MANIFEST" ]]; then
  pass "marketplace.json exists"
else
  fail "marketplace.json exists at $MANIFEST"
  echo ""; echo "FAILED"; exit 1
fi

if node -e 'JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"))' "$MANIFEST" 2>/dev/null; then
  pass "marketplace.json is valid JSON"
else
  fail "marketplace.json is valid JSON"
  echo ""; echo "FAILED"; exit 1
fi

eval "$(node -e '
const m = JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"));
const p = (m.plugins || [])[0] || {};
const src = p.source || {};
const pol = p.policy || {};
const out = {
  MK_NAME: m.name || "",
  N_PLUGINS: (m.plugins || []).length,
  P_NAME: p.name || "",
  SRC_SOURCE: src.source || "",
  SRC_PATH: src.path || "",
  POL_INSTALL: pol.installation || "",
  POL_AUTH: pol.authentication || "",
  CATEGORY: p.category || ""
};
for (const [k, v] of Object.entries(out)) console.log(k + "=" + JSON.stringify(String(v)));
' "$MANIFEST")"

[[ "$MK_NAME" == "hyperpowers" ]] && pass "marketplace name is hyperpowers" || fail "marketplace name is hyperpowers (got: $MK_NAME)"
[[ "$N_PLUGINS" == "1" ]] && pass "exactly one plugin entry" || fail "exactly one plugin entry (got: $N_PLUGINS)"
[[ "$P_NAME" == "hyperpowers" ]] && pass "plugin name is hyperpowers" || fail "plugin name is hyperpowers (got: $P_NAME)"
[[ "$SRC_SOURCE" == "local" ]] && pass "source.source is local" || fail "source.source is local (got: $SRC_SOURCE)"
case "$POL_INSTALL" in
  AVAILABLE|INSTALLED_BY_DEFAULT|NOT_AVAILABLE) pass "policy.installation is a valid enum ($POL_INSTALL)" ;;
  *) fail "policy.installation is a valid enum (got: $POL_INSTALL)" ;;
esac
case "$POL_AUTH" in
  ON_USE|ON_INSTALL|NONE) pass "policy.authentication is a valid value ($POL_AUTH)" ;;
  *) fail "policy.authentication is a valid value (got: $POL_AUTH)" ;;
esac
[[ -n "$CATEGORY" ]] && pass "category present ($CATEGORY)" || fail "category present"

PLUGIN_DIR="$(cd "$REPO_ROOT" && cd "$SRC_PATH" 2>/dev/null && pwd || true)"
if [[ -n "$PLUGIN_DIR" && -f "$PLUGIN_DIR/.codex-plugin/plugin.json" ]]; then
  pass "source.path ($SRC_PATH) resolves to a plugin root containing .codex-plugin/plugin.json"
else
  fail "source.path ($SRC_PATH) resolves to a plugin root containing .codex-plugin/plugin.json"
fi

if [[ $FAILURES -ne 0 ]]; then
  echo ""; echo "FAILED: $FAILURES assertion(s) failed."; exit 1
fi

echo ""; echo "PASS"
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `cd <repo-root> && bash tests/codex-marketplace/test-marketplace-manifest.sh`
Expected: FAIL — `[FAIL] marketplace.json exists at .../.agents/plugins/marketplace.json`, then `FAILED`, exit 1. (Red: the manifest does not exist yet.)

- [ ] **Step 3: Confirm `.agents/` will be tracked (not gitignored)**

Run: `git check-ignore .agents/plugins/marketplace.json; echo "exit=$?"`
Expected: no path printed and `exit=1` (nothing ignores it). If it IS ignored, stop and report — do not `git add -f`.

- [ ] **Step 4: Create the manifest**

Create `.agents/plugins/marketplace.json`:

```json
{
  "name": "hyperpowers",
  "interface": {
    "displayName": "Hyperpowers"
  },
  "plugins": [
    {
      "name": "hyperpowers",
      "source": {
        "source": "local",
        "path": "./"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_USE"
      },
      "category": "Coding"
    }
  ]
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/codex-marketplace/test-marketplace-manifest.sh`
Expected: every line `[PASS]`, final `PASS`, exit 0.

- [ ] **Step 6: Confirm the fork lint is unaffected**

Run: `bash scripts/lint-fork-customizations.sh`
Expected: `49 passed, 0 failed` (this change adds no advisory skill behavior).

- [ ] **Step 7: Commit**

```bash
git add .agents/plugins/marketplace.json tests/codex-marketplace/test-marketplace-manifest.sh
git commit -m "feat(codex): self-hosted marketplace manifest + validation test"
```

---

### Task 2: Remove the redundant external-sync tooling

**Files:**
- Delete: `scripts/sync-to-codex-plugin.sh`
- Delete: `tests/codex-plugin-sync/test-sync-to-codex-plugin.sh` (and the now-empty `tests/codex-plugin-sync/`)

- [ ] **Step 1: Delete both files**

```bash
git rm scripts/sync-to-codex-plugin.sh tests/codex-plugin-sync/test-sync-to-codex-plugin.sh
```

- [ ] **Step 2: Verify they are gone and nothing in non-frozen files still calls them**

Run:
```bash
test ! -f scripts/sync-to-codex-plugin.sh && test ! -d tests/codex-plugin-sync && echo "removed"
grep -rn "sync-to-codex-plugin\|codex-plugin-sync" \
  README.md docs/testing.md docs/porting-to-a-new-harness.md CLAUDE.md AGENTS.md
```
Expected: prints `removed`. The grep will still show matches in `README.md`/`docs/...` **only** until Tasks 3–5 edit them; it must show **zero** matches in `CLAUDE.md` / `AGENTS.md` now. (Frozen `docs/hyperpowers/specs|plans/*` and `RELEASE-NOTES.md` keep their historical references — they are not in this grep set.)

- [ ] **Step 3: Verify the remaining tests and lint are green**

Run:
```bash
bash tests/codex-marketplace/test-marketplace-manifest.sh
bash scripts/lint-fork-customizations.sh
```
Expected: marketplace test `PASS`; lint `49 passed, 0 failed`.

- [ ] **Step 4: Commit**

`git rm` in Step 1 already staged both deletions, so commit directly:

```bash
git commit -m "chore(codex): remove external-mirror sync tooling (superseded by self-hosted marketplace)"
```

---

### Task 3: README — Codex CLI one-liner

**Files:**
- Modify: `README.md` (the `### Codex CLI` block)

- [ ] **Step 1: Replace the manual-load block**

Find this exact block:

````markdown
### Codex CLI

Clone the repository and load the plugin manually:

```bash
git clone https://github.com/DaRealLebron/hyperpowers
```

Then follow the Codex CLI plugin docs to load `.codex-plugin/plugin.json`.
````

Replace it with:

````markdown
### Codex CLI

Hyperpowers is its own Codex plugin marketplace. Register it, then install:

```bash
codex plugin marketplace add DaRealLebron/hyperpowers
codex plugin install hyperpowers
```

(Inside a Codex session the equivalent slash commands are
`/plugin marketplace add DaRealLebron/hyperpowers` and `/plugin install hyperpowers`.)
Codex also reads the repo's `AGENTS.md` natively when you work inside the project.
````

- [ ] **Step 2: Verify**

Run: `grep -n "codex plugin marketplace add DaRealLebron/hyperpowers" README.md`
Expected: one match in the Codex CLI section. And `grep -n "load the plugin manually" README.md` returns nothing.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs(readme): Codex CLI one-liner install via self-hosted marketplace"
```

---

### Task 4: Porting guide — Codex as a native marketplace

**Files:**
- Modify: `docs/porting-to-a-new-harness.md` (distribution-channel table, the "no channel fits" guidance, summary table)

- [ ] **Step 1: Channel table — merge Codex into the native-marketplace row, delete the fork-sync row**

Find these two consecutive rows:

```markdown
| Native plugin marketplace | Claude Code | Register in `.claude-plugin/marketplace.json`; users `/plugin install`. The `DaRealLebron/hyperpowers` repo is both the source repo and the marketplace source users install from — see the release steps in `CLAUDE.md`. |
| External marketplace fork, synced by script | Codex | `scripts/sync-to-codex-plugin.sh` rsyncs the tracked plugin files into a separate fork repo and opens a PR. Read its include/exclude list so you ship the right tree (it deliberately drops repo-internal dirs and other harnesses' dotdirs). |
```

Replace them with this single row:

```markdown
| Native plugin marketplace | Claude Code, Codex | Register in `.claude-plugin/marketplace.json` (Claude Code) or `.agents/plugins/marketplace.json` (Codex); users `/plugin install`. The `DaRealLebron/hyperpowers` repo is both the source repo and the marketplace users install from — see the release steps in `CLAUDE.md`. Codex's entry sets `source.path: "./"` so the repo root is the plugin. |
```

- [ ] **Step 2: Rework the "no existing channel fits" guidance**

Find this exact bullet:

```markdown
- **If no existing channel fits, you're standing up a new one.** None of the four
  rows may match your harness. If it needs a Codex-style external fork sync,
  `scripts/sync-to-codex-plugin.sh` is the template to clone (note its anchored
  include/exclude list and its PR automation). And whenever you add a new
  per-harness directory, add it to the *other* harnesses' sync excludes (e.g. the
  EXCLUDES list in `sync-to-codex-plugin.sh`) so your dotdir doesn't leak into
  their distributions.
```

Replace it with:

```markdown
- **If no existing channel fits, you're standing up a new one.** None of the
  rows may match your harness. Prefer self-hosting from this repo when the harness
  supports it (Claude Code and Codex both do — a committed marketplace manifest that
  points at the repo as the plugin source, so there is no second repo and no copy to
  keep in sync). If your harness instead needs the plugin tree copied into a separate
  destination, you are introducing a sync step: document precisely which paths ship
  and which repo-internal dirs and other harnesses' dotdirs are excluded, so nothing
  leaks into its distribution.
```

- [ ] **Step 3: Summary table — update the Codex row**

Find this exact row:

```markdown
| Codex | `.codex-plugin/plugin.json` + `hooks/hooks-codex.json` | shell hook → `hooks/session-start-codex` | `references/codex-tools.md` | `tests/codex-plugin-sync/`, `tests/hooks/` | fork sync (`scripts/sync-to-codex-plugin.sh`) |
```

Replace it with:

```markdown
| Codex | `.codex-plugin/plugin.json` + `hooks/hooks-codex.json` | shell hook → `hooks/session-start-codex` | `references/codex-tools.md` | `tests/codex-marketplace/`, `tests/hooks/` | marketplace (`.agents/plugins/marketplace.json`) |
```

- [ ] **Step 4: Verify no stray references remain in this file**

Run: `grep -n "sync-to-codex-plugin\|codex-plugin-sync\|external fork sync" docs/porting-to-a-new-harness.md`
Expected: no output.

- [ ] **Step 5: Commit**

```bash
git add docs/porting-to-a-new-harness.md
git commit -m "docs(porting): Codex distributes via native self-hosted marketplace"
```

---

### Task 5: testing.md index + todo.md resolution

**Files:**
- Modify: `docs/testing.md`
- Modify: `todo.md`

- [ ] **Step 1: Swap the testing-index line**

In `docs/testing.md`, find:

```markdown
- `tests/codex-plugin-sync/` — bash sync verification.
```

Replace with:

```markdown
- `tests/codex-marketplace/` — bash validation of the Codex marketplace manifest (`.agents/plugins/marketplace.json`).
```

- [ ] **Step 2: Mark `todo.md` item #3 resolved**

In `todo.md`, find this section:

```markdown
## 3. Give the Codex sync tooling a Hyperpowers path (or remove it)
`scripts/sync-to-codex-plugin.sh` and `tests/codex-plugin-sync/` were intentionally left untouched in the rename. They still reference the old `superpowers` names and publish to the upstream-owned `prime-radiant-inc/openai-codex-plugins` (not yours). Decide:
- Remove them, **or**
- Point them at a Hyperpowers-owned Codex publish target and rebrand their internal references.
```

Replace it with:

```markdown
## 3. Give the Codex sync tooling a Hyperpowers path (or remove it) — ✅ RESOLVED (2026-06-22)
Resolved by **self-hosting**: added `.agents/plugins/marketplace.json` so `DaRealLebron/hyperpowers`
is its own Codex marketplace (`codex plugin marketplace add DaRealLebron/hyperpowers` →
`codex plugin install hyperpowers`), and **removed** `scripts/sync-to-codex-plugin.sh` and
`tests/codex-plugin-sync/` (they published to the upstream-owned `prime-radiant-inc/openai-codex-plugins`).
See `docs/hyperpowers/specs/2026-06-22-codex-publish-path-design.md`.
**Still open:** the live `codex plugin install` round-trip needs verifying on a machine with the
Codex CLI — folded into item #2's external-CLI checks.
```

- [ ] **Step 3: Verify**

Run:
```bash
grep -n "tests/codex-marketplace/" docs/testing.md
grep -n "RESOLVED" todo.md
grep -n "codex-plugin-sync" docs/testing.md
```
Expected: first two print a match; the third (stale ref in testing.md) prints nothing.

- [ ] **Step 4: Commit**

```bash
git add docs/testing.md todo.md
git commit -m "docs: point testing index at tests/codex-marketplace; resolve todo #3"
```

---

### Task 6: Update documentation & final verification gate

This is the mandatory documentation-update + completion-verification task. No code changes — it confirms the docs are coherent, project memory still matches reality, and every verification artifact passes.

- [ ] **Step 1: Curation checkpoint — confirm project memory matches reality**

Run: `grep -rn "sync-to-codex-plugin\|codex-plugin-sync\|clone the repository and load" CLAUDE.md AGENTS.md`
Expected: no output. (Neither canonical memory file references the removed tooling or the old manual-load story, so no `CLAUDE.md`/`AGENTS.md` edit is needed. If anything prints, update it — `CLAUDE.md` is canonical, then `cp CLAUDE.md AGENTS.md`.)

- [ ] **Step 2: Run every verification artifact (the completion gate)**

Run each and read the output:
```bash
node -e 'JSON.parse(require("fs").readFileSync(".agents/plugins/marketplace.json","utf8")); console.log("json ok")'
bash tests/codex-marketplace/test-marketplace-manifest.sh
bash scripts/lint-fork-customizations.sh
test ! -f scripts/sync-to-codex-plugin.sh && test ! -d tests/codex-plugin-sync && echo "tooling removed"
grep -n "codex plugin marketplace add DaRealLebron/hyperpowers" README.md
grep -rn "sync-to-codex-plugin\|codex-plugin-sync" README.md docs/testing.md docs/porting-to-a-new-harness.md CLAUDE.md AGENTS.md
```
Expected:
- `json ok`
- marketplace test: final `PASS`
- lint: `49 passed, 0 failed`
- `tooling removed`
- README grep: one match (the one-liner)
- final grep: **no output** in any non-frozen file

- [ ] **Step 3: Confirm the branch is clean and review the full diff**

Run: `git status --short && git diff main --stat`
Expected: clean working tree; the branch diff touches the seven files in File Structure **plus** the two prior-committed planning docs (`docs/hyperpowers/specs/2026-06-22-codex-publish-path-design.md` and `docs/hyperpowers/plans/2026-06-22-codex-publish-path.md`). A human reviews the complete `git diff main` before finishing.

---

## Verification Artifacts

Each pairs a runnable command with the observable delta (false before this change, true after):

- `node -e 'JSON.parse(require("fs").readFileSync(".agents/plugins/marketplace.json","utf8"))'` → exits 0. **Delta:** the file did not exist before; it is now valid JSON.
- `bash tests/codex-marketplace/test-marketplace-manifest.sh` → final `PASS`. **Delta:** suite was absent / red (no manifest) before; green now, asserting `name=hyperpowers`, one plugin, `source.source=local`, required `policy`/`category`, and that `source.path` resolves to a dir with `.codex-plugin/plugin.json`.
- `bash scripts/lint-fork-customizations.sh` → `49 passed, 0 failed`. **Delta:** unchanged — proves the change added no advisory skill behavior and broke no existing marker.
- `test ! -f scripts/sync-to-codex-plugin.sh && test ! -d tests/codex-plugin-sync` → both true. **Delta:** the external-mirror script + its test existed before; gone now.
- `grep -n "codex plugin marketplace add DaRealLebron/hyperpowers" README.md` → one match. **Delta:** README said "clone the repository and load the plugin manually" before; it is the one-liner now.
- `grep -rn "sync-to-codex-plugin\|codex-plugin-sync" README.md docs/testing.md docs/porting-to-a-new-harness.md CLAUDE.md AGENTS.md` → no output. **Delta:** live docs referenced the deleted tooling before; none do now (frozen specs/plans and `RELEASE-NOTES.md` history intentionally retain theirs).

**Not verifiable in-repo (manual, deferred to todo #2):** the live `codex plugin marketplace add DaRealLebron/hyperpowers` + `codex plugin install hyperpowers` round-trip on a machine with the Codex CLI — confirms root-source (`source.path: "./"`) installs and the bootstrap auto-triggers. If it fails, apply the spec's committed-`plugins/hyperpowers/`-subtree fallback.
