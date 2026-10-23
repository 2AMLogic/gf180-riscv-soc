# Environment pins

`scripts/setup-env.sh` is the single source of truth for the pins; this note
quotes it. `scripts/setup-env.sh --check` exits 1 when anything differs.

| Item | Pin | Source |
|------|-----|--------|
| PDK variant | `gf180mcuD` | `spec/pdk-pin-decision.md` |
| open_pdks revision | `f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7` | `spec/pdk-pin-decision.md` |
| Icarus Verilog | `13.0` | origin `sky130-riscv-soc` |
| cocotb | `2.0.1` | origin `sky130-riscv-soc` |

The PDK is read from `$PDK_ROOT/gf180mcuD/SOURCES` (default `PDK_ROOT=~/.ciel`).
The check refuses a tree whose `open_pdks` line differs, including the older
`c6d73a3` tree under `~/.volare`. The script only checks; it installs and
fetches nothing.

cocotb goes in a venv, not on the host:

    python3 -m venv .venv && .venv/bin/pip install cocotb==2.0.1
    . .venv/bin/activate && scripts/setup-env.sh --check
    make -C verification smoke

## CI

`.github/workflows/verification.yml` installs cocotb at the pinned version
(parsed from `scripts/setup-env.sh`) but Icarus Verilog from the distro
(`apt-get install iverilog`), which is **not** guaranteed to be `13.0`. CI does
not run `--check`; the pinned-version check is a local one. See
`spec/stamped-harness-decision.md`.
