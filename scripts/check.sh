#!/usr/bin/env bash
# Local verification gate: the same checks as .github/workflows/verification.yml.
#
#   scripts/check.sh lint   stamped-file hashes, record lint, fixture test, RTL lint
#   scripts/check.sh all    lint, then the cocotb smoke
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

lint() {
    "$PY" -I verification/tools/check_stamped.py
    "$PY" -I verification/tools/lint_records.py
    "$PY" -I verification/tools/tests/test_lint_records.py
    verification/tools/lint_rtl.sh
}

case "${1:-}" in
    lint) lint ;;
    all) lint; make -C verification smoke ;;
    *) echo "usage: $0 lint|all" >&2; exit 2 ;;
esac
