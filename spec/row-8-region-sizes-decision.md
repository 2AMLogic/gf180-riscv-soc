# Decision record: row 8 — region sizes and bases (4 KB + 4 KB)

**Status**: Decided, 2026-10-27
**Resolves**: `spec/soc.md` Part A row 8 (part (a) of #20, issue #32)

## Context

Origin row 8 is 8 KB instruction + 8 KB data, regions 8 KB wide at
`0x1000_0000` and `0x2000_0000`. The Part B SRAM row targets 4 KB + 4 KB
(8 × `sram_256x32`, [`sram-instance-plan-decision.md`](sram-instance-plan-decision.md)),
which takes region bases from the origin and does not settle region size.

Origin facts, read at `sky130-riscv-soc` `main` @ `a980771` (2026-10-27):
`soc_fabric.sv` slices `isd_addr[12:2]`, `isi_addr[12:2]` and
`dsr_addr[12:2]` into an 11-bit word address for 2048 × 32 wrappers.

## Decision

| Item | Value |
|---|---|
| Instruction region | 4 KB at `0x1000_0000` (`0x1000_0000`–`0x1000_0FFF`) |
| Data region | 4 KB at `0x2000_0000` (`0x2000_0000`–`0x2000_0FFF`) |
| Bases | Unchanged from the origin |
| Word address into a side's memory | `addr[11:2]` (10 bits, 1024 words) |
| Macro select within a side | `addr[11:10]`, as in the instance plan |

The region size is the SRAM size of the chosen plan (2 KB fallback, 8 KB
stretch change only the slice width), and a region is decoded at its
plan size. Accesses above the region size are not mapped to the SRAM.

## Consequence

The stamped origin RTL hard-codes `[12:2]` and the 8 KB decode, so this
cannot be applied by editing the stamped copy. The required parametrization
is tracked at the origin:
[`sky130-riscv-soc#52`](https://github.com/2AMLogic/sky130-riscv-soc/issues/52).
Part (b) of #20 (re-pin) depends on it merging; see
[`row-8a-instruction-sram-decision.md`](row-8a-instruction-sram-decision.md)
for the fallback rule, which applies to this row as well.

## Rejected alternatives

- **Keep 8 KB regions with 4 KB of backing store.** Leaves half of each
  region unmapped but decoded, and aliases or faults on the upper half;
  the origin's memory-map tests would not describe the hardware.
- **Move the bases.** No reason: bases are independent of size, and firmware
  and linker scripts are stamped from the origin.
- **Edit the stamped `soc_fabric.sv` locally.** Violates the stamping rule.

## Not decided here

Wrapper pin names, `WEN` polarity and read latency are not ratified upstream
([`gf180-sram#197`](https://github.com/2AMLogic/gf180-sram/issues/197)).
Nothing above depends on them.
