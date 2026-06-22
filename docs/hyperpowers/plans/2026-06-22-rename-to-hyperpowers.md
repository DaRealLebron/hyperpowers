# Rename Hyperpowers → Hyperpowers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use hyperpowers:subagent-driven-development (recommended) or hyperpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the project end-to-end from Hyperpowers to Hyperpowers and cut it loose from upstream `obra/superpowers`, becoming the standalone `DaRealLebron/hyperpowers`.

**Architecture:** A 1,253-hit mechanical rename done the fork's **shell-first** way: exact edits for the small structured manifests; scoped, **preserve-list-guarded**, *anchored* shell replacements for the bulk (`hyperpowers:`, `using-hyperpowers`, `docs/hyperpowers/`, owner/path-anchored strings) so upstream-pointing references are never collateral-damaged; `git mv` for directories/files. Eight phases, each gated by the structural lint (`49 passed`) + relevant tests + verification greps, committed by explicit path. Source spec: `docs/hyperpowers/specs/2026-06-22-rename-to-hyperpowers-design.md`.

**Tech Stack:** Bash + perl/grep/sed (Git Bash on Windows); JSON manifests; git.

## Global Constraints

- **Environment.** Bash tool on Windows (Git Bash); `perl`, `grep`, `sed`, `git`, `gh` available. No WSL. Run from the worktree root each command (the Bash tool resets cwd between calls — begin commands with `cd <worktree>`).
- **Worktree/branch.** `feat/rename-to-hyperpowers` in a global worktree at `~/.config/superpowers/worktrees/hyperpowers/feat-rename-to-hyperpowers`.
- **Explicit-path staging.** Never `git add -A`. Stage the exact files each phase touches. (Exception: phases with a wide mechanical sweep stage the previewed file list — print it first, then `git add` those paths.)
- **PRESERVE-LIST — never renamed.** The replacement commands are *anchored* so they cannot touch these; verification greps prove it after every phase:
  - `obra/superpowers`, `obra/superpowers-marketplace`, `github.com/obra/superpowers/issues/...` (e.g. the #571 URL in `hooks/session-start`)
  - `claude-plugins-official/superpowers`, `claude.com/plugins/superpowers`
  - `prime-radiant-inc/openai-codex-plugins`
  - the `Copyright (c) 2025 Jesse Vincent` line in `LICENSE`
- **OUT OF SCOPE — do not touch:** `scripts/sync-to-codex-plugin.sh`, `tests/codex-plugin-sync/`. Every sweeping `grep -rl` pipes through `grep -v -e codex-plugin-sync -e sync-to-codex-plugin` to exclude them.
- **Why anchored, not blanket.** A bare `s/superpowers/hyperpowers/g` would corrupt `obra/superpowers` etc. So phases 2–5 replace only *anchored* forms (`hyperpowers:` with colon, the distinctive `using-hyperpowers`, the `docs/hyperpowers/` path, `DaRealLebron/hyperpowers`, exact install ids, exact filenames). Phase 6 handles prose with a capital-anchored replace + a **residual-review** step (preview every remaining `superpowers`, fix only ours, leave the preserve-list).
- **Lint stays 49.** `bash scripts/lint-fork-customizations.sh` must print `49 passed, 0 failed` at the end of every phase that could affect it (its `US=` path changes in Phase 3).
- **The plan & spec move.** Phase 4 `git mv docs/hyperpowers docs/hyperpowers` relocates this plan and the spec; after Phase 4 they live under `docs/hyperpowers/`.

## Verification Artifacts

- `bash scripts/lint-fork-customizations.sh` → `49 passed, 0 failed` (after each phase; final too).
- `grep -rn 'hyperpowers:' --include=*.md --include=*.json --include=*.sh --include=*.ts --include=*.js . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin` → **no** matches (namespace fully migrated).
- `grep -rni 'obra/superpowers' . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin` → **only** the MIT attribution note in README/LICENSE and the preserved `obra/superpowers/issues/...` URLs (no manifest URLs).
- `test -f skills/using-hyperpowers/SKILL.md && ! test -e skills/using-hyperpowers` → bootstrap moved.
- `test -d docs/hyperpowers && ! test -e docs/hyperpowers` → docs path moved.
- `test -f .opencode/plugins/hyperpowers.js && test -f .pi/extensions/hyperpowers.ts` → plugin files renamed.
- `grep -c '"name": "hyperpowers"' .claude-plugin/plugin.json .codex-plugin/plugin.json .cursor-plugin/plugin.json .kimi-plugin/plugin.json package.json` → each `1`.
- Affected `tests/` suites pass (excluding `tests/codex-plugin-sync/`).
- Final: `git remote -v` shows no `upstream`; `origin` → `github.com/DaRealLebron/hyperpowers.git`.

---

### Task 1: Hard identifiers (manifests, package, marketplace, gemini, LICENSE)

**Files:** `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `.kimi-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `package.json`, `gemini-extension.json`, `LICENSE`, `README.md` (attribution note only).

- [ ] **Step 1: Edit `.claude-plugin/plugin.json`** — apply these exact replacements:
  - `"name": "superpowers"` → `"name": "hyperpowers"`
  - `"homepage": "https://github.com/obra/superpowers"` → `"homepage": "https://github.com/DaRealLebron/hyperpowers"`
  - `"repository": "https://github.com/obra/superpowers"` → `"repository": "https://github.com/DaRealLebron/hyperpowers"`
  - the author block `"name": "Jesse Vincent",` / `"email": "jesse@fsck.com"` → `"name": "DaRealLebron",` / `"email": "stephpangas@gmail.com"`

- [ ] **Step 2: Edit `.codex-plugin/plugin.json`** — exact replacements:
  - `"name": "superpowers"` → `"name": "hyperpowers"`
  - both `"https://github.com/obra/superpowers"` (homepage, repository) and the `"websiteURL": "https://github.com/obra/superpowers"` → `"https://github.com/DaRealLebron/hyperpowers"`
  - author `"name": "Jesse Vincent"` → `"name": "DaRealLebron"`, `"email": "jesse@fsck.com"` → `"email": "stephpangas@gmail.com"`, `"url": "https://github.com/obra"` → `"url": "https://github.com/DaRealLebron"`
  - `"developerName": "Jesse Vincent"` → `"developerName": "DaRealLebron"`
  - `"displayName": "Hyperpowers"` → `"displayName": "Hyperpowers"`
  - in `shortDescription`/`longDescription`: `Hyperpowers` → `Hyperpowers` (the prose "Use Hyperpowers to guide…" → "Use Hyperpowers to guide…")
  - `"composerIcon": "./assets/superpowers-small.svg"` → `"./assets/hyperpowers-small.svg"` (asset renamed in Step 9)

- [ ] **Step 3: Edit `.cursor-plugin/plugin.json`** — `"name": "superpowers"` → `"hyperpowers"`; `"displayName": "Hyperpowers"` → `"Hyperpowers"`; both obra URLs → `DaRealLebron/hyperpowers`; author Jesse Vincent/jesse@fsck.com → DaRealLebron/stephpangas@gmail.com.

- [ ] **Step 4: Edit `.kimi-plugin/plugin.json`** — `"name": "superpowers"` → `"hyperpowers"`; `"homepage": "https://github.com/obra/superpowers"` → `DaRealLebron/hyperpowers`; author → DaRealLebron/stephpangas@gmail.com; `"displayName": "Hyperpowers"` → `"Hyperpowers"`; in `longDescription`/`shortDescription` and the `skillInstructions` string, `Hyperpowers` → `Hyperpowers` (note `"sessionStart": { "skill": "using-hyperpowers" }` is handled in Task 3, not here).

- [ ] **Step 5: Edit `.claude-plugin/marketplace.json`** — `"name": "superpowers-dev"` → `"name": "hyperpowers"`; the plugin entry `"name": "superpowers"` → `"hyperpowers"`; `"Development marketplace for Hyperpowers core skills library"` → `"Marketplace for Hyperpowers core skills library"`; both owner and plugin `author` Jesse Vincent/jesse@fsck.com → DaRealLebron/stephpangas@gmail.com.

- [ ] **Step 6: Edit `package.json`** — `"name": "superpowers"` → `"hyperpowers"`; `"description": "Hyperpowers skills and runtime bootstrap for coding agents"` → `"Hyperpowers skills and runtime bootstrap for coding agents"`. (Leave `"main": ".opencode/plugins/hyperpowers.js"` and the `.pi` extension path — Task 5 renames the files and updates these.)

- [ ] **Step 7: Edit `gemini-extension.json`** — `"name": "superpowers"` → `"hyperpowers"`.

- [ ] **Step 8: Edit `LICENSE`** — keep line 3 `Copyright (c) 2025 Jesse Vincent` unchanged; insert directly below it: `Copyright (c) 2026 DaRealLebron` and a line `Hyperpowers is a fork of Hyperpowers (https://github.com/obra/superpowers) by Jesse Vincent.`

- [ ] **Step 9: Rename the brand asset** — `git mv assets/superpowers-small.svg assets/hyperpowers-small.svg` (if present; `ls assets/superpowers-small.svg` first — if absent, skip and revert the Step 2 composerIcon change to the actual asset name).

- [ ] **Step 10: Verify JSON validity + names**

```
cd <worktree>
for f in .claude-plugin/plugin.json .codex-plugin/plugin.json .cursor-plugin/plugin.json .kimi-plugin/plugin.json .claude-plugin/marketplace.json package.json gemini-extension.json; do node -e "JSON.parse(require('fs').readFileSync('$f','utf8'))" && echo "valid: $f"; done
grep -c '"name": "hyperpowers"' .claude-plugin/plugin.json .codex-plugin/plugin.json .cursor-plugin/plugin.json .kimi-plugin/plugin.json package.json
bash scripts/lint-fork-customizations.sh | tail -1
```
Expected: all `valid:` lines; each manifest reports `1`; `49 passed, 0 failed`.

- [ ] **Step 11: Commit**

```
cd <worktree>
git add .claude-plugin/plugin.json .codex-plugin/plugin.json .cursor-plugin/plugin.json .kimi-plugin/plugin.json .claude-plugin/marketplace.json package.json gemini-extension.json LICENSE assets/
git commit -m "rename: hard identifiers (manifests, marketplace, package, license) -> hyperpowers"
```

---

### Task 2: Skill namespace `hyperpowers:` → `hyperpowers:`

The `hyperpowers:` (colon-anchored) form is the skill namespace; no preserve-list string contains it, so this is safe.

- [ ] **Step 1: Preview**

```
cd <worktree>
grep -rln 'hyperpowers:' --include=*.md --include=*.json --include=*.sh --include=*.ts --include=*.js --include=*.cjs --include=*.txt . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin | tee /tmp/ns-files.txt
```
Expected: a list of skill/hook/doc files (no `codex-plugin-sync`).

- [ ] **Step 2: Apply**

```
cd <worktree>
xargs perl -pi -e 's/\bsuperpowers:/hyperpowers:/g' < /tmp/ns-files.txt
```

- [ ] **Step 3: Verify**

```
cd <worktree>
grep -rn 'hyperpowers:' --include=*.md --include=*.json --include=*.sh --include=*.ts --include=*.js --include=*.cjs --include=*.txt . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin
bash scripts/lint-fork-customizations.sh | tail -1
```
Expected: the first grep prints **nothing**; lint `49 passed, 0 failed`.

- [ ] **Step 4: Commit** — `git add` the files from `/tmp/ns-files.txt` (run `git add $(cat /tmp/ns-files.txt)`), then `git commit -m "rename: skill namespace hyperpowers: -> hyperpowers:"`.

---

### Task 3: Bootstrap `using-hyperpowers` → `using-hyperpowers` (lockstep)

`using-hyperpowers` is a distinctive substring (never part of a preserve URL), so replacing it everywhere is safe — but it MUST move and re-reference in one commit.

- [ ] **Step 1: Move the skill directory** — `cd <worktree> && git mv skills/using-hyperpowers skills/using-hyperpowers`

- [ ] **Step 2: Update the skill's own frontmatter** — in `skills/using-hyperpowers/SKILL.md`, replace `name: using-hyperpowers` → `name: using-hyperpowers`.

- [ ] **Step 3: Preview every remaining reference**

```
cd <worktree>
grep -rln 'using-hyperpowers' . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin | tee /tmp/boot-files.txt
```
Expected: includes `hooks/session-start`, `hooks/session-start-codex`, `.opencode/plugins/hyperpowers.js`, `.pi/extensions/hyperpowers.ts`, `.kimi-plugin/plugin.json`, `scripts/lint-fork-customizations.sh`, and skill/doc cross-refs.

- [ ] **Step 4: Apply**

```
cd <worktree>
xargs perl -pi -e 's/using-hyperpowers/using-hyperpowers/g' < /tmp/boot-files.txt
```

- [ ] **Step 5: Verify bootstrap integrity**

```
cd <worktree>
grep -rn 'using-hyperpowers' . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin
grep -n 'using-hyperpowers' hooks/session-start hooks/session-start-codex .kimi-plugin/plugin.json scripts/lint-fork-customizations.sh
bash scripts/lint-fork-customizations.sh | tail -1
```
Expected: first grep prints **nothing**; second grep shows each harness/lint now names `using-hyperpowers`; lint `49 passed, 0 failed`.

- [ ] **Step 6: Commit** — `git add skills/using-hyperpowers $(cat /tmp/boot-files.txt)` then `git commit -m "rename: bootstrap skill using-hyperpowers -> using-hyperpowers (+ all hooks)"`.

---

### Task 4: Docs path `docs/hyperpowers/` → `docs/hyperpowers/`

- [ ] **Step 1: Move the directory** — `cd <worktree> && git mv docs/hyperpowers docs/hyperpowers`

- [ ] **Step 2: Preview references**

```
cd <worktree>
grep -rln 'docs/hyperpowers' . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin | tee /tmp/docs-files.txt
```

- [ ] **Step 3: Apply** (path-anchored; cannot touch `obra/superpowers`)

```
cd <worktree>
xargs perl -pi -e 's{docs/hyperpowers/}{docs/hyperpowers/}g; s{docs/hyperpowers\b}{docs/hyperpowers}g' < /tmp/docs-files.txt
```

- [ ] **Step 4: Verify**

```
cd <worktree>
grep -rn 'docs/hyperpowers' . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin
test -d docs/hyperpowers && ! test -e docs/hyperpowers && echo PATH_MOVED
bash scripts/lint-fork-customizations.sh | tail -1
```
Expected: first grep prints **nothing**; `PATH_MOVED`; lint `49 passed`. **Note:** this plan and the spec now live under `docs/hyperpowers/`.

- [ ] **Step 5: Commit** — `git add docs/hyperpowers $(cat /tmp/docs-files.txt)` then `git commit -m "rename: docs/hyperpowers -> docs/hyperpowers"`.

---

### Task 5: Plugin entry filenames

- [ ] **Step 1: Move the files**

```
cd <worktree>
git mv .opencode/plugins/hyperpowers.js .opencode/plugins/hyperpowers.js
git mv .pi/extensions/hyperpowers.ts .pi/extensions/hyperpowers.ts
```

- [ ] **Step 2: Update references to those paths** (path-anchored; safe)

```
cd <worktree>
grep -rln -e '.opencode/plugins/hyperpowers.js' -e '.pi/extensions/hyperpowers.ts' . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin | tee /tmp/fn-files.txt
xargs perl -pi -e 's{\.opencode/plugins/superpowers\.js}{.opencode/plugins/hyperpowers.js}g; s{\.pi/extensions/superpowers\.ts}{.pi/extensions/hyperpowers.ts}g' < /tmp/fn-files.txt
```
(This updates `package.json` `main` and the `.pi` extensions array.)

- [ ] **Step 3: Verify**

```
cd <worktree>
test -f .opencode/plugins/hyperpowers.js && test -f .pi/extensions/hyperpowers.ts && echo FILES_OK
grep -rn -e 'plugins/superpowers.js' -e 'extensions/superpowers.ts' . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin
node -e "JSON.parse(require('fs').readFileSync('package.json','utf8'))" && echo pkg_valid
bash scripts/lint-fork-customizations.sh | tail -1
```
Expected: `FILES_OK`; second grep prints **nothing**; `pkg_valid`; `49 passed`.

- [ ] **Step 4: Commit** — `git add .opencode/plugins/hyperpowers.js .pi/extensions/hyperpowers.ts package.json $(cat /tmp/fn-files.txt)` then `git commit -m "rename: plugin entry files superpowers.{js,ts} -> hyperpowers.{js,ts}"`.

---

### Task 6: Branding prose + independence

- [ ] **Step 1: Strip obra official-install README sections** — open `README.md` and remove the blocks that document installing obra's OFFICIAL plugin (NOT the fork): the official Claude marketplace block (around `claude.com/plugins/superpowers` / `superpowers@claude-plugins-official`), the `obra/superpowers-marketplace` block (`hyperpowers@hyperpowers-marketplace`), and the official Codex/Copilot marketplace blocks (`obra/superpowers-marketplace`, official Codex marketplace, `copilot plugin marketplace add obra/superpowers-marketplace`). Keep ONLY the fork install paths. Update the fork install commands: `DaRealLebron/hyperpowers` → `DaRealLebron/hyperpowers` and `hyperpowers@hyperpowers` → `hyperpowers@hyperpowers` (and the droid `hyperpowers@hyperpowers` → `hyperpowers@hyperpowers`).

- [ ] **Step 2: Add the MIT attribution note** to `README.md` (near the top or in a "Credits"/"License" area): `> Hyperpowers is an independent fork of [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent, used under the MIT license.` (Deliberately uses the lowercase `obra/superpowers` URL form and **no** bare capital "Hyperpowers" token, so the Step 4 branding sweep and the owner/install replaces in Step 3 cannot alter it.)

- [ ] **Step 3: Owner-anchored + install-id replacements repo-wide** (safe; `DaRealLebron/` and the exact ids are not preserve-list)

```
cd <worktree>
grep -rln -e 'DaRealLebron/hyperpowers' -e 'hyperpowers@hyperpowers' . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin | tee /tmp/own-files.txt
xargs perl -pi -e 's{DaRealLebron/hyperpowers}{DaRealLebron/hyperpowers}g; s/superpowers\@superpowers-dev/hyperpowers\@hyperpowers/g; s/superpowers\@superpowers\b/hyperpowers\@hyperpowers/g' < /tmp/own-files.txt
```

- [ ] **Step 4: Capital-S branding prose** (safe; obra URLs are lowercase)

```
cd <worktree>
grep -rln 'Hyperpowers' --include=*.md --include=*.json --include=*.ts --include=*.js --include=*.cjs --include=*.html . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin | tee /tmp/brand-files.txt
xargs perl -pi -e 's/Hyperpowers/Hyperpowers/g' < /tmp/brand-files.txt
```

- [ ] **Step 5: Known lowercase brand spot** — in `hooks/session-start`, replace `You have superpowers.` → `You have hyperpowers.` (exact). Re-check `hooks/session-start-codex` for the same phrase and fix if present.

- [ ] **Step 6: Residual review (the safety net for the long tail)**

```
cd <worktree>
grep -rni 'superpowers' . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin | grep -v -e 'obra/superpowers' -e 'claude-plugins-official/superpowers' -e 'claude.com/plugins/superpowers' -e 'Jesse Vincent'
```
Review each remaining line. Anything that is OURS (a bare lowercase `superpowers` referring to this project) → fix to `hyperpowers` with a targeted `perl -pi -e` on that exact file/string. Anything in the preserve-list (obra refs, the LICENSE author, official-plugin references) → leave. Re-run this grep until only preserve-list lines remain.

- [ ] **Step 7: Remove the upstream remote**

```
cd <worktree>
git remote remove upstream 2>/dev/null || echo "no upstream remote"
git remote -v
```
Expected: only `origin` remains.

- [ ] **Step 8: Verify**

```
cd <worktree>
grep -rni 'obra/superpowers' . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin
grep -rn 'superpowers@' README.md docs/ ; echo "(only hyperpowers@ expected above, none)"
bash scripts/lint-fork-customizations.sh | tail -1
```
Expected: `obra/superpowers` appears ONLY in the attribution note + preserved issue URLs; no stale `superpowers@` install ids; `49 passed`.

- [ ] **Step 9: Commit** — `git add README.md LICENSE hooks/ $(cat /tmp/own-files.txt /tmp/brand-files.txt | sort -u)` (plus any files touched in residual review) then `git commit -m "rebrand: Hyperpowers -> Hyperpowers prose; go independent (strip obra installs, drop upstream)"`.

---

### Task 7: Tests + final lint

- [ ] **Step 1: Run the affected suites** (these assert names/branding/bootstrap)

```
cd <worktree>
bash tests/hooks/test-session-start.sh; echo "session-start EXIT=$?"
node --test tests/brainstorm-server/branding.test.js 2>/dev/null || (cd tests/brainstorm-server && npm test); echo "branding EXIT=$?"
bash tests/kimi/test-plugin-manifest.sh; echo "kimi EXIT=$?"
```

- [ ] **Step 2: Fix any failures** — these tests assert the OLD identifiers/branding; update the expected strings in the failing test files to the new names (`hyperpowers`, `using-hyperpowers`, `Hyperpowers`), matching what the code now emits. Do NOT weaken assertions — only update the expected values. Re-run until green. (Exclude `tests/codex-plugin-sync/` — out of scope.)

- [ ] **Step 3: Broader sweep for stragglers in tests**

```
cd <worktree>
grep -rln 'superpowers' tests/ | grep -v codex-plugin-sync
```
Update each non-sync test's expectations to the new identifiers as needed; re-run the relevant runner.

- [ ] **Step 4: Final full verification**

```
cd <worktree>
bash scripts/lint-fork-customizations.sh | tail -1
grep -rn 'hyperpowers:' --include=*.md --include=*.json --include=*.sh --include=*.ts --include=*.js . | grep -v -e codex-plugin-sync -e sync-to-codex-plugin
test -f skills/using-hyperpowers/SKILL.md && ! test -e skills/using-hyperpowers && echo BOOT_OK
test -d docs/hyperpowers && ! test -e docs/hyperpowers && echo DOCS_OK
echo "manifests:" && grep -h '"name":' .claude-plugin/plugin.json .codex-plugin/plugin.json .cursor-plugin/plugin.json .kimi-plugin/plugin.json package.json gemini-extension.json
```
Expected: `49 passed`; namespace grep empty; `BOOT_OK`; `DOCS_OK`; every manifest name `hyperpowers`.

- [ ] **Step 5: Commit** — `git add tests/` (the updated suites) then `git commit -m "test: update suites for the Hyperpowers rename"`.

---

### Task 8 (final): GitHub repo rename + remote repoint

Run this ONLY after Tasks 1–7 are merged to the local default branch (per finishing-a-development-branch). It is outward-facing — confirm with the operator before executing.

- [ ] **Step 1: Rename the GitHub repository**

```
gh repo rename hyperpowers --repo DaRealLebron/hyperpowers
```
Expected: GitHub confirms the rename to `DaRealLebron/hyperpowers` (old URL auto-redirects).

- [ ] **Step 2: Repoint the local origin remote**

```
cd /c/Users/12026/Documents/GitHub/hyperpowers
git remote set-url origin https://github.com/DaRealLebron/hyperpowers.git
git remote -v
```
Expected: `origin` → `https://github.com/DaRealLebron/hyperpowers.git`; no `upstream`.

- [ ] **Step 3: Push to the renamed repo**

```
cd /c/Users/12026/Documents/GitHub/hyperpowers
git push origin main
```
Expected: push succeeds to `DaRealLebron/hyperpowers`.
