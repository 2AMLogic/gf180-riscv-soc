# Decision record: row 8a — instruction SRAM is single-port 1RW

**Status**: Decided, 2026-10-27
**Resolves**: `spec/soc.md` Part A row 8a (part (a) of #20, issue #32)

## Context

The origin's instruction SRAM is `1rw1r`: port 0 takes data-side writes
(`csb0/web0/addr0`), port 1 takes instruction fetch (`csb1/addr1`). Origin
§ Interconnect says fetch and data-side write proceed in parallel. The
`gf180-sram` macro is single-port synchronous 1RW (`A`, `CEN`, `CLK`, `D`,
`Q`, `GWEN`, `WEN`), one OBI port per side
([`sram-instance-plan-decision.md`](sram-instance-plan-decision.md)).

Origin facts, read at `sky130-riscv-soc` `main` @ `a980771` (2026-10-27):
`soc_sram_i` is 1rw1r with a one-cycle registered read on both ports;
`soc_fabric.sv` ties `isd_gnt_i` and `isi_gnt_i` to `1'b1`, and every
subordinate responds exactly one cycle after the request.

## The conflict

With a single port, a same-cycle data-side write to the instruction region
and an instruction fetch both need the one port. Under always-granted
requests and a fixed one-cycle response neither can be delayed, so the
fabric as stamped cannot serve both. Two ports on the instruction side
are not available from the macro, and building a second port is a bitcell
and macro design, which is out of scope for this repo.

## Decision

**The fix is made at the origin, by the default rule.** The instruction
SRAM on gf180 is single-port 1RW and the SoC adapts to it.

Minimum origin change (filed as
[`sky130-riscv-soc#52`](https://github.com/2AMLogic/sky130-riscv-soc/issues/52)):

1. Parametrize SRAM depth (row 8, 4 KB per side, `addr[11:2]`).
2. Add a parameter selecting the instruction SRAM organization, `1rw1r`
   (default, unchanged sky130 behaviour) or `1rw`. In `1rw` the fabric
   arbitrates `isd` against `isi` onto one port and deasserts the loser's
   `gnt` rather than tying it to 1; the response stays one cycle after the
   grant.

Acceptance test, to pass before the origin change counts as done:

- Default parameters: existing cocotb, arch-test and firmware suites pass
  unchanged.
- `1rw`, 1024 words: a same-cycle data-side store to the instruction
  region and instruction fetch both complete with correct data (the loser
  delayed at least one cycle); the one-cycle response after grant holds;
  `riscv-arch-test` and the firmware tests pass on that configuration.

The SoC-level cost of this choice is that instruction fetch can stall when
firmware writes into the instruction region; this is accepted. Any
performance claim about it needs a simulation, not this record.

## Fallback rule

If `sky130-riscv-soc#52` has not merged when part (b) of #20 is picked up,
**part (b) stays blocked**. The only alternative to waiting is a *separate*
decision record for a local divergence (for example a local fabric
variant), which requires an operator ruling and is **not authored by a
Builder**. This record does not authorize one.

## Rejected alternatives

- **Local fork of `soc_fabric.sv`.** Violates the stamping rule.
- **Local behavioural dual-port model of the macro.** Out of scope per
  `CLAUDE.md` (no local SRAM or timing model).
- **Two single-port macro banks to emulate the second port.** Changes the
  memory map and doubles the instance plan; not decided here.

## Not decided here

Wrapper pin names, `WEN` polarity and read latency are not ratified upstream
([`gf180-sram#197`](https://github.com/2AMLogic/gf180-sram/issues/197)); the
`1rw` arbitration above is stated independent of them, and the wrapper
mapping is part (c).
