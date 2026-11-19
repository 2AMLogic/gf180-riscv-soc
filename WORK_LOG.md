# Work Log

Chronological record of merged PRs and closed issues, maintained by the Guide
triage role. Newest first.

### 2026-11-19

- **PR #115**: test(synth): cover klt error JSON written only to stderr
- **PR #113**: test(synth): cover regen.sh klt failure branches with a stub-klt harness
- **Issue #114** (closed): test(synth): regen.sh's klt error-JSON-on-stderr placement is uncovered
- **Issue #111** (closed): No automated test exercises synth/regen.sh's klt failure branches
- **PR #110**: feat(synth): name the reproducibility-gate break when klt rejects the interim macro declaration
- **Issue #54** (closed): synth/regen.sh --check cannot run on any installable klt: the interim macro declaration is rejected at request validation

### 2026-11-18

- **PR #108**: ci: add merge_group trigger to signoff and verification workflows
- **Issue #107** (closed): Merge queue: add the merge_group trigger to the required-check workflow(s)
- **PR #105**: ci: single-source the verification gate in scripts/check.sh
- **Issue #103** (closed): Single-source the verification gate: verification.yml calls scripts/check.sh

### 2026-11-17

- **PR #100**: chore(loom): resync installed Loom to v0.19.1306

### 2026-11-16

- **PR #96**: chore(loom): resync installed Loom to v0.19.1302

### 2026-11-15

- **PR #94**: fix: add lint-rtl-tests entry to item-10 inventory and correct its mirror claim
- **PR #91**: test: verify check_stamped.py detects stamped-file drift
- **PR #84**: test: assert lint_rtl.sh fails on an empty RTL tree
- **Issue #93** (closed): item-10 inventory does not mirror verification.yml: test_lint_rtl.py has no check entry
- **Issue #88** (closed): No committed test for check_stamped.py's drift detection
- **Issue #79** (closed): No committed regression test for lint_rtl.sh's empty-tree failure
- **PR #90**: docs: supersede the stale LINT_REQUIRE_CORE spec claim; name PIN_SV2V in setup-env.sh header
- **PR #86**: docs: refresh ROADMAP anchor, empty Now, and stale tracker enumerations
- **PR #76**: ci: lint soc_top.sv on every run — fetch the CVE2 core in CI and drop the LINT_REQUIRE_CORE skip
- **Issue #87** (closed): Two statements go stale when #76 lands: the spec record's LINT_REQUIRE_CORE line and setup-env.sh's "CI parses PIN_COCOTB" header
- **Issue #77** (closed): Refresh docs/ROADMAP.md: four merges landed after its deac81b anchor, one inverting Now item 2
- **Issue #65** (closed): RTL lint never checks rtl/common/soc_top.sv: nothing sets LINT_REQUIRE_CORE and its skip is the only arm CI takes
- **PR #85**: docs: warn readers that WORK_PLAN priority sections ignore hold labels
- **PR #82**: docs: record the dropped origin RISC-V GCC pin and narrow the pins source-of-truth claim
- **PR #75**: docs: append Superseded note to rtl-stamping-decision Divergence section
- **Issue #80** (closed): WORK_PLAN's priority sections present loom:blocked / loom:operator issues as the work to take first
- **Issue #70** (closed): scripts/setup-env.sh declares no PIN_RISCV_GCC, but stamped firmware/boot/build.sh delegates its toolchain pin to it
- **Issue #55** (closed): Append a superseded-by note to spec/rtl-stamping-decision.md's Divergence section
- **PR #81**: docs: correct regen.sh line citations in klt-0.9.1 probe record
- **PR #73**: fix: fail RTL lint on an empty RTL tree instead of reporting ok
- **PR #69**: docs: state stamped RTL and interim netlist in the README status
- **PR #57**: docs: roadmap as of 2026-11-13
- **Issue #68** (closed): Correct three citations in synth/probes/klt-0.9.1.md: two wrong regen.sh line ranges, an addition #54 already records, and an unscoped "sv2v never invoked"
- **Issue #61** (closed): Make the RTL lint fail on an empty RTL tree instead of reporting ok: the no-op guard predates the RTL
- **Issue #58** (closed): Bring the README status in line with the tree and the signoff record

### 2026-11-14

- **PR #74**: Remove dead analog sim/ and flow/ ignore rules from .gitignore
- **PR #72**: synth: generate boot ROM constants into the untracked build tree
- **PR #67**: docs(synth): record klt 0.9.1 rejecting the interim macro declaration
- **PR #66**: docs: index the two stamping records and list verification's contents
- **PR #64**: feat: check sv2v's version in setup-env.sh --check
- **PR #56**: refactor(synth): inline the single-call run() helper in regen.sh
- **PR #52**: chore: lint soc_fabric/soc_top unconditionally, drop LINT_REQUIRE_SRAM
- **Issue #71** (closed): Drop the analog sim/ and flow/ ignore rules from .gitignore: neither tree has ever existed in this digital repo
- **Issue #63** (closed): Stop tracking the generated synth/boot_rom_const.v: regen.sh rewrites it before every run, including --check
- **Issue #62** (closed): Check PIN_SV2V in setup-env.sh --check, or stop claiming all pins match
- **Issue #60** (closed): Probe: record what klt 0.9.1 does with the interim synthesis request
- **Issue #59** (closed): Complete the spec index and retire the "empty" verification README text
- **Issue #53** (closed): Inline the single-call run() helper in synth/regen.sh: leftover scaffolding from the removed second probe
- **Issue #51** (closed): Remove the pre-part-c LINT_REQUIRE_SRAM skip from lint_rtl.sh: the guard is now unreachable

### 2026-11-12

- **PR #49**: Bump Repo Skills 0.25.10 -> 0.26.1

### 2026-11-07

- **PR #48**: Bump Repo Skills 0.25.1 -> 0.25.10

### 2026-11-01

- **PR #47**: Bump Repo Skills 0.24.7 -> 0.25.1

### 2026-10-29

- **PR #46**: chore: remove the wrapper-only soc_sram_d synth probe
- **Issue #45** (closed): Remove wrapper-only soc_sram_d synth probe: superseded by soc_top netlist

### 2026-10-28

- **PR #44**: feat: add gf180 SRAM wrappers and a reproducible gate-level netlist

### 2026-10-27

- **PR #42**: refactor: share one stamped-hash check script across gate, CI and inventory
- **PR #41**: feat: stamp origin integration RTL, boot firmware and CVE2 scripts
- **PR #39**: docs(spec): decide region sizes and single-port instruction SRAM (rows 8, 8a)
- **PR #36**: feat(signoff): attest T1 item 10 repo hygiene
- **Issue #40** (closed): Dedupe stamped-file hash check into one script
- **Issue #33** (closed): T1 item 1 (b/4): re-pin sky130-riscv-soc and stamp the integration RTL, firmware boot and CVE2 imports
- **Issue #32** (closed): T1 item 1 (a/4): decision records for rows 8 and 8a, and the origin fix issue
- **Issue #21** (closed): T1 item 10 (repo hygiene): repo-hygiene inventory and klt signoff --attest 10 envelope
- **PR #31**: feat(signoff): record T1 item 6 as not applicable for the digital block
- **Issue #28** (closed): T1 item 6 (statistical rows): hash-bound not-applicable statement for the ratified spec

### 2026-10-23

- **PR #18**: fix: run the real verification checks from the package.json gate scripts
- **Issue #16** (closed): Replace package.json placeholder check scripts with the real verification checks
- **PR #15**: docs(spec): fill Part A from ratified origin spec and re-pin origin
- **PR #14**: feat: stamp cocotb harness and record linter, add gf180 env check and CI
- **Issue #11** (closed): Fill spec Part A from the now-ratified sky130-riscv-soc spec and re-pin the origin
- **Issue #12** (closed): Adopt sky130-riscv-soc's cocotb harness and record linter by stamped reference (T1 item 9)

### 2026-10-21

- **PR #9**: Bump Repo Skills 0.24.3 -> 0.24.7

### 2026-10-20

- **PR #7**: ci: add klt signoff gate and block manifest verdict of record
- **Issue #5** (closed): T1 item 10: add CI and a klt signoff block manifest as the verdict of record

### 2026-10-17

- **PR #6**: docs(spec): ratify SoC target spec and cell-library, supply and SRAM decisions
- **PR #2**: chore(loom): commit the Loom merge-driver .gitattributes
- **PR #1**: chore(loom): Install Loom 0.19.1180
- **Issue #3** (closed): Draft and ratify the target spec
