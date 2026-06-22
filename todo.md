# Hyperpowers — TODO

Follow-ups from the Superpowers → Hyperpowers rename (2026-06-22).

## 1. Reinstall the plugin under the new name
The fork now installs as `hyperpowers@hyperpowers` from `DaRealLebron/hyperpowers`. In Claude Code:
- Remove the old install (and its marketplace): `/plugin` → uninstall `superpowers@superpowers-dev`.
- Add the renamed one: `/plugin marketplace add DaRealLebron/hyperpowers` → `/plugin install hyperpowers@hyperpowers`.

## 2. Run the test suites that need external CLIs
These suites had their identifier strings updated during the rename but could **not be executed** on the rename machine (Windows + Git Bash) because they require external tools. Run them where those tools are available and confirm green:
- `tests/opencode/` — needs the `opencode` CLI
- `tests/claude-code/` — needs the `claude` CLI
- `tests/explicit-skill-requests/` — needs the `claude` CLI
- `tests/antigravity/` — needs `agy`
- `tests/pi/` — re-verify under `npx tsx` in a clean environment

## 3. Give the Codex sync tooling a Hyperpowers path (or remove it)
`scripts/sync-to-codex-plugin.sh` and `tests/codex-plugin-sync/` were intentionally left untouched in the rename. They still reference the old `superpowers` names and publish to the upstream-owned `prime-radiant-inc/openai-codex-plugins` (not yours). Decide:
- Remove them, **or**
- Point them at a Hyperpowers-owned Codex publish target and rebrand their internal references.

## Other deferred items (from earlier work this cycle)
- **Behavioral evals for the new skills** — the structural lint proves skill text is present, not that agents obey it. Add Drill eval scenarios for `curating-project-memory` (and the BMAD planning-OS skills) once `evals/` is in-tree. See the curation and BMAD design specs under `docs/hyperpowers/specs/`.
- **Optional version reset** — the plugin `version` stayed at `6.0.2` (inherited from upstream). Reset to `1.0.0` if you want to mark the independent Hyperpowers line.
