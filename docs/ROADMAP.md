# Roadmap

`gf180-riscv-soc` ports the `sky130-riscv-soc` microcontroller SoC to the
gf180mcu open PDK and earns its T1 evidence with `klt`; this file says where
that stands and what comes next.

**Status as of 2026-11-14, `main` @ `0c327b1`.** Where this file and the
verdict of record (`manifests/gf180-riscv-soc.signoff.json`) disagree, the
record wins.

## Where it stands

Position on the README's ladder: **spec ratified; integration RTL stamped and
synthesized to an interim gate-level netlist; nothing placed, routed or timed.**

T1 checklist, as graded by the committed record (1 met, 1 not applicable,
9 unmet, tier `null`), tracked in #4:

| Item | Record | Evidence today | Issue |
|---|---|---|---|
| 1 Design sources | unmet | parts a-c merged (#39, #41, #44); netlist in `synth/` is interim | #20, #34, #35, #43 |
| 2 Layout | unmet | `layout/` holds only a README | #23 |
| 3 DRC clean | unmet | none | #24 |
| 4 LVS clean | unmet | none | #25 |
| 5 Corner verification | unmet | corner set ratified in `spec/soc.md`; no STA report | #27 |
| 6 Statistical rows | not applicable | `spec/soc.item6-na-statement.json` (#31) | closed #28 |
| 7 Post-layout verification | unmet | none | #29 |
| 8 Characterization | unmet | none | #30 |
| 9 Testbenches shipped | unmet | stamped cocotb harness, smoke test only | #22 |
| 10 Repo hygiene | met | `manifests/item10.attest.json` (#36) | closed #21 |
| 11 Power delivery | unmet | none | #26 |

Done and in the tree:

- Ratified spec `spec/soc.md` with decision records for the PDK pin, cell
  library, supply plan, SRAM instance plan, rows 8 and 8a, RTL stamping and
  the stamped harness (#6, #15, #39).
- 22 stamped copies from the origin, pinned and hash-checked through
  `reuse.lock.json`, taken at two origin commits: 13 at `700b745` (integration
  RTL under `rtl/common/`, boot firmware, the CVE2 fetch/convert scripts) and 9
  at `0bd1c15` (the cocotb harness and the record linter, stamped via #14). The
  `ported_from` edge pin is `700b745` (#14, #41, #42).
- Local SRAM wrappers and a hand-written macro black box, marked INTERIM (#44).
- `synth/soc_top_synth.v`, an interim gate-level netlist (#44, #46). It is in
  the tree, but it is **not demonstrably reproducible**: its gate,
  `synth/regen.sh --check`, cannot run on any installable `klt` (#54 — see
  "Blocked and waiting"). `synth/README.md` states its two limits: one unmapped
  `$_DLATCH_N_` from the core's clock gate, and a macro declared through the
  array-core LEF only to satisfy a required field.
- The pre-part-c lint skip is gone: `verification/tools/lint_rtl.sh` lints
  `soc_fabric.sv` and `soc_top.sv` unconditionally, and `LINT_REQUIRE_SRAM` is
  absent from both the script and `verification.yml` (#51, merged as #52).
- CI: `verification.yml` and `signoff.yml`; `klt` pinned at `0.8.0`.

## Now

Can start today; none depends on the macro views.

1. **Bring the README status in line with the record.** It still says
   "Nothing is designed yet" and that every T1 item is `unmet`. Done when the
   status line, T1 paragraph and repo layout match the tree, and `manifests/item10.attest.json` plus the verdict of record are
   regenerated in the same PR so `signoff.yml` passes. #58.
2. **Complete the documentation indexes.** Done when `spec/README.md` lists
   `rtl-stamping-decision.md` and `stamped-harness-decision.md`, and
   `verification/README.md` no longer says "Empty until the first work lands
   here". #59.
3. **Record what the current `klt` release does with the interim synthesis
   request.** The clock-gate work (#43) was last tried on `klt` 0.9.0, which
   rejected the macro declaration because the black-box module name
   (`sram_256x32`) and the LEF `MACRO` name (`sram_256x32_array`) differ. This
   is a **known rejection, not an open question**: per #54 every `0.9.0+`
   release enforces that match and nothing is published in between, so the probe
   confirms and pins the exact rejection on `0.9.1` rather than testing an
   unknown. The capability that would lift it is
   [`klayout-tools#5612`](https://github.com/2AMLogic/klayout-tools/issues/5612).
   Done when a committed probe record under `synth/` gives the command, the
   `klt` version, the exit status and the validation message or cell-type
   counts, with the pin and the committed netlist unchanged. #60; feeds #43.

## Next

Each is unblocked by the named item.

- **Map the clock-gate latch with `klt`, core unmodified** (#43; ruling recorded
  there: no ICG stand-in, no tie-open). Done when `synth/soc_top_synth.v` holds
  only `gf180mcu_fd_sc_mcu7t5v0` cells plus the macro, `.github/klt-version` is
  bumped, and `spec/clock-gate-decision.md` exists. Needs
  [`gf180-sram#199`](https://github.com/2AMLogic/gf180-sram/issues/199) (LEF of
  the 1RW macro interface), or a decision on an interim macro view.
- **Close part c and attest item 1** (#34, #35): design-source inventory
  committed, `klt signoff --attest 1` passes, item 1 reads `met`. Follows #43;
  closes #20.
- **Item 9, testbenches shipped** (#22): the origin's architectural and
  firmware suites run from a fresh clone, inventory committed,
  `klt signoff --attest 9` passes. Follows #20.
- **Item 2, place and route** (#23): a committed `klt place-and-route` flow
  reproduces the routed GDS with 8 macros and `power.pdn: true`. Follows #20
  and needs the macro-level LEF pinned in `reuse.lock.json`.

## Later

- **DRC, LVS, power delivery** (#24, #25, #26). Question first: does the routed
  layout from #23 exist, and what deck coverage does `klt drc` disclose for
  this PDK variant?
- **Five-corner STA at 25 MHz** (#27). Question first: is a macro Liberty view
  available at a pinned `gf180-sram` commit
  ([`gf180-sram#200`](https://github.com/2AMLogic/gf180-sram/issues/200))?
  Until then any figure is "logic only, macro paths unconstrained" and not a
  signoff Fmax (`spec/macro-views-interim-decision.md`).
- **Post-layout verification and characterization** (#29, #30). Question first:
  do the item 9 suites pass on the post-route netlist with SDF?

## Blocked and waiting

- **Macro views from `gf180-sram`.** Every design issue here traces to #43, and
  #43 is parked on `gf180-sram#199`, itself open under
  [`gf180-sram#197`](https://github.com/2AMLogic/gf180-sram/issues/197). The
  Liberty view (`gf180-sram#200`) gates signoff STA. The pin in
  `reuse.lock.json` is still `d0bacc0`, which has neither view.
- **A decision on an interim macro view.** `CLAUDE.md` allows a labelled
  stand-in for a missing view only through a decision record; whether to take
  one for synthesis and floorplanning rather than wait is undecided (#43).
- **The reproducibility gate is red.** `synth/regen.sh --check` fails before
  synthesis on every installable `klt`: request validation rejects the interim
  macro declaration that `spec/macro-views-interim-decision.md` ratified,
  because the black-box module name (`sram_256x32`) and the LEF `MACRO` name
  (`sram_256x32_array`) differ. The pin in `.github/klt-version`, `0.8.0`,
  predates that schema; `0.9.0+` all enforce the match; nothing is published in
  between. No workflow runs the check either — `regen.sh` appears nowhere under
  `.github/` — so the green `verification` and `klt signoff` runs are not
  evidence for it. Byte-for-byte reproducibility of `synth/soc_top_synth.v` is
  **currently undemonstrable**; how to restore the gate is an open operator
  decision in #54.
- **Tool gaps: two closed upstream, one open and live.** `klayout-tools#4458`
  and `#4459` are closed, and `synth/README.md` still calls both open — it is
  corrected as part of #43. But `#4459` was closed by *rejecting* the
  blackbox-name-vs-LEF-`MACRO`-name shape this repo ratified, which is what
  turned the gate above red and opened a new gap:
  [`klayout-tools#5612`](https://github.com/2AMLogic/klayout-tools/issues/5612)
  — no way to declare a macro by blackbox alone, so a design whose macro has no
  LEF yet cannot be synthesized at all. That one is open, and the gate waits on
  it.
- **Housekeeping.** PR #38 (generated `WORK_PLAN.md`/`WORK_LOG.md` update) is
  open and awaiting re-review (`loom:review-requested`); its merge conflict has
  since been resolved and it is mergeable again, so both files lag the tracker
  only until it lands.

What is blocked is the **design chain**: #43 and the T1 items behind it (#20,
#22-#27, #29, #30, #34, #35) all wait on the macro views. The rest of the
tracker is dispatchable today — small, PDK-independent repo and tooling work:
the three Now items (#58, #59, #60), the `regen.sh`, lint and env follow-ups
(#53, #61, #62, #63, #65), the decision-record note #55, and the T1 tracking
issue #4. Two open items are nobody's to dispatch: #54 needs an operator
ruling, and #50 is a Champion digest.

## Not planned

- A local SRAM, bitcell, or behavioural or timing model of the macro
  (`CLAUDE.md`; the macro belongs to `gf180-sram`).
- Edits to stamped files; fixes go to `sky130-riscv-soc` or into a decision
  record.
- A PLL, a pad ring, or level shifters inside the block.
- Relaxing a ratified row to make a result pass, or calling any simulated or
  STA figure "measured".
