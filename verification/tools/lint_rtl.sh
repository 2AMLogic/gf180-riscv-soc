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
# build/cve2/cve2_top.v). When that file exists it is linted with the top;
# warnings in that generated file (sv2v output we never edit) are ignored, any
# warning or error located in rtl/ fails. When it is absent soc_top.sv is
# skipped with a notice, or the script fails if LINT_REQUIRE_CORE=1.
#
# soc_fabric.sv and soc_top.sv are likewise skipped with a notice while no
# soc_sram_d module is defined under rtl/, or the script fails if
# LINT_REQUIRE_SRAM=1.
set -euo pipefail
cd "$(dirname "$0")/../.."
CORE="${CVE2_BUILD:-build/cve2}/cve2_top.v"
mapfile -t files < <(find rtl \( -name '*.v' -o -name '*.sv' \) -type f | sort)
if [[ ${#files[@]} -eq 0 ]]; then echo "rtl lint: ok (no RTL files yet)"; exit 0; fi
command -v verilator >/dev/null || { echo "rtl lint: verilator not on PATH" >&2; exit 1; }

skip() {  # drop the named basenames from files[]
    local kept=() f b
    for f in "${files[@]}"; do
        for b in "$@"; do [[ "$f" == */"$b" ]] && continue 2; done
        kept+=("$f")
    done
    files=("${kept[@]}")
}

args=(--lint-only -Wno-MULTITOP -GISRAM_1RW=1 -GISRAM_AW=10 -GDSRAM_AW=10)
notes=""
if grep -qs '^module soc_sram_d\b' "${files[@]}"; then :
elif [[ "${LINT_REQUIRE_SRAM:-0}" == 1 ]]; then
    echo "rtl lint: no soc_sram_d wrapper under rtl/" >&2; exit 1
else
    echo "rtl lint: note: no soc_sram_d wrapper yet; skipping soc_fabric.sv and soc_top.sv"
    skip soc_fabric.sv soc_top.sv
    notes=", SRAM-dependent files skipped"
fi
if [[ -r "$CORE" ]]; then
    # warnings are not fatal for the generated file; they are filtered below
    args+=(-Wno-fatal "$CORE")
    notes="${notes}, generated core not gated"
elif [[ "${LINT_REQUIRE_CORE:-0}" == 1 ]]; then
    echo "rtl lint: $CORE missing; run scripts/fetch-cve2.sh && scripts/convert-cve2.sh" >&2; exit 1
else
    echo "rtl lint: note: $CORE missing; skipping soc_top.sv (needs the converted core)"
    skip soc_top.sv
fi
# several independent tops (rst_sync, soc_fabric, ...) besides soc_top
out="$(mktemp)"; trap 'rm -f "$out"' EXIT
if ! verilator "${args[@]}" "${files[@]}" >"$out" 2>&1; then cat "$out" >&2; exit 1; fi
# with -Wno-fatal, gate on warnings located in our own files only
if grep -E '^%(Warning|Error)[^:]*: rtl/' "$out" >&2; then
    echo "rtl lint: FAIL (warnings in rtl/)" >&2; exit 1
fi
echo "rtl lint: ok (${#files[@]} files${notes})"
