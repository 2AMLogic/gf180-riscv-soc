"""Check that every stamped file still matches its sha256 in reuse.lock.json.

Run from the repo root: python3 -I verification/tools/check_stamped.py
"""
import hashlib, json, sys

bad = 0
for e in json.load(open("reuse.lock.json"))["stamped"]:
    got = hashlib.sha256(open(e["path"], "rb").read()).hexdigest()
    if got != e["sha256"]:
        print("MISMATCH", e["path"]); bad = 1
sys.exit(bad)
