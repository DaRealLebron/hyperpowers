# Rename Superpowers → Hyperpowers (Independent Fork) Design

**Date:** 2026-06-22
**Status:** Approved (brainstorming complete; ready for writing-plans)
**Fork:** `DaRealLebron/superpowers` (fork of `obra/superpowers`) → becoming the standalone `DaRealLebron/hyperpowers`

## Context

The operator is taking their fork independent: it should stop pointing at upstream `obra/superpowers`
and be renamed end-to-end from "Superpowers" to "Hyperpowers" — branding, plugin identifiers, the
skill namespace, the bootstrap skill, the docs path, plugin filenames, hooks, tests, and the GitHub
repository. The operator explicitly chose the **deepest** rename tier and a **fully independent**
relationship to upstream.

Recon established the magnitude and the hazards:

- **1,253 occurrences of "superpowers" across 117 files**, plus 75 `obra`/`obra-superpowers`
  references across 22 files.
- The hits are **not interchangeable**. Some point at obra's *official* plugin and must not be
  renamed; some are behavior-critical identifiers; some are frozen historical prose.
- The bootstrap skill `using-hyperpowers` is wired into hooks and bootstrap injection across every
  harness — it is what makes skills auto-trigger. Renaming it wrong silently breaks the core value.

## Goals

1. Rebrand the project to **Hyperpowers** in every category: branding prose, plugin/package/
   marketplace identifiers, the `hyperpowers:` skill namespace, the `using-hyperpowers` bootstrap
   skill, the `docs/superpowers/` path, and plugin entry filenames.
2. Make the project **fully independent** of `obra/superpowers`: drop the upstream git remote, remove
   the README sections that document installing obra's *official* plugin, and keep only the
   Hyperpowers install path — while preserving the MIT fork-attribution required by the license.
3. Repoint ownership: manifests credit `DaRealLebron <stephpangas@gmail.com>`; URLs point at
   `github.com/DaRealLebron/hyperpowers`.
4. Rename the GitHub repository `DaRealLebron/superpowers` → `DaRealLebron/hyperpowers` and repoint
   the local `origin` remote.
5. Keep the project working: the structural lint stays at **49 passed**, the affected `tests/` suites
   pass, and every harness's bootstrap still auto-triggers under the new name.

## Non-Goals — explicitly out of scope

- **The Codex sync tooling.** `scripts/sync-to-codex-plugin.sh` and `tests/codex-plugin-sync/` are
  **left untouched this round** (operator deferred). They publish to the upstream-owned
  `prime-radiant-inc/openai-codex-plugins`, which the operator does not control, so they are
  knowingly left stale/non-functional until a follow-up gives Hyperpowers its own publish path.
- **Re-tracking upstream.** No future-merge compatibility with `obra/superpowers` is preserved; the
  deep rename makes upstream merges conflict-heavy by design. This is accepted.
- **A version reset.** The plugin `version` stays at `6.0.2` for continuity (revisit a `1.0.0` reset
  separately if desired).

## The Preserve-List (never renamed)

A blind global replace is forbidden. These strings refer to upstream/official artifacts and stay
**exactly as-is** wherever they survive the independence edits:

- `obra/superpowers`, `obra/superpowers-marketplace` — only inside the single MIT attribution note
  (everywhere else they are *removed* by the independence edits, not renamed).
- `claude-plugins-official/superpowers`, `claude.com/plugins/superpowers` — obra's official plugin /
  listing (these live in README install sections that are being *removed* per Goal 2).
- `prime-radiant-inc/openai-codex-plugins` — the deferred sync target (whole file out of scope).
- The original `Copyright (c) … Jesse Vincent` line in `LICENSE`.

Every text-replace phase runs against this preserve-list, including the rewrite of the frozen
`docs/` history.

## Identifier Rename Map

| Category | From | To |
|---|---|---|
| Plugin name (`.claude-plugin`, `.codex-plugin`, `.cursor-plugin`, `.kimi-plugin` manifests; `package.json`; `marketplace.json` plugin entry) | `superpowers` | `hyperpowers` |
| Marketplace name (`marketplace.json`) | `superpowers-dev` | `hyperpowers` |
| Install command | `superpowers@superpowers-dev` (from `DaRealLebron/superpowers`) | `hyperpowers@hyperpowers` (from `DaRealLebron/hyperpowers`) |
| Skill namespace (cross-refs in skills, hooks, docs) | `hyperpowers:` | `hyperpowers:` |
| Bootstrap skill (dir, frontmatter `name:`, and **all** hook/extension references) | `using-hyperpowers` | `using-hyperpowers` |
| Docs path (`git mv` + every reference) | `docs/superpowers/` | `docs/hyperpowers/` |
| Plugin entry files (+ their internal refs and any config pointing at them) | `.opencode/plugins/superpowers.js`, `.pi/extensions/superpowers.ts` | `…/hyperpowers.{js,ts}` |
| Manifest URLs (`homepage`, `repository`) | `github.com/obra/superpowers` | `github.com/DaRealLebron/hyperpowers` |
| Manifest author/owner | `Jesse Vincent <jesse@fsck.com>` | `DaRealLebron <stephpangas@gmail.com>` |
| Branding prose | "Superpowers" | "Hyperpowers" |

## Independence Changes

- Remove the obra `upstream` git remote (`git remote remove upstream`).
- **Strip** the README install sections for obra's official plugin: the official Claude marketplace
  block, `obra/superpowers-marketplace`, and the official Codex/Copilot marketplace blocks. The
  README documents **only** the Hyperpowers install (`/plugin marketplace add DaRealLebron/hyperpowers`
  → `/plugin install hyperpowers@hyperpowers`, and the equivalent per-harness install for the fork).
- **Add** the MIT attribution note (README + `LICENSE`): *"Hyperpowers is a fork of
  [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent, used under the MIT
  license."* Keep the original `LICENSE` copyright line and add the operator's copyright line.

## Risk Containment

- **Bootstrap rename in lockstep.** Renaming `skills/using-hyperpowers/` → `skills/using-hyperpowers/`
  happens together with updating every reference: `hooks/session-start`, `hooks/session-start-codex`,
  the SessionStart content, `.opencode/plugins/*.js`, `.pi/extensions/*.ts`, the Kimi inline manifest,
  and `scripts/lint-fork-customizations.sh` (`US=…`). Acceptance includes a per-harness check that the
  bootstrap still names the skill.
- **Lint stays green.** The lint references renamed paths (`US="skills/using-hyperpowers/SKILL.md"`)
  and contains "superpowers" in comments; both are updated and the lint re-run must print
  `49 passed, 0 failed` after each phase that could affect it.
- **Tests updated in-phase.** Branding/manifest tests that assert the old names
  (`tests/brainstorm-server/branding.test.js`, `tests/kimi/test-plugin-manifest.sh`,
  `tests/opencode/*`, `tests/pi/*`, `tests/hooks/test-session-start.sh`, `tests/antigravity/*`, …) are
  updated alongside the code they cover and re-run. (`tests/codex-plugin-sync/` is excluded — see
  Non-Goals.)
- **Frozen history.** Per the operator's choice, the `docs/` plans/specs are path-moved and
  text-rewritten too. Accepted trade-off: those records become slightly anachronistic.

## Phasing (one spec, sequenced plan; lint/tests gate each phase)

1. **Hard identifiers** — manifests, `package.json`, `marketplace.json` (name + plugin + owner +
   author + URLs), `LICENSE` attribution.
2. **Namespace** — `hyperpowers:` → `hyperpowers:` across skills, hooks, docs (preserve-list applied).
3. **Bootstrap** — `using-hyperpowers` → `using-hyperpowers` dir + frontmatter + **all** hook/
   extension/lint references, in lockstep.
4. **Docs path** — `git mv docs/superpowers docs/hyperpowers` + update every `docs/superpowers/`
   reference (including `CLAUDE.md`'s Documentation index and the skills that write to
   `docs/.../specs|plans`).
5. **Plugin filenames** — rename `.opencode/plugins/superpowers.js`, `.pi/extensions/superpowers.ts`
   + their internal refs and any config that points at them.
6. **Branding + independence** — prose "Superpowers" → "Hyperpowers"; strip obra official-install
   README sections; add MIT attribution; remove `upstream` remote.
7. **Tests + lint** — update affected suites; confirm `49 passed` and green tests.
8. **GitHub repo rename** — after the code rename is merged: `gh repo rename hyperpowers`, then
   `git remote set-url origin https://github.com/DaRealLebron/hyperpowers.git`.

## Verification / Acceptance

- `bash scripts/lint-fork-customizations.sh` → `49 passed, 0 failed`.
- The affected `tests/` suites pass (excluding the deferred `tests/codex-plugin-sync/`).
- `grep -rn 'hyperpowers:' --include=*.md --include=*.json --include=*.sh .` returns **no** stray
  old-namespace cross-references (only the deferred sync file, if anything).
- `grep -rni 'obra/superpowers' .` returns **only** the single MIT attribution note (and the deferred
  sync file).
- `ls skills/using-hyperpowers/SKILL.md` exists; `ls skills/using-hyperpowers` is gone.
- `ls docs/hyperpowers` exists; `ls docs/superpowers` is gone.
- Each harness's bootstrap script/extension names `using-hyperpowers`.
- Final: `git remote -v` shows no `upstream`; `origin` → `DaRealLebron/hyperpowers`.

## Known Follow-Up (out of scope)

- Give the Codex sync tooling a Hyperpowers-owned publish target (or remove it).
- Optionally reset the plugin version to `1.0.0` to mark the independent line.
