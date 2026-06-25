# Eval Log: Root-Cause Review Gate

Behavioral eval for the **Root-Cause Review Gate** added to `SKILL.md` (between Phase 3 and
Phase 4). Follows the `hyperpowers:writing-skills` RED → GREEN → REFACTOR methodology
(`testing-skills-with-subagents.md`).

The gate is a discipline + proportionality rule: *run an independent root-cause review before a
risky fix; skip it for trivial fixes.* So the eval must verify BOTH sides — it fires when risk
warrants, and it is correctly skipped when it doesn't.

## Scenarios (this directory)

- `test-gate-pressure-highrisk.md` — confident root cause, multi-file/production/user-facing fix.
  Correct = **B** (run the gate before implementing).
- `test-gate-proportionality-trivial.md` — obvious one-line typo, isolated, deterministic repro.
  Correct = **A** (skip the gate; implement directly).
- `test-gate-academic.md` — comprehension of the gate's timing, scope, reviewer role, advisory
  nature, and degraded-mode behavior.

## Method (controlled variable = the gate only)

Fresh-context `general-purpose` subagents, model **claude-sonnet**, run 2026-06-25. Each subagent
was restricted to ONE debugging-guidance fixture and told not to recall any other methodology, so
the gate is the only difference between arms:

- **RED fixture** = `SKILL.md` at commit `0f4cf84` (pre-gate).
- **GREEN fixture** = `SKILL.md` at `HEAD` (with gate). GREEN = RED + 57 lines, 0 removed
  (`git diff 0f4cf84 HEAD -- skills/systematic-debugging/SKILL.md`).

Scenarios were given to agents WITHOUT the "correct answer" headers (answer-key-free copies), so
no leakage. Agents returned `CHOICE: A|B|C` + cited guidance.

## Results

| Arm | Scenario | n | Choices | Verdict |
|-----|----------|---|---------|---------|
| RED (no gate) | high-risk | 3 | **A, B, B** | inconsistent — see below |
| GREEN (gate)  | high-risk | 3 | **B, B, B** | ✅ gate fires, criteria-driven |
| GREEN (gate)  | trivial   | 2 | **A, A**    | ✅ gate correctly skipped |
| Academic      | —         | 1 | full marks  | ✅ comprehension solid |

### What the gate changed (RED → GREEN, high-risk)

- **RED was inconsistent.** One agent chose **A** — shipped a 3-file auth change straight to
  production on confidence, explicitly noting "adding a 10-minute independent review before coding
  is not prescribed." The other two chose **B**, but on *ad-hoc* grounds ("Phase 3: Ask for help",
  general "verify before continuing") — none articulated a review mechanism or a stopping rule.
- **GREEN was unanimous and structured.** All three chose **B** and cited the gate's explicit
  triggers verbatim ("touches multiple files", "production / user-facing / hard to roll back"),
  treated it as advisory-but-required at this risk level, and **ruled out option C** (review in
  parallel) because the gate requires verdicts *before* Phase 4. The gate converted inconsistent,
  vaguely-justified caution into consistent, criteria-driven review with a concrete refute-the-
  diagnosis mechanism.

### Proportionality (GREEN, trivial)

Both agents chose **A** and cited the skip clause ("Skip it for an obvious, self-contained fix
(a one-line typo…)"), explicitly calling option B "process theater" / "bureaucratic overhead"
here. The risk-scaling works — the gate does not fire on trivial fixes.

### Comprehension (academic)

All five answers correct with accurate quotes: timing (after Phase 3, before Phase 4),
skip-vs-run conditions, reviewer role ("refute the diagnosis"), advisory + must-state-override,
and degraded-mode self-review where subagents/Codex are unavailable.

## Conclusion

GREEN is clean on both the fire and skip sides, and no agent rationalized *around* the gate — so
**no REFACTOR of the skill wording is required for these scenarios.** The gate behaves as designed.

## Known limitations / next iterations (recommended, not blocking)

1. **RED signal is soft.** The high-risk auth scenario is alarming enough that caution is partly
   natural (2/3 sought review even without the gate). Add a **confidence-trap** scenario — high
   confidence + *moderate, non-alarming* risk — where a no-gate agent naturally skips review, to
   sharpen the RED→GREEN contrast.
2. **Override pressure untested.** Add a scenario combining 3+ pressures (time + economic + the
   reviewer being slow/asleep) that tempts overriding a `revise` verdict, to pressure-test the
   advisory escape hatch and the "state explicitly why you are overriding" requirement.
3. **Single model, low reps.** Re-run at 5+ reps per arm and across models (opus, plus a Codex /
   Gemini harness) once the `evals/` Drill harness is cloned, for cross-model coverage.

---

*Run: 2026-06-25 · model claude-sonnet · fixtures from git `0f4cf84` (RED) vs `HEAD` (GREEN).*
