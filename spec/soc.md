# Target spec: gf180mcu RISC-V microcontroller SoC

**Status**: Ratified, 2026-10-17
**Resolves**: #3 ("Draft and ratify the target spec")
**Decision records**: [`pdk-pin-decision.md`](pdk-pin-decision.md),
[`cell-library-decision.md`](cell-library-decision.md),
[`supply-plan-decision.md`](supply-plan-decision.md),
[`sram-instance-plan-decision.md`](sram-instance-plan-decision.md),
[`macro-views-interim-decision.md`](macro-views-interim-decision.md)

This ratifies the `README.md` DRAFT target table. It is the spec agents build
and verify against; it is not relaxed to make results pass. A change to any
row needs a new decision record, not an edit against a failing result.

The spec has two halves, as the repo is a port: **Part A** is inherited from
`sky130-riscv-soc` and not decided here; **Part B** is what the PDK changes
and is decided here.

Sources read for this spec (pinned in [`reuse.lock.json`](../reuse.lock.json)):

| Repo | Role | Commit read |
|---|---|---|
| `2AMLogic/sky130-riscv-soc` | origin, `ported_from` | `700b74596f52eccf867f91b30f09d963f4cb9de7` (main, 2026-10-27); re-pinned from `0bd1c151156088072b591d38800feac1da0ae2cc` (2026-10-23) to reach the integration RTL and the row-8a fix (`befb9d8`, an ancestor of the pin). The Part A rows below were read at `0bd1c151…` |
| `2AMLogic/gf180-sram` | `consumes` | `d0bacc0fceb6e9400e54e3efe15ec1630711faa9` (main, 2026-10-17) |

## Part A — Inherited from `sky130-riscv-soc` (not re-decided here)

The origin's SoC spec is ratified: `spec/soc.md` there was ratified on
2026-10-17 by `sky130-riscv-soc#2` (closed), in commit `1e6c447d571e95f2aa4f8e29ae1ef30ab03bdaa8`,
the only origin commit that touches it, with decision records
[`0001-core-choice.md`](https://github.com/2AMLogic/sky130-riscv-soc/blob/0bd1c151156088072b591d38800feac1da0ae2cc/spec/decision-records/0001-core-choice.md)
and [`0002-sram-source.md`](https://github.com/2AMLogic/sky130-riscv-soc/blob/0bd1c151156088072b591d38800feac1da0ae2cc/spec/decision-records/0002-sram-source.md).
The pin is origin `main` at `0bd1c151156088072b591d38800feac1da0ae2cc` rather than the ratifying commit, because
the origin's cocotb harness (`verification/Makefile`, `tests/`, `tools/`)
lands after `1e6c447d`; `spec/soc.md` is unchanged between the two. Below,
"origin `spec/soc.md`" means that file at the pin
([view](https://github.com/2AMLogic/sky130-riscv-soc/blob/0bd1c151156088072b591d38800feac1da0ae2cc/spec/soc.md)),
and "row N" is its parameter-table row N.

A row here cites the origin; it does not restate or re-decide the value.
Filling in Part A changes no Part B value.

| Item | Origin row / section | Origin commit | State |
|---|---|---|---|
| Core choice, ISA configuration, pinned upstream commit | rows 1-4; `decision-records/0001-core-choice.md` (CVE2 `cve2_top` at `d7f21568…`, RV32IMC, `RV32MFast`, debug out of scope) | `0bd1c151…` | Ratified at origin |
| OBI crossbar topology | row 5; § Interconnect (OBI v1.4, 2 managers, 4 subordinates) | `0bd1c151…` | Ratified at origin; the parallel-port arbitration sentence is re-derived, see [below](#origin-rows-re-derived-for-gf180) |
| Memory map, reset vector | row 6; § Memory map (reset vector `0x0000_0000`, region bases, interrupt map) | `0bd1c151…` | Ratified at origin; this repo's SRAM decode ([`sram-instance-plan-decision.md`](sram-instance-plan-decision.md)) is expressed as offsets within a region, not as addresses. Region sizes are re-derived, see below |
| Boot flow (boot ROM) | § Memory map ("Boot flow") and § Peripherals (boot ROM) | `0bd1c151…` | Ratified at origin |
| Peripherals | row 9; § Peripherals (boot ROM, UART, 8-bit GPIO, machine timer; SPI XIP stretch) | `0bd1c151…` | Ratified at origin |
| Clock and reset | row 10; § Clock and reset (one clock `clk_i`, async-assert / sync-deassert reset) | `0bd1c151…` | Ratified at origin |
| Firmware and verification plan (architectural tests, firmware tests) | § Verification plan (`riscv-arch-test` pinned at `9929db1c…`, cocotb suites, golden UART transcripts) | `0bd1c151…` | Ratified at origin; the Timing and Physical rows of that plan use origin corners, see below |
| Integration RTL | § "PDK-independent seam", left column (SoC top, crossbar, peripherals, boot ROM source); `rtl/` at the origin | `700b745…` | Ratified at origin; stamped under `rtl/common/` (`soc_top`, `soc_fabric`, `obi_xbar`, `obi_err_resp`, `rst_sync`, `boot_rom`, `boot_rom.hex`), with `firmware/boot/*` and `scripts/{fetch,convert}-cve2.sh`. `soc_sram_*` is not stamped (part c). See [`rtl-stamping-decision.md`](rtl-stamping-decision.md) |

Re-pin record: `reuse.lock.json` edge `sky130-riscv-soc` moved from
`f2587409c9cbc504c01c9fe3fa432fc34e49a3bb` (pinned 2026-10-17) to `0bd1c151156088072b591d38800feac1da0ae2cc` (pinned 2026-10-23),
then to `700b74596f52eccf867f91b30f09d963f4cb9de7` (pinned 2026-10-27). The harness files stamped at `0bd1c151…` keep
their own `origin_commit` in `stamped`; only the files added by #33 are stamped at `700b745…`.

### Origin rows re-derived for gf180

Origin values that depend on sky130 and must not be carried over silently.
Each is **superseded by a Part B row** or **open: needs a decision record
here**. This list does not decide any open row, and changes no Part B value.

| Origin row | Origin value | Disposition |
|---|---|---|
| 7 SRAM source | OpenRAM sky130 macros | Superseded by the Part B SRAM row (`gf180-sram` macro) |
| 8 SRAM size; § Memory map region sizes | 8 KB instruction + 8 KB data; regions 8 KB at `0x1000_0000` and `0x2000_0000` | Capacity superseded by the Part B SRAM row (4 KB + 4 KB target). Decided: 4 KB + 4 KB regions at the origin's unchanged bases, `addr[11:2]`, in [`row-8-region-sizes-decision.md`](row-8-region-sizes-decision.md); needs an origin change ([`sky130-riscv-soc#52`](https://github.com/2AMLogic/sky130-riscv-soc/issues/52)) |
| 8a SRAM macro organization | instruction `1rw1r`, data `1rw`, 32-bit, 8-bit write mask | Decided in [`row-8a-instruction-sram-decision.md`](row-8a-instruction-sram-decision.md): single-port 1RW, fixed at the origin ([`sky130-riscv-soc#52`](https://github.com/2AMLogic/sky130-riscv-soc/issues/52)). Context: `gf180-sram` is single-port 1RW with `GWEN`/`WEN`, one OBI port per side per [`sram-instance-plan-decision.md`](sram-instance-plan-decision.md); the origin's "instruction fetch and data-side write proceed in parallel" arbitration (§ Interconnect) assumes a second port on the instruction SRAM |
| 11 Signoff Fmax | 50 MHz target, 25 MHz fallback, 100 MHz stretch, at `ss_100C_1v60` | Superseded by the Part B signoff Fmax row (25 / 12.5 / 50 MHz) and [STA corner set](#sta-corner-set) |
| 12 PVT corner set | `ss_100C_1v60`, `tt_025C_1v80`, `ff_n40C_1v95` | Superseded by the Part B [STA corner set](#sta-corner-set) |
| 13 Standard cells | `sky130_fd_sc_hd` | Superseded by the Part B standard-cell library row |
| 14 Signoff; § STA corners macro coverage | STA closed at every corner that has a macro view | Superseded by the Part B signoff row and [`macro-views-interim-decision.md`](macro-views-interim-decision.md) |
| § "PDK-independent seam", right column | SRAM wrapper `soc_sram_*`, SDC timing numbers, floorplan, macro placement, power grid, CTS/PnR recipe, DRC/LVS decks | Not inherited, per-PDK by the origin's own statement. The `soc_sram_*` wrapper boundary is where the `gf180-sram` macro attaches |

## Part B — Re-derived for gf180mcu

| Parameter | Target | Fallback | Stretch | Record |
|---|---|---|---|---|
| PDK variant and revision | `gf180mcuD`, open_pdks `f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7` | — | — | [`pdk-pin-decision.md`](pdk-pin-decision.md) |
| Standard-cell library | `gf180mcu_fd_sc_mcu7t5v0` (7-track) | `gf180mcu_fd_sc_mcu9t5v0` (9-track) | — | [`cell-library-decision.md`](cell-library-decision.md) |
| Core supply | 3.3 V, shared with `gf180-sram` | — | — | [`supply-plan-decision.md`](supply-plan-decision.md) |
| SRAM | 4 KB instruction + 4 KB data = 8 × `sram_256x32` | 2 KB + 2 KB = 4 × | 8 KB + 8 KB = 16 × | [`sram-instance-plan-decision.md`](sram-instance-plan-decision.md) |
| Signoff Fmax (post-route STA, slow corner) | 25 MHz | 12.5 MHz | 50 MHz | below |
| Signoff | DRC + LVS clean; STA closed at every corner in the table below | — | — | below |

Peripherals, core and interconnect rows are Part A.

### Signoff Fmax

"Signoff Fmax" is the highest clock frequency at which post-route STA closes
at every corner in the table below, stated with its corner and layout state.
Nothing in this repo is *measured* until silicon is on a bench; a simulated
or STA figure is never called measured. No Fmax figure exists yet.

Macro paths cannot be signed off until `gf180-sram` ships a Liberty view of
the macro interface; see [Open questions](#open-questions).

### STA corner set

The logic library's characterized corners at the 3.3 V family, read from
`gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/` (identical file names and
`nom_voltage` under both the `c6d73a3` and `f6eeac7` trees; the 9t library
has the same set):

| Corner | Logic Liberty (`gf180mcu_fd_sc_mcu7t5v0__…`) | Library nom voltage |
|---|---|---|
| ss, -40 C | `ss_n40C_3v00.lib` | 3.00 V |
| ss, 125 C | `ss_125C_3v00.lib` | 3.00 V |
| tt, 25 C | `tt_025C_3v30.lib` | 3.30 V |
| ff, -40 C | `ff_n40C_3v60.lib` | 3.60 V |
| ff, 125 C | `ff_125C_3v60.lib` | 3.60 V |

The macro's ratified corner set (`gf180-sram` `spec/sram.md`) is
{ff, tt, ss} × {-40, 25, 125 C} × {2.97, 3.30, 3.63 V} = 27 corners. The two
sets **do not line up**, and this is recorded rather than papered over:

| Mismatch | Detail |
|---|---|
| Voltage | Library characterizes ss at 3.00 V and ff at 3.60 V; macro ratifies 2.97 V and 3.63 V (±10 % of 3.3 V). Differences are 30 mV on each side |
| Temperature | Library has tt only at 25 C; macro ratifies tt at -40/25/125 C. Library has no corner at 2.97 V, 3.30 V at ff/ss, or 3.63 V |
| Macro view | `gf180-sram` has **no Liberty view at any corner** at `d0bacc0`, so no macro view name exists to pair with any logic corner yet |

The STA corner set for signoff is the five library corners above, until the
macro supplies Liberty views; each macro view that arrives is paired to the
nearest library corner in a new decision record, with the voltage offset
stated. The slow-corner Fmax is quoted at the worst setup corner among the
`ss` corners; which of `ss_n40C_3v00` / `ss_125C_3v00` that is comes from
STA, not from this spec. Voltage derating or interpolation between library
corners is not assumed here.

### Open questions

Each is answered from the artifacts actually present at the pinned commits.

1. **Does `gf180-sram` have the timing view this SoC needs for signoff STA?**
   **No.** `views/` at `d0bacc0` contains `sram_256x32_array.lef`,
   `.socket.json` and two reports; there is no `.lib` file anywhere in the
   repo. `views/README.md` lists Liberty as "the next seed". Raised upstream
   as [`gf180-sram#197`](https://github.com/2AMLogic/gf180-sram/issues/197).
   Interim handling is [`macro-views-interim-decision.md`](macro-views-interim-decision.md).
2. **Is the macro's LEF abstract sufficient for OpenROAD macro placement and
   routing?** **Not yet, and not testable here.** The committed LEF is an
   abstract of the *array core* only: `MACRO sram_256x32_array`,
   `CLASS BLOCK`, `SIZE 143.1500 BY 1382.4000`, 322 pins (`WL0..255`,
   `BL0..31`, `BLB0..31`, `VDD`, `VSS`) on Metal1 with Metal1/Metal2 `OBS`.
   It is not the 1RW macro: the `A`/`CEN`/`CLK`/`D`/`Q`/`GWEN`/`WEN`
   interface does not exist in that LEF (`views/README.md` states this).
   Pin access and blockage sufficiency for OpenROAD is therefore not
   evaluable until the macro-level LEF exists; included in `gf180-sram#197`.
3. **Which origin files are stamped and which fetched?** Resolved: the harness
   was stamped by #12 and the integration RTL, boot firmware and CVE2 scripts
   by #33 ([`rtl-stamping-decision.md`](rtl-stamping-decision.md)); CVE2
   itself is fetched at its pinned commit (`imports` in
   [`reuse.lock.json`](../reuse.lock.json)), never stamped.

### Out of scope

No RTL, bitcell, local SRAM or local timing model of the macro; no PLL; no pad
ring. CI and the signoff manifest are #5.
