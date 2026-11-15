# Work Log

Chronological record of merged PRs and closed issues, maintained by the Guide
triage role. Newest first.

### 2026-11-15

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
