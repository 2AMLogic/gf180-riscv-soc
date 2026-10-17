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
| `2AMLogic/sky130-riscv-soc` | origin, `ported_from` | `f2587409c9cbc504c01c9fe3fa432fc34e49a3bb` (main, 2026-10-17) |
| `2AMLogic/gf180-sram` | `consumes` | `d0bacc0fceb6e9400e54e3efe15ec1630711faa9` (main, 2026-10-17) |

## Part A — Inherited from `sky130-riscv-soc` (not re-decided here)

At the commit above the origin's `spec/` holds only `spec/README.md` ("Empty
until the first work lands here"); its `rtl/` and `verification/` hold only
READMEs. **None of the inherited items is ratified at the origin yet.** Per
the issue, they are tracked there, not decided here. The origin's
spec-ratification issue is
[`sky130-riscv-soc#2`](https://github.com/2AMLogic/sky130-riscv-soc/issues/2);
this repo's row for each item is filled in with the origin commit once that
issue lands.

| Item | Origin location | Origin commit | State |
|---|---|---|---|
| Core choice (Ibex or CVE2), ISA configuration, pinned upstream commit | `spec/` (not yet written) | `f2587409…` | **Tracked at origin** (`sky130-riscv-soc#2`); origin README says only "Ibex/CVE2-class", choice made in `spec/` |
| OBI crossbar topology | `spec/` (not yet written) | `f2587409…` | **Tracked at origin** |
| Memory map layout | `spec/` (not yet written) | `f2587409…` | **Tracked at origin**; this repo's SRAM decode ([`sram-instance-plan-decision.md`](sram-instance-plan-decision.md)) is expressed as offsets within a region, not as addresses |
| Boot flow (boot ROM) | `spec/` (not yet written) | `f2587409…` | **Tracked at origin** |
| Firmware and verification plan (architectural tests, firmware tests) | `verification/` (README only) | `f2587409…` | **Tracked at origin**; the README names riscv-arch-test |
| Integration RTL | `rtl/` (README only) | `f2587409…` | **Tracked at origin**; arrives as stamped copies under `rtl/common/` |

Until an item is ratified at the origin, this repo's README rows for it
(RV32IMC, OBI crossbar, boot ROM/UART/GPIO/timer) are **provisional mirrors
of the origin's README draft**, not independent decisions. No file is stamped
yet, so `reuse.lock.json` has an empty `stamped` list.

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
3. **Which origin files are stamped and which fetched?** None is stamped yet,
   because the origin has no RTL, firmware or testbench files at `f2587409…`.
   The first [`reuse.lock.json`](../reuse.lock.json) names both siblings and
   an empty stamped list; it is filled in as origin files land.

### Out of scope

No RTL, bitcell, local SRAM or local timing model of the macro; no PLL; no pad
ring. CI and the signoff manifest are #5.
