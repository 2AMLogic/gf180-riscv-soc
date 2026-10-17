# Decision record: PDK variant and open_pdks revision

**Status**: Decided, 2026-10-17
**Resolves**: part of #3 ("PDK variant and revision")

## Question

`CLAUDE.md` says to pin the same variant and `open_pdks` revision as
`gf180-sram` unless a decision record says otherwise. Which pin applies?

## Options

1. `gf180mcuD` at `c6d73a35f524070e85faff4a6a9eef49553ebc2b` — what
   `gf180-sram` pins today (`spec/pdk-variant-decision.md`, `d0bacc0`).
2. `gf180mcuD` at `f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7` — the fleet
   revision from the 2026-10-15 fleet-wide decision.

## Decision

**Variant `gf180mcuD`** (same as `gf180-sram`; fleet ruling cited in that
repo's decision record). **Revision `f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7`,
fetched with ciel**, so this repo starts on the new revision instead of
migrating later.

This is a **recorded divergence** from `gf180-sram`'s current pin: that repo
still pins `c6d73a3` and tracks its own move in
[`gf180-sram#173`](https://github.com/2AMLogic/gf180-sram/issues/173), which
describes `c6d73a3` as retired from volare's release feed and `f6eeac7` as the
fleet revision. When `#173` merges the two pins agree and this divergence
closes.

## Evidence

Checked 2026-10-17 on the build host:

- `~/.ciel/gf180mcuD/SOURCES` reads `open_pdks f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7`.
- `~/.volare/gf180mcuD/SOURCES` reads `open_pdks c6d73a35f524070e85faff4a6a9eef49553ebc2b`.
- The `gf180mcu_fd_sc_mcu7t5v0` Liberty file list is identical under both
  trees (15 files; names in `soc.md`), as are the `nom_voltage` values read
  from `ss_125C_3v00.lib` (3.0) and `ff_n40C_3v60.lib` (3.6) under `~/.ciel`.

Not checked: whether Liberty *content* differs between the two revisions.
Anything quoted from a library is read from the `f6eeac7` tree and cites its
corner file name. A tool that finds both a `~/.volare` and a `~/.ciel` tree
must be told which; do not rely on search order (see `gf180-sram#173`).

## Consequence

Every flow record in this repo cites `gf180mcuD` and `f6eeac7…`. Any
`gf180-sram` result produced under `c6d73a3` is cited with its own revision
and is not silently re-labelled.
