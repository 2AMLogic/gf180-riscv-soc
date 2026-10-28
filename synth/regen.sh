#!/usr/bin/env bash
# Regenerate the gate-level netlist synth/soc_top_synth.v (and the wrapper-only
# probe synth/soc_sram_d_synth.v) from the committed RTL and requests.
#
#   synth/regen.sh            rewrite the netlists
#   synth/regen.sh --check    regenerate into a scratch copy and fail if either
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

# the constant ROM is generated from the boot image; it must be current
python3 -I synth/gen_boot_rom.py firmware/boot/boot_rom.hex synth/boot_rom_const.v

mode="${1:-}"
out=synth
if [[ "$mode" == "--check" ]]; then
    out="$(mktemp -d)"; trap 'rm -rf "$out"' EXIT
elif [[ -n "$mode" ]]; then
    echo "usage: $0 [--check]" >&2; exit 2
fi

run() {  # run <request-stem> <run_id> <netlist-name> <out-name>
    rm -rf "synth/.klt/synthesize/$2"
    klt synthesize --pdk "$PDK" "synth/$1.request.json" --format json >"synth/.klt-$1.json"
    cp "synth/.klt/synthesize/$2/$3" "$out/$4"
}
mkdir -p synth/.klt
run soc_sram_d soc-sram-d soc_sram_d_synth.v soc_sram_d_synth.v
run soc_top soc-top soc_top_synth.v soc_top_synth.v
rm -f synth/.klt-*.json

if [[ "$mode" == "--check" ]]; then
    cmp "$out/soc_sram_d_synth.v" synth/soc_sram_d_synth.v
    cmp "$out/soc_top_synth.v" synth/soc_top_synth.v
    echo "regen: netlists reproduce byte-for-byte"
fi
