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
`f6eeac7…` (`spec/pdk-pin-decision.md`), iverilog `13.0`, cocotb `2.0.1` and
sv2v `v0.0.13` (added with #62/#64). The origin's `PIN_COCOTB="…"` line format
is kept so the CI parse works.

The origin also pins a RISC-V GCC (`PIN_RISCV_GCC="14.2.0"`, xPack
`riscv-none-elf-gcc 14.2.0-3`) for its boot and SoC firmware. That pin is
deliberately **not** replicated here (**Amended** 2026-11-15, #70): boot-ROM
regeneration is an origin-only activity in this repo. The artifact the stamped
`firmware/boot/build.sh --check` compares against, `firmware/boot/boot_rom.hex`,
is itself stamped and arrives with the origin commit; nothing in this repo runs
`build.sh`; and `synth/boot_rom_const.v` is derived from the committed hex
rather than rebuilt from `boot.S`. Consequently the stamped script's pointer to
"`PIN_RISCV_GCC` in scripts/setup-env.sh" is unresolved in this repo by this
decision — the toolchain that rebuilds the boot ROM belongs to the origin, which
pins it in its own `scripts/setup-env.sh`. The local `scripts/setup-env.sh`
pins the tools this repo's own verification uses, and is the source of truth
for those only; `docs/environment.md` says the same.

## CI and pinned versions

CI (`.github/workflows/verification.yml`) installs cocotb at the pin but uses
the distro iverilog, as the origin does; that may not be `13.0`. CI results
are therefore not claimed to be at the pinned iverilog. A sha256 check of every
`stamped` entry fails CI on a local edit to a stamped file.
