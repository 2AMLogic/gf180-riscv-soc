# Decision record: supply plan and level shifting

**Status**: Decided, 2026-10-17
**Resolves**: part of #3 ("Supplies")

## Question

What supply does the core run at, does it match `gf180-sram`'s single 3.3 V
supply, and where is level shifting needed?

## Options

1. **Single 3.3 V rail for logic and SRAM.** Matches `gf180-sram`
   (`spec/sram.md`: single 3.3 V supply, ±10 %: 2.97 / 3.30 / 3.63 V).
2. **Logic at 5.0 V, SRAM at 3.3 V.** The library devices are 5 V-rated and
   the libraries have `5v00` corners, but this needs level shifters on every
   logic-to-macro signal.
3. **Logic at 1.8 V.** The libraries have `1v80` / `1v62` / `1v98` corners,
   but the macro is not characterized there.

## Decision

**Core supply 3.3 V, shared with the macros (option 1).** One logic supply
domain, one macro supply domain, same rail, so **no level shifters inside
this block.**

- **I/O supply**: not defined by this repo. There is no pad ring here. The
  block boundary is the 3.3 V domain. A later pad ring is the only place a
  different rail could appear, and it would own its level shifting; the
  `gf180mcu_fd_io` library carries `ss_125C_2v97` and `ff_*_3v63` corners
  that bracket 3.3 V ±10 % (file names read under `libs.ref/gf180mcu_fd_io/lib`).
- **Level shifting**: none at the logic-macro seam. Required only if a future
  decision moves one side off 3.3 V, which would need a new record and a
  macro characterized at that rail.

## Consistency with the cell library

The libraries are 5 V-device libraries; "3.3 V" here means the **3.3 V
characterization family** the library ships (`ss_*_3v00`, `tt_025C_3v30`,
`ff_*_3v60`). Timing at this supply is quoted only from those files, each
cited by corner. The library's voltage points (3.00 / 3.30 / 3.60 V) do not
equal the macro's (2.97 / 3.30 / 3.63 V); the reconciliation and the
unmatched corners are in `soc.md` § "STA corner set". This record does not
claim the library is characterized at 2.97 V or 3.63 V: it is not.

## Not decided here

Whether to margin the logic corners to cover the 30 mV gap to the macro's
voltage points, by scaling or by an additional library characterization, is
left to the STA work, with its own record.
