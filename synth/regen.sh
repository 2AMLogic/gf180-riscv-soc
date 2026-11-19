#!/usr/bin/env bash
# Regenerate the gate-level netlist synth/soc_top_synth.v from the committed
# RTL and request.
#
#   synth/regen.sh            rewrite the netlist
#   synth/regen.sh --check    regenerate into a scratch copy and fail if it
#                             differs byte-for-byte from the committed netlist
#
# Needs on PATH: klt, yosys, sv2v (pinned PIN_SV2V in scripts/setup-env.sh; the
# request selects sv_frontend "sv2v" because the stamped RTL uses constructs the
# native Yosys front end rejects), curl, python3, gh (to fetch one pinned file).
# Installs nothing: a missing tool fails.
#
# INTERIM (spec/macro-views-interim-decision.md): klt synthesize requires a LEF
# for the macro. The only LEF at the pinned gf180-sram commit is the 322-pin
# array core, so it is fetched, hash-checked and used solely to satisfy that
# field. No pin-level claim comes from it; the macro pins come from the
# hand-written rtl/sram_256x32_blackbox.v (unratified, gf180-sram#197).
set -euo pipefail
cd "$(dirname "$0")/.."

SRAM_REPO="2AMLogic/gf180-sram"
SRAM_COMMIT="d0bacc0fceb6e9400e54e3efe15ec1630711faa9"   # reuse.lock.json, edge gf180-sram
LEF_SHA256="3cda2519cab4033a7009d5cd665c92035c9e9f2625a6db8222907e352e84b446"
LEF=build/macro/sram_256x32_array.lef
PDK="${PDK_VARIANT:-gf180mcuD}"                          # spec/pdk-pin-decision.md

for t in klt yosys sv2v python3; do
    command -v "$t" >/dev/null || { echo "regen: $t not on PATH" >&2; exit 1; }
done

if [[ ! -r "$LEF" || "$(sha256sum "$LEF" | cut -d' ' -f1)" != "$LEF_SHA256" ]]; then
    mkdir -p "$(dirname "$LEF")"
    gh api -H "Accept: application/vnd.github.raw" \
        "repos/$SRAM_REPO/contents/views/sram_256x32_array.lef?ref=$SRAM_COMMIT" >"$LEF"
    [[ "$(sha256sum "$LEF" | cut -d' ' -f1)" == "$LEF_SHA256" ]] \
        || { echo "regen: $LEF does not match the pinned sha256" >&2; exit 1; }
fi

[[ -r build/cve2/cve2_top.v ]] || { scripts/fetch-cve2.sh && scripts/convert-cve2.sh; }

# the constant ROM is generated from the boot image; it must be current.
# Generated into the untracked build tree: it is an input to the run below,
# never a checked-in artifact.
mkdir -p build/synth
python3 -I synth/gen_boot_rom.py firmware/boot/boot_rom.hex build/synth/boot_rom_const.v

mode="${1:-}"
out=synth
if [[ "$mode" == "--check" ]]; then
    out="$(mktemp -d)"; trap 'rm -rf "$out"' EXIT
elif [[ -n "$mode" ]]; then
    echo "usage: $0 [--check]" >&2; exit 2
fi

# "soc-top" is the request's own run_id (synth/soc_top.request.json); it names
# the run directory klt writes the netlist and its debug artifacts into. Both
# the run directory and the JSON response live under the gitignored synth/.klt/,
# so a failed run leaves nothing untracked behind.
mkdir -p synth/.klt
rm -rf synth/.klt/synthesize/soc-top
resp=synth/.klt/soc_top.response.json
err=synth/.klt/soc_top.synthesize.err
if ! klt synthesize --pdk "$PDK" synth/soc_top.request.json --format json >"$resp" 2>"$err"; then
    # klt has written the error JSON to the stdout response on some versions
    # and to stderr on others; read it from whichever carries it.
    msg=""
    for f in "$resp" "$err"; do
        [[ -n "$msg" ]] || msg="$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["error"]["message"])' "$f" 2>/dev/null)" || true
    done
    if [[ "$msg" == *"verilog_blackbox declares module(s)"* ]]; then
        # The committed request is the interim declaration spec/macro-views-
        # interim-decision.md ratified; klayout-tools#4459 resolved by rejecting
        # it, so no installable klt runs this request. Not fixable here (#54).
        echo "regen: klt rejects the interim macro declaration: $msg" >&2
        echo "regen: byte-for-byte netlist reproducibility is currently undemonstrable; the gate waits" >&2
        echo "regen: on 2AMLogic/klayout-tools#5612 (blackbox-only macro declaration) - see issue #54." >&2
    elif [[ -n "$msg" ]]; then
        echo "regen: klt synthesize failed: $msg" >&2
    else
        echo "regen: klt synthesize failed" >&2
        cat "$resp" "$err" 2>/dev/null >&2
    fi
    exit 1
fi
if [[ -s "$err" ]]; then cat "$err" >&2; fi
cp synth/.klt/synthesize/soc-top/soc_top_synth.v "$out/soc_top_synth.v"

if [[ "$mode" == "--check" ]]; then
    cmp "$out/soc_top_synth.v" synth/soc_top_synth.v
    echo "regen: netlist reproduces byte-for-byte"
fi
