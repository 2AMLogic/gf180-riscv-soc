# verification

The cocotb + Icarus smoke harness, the record linter with its fixtures, and
the two local check scripts. Nine of the twelve files here are stamped from
`sky130-riscv-soc` @ `0bd1c15` and must not be edited in this repo — fix them
at the origin, or record the divergence
([`../spec/stamped-harness-decision.md`](../spec/stamped-harness-decision.md)).
The stamped set and its hashes are pinned in
[`../reuse.lock.json`](../reuse.lock.json), which
`verification/tools/check_stamped.py` enforces.

| File | Origin |
| --- | --- |
| `Makefile` | stamped |
| `cocotb.mk` | stamped |
| `tests/smoke/dut.v` | stamped |
| `tests/smoke/test_smoke.py` | stamped |
| `tools/lint_records.py` | stamped |
| `tools/tests/test_lint_records.py` | stamped |
| `tools/tests/good/lint-fixture/20261018T000000Z-0123456789ab/provenance.json` | stamped |
| `tools/tests/bad/missing-key/20261018T000000Z-0123456789ab/provenance.json` | stamped |
| `tools/tests/bad/bad-name/not-a-timestamp/.keep` | stamped |
| `tools/check_stamped.py` | local |
| `tools/lint_rtl.sh` | local — de-stamped, see [`../spec/rtl-stamping-decision.md`](../spec/rtl-stamping-decision.md) § Divergence |
| `README.md` | local |

## Runner

    make -C verification smoke                       # needs cocotb, iverilog
    python3 -I verification/tools/lint_records.py
    python3 -I verification/tools/tests/test_lint_records.py
    verification/tools/lint_rtl.sh

`smoke` fails, not skips, when cocotb is missing. Pins: `docs/environment.md`.
