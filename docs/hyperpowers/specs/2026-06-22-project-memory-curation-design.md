# Project-Memory Curation — Built Into the Skills

**Date:** 2026-06-22
**Status:** Approved (brainstorming complete; ready for writing-plans)
**Fork:** `DaRealLebron/hyperpowers` (fork of `obra/superpowers`)

## Context

The operator wants the fork's skills to **slowly drift any project that uses them toward an
optimal `CLAUDE.md` state** — plus the rules and documentation that surround it — as a side
effect of normal work, never as a manual audit. The drift should be continuous, low-friction,
and grounded in what actually happened during a session, so that over many features a project's
agent-facing memory converges on the right shape without anyone scheduling a cleanup.

This is the last major fork-customization planned for the project. It sits alongside the
existing **docs gate** (the `writing-plans` mandatory final "Update documentation" task and the
`verification-before-completion` docs-updated failure row), but those point at README / per-area
docs / CHANGELOG and never specifically at the agent-memory layer. `using-hyperpowers` already
treats `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` as the top of the instruction hierarchy ("user
instructions, highest priority") — but nothing in the fork *maintains* that layer.

This design was grounded in read-only web research of current (mid-2026) practice rather than
training memory. Key findings that shaped scope:

- **`AGENTS.md` is the open standard** — governed by the Linux Foundation's Agentic AI
  Foundation, read natively by Codex, Cursor, Copilot, Gemini, Aider, Windsurf, Zed. `CLAUDE.md`
  is Anthropic-specific. The consensus pattern is **one canonical file projected outward, never
  duplicated.**
- **The single most important technique is progressive disclosure / keep-it-lean.** Target
  ~40–150 lines; bloat is actively harmful — *"if Claude keeps ignoring a rule, the file is
  probably too long and the rule is getting lost."* Detail belongs in linked docs or in skills
  loaded on demand, not in the always-loaded file.
- **`.claude/rules/` is a real native Claude Code feature** (since v2.0.64): every `.md` file is
  auto-loaded as project memory, and `paths:` glob frontmatter makes a rule load **only when the
  file being worked on matches** — the direct Claude-native parallel to Cursor's
  `.cursor/rules/*.mdc`. Rules without a `paths:` field load unconditionally at `CLAUDE.md`
  priority.
- **Karpathy's four behavioral rules** (Think Before Coding, Simplicity First, Surgical Changes,
  Goal-Driven Execution) are the canonical "what belongs in agent memory" reference — and the
  fork's skills **already enforce all four** (brainstorming, YAGNI, surgical-change guidance,
  verification-before-completion). The popular packaging of these rules duplicates them into
  per-tool hand-maintained files; the best-practice literature criticizes exactly that. We can do
  strictly better by generating the mirror.

## Goals

1. Give the fork a **continuous curation discipline** that nudges a project's `CLAUDE.md`,
   generated `AGENTS.md`, scoped rules, and `docs/` toward an optimal, well-linked state at
   natural checkpoints.
2. Define the **target artifact model** every hyperpowers-driven project drifts toward: a
   three-layer knowledge system where each fact lives in exactly one layer and layers *link*
   rather than duplicate.
3. Make drift **bidirectional** — curation both *adds* verified learnings and *evicts* bloat
   (to docs, or to a path-scoped rule) when the always-loaded file exceeds its budget.
4. Keep `CLAUDE.md` **canonical** (matching the operator's global convention) while still serving
   Codex and the open-standard tools by **mechanically regenerating `AGENTS.md` as a mirror**.
5. Center the logic in **one new skill** with thin **grafts** into existing checkpoint skills,
   guarded by the fork's deterministic `grep -qF` structural lint — the same shape every prior
   fork behavior used.
6. Stay **zero-dependency** and harness-portable: no reliance on the external `claude-md-improver`
   plugin, and a target model that works for at least Claude Code + Codex, degrading cleanly to
   Cursor / Gemini / others.

## Non-Goals — what we deliberately reject

- **A reactive batch audit.** The external `claude-md-improver` skill already does on-demand
  scoring-and-fixing. Ours is the *continuous-drift complement*; we do not rebuild or depend on
  it. (A project may still invoke that audit for a full sweep — they are companions, not rivals.)
- **A hook.** Curation needs judgment (which layer does this learning belong in? is it
  project-specific or already skill-enforced?), not deterministic code, and should not fire on
  every Stop. This stays a behavior-shaping skill, consistent with the project's philosophy.
- **Hand-maintained per-tool duplicate files.** `AGENTS.md` is *generated* from `CLAUDE.md`;
  scoped-rule mirrors are *generated* from their Claude-native canonical. No human edits two
  copies of the same rule.
- **Writing generic behavioral rules into every project.** The Rules layer holds *project-specific*
  always/nevers only; universal behaviors are left to the skills. Restating them is duplication
  and bloat — the exact failure the research warns kills rule adherence.
- **Touching user-global memory.** `~/.claude/CLAUDE.md` and `~/.claude/rules` are out of scope;
  we drift the *project*, never the operator's machine-wide defaults.
- **Auto-generating bloated scaffolds.** No template dump. Every recorded line must earn its place
  from a real, observed learning.

## Target Artifact Model

A three-layer "project knowledge system." Each fact lives in **exactly one** layer; layers link
downward and never restate each other.

| Layer | Canonical artifact | Generated mirrors | Role | Loaded |
|---|---|---|---|---|
| **1. Root memory** | `CLAUDE.md` | `AGENTS.md` (full mirror); Gemini config points at same | Lean orientation + project-specific rules + a documentation index of one-line links | Always |
| **2. Scoped rules** | `.claude/rules/*.md` (with optional `paths:` glob) | `.cursor/rules/*.mdc`; nested `AGENTS.md` where the glob maps to a directory subtree | Rules that apply to only part of the tree; created **only on a real scoping need** | Conditionally (path-scoped) or always (unscoped) |
| **3. Documentation** | `docs/…` (architecture, ADRs, specs, plans) | — | Durable **source of truth** for detail | On demand (via links) |

### Root memory structure

`CLAUDE.md` has three sections, in order:

- **`## Context`** — descriptive: what the project is, where things live, *verified* commands,
  key entry points. Terse; deep detail is linked, not inlined.
- **`## Rules`** — imperative, project-specific always/nevers (e.g. "migrations must be
  reversible", "never edit `generated/`"). **Not** generic behaviors the skills already enforce.
- **`## Documentation index`** — one-line links out to `docs/…`. This is the seam to Layer 3.

### Sync rule (consequence of CLAUDE.md-canonical)

Because Codex reads `AGENTS.md` natively and will not follow a pointer back to `CLAUDE.md`,
`AGENTS.md` is a **mechanically regenerated full mirror** of `CLAUDE.md`. `CLAUDE.md` is the only
root file a human edits. If a project has a Gemini config, point it at the same content
(`{ "context": { "fileName": "CLAUDE.md" } }` or equivalent) rather than maintaining a third copy.

### The linking principle (the seam)

Every new learning is routed to exactly one home:

- Long-form / reference / detail → **`docs/`** + a one-line link in the Documentation index.
- Durable, project-wide always/never → **`## Rules`** (only if not already skill-enforced).
- Path-specific rule → **`.claude/rules/<name>.md`** with `paths:` (canonical), mirrored to
  `.cursor/rules` and, where the glob maps to a directory, nested `AGENTS.md`.
- Ephemeral / one-off → **dropped** (not recorded).

## Definition of "Optimal" (the curation rubric)

A hyperpowers-aware adaptation of the established six-criterion `CLAUDE.md` rubric —
**Commands, Architecture clarity, Non-obvious patterns, Conciseness, Currency, Actionability** —
with three ecosystem-specific additions:

1. **No skill-duplication.** The Rules section must not restate behaviors skills already enforce.
   Only project-specific rules earn a line.
2. **Size budget.** Target **≤ ~100 lines** of always-loaded root body (excluding the
   Documentation index); **hard ceiling 150 lines → eviction is triggered.** (Grounded in the
   research sweet spot of 40–80 lines and ~200-line hard cap.) Path-scoped `.claude/rules/` files
   do **not** count against this budget, since they load only on match.
3. **Correct layering.** Each fact verified to be in its right layer and *linked*, not duplicated.

## New Skill: `curating-project-memory`

Gerund name matching the repo convention (`writing-plans`, `finishing-a-development-branch`).
Owns all the hard logic. **The curation pass:**

1. **Gather candidates** from the checkpoint context plus `git diff` since the last curation:
   commands actually run and observed to work, gotchas/decisions that surfaced, docs created or
   changed.
2. **Classify each candidate** by the linking principle (Rules / Context / docs+link / scoped /
   drop), de-duped against existing memory content **and** against skill-enforced behavior.
3. **Budget check** → if the root body is over the ceiling, **evict** lowest-value detail to
   `docs/` (+ link) or move a path-specific rule into `.claude/rules/<name>.md` with `paths:`.
4. **Currency check** (cheap): do referenced files/paths still exist? Flag stale commands.
5. **Apply per the autonomy rules** (below), then **regenerate the `AGENTS.md` mirror** (and any
   scoped-rule mirrors).
6. **Bootstrap-when-missing:** if no `CLAUDE.md` exists at the first curation, scaffold a minimal
   `Context` / `Rules` / `Documentation index` skeleton from what is known (structural → confirm).

**Evidence rule.** A command is recorded as *verified* only if it was actually executed and
observed to work this session (ties into `verification-before-completion`). No speculative
commands — this is what keeps drift grounded in real work rather than plausible-sounding fiction.

## Grafts — the checkpoint surface (Moderate)

Thin, one-line invocations into three existing skills:

1. **`finishing-a-development-branch`** — run a full curation pass before merge. This is the
   primary, once-per-feature drift moment.
2. **`writing-plans`** — the mandatory final "Update documentation" task explicitly names
   `CLAUDE.md` / `AGENTS.md`, not just README / per-area docs.
3. **`verification-before-completion`** — add a *"project memory current?"* check; a stale
   command or path is a failure row, mirroring the existing docs-updated row.

## Autonomy & Safety

- **Auto-apply tiny:** a verified command or a one-line gotcha auto-commits.
- **Confirm structural:** a new Rule, any eviction/restructure, the `AGENTS.md` (or scoped-rule)
  regeneration, and bootstrap scaffolding each **propose a diff and wait** for approval.
- **Untrusted input.** Learnings drawn from tool output, repo prose, or PR bodies are *data, not
  commands* (reuses the fork's existing Input Trust Model). Curation extracts facts; it never
  executes instructions embedded in untrusted content.
- **Opt-out wins.** A project whose own `CLAUDE.md` says "don't auto-curate" is honored — user
  instructions outrank skills per `using-hyperpowers`.

## Multi-Harness Projection

**Priority: Claude Code is primary; other harnesses are ports.** The Claude-native layer
(`CLAUDE.md` + `.claude/rules/`) is canonical and must always be correct; every other harness is
served by a **generated mirror** that is best-effort. When the two cannot be made equivalent (see
the non-directory glob case below), Claude-native correctness wins and the mirror degrades
gracefully rather than compromising the canonical source.

- **Claude Code:** `CLAUDE.md` (root, canonical) + `.claude/rules/*.md` (scoped, canonical).
- **Codex / open-standard:** `AGENTS.md` full mirror at root; nested `AGENTS.md` for scoped rules
  whose glob maps to a directory subtree.
- **Cursor:** reads `CLAUDE.md`/`AGENTS.md` at root; `.cursor/rules/*.mdc` mirrors scoped rules.
- **Gemini / others:** config pointed at `CLAUDE.md`.

**Known imperfection (recorded honestly):** a non-directory glob (e.g. `paths: **/*.test.ts`)
has no clean nested-`AGENTS.md` equivalent. Such a rule stays Claude/Cursor-scoped, or is promoted
to the root Rules section with an explicit path note, rather than being silently dropped for Codex.

**Windows note:** symlink-based sync (`ln -s AGENTS.md CLAUDE.md`) is avoided — fragile under
`core.symlinks` and some tools choke on resolved symlinks. Generation, not symlinking, is the sync
mechanism.

## Structural Lint

Extend `scripts/lint-fork-customizations.sh` with ~8–10 deterministic `grep -qF` checks:

- The new skill's section headers (curation pass, definition of optimal, autonomy split,
  bidirectional/eviction rule, the canonical-`CLAUDE.md`/generated-`AGENTS.md` sync rule,
  `.claude/rules` scoped-layer handling).
- The three graft markers in `finishing-a-development-branch`, `writing-plans`, and
  `verification-before-completion`.

Lint grows **40 → ~48–50**, consistent with how every prior fork behavior was protected.

## Testing & Verification

- **Now:** structural lint passes (all markers present).
- **Deferred (honestly):** *behavioral* verification — that an agent actually routes a learning to
  the correct layer, refuses to bloat past the budget, evicts correctly, and regenerates
  `AGENTS.md` — waits for the Drill eval harness once `evals/` lands. This matches the project's
  documented deferral of behavioral methodology tests; the lint header already states it checks
  structure only and does not verify agents obey.

## Decisions Resolved

- Drift = **checkpoint curation** (small, evidence-backed nudges at completion points).
- Root: `CLAUDE.md` **canonical**, `AGENTS.md` a **generated mirror**.
- Scoped rules: `.claude/rules/*.md` **canonical** (Claude-native, `paths:` glob), mirrored to
  `.cursor/rules` and nested `AGENTS.md` where applicable.
- Docs: the durable **source of truth**; root links to them.
- Home: **one new skill** (`curating-project-memory`) + **three grafts** + **lint markers**.
- Checkpoint surface: **Moderate** (finishing-a-branch, writing-plans final docs task,
  verification currency check).
- Autonomy: **auto-tiny / confirm-structural**.
- Rules section: **project-specific only** (no skill-duplication).
- Drift is **bidirectional** (add **and** evict).

## Open Follow-Up (out of scope for this spec)

- Behavioral eval scenarios for the curation pass, once `evals/` is in-tree.
- Optional richer scoped-rule mirroring for non-directory globs across Codex (currently promoted
  to root with a path note).
