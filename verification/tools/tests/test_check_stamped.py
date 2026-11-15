"""Fixture test for check_stamped.py: matching bytes pass, drift fails.

    python3 -I verification/tools/tests/test_check_stamped.py
"""
import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
SCRIPT = HERE.parent / "check_stamped.py"


def run(root):
    return subprocess.run([sys.executable, "-I", str(SCRIPT)],
                          cwd=root, capture_output=True, text=True)


def build_tree(root, contents):
    """Write each file with its bytes and pin its sha256 in reuse.lock.json."""
    stamped = []
    for rel, data in contents.items():
        path = root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        stamped.append({"path": rel,
                        "sha256": hashlib.sha256(data).hexdigest()})
    (root / "reuse.lock.json").write_text(json.dumps({"stamped": stamped}))


class CheckStamped(unittest.TestCase):
    def test_clean_tree_passes(self):
        with tempfile.TemporaryDirectory() as d:
            build_tree(Path(d), {"rtl/top.v": b"module top; endmodule\n"})
            r = run(d)
            self.assertEqual(r.returncode, 0)
            self.assertEqual(r.stdout, "")

    def test_single_byte_drift_fails(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            build_tree(root, {"rtl/top.v": b"module top; endmodule\n"})
            (root / "rtl/top.v").write_bytes(b"module top; endmodulE\n")
            r = run(d)
            self.assertEqual(r.returncode, 1)
            self.assertIn("MISMATCH", r.stdout)
            self.assertIn("rtl/top.v", r.stdout)

    def test_only_drifted_entry_is_named(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            build_tree(root, {"a/first.v": b"first\n",
                              "b/second.v": b"second\n"})
            (root / "b/second.v").write_bytes(b"second!\n")
            r = run(d)
            self.assertEqual(r.returncode, 1)
            self.assertIn("b/second.v", r.stdout)
            self.assertNotIn("a/first.v", r.stdout)

    def test_empty_stamped_list_passes(self):
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "reuse.lock.json").write_text(
                json.dumps({"stamped": []}))
            self.assertEqual(run(d).returncode, 0)

    def test_absent_stamped_file_fails(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            build_tree(root, {"rtl/top.v": b"module top; endmodule\n"})
            (root / "rtl/top.v").unlink()
            self.assertEqual(run(d).returncode, 1)

    def test_absent_lockfile_fails(self):
        with tempfile.TemporaryDirectory() as d:
            self.assertEqual(run(d).returncode, 1)


if __name__ == "__main__":
    unittest.main()
