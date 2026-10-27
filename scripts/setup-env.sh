#!/usr/bin/env bash
# Pin and prove the gf180mcu PDK + open simulation toolchain for this repo.
#
#   scripts/setup-env.sh --check   verify the PDK revision and tool versions
#                                  against the pins below; exit 1 on mismatch
#
# Local gf180 variant of the origin's sky130-only scripts/setup-env.sh (see
# spec/stamped-harness-decision.md). This file is the single source of truth
# for the pins; docs/environment.md quotes it, and CI parses PIN_COCOTB from
# it. It never installs or fetches anything: it only checks.
set -euo pipefail

# ---- pins -----------------------------------------------------------------
PIN_PDK_VARIANT="gf180mcuD"                                    # spec/pdk-pin-decision.md
PIN_OPEN_PDKS_REV="f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7"   # spec/pdk-pin-decision.md
PIN_IVERILOG="13.0"
PIN_COCOTB="2.0.1"
PIN_SV2V="v0.0.13"        # SystemVerilog -> Verilog for CVE2; scripts/convert-cve2.sh (not yet checked by --check)
# ---------------------------------------------------------------------------

PDK_ROOT="${PDK_ROOT:-$HOME/.ciel}"

FAILED=0
ok()   { printf 'ok    %-10s %s\n' "$1" "$2"; }
fail() { printf 'FAIL  %-10s %s\n' "$1" "$2" >&2; FAILED=1; }

check_pdk() {
    local src="${PDK_ROOT}/${PIN_PDK_VARIANT}/SOURCES" got
    if [[ ! -r "$src" ]]; then
        fail pdk "no ${src} (PDK_ROOT=${PDK_ROOT}); fetch ${PIN_PDK_VARIANT} at ${PIN_OPEN_PDKS_REV} with ciel"
        return
    fi
    got="$(awk '/^open_pdks/ {print $2; exit}' "$src")"
    if [[ "$got" == "$PIN_OPEN_PDKS_REV" ]]; then ok pdk "${PIN_PDK_VARIANT} open_pdks ${got}"
    else fail pdk "open_pdks ${got:-unknown}, pinned ${PIN_OPEN_PDKS_REV}"; fi
}

check_iverilog() {
    local out
    if ! command -v iverilog >/dev/null 2>&1; then fail iverilog "not on PATH (pinned ${PIN_IVERILOG})"; return; fi
    out="$(iverilog -V 2>&1 | head -n 1)" || true
    if [[ "$out" == *"version ${PIN_IVERILOG} "* ]]; then ok iverilog "$out"
    else fail iverilog "got '${out}', pinned '${PIN_IVERILOG}'"; fi
}

check_cocotb() {
    local got
    got="$(python3 -c 'import cocotb;print(cocotb.__version__)' 2>/dev/null || true)"
    if [[ -z "$got" ]]; then fail cocotb "not importable (pinned ${PIN_COCOTB})"
    elif [[ "$got" == "$PIN_COCOTB" ]]; then ok cocotb "$got"
    else fail cocotb "got ${got}, pinned ${PIN_COCOTB}"; fi
}

case "${1:-}" in
    --check)
        check_pdk
        check_iverilog
        check_cocotb
        if [[ "$FAILED" -ne 0 ]]; then echo "environment does not match the pins" >&2; exit 1; fi
        echo "environment matches the pins"
        ;;
    *) echo "usage: $0 --check" >&2; exit 2 ;;
esac
