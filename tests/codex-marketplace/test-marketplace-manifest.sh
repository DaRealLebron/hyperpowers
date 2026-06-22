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
