# gf180-riscv-soc

A small RISC-V microcontroller SoC on the
[gf180mcu](https://github.com/google/gf180mcu-pdk) open PDK — an
Ibex/CVE2-class RV32 core, an OBI crossbar, the fleet's own gf180mcu SRAM
macro and a minimal peripheral set — designed by AI agents driving
[klayout-tools](https://github.com/2AMLogic/klayout-tools) and the
open-source cocotb + Icarus, Yosys and OpenROAD flow.

**Status: just opened, specification phase.** Nothing is designed yet.

**Built agent-native.** Every specification, decision record, testbench, and
line of documentation here is produced by AI agents working from a ratified
spec and an append-only evidence trail — not human-authored work that agents
merely assisted with. Verification is the product: every claim traces to a
recorded result. Where the agents hit friction with the open-source tooling —
most often [klayout-tools](https://github.com/2AMLogic/klayout-tools) — that
friction is filed as a public issue against the tool itself, so the fix
benefits everyone using gf180mcu, not just this repo.

## Why this block, on this PDK

This is a **port**. Its origin is
[sky130-riscv-soc](https://github.com/2AMLogic/sky130-riscv-soc), which owns
the SoC's PDK-independent half — integration RTL, memory map, firmware and
testbenches. That half is designed there once and comes here as stamped
copies; what this repo re-derives is everything the PDK changes:

- **Standard cells and supplies.** The gf180mcu standard-cell libraries are
  built on 5 V-rated devices and are used here at more than one supply. The
  core supply, whether logic and SRAM share it, and the level shifting at the
  core-to-I/O seam are decisions for this repo, not inherited ones.
- **Memory.** The SRAM is the fleet's
  [gf180-sram](https://github.com/2AMLogic/gf180-sram) macro, not a
  sky130 macro retargeted. Its organization sets the memory map's granularity.
- **Timing.** Every frequency is re-earned on this PDK. Nothing from the
  sky130 repo's timing carries over.

It is also an early consumer of `gf180-sram` as a placed macro inside a
standard-cell floorplan, so the macro's views (abstract, timing) get an
integration test here.

## What comes from siblings

| From | What | Edge |
|---|---|---|
| `sky130-riscv-soc` | SoC integration RTL, memory map, firmware, testbenches | `ported_from` (master) |
| `gf180-sram` | 256 x 32 (1 kB) single-port synchronous SRAM macro: GDS, LEF abstract, timing view | `consumes` |

The SRAM interface is the one ratified in `gf180-sram`'s `spec/sram.md` —
single-port 1RW, one clock, pin interface matching the gf180mcu foundry SRAM
(`A`, `CEN`, `CLK`, `D`, `Q`, `GWEN`, `WEN`), a single 3.3 V supply. This repo
specifies how it uses that interface; it does not redesign it.

## Target specification (DRAFT — engineering to ratify, see issue #1)

Port parity with the sky130 origin where the PDK allows; departures go
through decision records.

| Parameter | Target | Fallback | Stretch |
|---|---|---|---|
| Core | RV32IMC, same core and configuration as `sky130-riscv-soc` | RV32EC | + debug module over JTAG |
| Interconnect | OBI crossbar, as the origin | single shared OBI bus | — |
| SRAM | 4 KB instruction + 4 KB data (`gf180-sram` instances) | 2 KB + 2 KB | 8 KB + 8 KB |
| Peripherals | boot ROM, UART, GPIO, timer | boot ROM, UART, GPIO | SPI flash execute-in-place |
| Core supply | 3.3 V, shared with `gf180-sram` | — | — |
| Signoff Fmax (post-route STA, slow corner) | 25 MHz | 12.5 MHz | 50 MHz |
| Signoff | DRC + LVS clean, STA closed at every ratified corner | — | — |

Maturity ladder: spec ratified → origin's SoC RTL and tests passing on this
repo's netlist → synthesized with timing met at the target → placed and
routed with the `gf180-sram` macros, DRC/LVS-clean → post-route
multi-corner STA closed → shuttle seat → measured silicon (bench Fmax).
**Current position: pre-spec.**

## Repo layout

```
spec/          ratified spec + decision records
rtl/           PDK-specific RTL; stamped copies from the origin under rtl/common/
verification/  cocotb testbenches (stamped from the origin) + run records
layout/        GDS + DRC/LVS reports + STA reports (klayout-tools driven)
measurements/  silicon characterization (empty until tape-out)
```

## License

Apache License 2.0 — see [LICENSE](LICENSE).
