#!/usr/bin/env python3
"""Build a patch against the recorded original Serpantinum checkout."""
import difflib
import json
from pathlib import Path
import sys

repo = Path(__file__).resolve().parent
original = Path(sys.argv[1]) if len(sys.argv) > 1 else repo / 'upstream'
prefix = '.local/share/serpantinum/'
manifest = json.loads((repo / 'managed.json').read_text())
chunks = []
for rel in manifest['home']:
    if not rel.startswith(prefix):
        continue
    vendor_path = rel[len(prefix):]
    before = original / vendor_path
    after = repo / 'home' / rel
    if not after.is_file():
        continue
    chunks.extend(difflib.unified_diff(
        before.read_text().splitlines(keepends=True) if before.exists() else [],
        after.read_text().splitlines(keepends=True),
        fromfile='a/' + vendor_path if before.exists() else '/dev/null',
        tofile='b/' + vendor_path))
(repo / 'serpantinum.patch').write_text(''.join(chunks))
print('Updated serpantinum.patch')
