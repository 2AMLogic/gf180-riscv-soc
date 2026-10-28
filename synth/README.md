# synth

Gate-level netlist of `soc_top` against `gf180mcu_fd_sc_mcu7t5v0` with the
`gf180-sram` macro left as a black box.

| File | Role |
|---|---|
| `soc_top.request.json` | `klt synthesize` request: `soc_top` at `ISRAM_1RW=1`, `ISRAM_AW=DSRAM_AW=10`, library `gf180mcu_fd_sc_mcu7t5v0`, PDK `gf180mcuD` |
| `soc_top_synth.v` | the netlist (generated, committed) |
| `soc_sram_d.request.json`, `soc_sram_d_synth.v` | wrapper-only probe: 4 macros survive as opaque cells |
| `boot_rom_const.v`, `gen_boot_rom.py` | the boot ROM as constants, generated from `firmware/boot/boot_rom.hex` |
| `regen.sh` | regenerates both netlists; `--check` fails if they differ byte-for-byte |

Run `synth/regen.sh --check` to reproduce. It needs `klt`, `yosys` and `sv2v`
(the pinned v0.0.13) on `PATH`; it installs nothing.

## What the netlist is, and is not

- **Mapping corner, not signoff.** Mapped against `ss_125C_3v00` with a 40 ns
  target (`spec/soc.md`: 25 MHz). `klt synthesize` reports no timing for this
  design (`sta` is null); no Fmax and no area figure from here is a signoff
  number. The area `klt` reports excludes the macros.
- **Interim macro declaration** (`spec/macro-views-interim-decision.md`).
  `klt synthesize` requires a LEF for each macro. The only LEF at the pinned
  `gf180-sram` commit is the 322-pin array core, `MACRO sram_256x32_array`;
  it is fetched at that commit, hash-checked, and used only to satisfy the
  field. No pin-level claim comes from it. The instantiated cell is
  `sram_256x32`, whose pins come from `rtl/sram_256x32_blackbox.v` (unratified,
  `gf180-sram#197`). Because the two names differ, the response's
  `macro_instance_count` is 0 although the netlist holds 8 `sram_256x32`
  instances (4 per side); count them in `instance_counts_by_type`. Downstream
  place-and-route must not take this declaration as the macro's LEF. Tool gap:
  `2AMLogic/klayout-tools#4459`.
- **One cell is not a gf180 cell.** The unmodified core's `cve2_clock_gate`
  holds a latch, which `klt synthesize` never maps, so the netlist contains one
  `$_DLATCH_N_`. The request sets `structural.expected_latches` to 1 to record
  this. Until the clock gate is decided and mapped (a decision for this repo;
  the core stays unmodified) and `klt` can map or replace it (`2AMLogic/klayout-tools#4458`), this netlist is
  not ready for place-and-route.
- **Boot ROM.** `boot_rom.sv` is stamped and cannot be read by the Yosys front
  end ( `$readmemh`, plusargs), so `boot_rom_const.v` replaces it for synthesis:
  same module name and ports, the image from `firmware/boot/boot_rom.hex`,
  checked equal to the original over all 1024 addresses in simulation.
