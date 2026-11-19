#!/usr/bin/env bash
# Failure-path tests for synth/regen.sh's klt response handling (issue #111).
#
# Each case runs regen.sh in a scratch copy of the tree against a stub `klt`
# that replays a scripted stdout/stderr/exit, then asserts regen's exit
# status and stderr. Stubs (yosys, sv2v, sha256sum, gh) neutralise the
# everything-else the script touches — the seeded LEF matches the pinned
# sha256 only through the sha256sum stub, so no real LEF, PDK or network is
# involved; gh and the real synthesis tools are tripwires that fail the test
# if regen ever calls them.
#
# Cases (synth/regen.sh klt block):
#   macro-name rejection  klt error message names the interim blackbox
#                         declaration -> the reproducibility-gate break text
#   generic error.message any other klt error JSON -> message echoed to stderr
#   unparseable response  no JSON on either stream -> the raw response and
#                         stderr are dumped; regression for the
#                         `cat ... 2>/dev/null >&2` redirect-order bug that
#                         sent the dump to /dev/null
#   success with stderr   klt succeeds with a warning on stderr -> warning
#                         replayed, netlist copied into place
#   --check cleanup       a failing --check removes its mktemp scratch dir
set -euo pipefail
cd "$(dirname "$0")/../.."

# synth/regen.sh; must stay in sync with it.
LEF_SHA256="3cda2519cab4033a7009d5cd665c92035c9e9f2625a6db8222907e352e84b446"

pass=0
fail=0
scratch=""

cleanup() { [[ -n "$scratch" ]] && rm -rf "$scratch" || :; }
trap cleanup EXIT

# ok NAME — record a passing assertion.
ok() { echo "ok - $1"; pass=$((pass + 1)); }

# bad NAME DETAIL — record a failing assertion.
bad() { echo "FAIL - $1: $2" >&2; fail=$((fail + 1)); }

# new_scratch — fresh scratch tree with stubs on its bin/ PATH.
new_scratch() {
    cleanup
    scratch="$(mktemp -d)"
    mkdir -p "$scratch/synth" "$scratch/firmware/boot" "$scratch/bin" \
        "$scratch/build/macro" "$scratch/build/cve2" "$scratch/tmp"
    cp synth/regen.sh synth/gen_boot_rom.py "$scratch/synth/"
    cp firmware/boot/boot_rom.hex "$scratch/firmware/boot/"
    # The seeded LEF's hash comes from the sha256sum stub below, so regen
    # skips the gh fetch; the seeded CVE2 top skips scripts/fetch-cve2.sh.
    : > "$scratch/build/macro/sram_256x32_array.lef"
    : > "$scratch/build/cve2/cve2_top.v"

    for t in yosys sv2v gh; do
        printf '#!/usr/bin/env bash\necho "test-regen: %s must not run" >&2\nexit 1\n' "$t" \
            > "$scratch/bin/$t"
    done
    printf '#!/usr/bin/env bash\necho "%s  $*"\n' "$LEF_SHA256" > "$scratch/bin/sha256sum"

    cat > "$scratch/bin/klt" <<'EOF'
#!/usr/bin/env bash
# Test stub: replays KLT_STUB_STDOUT/KLT_STUB_STDERR (file paths) and exits
# KLT_STUB_EXIT; KLT_STUB_NETLIST=1 also writes the run artifact a real
# successful synthesize leaves behind.
[[ -n "${KLT_STUB_STDOUT:-}" ]] && cat "$KLT_STUB_STDOUT"
[[ -n "${KLT_STUB_STDERR:-}" ]] && cat "$KLT_STUB_STDERR" >&2
if [[ "${KLT_STUB_NETLIST:-0}" == 1 ]]; then
    mkdir -p synth/.klt/synthesize/soc-top
    printf 'module soc_top();\nendmodule\n' \
        > synth/.klt/synthesize/soc-top/soc_top_synth.v
fi
exit "${KLT_STUB_EXIT:-0}"
EOF
    chmod +x "$scratch/bin"/*

    # Fixture payload files the cases point the stub at.
    cat > "$scratch/macro-rejection.json" <<'EOF'
{"error": {"message": "verilog_blackbox declares module(s) absent from the netlist: sram_256x32_array"}}
EOF
    cat > "$scratch/generic-error.json" <<'EOF'
{"error": {"message": "pdk gf180mcuD timing view missing"}}
EOF
    printf 'klt: internal failure: no json here\n' > "$scratch/raw-stdout.txt"
    printf 'panic: netlist writer crashed\n' > "$scratch/raw-stderr.txt"
    printf 'warn: legacy cell gf180mcu_fd_sc_mcu7t5v0 swapped\n' \
        > "$scratch/success-stderr.txt"
}

# run_regen ARGS... — run regen.sh in the scratch tree; sets regen_rc and
# regen_stderr. REGEN_ENV (array of NAME=VALUE) carries the stub control
# vars through env; PATH puts the stubs first, python3 stays the real one.
run_regen() {
    set +e
    ( cd "$scratch" && env PATH="$scratch/bin:$PATH" \
        "${REGEN_ENV[@]}" synth/regen.sh "$@" ) \
        >/dev/null 2>"$scratch/regen.stderr"
    regen_rc=$?
    set -e
    regen_stderr="$(cat "$scratch/regen.stderr")"
}

# expect_rc NAME EXPECTED ACTUAL
expect_rc() {
    if [[ "$3" == "$2" ]]; then ok "$1 exit status is $2"; else
        bad "$1" "exit $3, expected $2; stderr: $regen_stderr"; fi
}

# expect_stderr NAME SUBSTRING — substring must appear in regen's stderr.
expect_stderr() {
    if [[ "$regen_stderr" == *"$2"* ]]; then ok "$1 stderr has '$2'"; else
        bad "$1" "stderr missing '$2'; got: $regen_stderr"; fi
}

# 1. Macro-name rejection: the interim-declaration break is named, not just
#    "klt failed".
new_scratch
REGEN_ENV=("KLT_STUB_STDOUT=$scratch/macro-rejection.json" "KLT_STUB_EXIT=1")
run_regen
expect_rc "macro rejection" 1 "$regen_rc"
expect_stderr "macro rejection" "klt rejects the interim macro declaration"
expect_stderr "macro rejection" "verilog_blackbox declares module(s)"

# 2. Generic error JSON: the message is surfaced.
new_scratch
REGEN_ENV=("KLT_STUB_STDOUT=$scratch/generic-error.json" "KLT_STUB_EXIT=1")
run_regen
expect_rc "generic error" 1 "$regen_rc"
expect_stderr "generic error" "klt synthesize failed: pdk gf180mcuD timing view missing"

# Some klt versions write the error JSON only to stderr.
new_scratch
REGEN_ENV=("KLT_STUB_STDOUT=" "KLT_STUB_STDERR=$scratch/generic-error.json" "KLT_STUB_EXIT=1")
run_regen
expect_rc "generic error on stderr" 1 "$regen_rc"
expect_stderr "generic error on stderr" "regen: klt synthesize failed: pdk gf180mcuD timing view missing"

# 3. Unparseable response on both streams: the raw dump must be visible on
#    regen's stderr (regression for the `2>/dev/null >&2` redirect-order bug
#    that discarded it).
new_scratch
REGEN_ENV=("KLT_STUB_STDOUT=$scratch/raw-stdout.txt"
    "KLT_STUB_STDERR=$scratch/raw-stderr.txt" "KLT_STUB_EXIT=1")
run_regen
expect_rc "unparseable response" 1 "$regen_rc"
expect_stderr "unparseable response" "regen: klt synthesize failed"
expect_stderr "unparseable response" "klt: internal failure: no json here"
expect_stderr "unparseable response" "panic: netlist writer crashed"

# 4. Success with a warning on stderr: warning replayed, netlist copied.
new_scratch
REGEN_ENV=("KLT_STUB_STDERR=$scratch/success-stderr.txt"
    "KLT_STUB_NETLIST=1" "KLT_STUB_EXIT=0")
run_regen
expect_rc "success with stderr" 0 "$regen_rc"
expect_stderr "success with stderr" "warn: legacy cell gf180mcu_fd_sc_mcu7t5v0 swapped"
if grep -q '^module soc_top();$' "$scratch/synth/soc_top_synth.v" 2>/dev/null \
    && grep -q '^endmodule$' "$scratch/synth/soc_top_synth.v"; then
    ok "success with stderr netlist copied"
else
    bad "success with stderr" "netlist not copied into synth/"
fi

# 5. Failing --check: the mktemp scratch dir is removed by the EXIT trap.
new_scratch
REGEN_ENV=("TMPDIR=$scratch/tmp" "KLT_STUB_STDOUT=$scratch/generic-error.json"
    "KLT_STUB_EXIT=1")
run_regen --check
expect_rc "--check cleanup" 1 "$regen_rc"
if [[ -z "$(ls -A "$scratch/tmp")" ]]; then
    ok "--check cleanup scratch dir removed"
else
    bad "--check cleanup" "mktemp dir left behind in tmp/: $(ls -A "$scratch/tmp")"
fi

echo "----------------------------------------"
echo "test-regen-failure-paths: $pass passed, $fail failed"
[[ "$fail" == 0 ]]
