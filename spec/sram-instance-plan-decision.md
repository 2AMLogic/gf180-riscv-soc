# Decision record: SRAM instance plan

**Status**: Decided, 2026-10-17
**Resolves**: part of #3 ("SRAM use")

This specifies how the SoC uses the macro. It does not design a bitcell, a
local SRAM or a local timing model of the macro.

## Interface used

From `gf180-sram` `spec/sram.md` and `spec/bitcell-decision.md` (`d0bacc0`):
`sram_256x32`, 256 words × 32 bits = 1 KB, single-port synchronous 1RW, one
clock, one 3.3 V supply; pin names `A`, `CEN`, `CLK`, `D`, `Q`, `GWEN`, `WEN`.

The widths here follow from the 256 × 32 organization:
`A[7:0]`, `D[31:0]`, `Q[31:0]`, `WEN[31:0]`. **Not ratified upstream** (so not
decided here): pin polarity, `WEN` semantics (the foundry macro the interface
is modelled on has `WEN[7:0]` over `D[7:0]`, one per data bit), and read
latency. They are raised in `gf180-sram#197`; everything below that depends on
them is marked.

## Decision

| Plan | Instruction | Data | Macros |
|---|---|---|---|
| Target | 4 KB | 4 KB | 8 |
| Fallback | 2 KB | 2 KB | 4 |
| Stretch | 8 KB | 8 KB | 16 |

One macro is 1 KB, so instruction and data memories are each built from
*N* macros of depth 256, never from a partial macro.

## Address mapping (target, 4 KB per side)

Within a region, for byte offset `o[11:0]`:

- `o[1:0]`: byte lane (not sent to the macro).
- `o[9:2]` → macro `A[7:0]` (word within a 256-word macro).
- `o[11:10]` → macro select (one of four).

`CEN` is asserted only on the selected macro. For 2 KB the select is
`o[10]`; for 8 KB it is `o[12:10]`. Region base addresses come from the
origin's memory map, which is not ratified yet (Part A of `soc.md`).

## OBI to macro mapping

- One OBI port drives each side (instruction, data); a side's four macros
  share `CLK` (the core clock), `A`, `D` and the write controls, and differ
  only in `CEN`.
- A write request sets `GWEN` for a write and clears it for a read.
- `Q` of the four macros is selected by the registered macro-select, since
  the response comes in a later cycle (**read latency not ratified upstream**).
- OBI `rvalid`/`gnt` timing follows from that latency and is not fixed here.

## Byte-write handling

OBI carries a 4-bit byte enable `be[3:0]`. The macro's `WEN` is
assumed to be a per-bit mask `WEN[31:0]` (by analogy with the foundry macro; not
ratified), so each `be[i]` expands to the 8 `WEN` bits of byte *i*.
Whether that expansion is active-high or active-low depends on the
unratified `WEN` polarity and is **provisional** until `gf180-sram#197`
closes. Read-modify-write is not used.

## Area note (measured from the LEF, array core only)

`views/sram_256x32_array.lef` (`d0bacc0`) is `SIZE 143.1500 BY 1382.4000` µm,
about 0.198 mm² per array core, so about 1.58 mm² for eight. This excludes
all periphery (none is drawn) and is a tall 1:9.7 shape, which is a
floorplanning risk to watch; neither figure is a macro size.
