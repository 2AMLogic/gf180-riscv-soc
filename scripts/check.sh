#!/usr/bin/env bash
# The verification gate: the commands .github/workflows/verification.yml runs,
# written once here — each workflow job installs its tools and then calls this
# script. CI-only setup stays in the workflow (apt installs, the pinned sv2v
# download, the pinned cocotb venv, and the CVE2 fetch/convert that the RTL
# lint needs); this script installs nothing.
#
#   scripts/check.sh stamped  stamped-file hashes (reuse.lock.json)
#   scripts/check.sh lint     stamped-file hashes, record lint, fixture tests, RTL lint
#   scripts/check.sh smoke    the cocotb smoke
#   scripts/check.sh all      lint, then the smoke
#
# Behind `pnpm check:ci|check:all|test|lint`. A missing tool fails the gate; it
# never skips. Installs nothing: use a venv with the pinned cocotb (.venv is
# picked up if present; see scripts/setup-env.sh for the pins).
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -z "${PYTHON_BIN:-}" && -x .venv/bin/python3 ]]; then
    export PYTHON_BIN="$PWD/.venv/bin/python3"
    export PATH="$PWD/.venv/bin:$PATH"
fi
PY="${PYTHON_BIN:-python3}"

step() { echo "==> $*"; }

stamped() {
    step stamped-file-hashes
    "$PY" -I verification/tools/check_stamped.py
}

lint() {
    stamped
    step lint-records
    "$PY" -I verification/tools/lint_records.py
    step lint-records-tests
    "$PY" -I verification/tools/tests/test_lint_records.py
    step lint-rtl-tests
    "$PY" -I verification/tools/tests/test_lint_rtl.py
    step check-stamped-tests
    "$PY" -I verification/tools/tests/test_check_stamped.py
    step regen-failure-paths
    synth/tests/test-regen-failure-paths.sh
    step lint-rtl
    verification/tools/lint_rtl.sh
}

smoke() {
    step cocotb-smoke
    make -C verification smoke
}

case "${1:-}" in
    stamped) stamped ;;
    lint) lint ;;
    smoke) smoke ;;
    all) lint; smoke ;;
    *) echo "usage: $0 stamped|lint|smoke|all" >&2; exit 2 ;;
esac
