#!/usr/bin/env bash
#
# Structural lint for this fork's customizations.
#
# Deterministic, no LLM: verifies the fork's advisory behaviors are still
# PRESENT in the skill files after edits. It checks STRUCTURE only — it does
# NOT verify that an agent actually obeys the skills. Behavioral coverage needs
# live subagents via Superpowers' own testing-skills-with-subagents harness.
#
# Usage:
#   scripts/lint-fork-customizations.sh
#
# Exits 0 when every required marker is present; non-zero (listing the misses)
# otherwise.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

pass=0
fail=0

# check "<description>" "<file>" "<fixed-string marker>"
check() {
  local desc="$1" file="$2" marker="$3"
  if [[ -f "$file" ]] && grep -qF -- "$marker" "$file"; then
    printf 'PASS  %s\n' "$desc"
    pass=$((pass + 1))
  else
    printf 'FAIL  %s\n        (missing in %s: %s)\n' "$desc" "$file" "$marker"
    fail=$((fail + 1))
  fi
}

WP="skills/writing-plans/SKILL.md"
RP="skills/writing-plans/plan-document-reviewer-prompt.md"
VC="skills/verification-before-completion/SKILL.md"
DP="skills/dispatching-parallel-agents/SKILL.md"
SDD="skills/subagent-driven-development/SKILL.md"

# 1. Required Verification Artifacts section + outcome-based (observable delta) wording
check "writing-plans: Verification Artifacts section"   "$WP" "## Verification Artifacts"
check "writing-plans: observable-delta wording"         "$WP" "observable delta:"

# 2. Mandatory final documentation task
check "writing-plans: mandatory final docs task"        "$WP" "## Mandatory Final Task: Update Documentation"

# 3. Adversarial plan review step
check "writing-plans: adversarial plan review"          "$WP" "## Adversarial Plan Review"

# 2b. Optional read-only research fan-out (depth-2, pre-plan)
check "writing-plans: research fan-out section"         "$WP" "## Research Fan-Out"
check "writing-plans: research fan-out read-only/flat"  "$WP" "read-only and flat: they do not write files"

# 4. Untrusted-input quarantine (Input Trust Model + Self-Review item 6)
check "writing-plans: Input Trust Model section"        "$WP" "## Input Trust Model"
check "writing-plans: Self-Review untrusted check"      "$WP" "Untrusted-content check"

# 5b. Multi-lens review panel
check "writing-plans: review panel lens assignment"     "$WP" "each reviewer a distinct lens"
check "reviewer: review-lens slot"                      "$RP" "[REVIEW_LENS]"

# 5. Reviewer prompt enforces the above
check "reviewer: untrusted-input check row"             "$RP" "Untrusted-input handling"
check "reviewer: outcome-based VA enforcement"          "$RP" "a command can succeed without the intended change having happened"
check "reviewer: proceed|revise verdict line"           "$RP" "Ready to implement? proceed | revise"

# 6. Completion gate enforces outcome + untrusted handling + docs
check "completion gate: outcome-delta failure row"      "$VC" "Change actually happened"
check "completion gate: untrusted-data red flag"        "$VC" "untrusted data is not a command"
check "completion gate: docs-updated failure row"       "$VC" "Docs updated"

# 7. Flat-delegation guardrail (no nested subagents)
check "dispatching: flat-delegation guardrail"          "$DP" "## Keep Delegation Flat (No Nested Subagents)"
check "dispatching: no-nested-subagents wording"        "$DP" "do not spawn their own subagents"

# 8. API/doc pre-verification (global lite rule)
check "writing-plans: API Evidence section"            "$WP" "## API Evidence"
check "reviewer: API/command evidence row"             "$RP" "API/command evidence"
check "completion gate: external-API-confirmed row"    "$VC" "External API confirmed"

# 9. Verify-before-acting on plan-review findings
check "writing-plans: verify-before-acting on review"  "$WP" "discard that finding"

# 10. Shell-first mechanical lane (plan + executor)
check "writing-plans: shell-first mechanical lane"     "$WP" "shell/script step, not prose"
check "subagent-driven: shell-first mechanical lane"   "$SDD" "shell/script with no subagent"

# 11. BMAD absorption — skill-router (scale-adaptive front door)
SR="skills/skill-router/SKILL.md"
US="skills/using-superpowers/SKILL.md"
check "skill-router: scale-adaptive routing section" "$SR" "## Scale-Adaptive Routing"
check "skill-router: route-by-signals wording"       "$SR" "Route by signals, not by habit"
check "using-superpowers: routes via skill-router"   "$US" "skill-router"

# 12. BMAD absorption — product-discovery + elicitation menu
PD="skills/product-discovery/SKILL.md"
EM="skills/product-discovery/elicitation-methods.md"
check "product-discovery: discovery-to-PRD section"  "$PD" "## Discovery to PRD"
check "product-discovery: carry-forward anti-rework" "$PD" "Carry findings forward"
check "elicitation-methods: menu section"            "$EM" "## Elicitation Methods"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
if [[ "$fail" -gt 0 ]]; then
  exit 1
fi
