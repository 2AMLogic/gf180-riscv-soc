# rtl

`common/` is the stamped integration RTL (see `../spec/rtl-stamping-decision.md`);
do not edit it. The files directly under `rtl/` are local, gf180-specific, and
are the SRAM seam that the origin leaves per-PDK.

| File | Role |
|---|---|
| `soc_sram_d.sv` | data SRAM wrapper: 2**(AW-8) `sram_256x32` macros (default AW=10, 4 KB), `addr[7:0]` to the macro, `addr[AW-1:8]` selects one through `CEN` |
| `soc_sram_i.sv` | `soc_sram_i_1rw` (the instruction SRAM, same array as `soc_sram_d`; `spec/row-8a-instruction-sram-decision.md`) and `soc_sram_i`, the origin's 1rw1r wrapper, which errors on elaboration because the macro has one port |
| `sram_256x32_blackbox.v` | hand-written `(* blackbox *)` declaration of the macro, for lint and `klt synthesize` |

**INTERIM.** The macro pin list, polarity and read latency are the ones in
`gf180-sram` `spec/macro-interface-decision.md`, which is proposed, not
ratified (`gf180-sram#197`). Everything that depends on them is marked
PROVISIONAL, and the wrappers are governed by
`../spec/macro-views-interim-decision.md`. There is no behavioural model of the
macro here (CLAUDE.md), so these wrappers do not simulate on their own; the
SoC must be built with `ISRAM_1RW=1` and 1024-word sides (`ISRAM_AW=DSRAM_AW=10`),
and `verification/tools/lint_rtl.sh` lints at that configuration.
