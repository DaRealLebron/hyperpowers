# Hyperpowers

Hyperpowers is a complete software development methodology for your coding agents, built on top of a set of composable skills and some initial instructions that make sure your agent uses them.

> Hyperpowers is an independent fork of [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent, used under the MIT license.

## Quickstart

Give your agent Hyperpowers: [Claude Code](#claude-code), [Codex CLI](#codex-cli), [Cursor](#cursor), [Gemini CLI](#gemini-cli), [Kimi Code](#kimi-code), [OpenCode](#opencode), [Pi](#pi).

## How it works

It starts from the moment you fire up your coding agent. As soon as it sees that you're building something, it *doesn't* just jump into trying to write code. Instead, it steps back and asks you what you're really trying to do. 

Once it's teased a spec out of the conversation, it shows it to you in chunks short enough to actually read and digest. 

After you've signed off on the design, your agent puts together an implementation plan that's clear enough for an enthusiastic junior engineer with poor taste, no judgement, no project context, and an aversion to testing to follow. It emphasizes true red/green TDD, YAGNI (You Aren't Gonna Need It), and DRY. 

Next up, once you say "go", it launches a *subagent-driven-development* process, having agents work through each engineering task, inspecting and reviewing their work, and continuing forward. It's not uncommon for your agent to work autonomously for a couple hours at a time without deviating from the plan you put together.

There's a bunch more to it, but that's the core of the system. And because the skills trigger automatically, you don't need to do anything special. Your coding agent just has Hyperpowers.

## Fork customizations

This fork adds sixteen behaviors on top of upstream Hyperpowers. All are **advisory**: the
operator may override any gate by proceeding with an explicit statement of intent and reason.

- **Adversarial plan review** — before implementation, `writing-plans` dispatches a required
  in-session subagent reviewer plus best-effort Codex and Gemini reviewers (each skipped
  gracefully when unavailable); verdicts are summarized per reviewer.
- **Mandatory "Update documentation" final task** — every plan the `writing-plans` skill
  produces ends with an explicit documentation-update task as its last step.
- **Required `## Verification Artifacts` section** — every plan must include a
  `Verification Artifacts` section where each bullet pairs a runnable command with an
  *observable delta* (the postcondition that is false before the change and true after, not
  merely "exit 0"); a plan missing it, or one whose criteria only prove a command ran, is
  caught by Self-Review and the adversarial reviewer (advisory, not a hard gate).
- **Docs-updated completion check** — the `verification-before-completion` skill now asks the
  agent to confirm (via a VCS diff) that relevant documentation was updated before it claims a
  task complete.
- **Untrusted-input quarantine** — `writing-plans` separates *trusted instructions* (operator
  requests, the approved spec) from *untrusted content* (repo prose, issue/PR text, tool and
  subagent output). Instructions embedded in untrusted content are data, not commands, and may
  not redefine scope, gates, permissions, or "done" without an explicit reason tied to a
  trusted source; the adversarial reviewer and `verification-before-completion` enforce it.
- **Research fan-out (optional, pre-plan)** — when a plan's surface area justifies it,
  `writing-plans` gathers grounding by dispatching a flat fan-out of **read-only** investigator
  subagents (pattern scout, dependency/impact mapper, risk analyst) and synthesizes their briefs
  into the plan; it is proportional (skipped for small/familiar changes) and never writes.
- **Multi-lens review panel** — the adversarial plan review dispatches several parallel
  reviewers, each assigned a distinct lens (spec coverage, buildability, verification artifacts,
  untrusted-input handling, failure modes), instead of one generalist pass.
- **Flat-delegation guardrail** — `dispatching-parallel-agents` states the rule that dispatched
  subagents do not spawn their own subagents: delegation stays flat (depth 2), avoiding the
  geometric cost, runaway recursion, and lost observability of nested subagents.
- **API/doc pre-verification** — a plan must confirm an external API/CLI/schema exists (or mark it
  an explicit ASSUMPTION) before relying on it.
- **Verify-before-acting on review** — a reviewer's suggested fix is checked against what it cites
  before it is implemented; phantom findings are discarded.
- **Shell-first mechanical lane** — deterministic mechanical work (rename/format/codemod) goes to
  shell/script, not an LLM pass, in both the planner and the executor.
- **Project altitude (BMAD absorption):** `skill-router` routes work by scale (trivial → feature → project); `product-discovery` writes the brief + PRD; `architecture-design` writes the durable architecture + ADRs and runs a PASS/CONCERNS/FAIL readiness gate (reusing the review panel); `reevaluation` handles major change by superseding — not rewriting — completed work.
- **Project-memory curation** — `curating-project-memory` drifts a project's `CLAUDE.md` (canonical),
  its generated `AGENTS.md` mirror, scoped `.claude/rules/`, and `docs/` toward an optimal,
  well-linked state at completion checkpoints (finishing a branch, the plan's final docs task, the
  completion gate); tiny additions auto-apply while structural changes are proposed first, and drift
  is bidirectional — a pass both records verified learnings and evicts bloat past a ~100-line budget.
- **Grafts:** a shared elicitation-methods menu (offered from `brainstorming` and `product-discovery`), scale-adaptive planning depth, and Finding A (oracle-strengthening test assertions). `49 checks`.

A deterministic structural check, `scripts/lint-fork-customizations.sh`, verifies these
behaviors remain present in the skill files after edits (no LLM; structure only — it does not
verify an agent obeys them).

### Installing this fork

This fork is published at [`DaRealLebron/hyperpowers`](https://github.com/DaRealLebron/hyperpowers).
To use it in Claude Code instead of upstream:

```bash
/plugin marketplace add DaRealLebron/hyperpowers
/plugin install hyperpowers@hyperpowers
```

Both plugins share skill names with upstream, so disable the upstream one to avoid a
collision: open `/plugin`, toggle `hyperpowers@claude-plugins-official` **off**, then restart Claude
Code. Verify the customizations are present with `bash scripts/lint-fork-customizations.sh` (49 checks
should pass).

See [`docs/workflow.md`](docs/workflow.md) for the happy-path flowcharts (upstream vs. this fork).

## Installation

Installation differs by harness. If you use more than one, install separately for each one.

### Claude Code

To install from this fork:

```bash
/plugin marketplace add DaRealLebron/hyperpowers
/plugin install hyperpowers@hyperpowers
```

### Codex CLI

Clone the repository and load the plugin manually:

```bash
git clone https://github.com/DaRealLebron/hyperpowers
```

Then follow the Codex CLI plugin docs to load `.codex-plugin/plugin.json`.

### Cursor

- In Cursor Agent chat, install from marketplace:

  ```text
  /add-plugin hyperpowers
  ```

- Or search for "hyperpowers" in the plugin marketplace.

### Gemini CLI

- Install the extension:

  ```bash
  gemini extensions install https://github.com/DaRealLebron/hyperpowers
  ```

- Update later:

  ```bash
  gemini extensions update hyperpowers
  ```

### Kimi Code

- Or install directly from this repository:

  ```text
  /plugins install https://github.com/DaRealLebron/hyperpowers
  ```

- Detailed docs: [docs/README.kimi.md](docs/README.kimi.md)

### OpenCode

OpenCode uses its own plugin install; install separately even if you
already use it in another harness.

- Tell OpenCode:

  ```
  Fetch and follow instructions from https://raw.githubusercontent.com/DaRealLebron/hyperpowers/refs/heads/main/.opencode/INSTALL.md
  ```

- Detailed docs: [docs/README.opencode.md](docs/README.opencode.md)

### Pi

Install as a Pi package from this repository:

```bash
pi install git:github.com/DaRealLebron/hyperpowers
```

For local development, run Pi with this checkout loaded as a temporary package:

```bash
pi -e /path/to/hyperpowers
```

The Pi package loads the skills and a small extension that injects the `using-hyperpowers` bootstrap at session startup and again after compaction. Pi has native skills, so no compatibility `Skill` tool is required. Subagent and task-list tools remain optional Pi companion packages.

## The Basic Workflow

1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **subagent-driven-development** or **executing-plans** - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Reviews against plan, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle (includes testing anti-patterns reference)

**Debugging**
- **systematic-debugging** - 4-phase root cause process (includes root-cause-tracing, defense-in-depth, condition-based-waiting techniques)
- **verification-before-completion** - Ensure it's actually fixed

**Collaboration** 
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Batch execution with checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow
- **subagent-driven-development** - Fast iteration with two-stage review (spec compliance, then code quality)

**Meta**
- **writing-skills** - Create new skills following best practices (includes testing methodology)
- **using-hyperpowers** - Introduction to the skills system

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

## Contributing

The general contribution process is below. Keep in mind that we don't generally accept contributions of new skills and that any updates to skills must work across all of the coding agents we support.

1. Fork the repository
2. Switch to the 'dev' branch
3. Create a branch for your work
4. Follow the `writing-skills` skill for creating and testing new and modified skills
5. Submit a PR, being sure to fill in the pull request template.

Skill-behavior tests use the drill eval harness from [superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals/), cloned into `evals/` — see `evals/README.md` for setup. Plugin-infrastructure tests live at `tests/` and run via the relevant `run-*.sh` or `npm test`.

See `skills/writing-skills/SKILL.md` for the complete guide.

## Updating

Updates are somewhat coding-agent dependent, but are often automatic.

## License

MIT License - see LICENSE file for details

## Visual companion telemetry

Because skills and plugins don't provide any feedback to creators, we have no idea how many of you are using this. By default, the Prime Radiant logo on brainstorming's optional visual companion feature is loaded from our website. It includes the version in use. It does not include any details about your project, prompt, or coding agent. We don't see your clicks or anything about what you're building. It's 100% optional. To disable this, set the environment variable `HYPERPOWERS_DISABLE_TELEMETRY` to any true value. This also honors Claude Code's `DISABLE_TELEMETRY` and `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` opt-outs.

## Community

- **Issues**: https://github.com/DaRealLebron/hyperpowers/issues
