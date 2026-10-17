#!/usr/bin/env python3
"""Snapshot the managed desktop files into this local Git repository."""
import json
from pathlib import Path
import shutil

repo = Path(__file__).resolve().parent
home = Path.home()
manifest = json.loads((repo / 'managed.json').read_text())
for scope, paths in manifest.items():
    for rel in paths:
        source = home / rel if scope == 'home' else Path(rel)
        if not source.exists():
            continue
        target = repo / scope / rel.lstrip('/')
        target.parent.mkdir(parents=True, exist_ok=True)
        if source.is_dir():
            if target.exists():
                shutil.rmtree(target)
            shutil.copytree(source, target)
        else:
            shutil.copy2(source, target)

settings = json.loads((home / '.config/serpantinum/settings.json').read_text())
saved = {key: settings[key] for key in ('bar', 'theme', 'idle', 'notifications') if key in settings}
saved['general'] = {key: settings.get('general', {})[key]
                    for key in ('language', 'muteSfx') if key in settings.get('general', {})}
(repo / 'settings.json').write_text(json.dumps(saved, ensure_ascii=False, indent=2) + '\n')
print('Desktop configuration captured in', repo)
