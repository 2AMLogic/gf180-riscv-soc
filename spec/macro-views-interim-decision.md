# Decision record: interim handling of missing `gf180-sram` macro views

**Status**: Decided, 2026-10-17 — **INTERIM**, retired when `gf180-sram`
ships the views
**Resolves**: part of #3 (open questions 1 and 2)

## Gap

At `gf180-sram` `d0bacc0` there is **no Liberty (`.lib`) view**, and the only
LEF is of the 322-pin array core, not of the 1RW macro interface
(`A`/`CEN`/`CLK`/`D`/`Q`/`GWEN`/`WEN`). This SoC needs both for macro
placement and for signoff STA through the macro.

Raised upstream: [`gf180-sram#197`](https://github.com/2AMLogic/gf180-sram/issues/197).

## Interim decision

1. **No local stand-in timing model and no local macro model.** `CLAUDE.md`
   forbids one, and none is created here.
2. **Any STA run before the macro Liberty exists treats macro paths as not
   signed off.** Reports must say so; a figure from such a run is labelled
   **"logic only, macro paths unconstrained"** wherever it appears and is not
   a signoff Fmax.
3. **Floorplan experiments** may use the array-core LEF solely as a
   placeholder bounding box, labelled as such, and make no pin-access claim.

## Retirement

Replace this record, with a new one, when the macro-level LEF and Liberty
views exist at a `gf180-sram` commit pinned in `reuse.lock.json`.
