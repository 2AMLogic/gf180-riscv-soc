# spec

Ratified spec and decision records for this block.

- [`soc.md`](soc.md) — resolves #3: the ratified target spec. Part A lists
  items inherited from `sky130-riscv-soc` (tracked at the origin, not decided
  here); Part B re-derives what the PDK changes, with the STA corner set and
  its mismatch against `gf180-sram`'s corners.
- [`pdk-pin-decision.md`](pdk-pin-decision.md) — `gf180mcuD` at open_pdks
  `f6eeac7`; a recorded divergence from `gf180-sram`'s current pin.
- [`cell-library-decision.md`](cell-library-decision.md) — 7-track
  `gf180mcu_fd_sc_mcu7t5v0`, 9-track as fallback.
- [`supply-plan-decision.md`](supply-plan-decision.md) — single 3.3 V rail
  shared with the macros; no level shifters inside the block.
- [`sram-instance-plan-decision.md`](sram-instance-plan-decision.md) — 8
  `gf180-sram` macros at target; address and byte-write mapping.
- [`macro-views-interim-decision.md`](macro-views-interim-decision.md) —
  INTERIM: handling of the missing macro Liberty and macro-level LEF.

Pins to siblings are in [`../reuse.lock.json`](../reuse.lock.json).
