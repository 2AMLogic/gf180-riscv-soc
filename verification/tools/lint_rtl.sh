#!/usr/bin/env bash
# RTL lint over rtl/: passes as a no-op while the tree has no .v/.sv files.
# Verilator --lint-only (handles SystemVerilog).
#
# Local gf180 variant of the origin's verification/tools/lint_rtl.sh (see
# spec/rtl-stamping-decision.md); not stamped. Differences from the origin:
# the stamped RTL is under rtl/common/, and the SRAM wrappers soc_sram_i/d are
# gf180-specific, local files under rtl/ (spec/soc.md "PDK-independent seam").
# The stamped defaults (ISRAM_1RW=0, 11-bit addresses) are the origin's 1rw1r
# 8 KB build, which the gf180 macro cannot serve, so the tops are linted at the
# gf180 target configuration: ISRAM_1RW=1, 1024 words per side.
#
# rtl/common/soc_top.sv instantiates cve2_top, which is generated, not checked
# in (scripts/fetch-cve2.sh then scripts/convert-cve2.sh ->
# build/cve2/cve2_top.v). The converted core is required: when it is absent
# the script fails with those commands, so a passing lint always includes
# soc_top.sv. Warnings in that generated file (sv2v output we never edit) are
# ignored; any warning or error located in rtl/ fails.
set -euo pipefail
cd "$(dirname "$0")/../.."
CORE="${CVE2_BUILD:-build/cve2}/cve2_top.v"
mapfile -t files < <(find rtl \( -name '*.v' -o -name '*.sv' \) -type f | sort)
if [[ ${#files[@]} -eq 0 ]]; then echo "rtl lint: ok (no RTL files yet)"; exit 0; fi
command -v verilator >/dev/null || { echo "rtl lint: verilator not on PATH" >&2; exit 1; }

args=(--lint-only -Wno-MULTITOP "-GISRAM_1RW=1'b1" -GISRAM_AW=10 -GDSRAM_AW=10)
notes=""
if [[ ! -r "$CORE" ]]; then
    echo "rtl lint: $CORE missing; run scripts/fetch-cve2.sh && scripts/convert-cve2.sh" >&2; exit 1
fi
# warnings are not fatal for the generated file; they are filtered below
args+=(-Wno-fatal "$CORE")
notes="${notes}, generated core not gated"
# several independent tops (rst_sync, soc_fabric, ...) besides soc_top
out="$(mktemp)"; trap 'rm -f "$out"' EXIT
if ! verilator "${args[@]}" "${files[@]}" >"$out" 2>&1; then cat "$out" >&2; exit 1; fi
# with -Wno-fatal, gate on warnings located in our own files only
if grep -E '^%(Warning|Error)[^:]*: rtl/' "$out" >&2; then
    echo "rtl lint: FAIL (warnings in rtl/)" >&2; exit 1
fi
echo "rtl lint: ok (${#files[@]} files${notes})"
