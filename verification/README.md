# verification

Empty until the first work lands here. See the repo README for scope.

## Runner

The cocotb + Icarus harness and record linter are stamped from
`sky130-riscv-soc` (see `reuse.lock.json`; do not edit them here).

    make -C verification smoke                       # needs cocotb, iverilog
    python3 -I verification/tools/lint_records.py
    python3 -I verification/tools/tests/test_lint_records.py
    verification/tools/lint_rtl.sh

`smoke` fails, not skips, when cocotb is missing. Pins: `docs/environment.md`.
