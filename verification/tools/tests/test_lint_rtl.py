"""Regression test for lint_rtl.sh's empty-tree guard: an RTL set with zero
.v/.sv files must fail, never pass green over nothing.

    python3 -I verification/tools/tests/test_lint_rtl.py

Each case copies lint_rtl.sh into a TemporaryDirectory and runs the copy
there: the script cd's to $(dirname $0)/../.., so the copy anchors the probe
and the real checkout is never read or written by the run. Needs no
Verilator: the empty-tree guard fires before the verilator check, and the
positive control asserts on the message, not the exit code.
"""
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
LINT_RTL = HERE.parent / "lint_rtl.sh"
EMPTY_MSG = "FAIL (no .v/.sv files under rtl/)"


class LintRtlEmptyTree(unittest.TestCase):
    def run_in(self, root):
        tools = Path(root) / "verification" / "tools"
        tools.mkdir(parents=True)
        script = tools / "lint_rtl.sh"
        shutil.copy2(LINT_RTL, script)  # copy2 keeps the exec bit
        return subprocess.run([str(script)], capture_output=True, text=True)

    def test_no_rtl_dir_fails(self):
        # the absent-directory find warning precedes the FAIL line on stderr,
        # so assert a substring, never stderr equality
        with tempfile.TemporaryDirectory() as d:
            r = self.run_in(d)
            self.assertEqual(r.returncode, 1)
            self.assertIn(EMPTY_MSG, r.stderr)

    def test_empty_rtl_dir_fails(self):
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "rtl").mkdir()
            r = self.run_in(d)
            self.assertEqual(r.returncode, 1)
            self.assertIn(EMPTY_MSG, r.stderr)

    def test_rtl_without_verilog_sources_fails(self):
        # exercises the find filter, not just an absent directory
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "rtl").mkdir()
            (Path(d) / "rtl" / "README.md").write_text("not a source\n")
            r = self.run_in(d)
            self.assertEqual(r.returncode, 1)
            self.assertIn(EMPTY_MSG, r.stderr)

    def test_rtl_with_source_does_not_report_empty(self):
        # positive control: with a .v present the empty-tree message is gone.
        # the exit code is NOT asserted — with verilator on PATH the lint
        # result decides it, without it the script exits 1 on the missing
        # verilator check; both are fine here.
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "rtl").mkdir()
            (Path(d) / "rtl" / "dummy.v").write_text("module dummy; endmodule\n")
            r = self.run_in(d)
            self.assertNotIn(EMPTY_MSG, r.stderr)


if __name__ == "__main__":
    unittest.main()
