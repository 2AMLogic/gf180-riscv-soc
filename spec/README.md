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
- [`row-8-region-sizes-decision.md`](row-8-region-sizes-decision.md) — 4 KB +
  4 KB regions at the origin's bases; needs an origin change.
- [`row-8a-instruction-sram-decision.md`](row-8a-instruction-sram-decision.md) —
  single-port 1RW instruction SRAM, fixed at the origin; fallback rule.
- [`macro-views-interim-decision.md`](macro-views-interim-decision.md) —
  INTERIM: handling of the missing macro Liberty and macro-level LEF.
- [`stamped-harness-decision.md`](stamped-harness-decision.md) — the
  PDK-independent cocotb harness and record linter are adopted unmodified as
  stamped copies; defines the `reuse.lock.json` `stamped` entry schema, and
  keeps `scripts/setup-env.sh` as a local gf180 variant.
- [`rtl-stamping-decision.md`](rtl-stamping-decision.md) — what is stamped
  from `sky130-riscv-soc` `700b745` under `rtl/common/`, `firmware/boot/` and
  `scripts/`, and so may not be edited here; CVE2 is fetched rather than
  stamped, and the SRAM seam is not stamped.

Pins to siblings are in [`../reuse.lock.json`](../reuse.lock.json).

Two machine-readable companions to [`soc.md`](soc.md) carry the T1 item 6
(statistical rows) evidence. Both are hash-pinned by
[`../manifests/gf180-riscv-soc.json`](../manifests/gf180-riscv-soc.json) under
`evidence."6"` and mirrored in the verdict of record
[`../manifests/gf180-riscv-soc.signoff.json`](../manifests/gf180-riscv-soc.signoff.json),
so editing either one means regenerating both manifests in the same change:

- [`soc.rows.json`](soc.rows.json) — the ratified row inventory of `soc.md`
  (14 rows across Parts A and B); the `spec` leg of the item 6
  `not_applicable` verdict.
- [`soc.item6-na-statement.json`](soc.item6-na-statement.json) — per row, why
  a statistical treatment does not apply (`deterministic`, `fixed-choice` or
  `corner-bounded`); the `statement` leg of the same verdict.
