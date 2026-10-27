# Decision record: stamped integration RTL, boot firmware and CVE2 scripts

**Status**: Decided, 2026-10-27
**Resolves**: part (b) of #20 (T1 item 1 of #4), via #33

## Decision

The `sky130-riscv-soc` edge is re-pinned to `700b74596f52eccf867f91b30f09d963f4cb9de7`
(origin `main`, 2026-10-27). `git merge-base --is-ancestor befb9d8 700b745` holds in
the origin, so the pin contains the row-8a fix (origin PR #58).

Stamped at that commit, unmodified, entries in `reuse.lock.json` `stamped`:

- `rtl/common/`: `soc_top.sv`, `soc_fabric.sv`, `obi_xbar.sv`, `obi_err_resp.sv`,
  `rst_sync.sv`, `boot_rom.sv`, `boot_rom.hex` (origin `rtl/<same name>`).
- `firmware/boot/`: `boot.S`, `boot_rom.hex`, `build.sh`, `link.ld`. The two
  `boot_rom.hex` files differ at the origin and are stamped separately.
- `scripts/fetch-cve2.sh`, `scripts/convert-cve2.sh`.

CVE2 is fetched, not stamped: the `openhwgroup/cve2` entry of the origin's
`imports` (commit `d7f21568…`, 32 files with sha256) is copied into `imports`.
The origin's sky130 macro and OpenRAM imports are not.

Not stamped: `soc_sram_i.sv`, `soc_sram_d.sv`, `soc_sram_i_1rw.sv` (the SRAM
seam, part c), `rtl/README.md`, the origin `setup-env.sh`, the origin harness
changes after `0bd1c151…` (`verification/Makefile`, smoke test, `check_soc_rows.py`,
`test_fetch_cve2.sh`; testbench stamping is #22).

## Divergence

`verification/tools/lint_rtl.sh` is **no longer stamped**; it is a local variant,
as `scripts/setup-env.sh` is. Reasons, both layout/seam: the origin script
assumes a flat `rtl/` (it skips `rtl/soc_top.sv` by path) while the stamped RTL
is under `rtl/common/`; and the stamped `soc_fabric.sv` instantiates
`soc_sram_i`/`soc_sram_d`, which do not exist here until part c, so Verilator
fails with MODMISSING. The local script skips `soc_fabric.sv` and `soc_top.sv`
with a printed notice while no `soc_sram_d` module is defined, and `soc_top.sv`
while the converted core is absent. `LINT_REQUIRE_SRAM=1` and `LINT_REQUIRE_CORE=1`
make either skip a failure. The origin's alternate-fabric elaboration
(`ISRAM_1RW=1`) is dropped for now. Until part c lands, `soc_fabric`/`soc_top`
are therefore **not lint-checked here**; part c should set `LINT_REQUIRE_SRAM=1` in CI.

`scripts/setup-env.sh` gains `PIN_SV2V="v0.0.13"` (the origin's pin); `--check`
does not test for sv2v yet.

## Evidence

`scripts/fetch-cve2.sh` verified all 32 files and is idempotent (run twice).
`scripts/convert-cve2.sh` with sv2v v0.0.13 elaborates `cve2_top` in Icarus and
produced the same `cve2_top.v` on two runs (sha256 `f2a58b07…`). This is a
conversion/elaboration check, not a functional result.
