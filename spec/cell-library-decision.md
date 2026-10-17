# Decision record: standard-cell library

**Status**: Decided, 2026-10-17
**Resolves**: part of #3 ("Standard-cell library")

## Question

Which gf180mcu standard-cell library does the core and glue logic use?

## Options

Both are in `gf180mcuD/libs.ref/` (`f6eeac7`) and both are 5 V-rated device
libraries with Liberty files at the 3.3 V family corners:

| | `gf180mcu_fd_sc_mcu7t5v0` | `gf180mcu_fd_sc_mcu9t5v0` |
|---|---|---|
| Site | `GF018hv5v_mcu_sc7`, 0.56 × 3.92 µm | `GF018hv5v_green_sc9`, 0.56 × 5.04 µm |
| Liberty corners | 15 (ss/tt/ff × temp × 3 voltage families) | 15, same set |
| 3.3 V family files | `ss_*_3v00`, `tt_025C_3v30`, `ff_*_3v60` | same |

(Site sizes read from `techlef/*__nom.tlef`.) The OSU `gf180mcu_osu_sc_*`
libraries are 3.3 V native but are not the foundry `fd` library and are not
considered further.

## Decision

**Target: `gf180mcu_fd_sc_mcu7t5v0` (7-track).** **Fallback:**
`gf180mcu_fd_sc_mcu9t5v0` (9-track), switched to only through a new decision
record if the 7-track netlist cannot close the fallback frequency.

## Why

- The 7-track row is 22 % shorter (3.92 vs 5.04 µm for the same 0.56 µm
  pitch), so the same logic occupies less area. Area matters here because
  eight macro array cores already take about 1.58 mm² (see
  [`sram-instance-plan-decision.md`](sram-instance-plan-decision.md)).
- The target is 25 MHz (40 ns period), a low frequency for a 180 nm library
  at 3.3 V; the rationale for a taller, higher-drive library has to come from
  evidence that 7-track misses it.
- Both libraries expose the same corners at the same voltages, so the choice
  does not change the corner reconciliation in `soc.md` or the supply plan.

## What this does not establish

No synthesis or timing run backs this choice. "Smaller" is a geometry fact;
that 7-track meets 25 MHz at any corner is **not** claimed. The supply and
corner question that the library choice does not settle is in
[`supply-plan-decision.md`](supply-plan-decision.md).
