# Probe: `klt` 0.9.1 on the committed interim synthesis request

**Dated measurement record. It decides nothing and ratifies nothing** — it
records what one tool version did with the request already committed at
`synth/soc_top.request.json`. The interim macro declaration it exercises is
ratified in `spec/macro-views-interim-decision.md`; how the reproducibility
gate is restored is an open operator decision on #54, not a question this
record answers.

- **Run date**: 2026-11-14
- **Repo state**: `main` @ `0c327b1` (probed from `feature/issue-60`, which adds
  only this record and one README line)
- **Verdict**: **(a) rejected at macro validation.** Synthesis never started.
- **Agrees with #54?** **Yes** — byte-identical message, same exit status. See
  [Corroboration](#corroboration).

## Command

Run from the repository root:

```
uvx --from "klayout-tools==0.9.1" klt synthesize --pdk gf180mcuD synth/soc_top.request.json --format json
```

`--pdk gf180mcuD` is the default `synth/regen.sh:26` uses
(`spec/pdk-pin-decision.md`). The request was used **unchanged**
(`git diff --exit-code synth/soc_top.request.json` was clean immediately before
the run), and the `cve2_clock_gate` is the unmodified upstream core's — see
[Sources](#sources).

## Environment

Captured from the same shell as the run.

| Tool | Version | Notes |
|---|---|---|
| `klt` **used by this run** | `0.9.1` | isolated, via `uvx --from "klayout-tools==0.9.1"`; newest published release |
| `klt` on this host's `PATH` | `0.9.2.dev1025+ga90545db9ea6` | **not used** — a bare `klt` here probes a newer unpublished build |
| `yosys` | `Yosys 0.67+post (git sha1 b8e7da6f40ae8f552c116bf6c359b07c6533e159, Release, GNU /usr/bin/c++ 13.3.0)` | `/home/ubuntu/.local/bin/yosys`; on `PATH`, **never invoked** (see below) |
| `sv2v` | `sv2v v0.0.13` | `/home/ubuntu/.local/bin/sv2v`; the pin named in `synth/regen.sh`'s header; on `PATH`, **never invoked** |
| `uvx` | `uvx 0.13.5 (x86_64-unknown-linux-gnu)` | |
| host | `Linux 7.0.0-1014-aws x86_64` | fleet worker |

`yosys` and `sv2v` versions are recorded because they were on `PATH` and are
what the run *would* have used, but this run never reached them: `klt` rejected
the request during validation, before invoking either. Evidence — no
`synth/.klt/` directory, no `synth/.klt-*.json`, and no Yosys log was produced.

## Result

**Exit status: `1`.** `stdout` was empty; `stderr` was, verbatim:

```json
{
  "schema_version": 1,
  "error": {
    "command": "synthesize",
    "message": "request.macros[0].verilog_blackbox declares module(s) ['sram_256x32'] but the macro cell is 'sram_256x32_array' (from its lef); rename the blackbox module to 'sram_256x32_array' so the design's instances resolve to this macro"
  }
}
```

This is the ratified interim declaration being rejected on its own terms: the
request supplies the 322-pin array-core LEF (`MACRO sram_256x32_array`, fetched
at the pinned `gf180-sram` commit and hash-checked) solely to satisfy the
required `macros[].lef` field, while the macro's pins come from
`rtl/sram_256x32_blackbox.v`, which declares `sram_256x32`. The two names differ
deliberately (`spec/macro-views-interim-decision.md`); 0.9.1 treats that
difference as an error.

### Outcomes (b) and (c) are unreachable, not unmeasured

The three outcomes this probe was to choose between were (a) rejected at macro
validation, (b) completes with the latch mapped to a library cell, (c) completes
with a non-library cell remaining. Because 0.9.1 rejects at validation,
**`instance_counts_by_type` and the latch count cannot be obtained from 0.9.1 at
all** — not "left blank": there is no response object to read them from. The
same holds for `macro_instance_count`.

**Consequence for #43.** `klayout-tools#4458` (inferred latches never mapped)
was closed 2026-10-28, so 0.9.1 may well map the `cve2_clock_gate` latch — but
this probe cannot tell, and no probe can tell on *this* request, because macro
validation runs before synthesis. Whether 0.9.1 maps the latch stays
**unanswered** until either the macro declaration is accepted
(`klayout-tools#5612`) or the request changes (#54's pending decision). The
latch question is not resolved by this record in either direction.

### Validation order (previously untraced)

An earlier run of the same command, with `build/` absent, failed differently:

```json
{
  "schema_version": 1,
  "error": {
    "command": "synthesize",
    "message": "RTL source not found: ../build/cve2/cve2_top.v"
  }
}
```

also exit `1`. So 0.9.1 checks **RTL source existence first, macro-name
validation second, and synthesis last**. The CVE2 fetch and `sv2v` conversion
are therefore required to reach the macro rejection — the macro declaration is
*not* rejected before sources are read.

## Sources

`build/` is gitignored and absent on a fresh checkout, so it was populated
exactly as `synth/regen.sh` does (lines 27-36) before the definitive run:

- `build/macro/sram_256x32_array.lef` — fetched from
  `2AMLogic/gf180-sram` @ `d0bacc0fceb6e9400e54e3efe15ec1630711faa9`,
  sha256 `3cda2519cab4033a7009d5cd665c92035c9e9f2625a6db8222907e352e84b446`,
  matching the pin in `synth/regen.sh:24`. Its first `MACRO` statement is
  `MACRO sram_256x32_array`.
- `build/cve2/` — `scripts/fetch-cve2.sh` (32 files @
  `d7f21568028a1114be663599bd42145dccf28928`, every sha256 verified against
  `reuse.lock.json`) then `scripts/convert-cve2.sh`. The clock gate is
  unmodified: `build/cve2/upstream/rtl/cve2_clock_gate.sv` is sha256
  `10c5666623b9e1eb0be9d3566c7eab1f4fec37a40e1aff1ec396474d8232705e`, equal to
  the `reuse.lock.json` entry for `rtl/cve2_clock_gate.sv`.

## Corroboration

#54 measured `klt` 0.9.1 on this same committed request at `main` @ `2674291`
and recorded the same rejection. **This run agrees with it**: same verbatim
message, same exit status `1`. Nothing under `synth/`, `rtl/`,
`.github/klt-version` or `reuse.lock.json` changed between `2674291` and
`0c327b1`, and 0.9.1 is still the newest published release, so the two
measurements describe the same thing from two environments.

What this record adds over #54's table is the complete environment — the exact
command, all three tool versions from the run's own shell, the exit status, the
source provenance hashes, and the validation ordering above — so a later reader
can re-run it rather than trust a comment.

## Tool gap

The open gap this rejection belongs to is
**`2AMLogic/klayout-tools#5612`** — *"synthesize: no way to declare a macro by
blackbox alone, so a design whose macro has no LEF yet cannot be synthesized at
all"* (open, filed 2026-11-14). No new upstream issue was filed for this probe:
#5612 already describes the gap generically, and this run showed nothing it does
not cover.

For the record's completeness, the rejection itself is intended behaviour, not a
defect: `klayout-tools#4459` — this repo's own friction report that
`macro_instance_count` read 0 when the blackbox module name differs from the LEF
`MACRO` name — was **closed 2026-10-28 by introducing this rejection**, i.e. the
report was resolved in the way that makes this request invalid.
`klayout-tools#4458` (latches never mapped) was also closed 2026-10-28.

## What was deliberately not attempted

- **The reproducibility gate.** `synth/regen.sh --check` was **not run** and
  this record makes **no claim that it passes**. Per #54's measured table it
  fails on every published `klt` — including the pinned `0.8.0`, which predates
  the request schema and reports `unknown fields 'macros', 'sv_frontend'`. That
  row is cited from #54 and was not re-run here. Byte-for-byte reproducibility
  of `synth/soc_top_synth.v` is currently undemonstrable; how to restore the
  gate is #54's open operator decision.
- **No timing, area or power figure** was produced, called measured, or treated
  as a signoff number — the run produced no response object at all. Even on
  success `klt synthesize` reports `sta: null` for this design
  (`synth/README.md`), and the mapping corner `ss_125C_3v00` is not a signoff
  corner.
- **No change to the pin, the request, the netlist, or the black box.**
  `.github/klt-version` stays `0.8.0`; renaming the blackbox or editing the
  request to get past validation would pre-empt #54's decision.

## Re-running this

From a worktree (the main checkout refuses writes into `build/`):

```sh
scripts/fetch-cve2.sh && scripts/convert-cve2.sh
# build/macro/sram_256x32_array.lef: fetch + hash-check per synth/regen.sh:20-34
uvx --from "klayout-tools==0.9.1" klt synthesize --pdk gf180mcuD \
    synth/soc_top.request.json --format json; echo "exit=$?"
```

Expect exit `1` and the macro-name message above. `build/` is gitignored; the
run leaves no scratch in `synth/` (note that `synth/.gitignore` covers `.klt/`
only, so an aborted `regen.sh` — not this command — would leave an untracked
`synth/.klt-*.json`).
