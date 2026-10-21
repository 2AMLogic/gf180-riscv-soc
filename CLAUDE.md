# gf180-riscv-soc — agent instructions

Open-source canary block: a small RISC-V microcontroller SoC on the gf180mcu
PDK, designed and verified by AI agents. **Digital**, and a **port** of
`sky130-riscv-soc`.

- **PDK**: gf180mcu (open PDK, google/gf180mcu-pdk); pin the same variant and
  `open_pdks` revision as `gf180-sram` unless a decision record says
  otherwise. Digital flow: cocotb + Icarus for simulation, Yosys for
  synthesis, OpenROAD for place-and-route and timing. Layout, DRC, and LVS
  through klayout-tools (`klt`).
- **The PDK is the variable, not the SoC.** The integration RTL, memory map,
  firmware and testbenches are mastered in `sky130-riscv-soc` (lineage makes
  it master) and arrive as stamped copies, pinned in `reuse.lock.json`. Do
  not edit a stamped file locally; fix it at the origin, or record the
  divergence in a decision record. If something breaks here, suspect the PDK,
  the cell library or the macro before the RTL.
- **The cell-library and supply choice is the central risk.** The gf180mcu
  standard cells are 5 V-rated devices used at more than one supply. Which
  library, which supply for the core, whether it matches `gf180-sram`'s
  single 3.3 V supply, and where level shifting is needed are decided once in
  `spec/` and then held. A timing number means nothing without the library
  corner it came from.
- **Scope discipline.** The SRAM comes from `gf180-sram`
  (`consumes:`) — a 256 x 32 single-port macro with the interface ratified in
  its `spec/sram.md`. Specify how this SoC uses that interface and stop: do
  not design a bitcell, a local SRAM, or a local timing model of the macro.
  If the macro lacks a view this SoC needs (for example a Liberty timing
  view), raise it on `gf180-sram`; any interim stand-in is a decision record
  and is labelled as such everywhere it is used. The core is used unmodified;
  no PLL and no pad ring here.
- **Fmax honesty.** A frequency from STA is a *signoff Fmax*, stated with its
  corner and layout state. Nothing here is *measured* until silicon is on a
  bench. Never call a simulated or STA figure measured.
- **Friction protocol (the canary's job)**: every time klayout-tools is
  awkward, missing a capability, or wrong for what you need, file an issue at
  `2AMLogic/klayout-tools` describing the tool gap generically — that tracker
  is scoped to the tool, so keep design-specific detail out of it and describe
  the gap, not the design.
- **Verification is the product**: no claim without a testbench. The origin's
  architectural and firmware tests must pass on this repo's netlist before
  any claim; timing claims come from STA reports at stated corners. Recorded
  results are append-only evidence.
- Spec changes go through `spec/` with a decision record; agents do not relax
  the ratified spec to make results pass.
- **25 MHz post-route at the slow corner is the target.** 12.5 MHz is the
  fallback and 50 MHz is a stretch.

<!-- BEGIN LOOM ORCHESTRATION -->
This repository uses [Loom](https://github.com/rjwalters/loom) for AI-powered development orchestration — see the Loom repository for the full guide (roles, labels, worktrees, configuration). When installed, Loom also writes a locally-substituted copy of that guide to `.loom/CLAUDE.md`.

Work is coordinated through `loom:` labels on issues and pull requests, and the same roles run either under `loom-daemon` or by hand in an attended session — daemon mode is optional. Create the labels once with `.loom/scripts/sync-labels.sh` (an install ships `.github/labels.yml` but does not create the labels on the forge). A pull request ready for review carries `loom:review-requested`; Judge reviews it and applies `loom:pr` (approved) or `loom:changes-requested`; Doctor fixes a `loom:changes-requested` pull request and returns it to `loom:review-requested`. Only a `loom:pr` pull request gets merged, and always via this repo's merge script (`.loom/scripts/merge-pr.sh`) — never a raw forge merge command such as `gh pr merge`. Full state machine: `.loom/docs/label-state-machine.md`.
<!-- END LOOM ORCHESTRATION -->

<!-- BEGIN REPO-SKILLS -->
This repository has [Repo Skills](https://github.com/rjwalters/repo) v0.24.7 installed —
general repository hygiene and environment commands invoked as `/repo:<command>`. Run
`/repo:help` for the command list, or see `.claude/skills/repo/SKILL.md` for the full
guide. Hygiene commands apply safe, reversible fixes by default and report each
change; run with `--ask` to review first, and `--prune` to allow irreversible
removals. Managed by `install.sh` — edit outside the markers only.
<!-- END REPO-SKILLS -->
