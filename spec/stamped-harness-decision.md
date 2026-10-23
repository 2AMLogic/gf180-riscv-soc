# Decision record: stamped verification harness and local environment script

**Status**: Decided, 2026-10-23
**Resolves**: T1 item 9 of #4 (via #12)

## Decision

The PDK-independent harness of `sky130-riscv-soc` is adopted unmodified, as
stamped copies pinned in `reuse.lock.json` (`stamped`, one entry per file:
`path`, `origin_repo`, `origin_path`, `origin_commit`, `sha256`). The entry
schema was undefined before; this record defines it. The `sky130-riscv-soc`
edge moved from `f2587409` (which carries no harness) to `0bd1c15`, the commit
the files were stamped at. `verification/README.md` and `verification/records/**`
are not stamped.

## Divergence

`scripts/setup-env.sh` is **not** stamped. The origin's script hard-codes
`sky130`/`sky130A` and its tool pins (klt, Yosys, OpenROAD), so it cannot be
used as is, and editing a stamped copy is not allowed. `scripts/setup-env.sh`
here is a local gf180 variant: `--check` only, pinning `gf180mcuD`, open_pdks
`f6eeac7…` (`spec/pdk-pin-decision.md`), iverilog `13.0` and cocotb `2.0.1`.
The origin's `PIN_COCOTB="…"` line format is kept so the CI parse works.

## CI and pinned versions

CI (`.github/workflows/verification.yml`) installs cocotb at the pin but uses
the distro iverilog, as the origin does; that may not be `13.0`. CI results
are therefore not claimed to be at the pinned iverilog. A sha256 check of every
`stamped` entry fails CI on a local edit to a stamped file.
