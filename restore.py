#!/usr/bin/env python3
"""Restore desktop settings with backups and preflight the Serpantinum patch."""
import argparse
from datetime import datetime
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

repo = Path(__file__).resolve().parent
home = Path.home()
prefix = '.local/share/serpantinum/'
manifest = json.loads((repo / 'managed.json').read_text())
args = argparse.ArgumentParser()
args.add_argument('--settings', action='store_true', help='also restore saved appearance and idle preferences')
options = args.parse_args()
runtime = home / prefix
if not (runtime / 'src/quickshell/Shell.qml').is_file():
    raise SystemExit('Install Serpantinum first; its assets are not stored in this repository.')


def merge(old, new):
    for key, value in new.items():
        if isinstance(value, dict) and isinstance(old.get(key), dict):
            merge(old[key], value)
        else:
            old[key] = value


with tempfile.TemporaryDirectory(prefix='serpantinum-restore-') as staging:
    staging = Path(staging)
    vendor_files = [rel for rel in manifest['home'] if rel.startswith(prefix)]
    for rel in vendor_files:
        source = home / rel
        if source.is_file():
            target = staging / rel[len(prefix):]
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
    command = ['patch', '--batch', '--forward', '-p1', '-i', str(repo / 'serpantinum.patch')]
    check = subprocess.run(command + ['--dry-run'], cwd=staging, capture_output=True, text=True)
    apply_patch = check.returncode == 0
    if not apply_patch:
        reverse = subprocess.run(['patch', '--batch', '--reverse', '--dry-run', '-p1', '-i', str(repo / 'serpantinum.patch')],
                                 cwd=staging, capture_output=True, text=True)
        if reverse.returncode:
            raise SystemExit('The new Serpantinum version conflicts with the saved patch. No files changed.\n' + check.stdout + check.stderr)
    if apply_patch:
        subprocess.run(command, cwd=staging, check=True)

    backup = home / '.local/state/desktop-config' / datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    backup.mkdir(parents=True)
    for rel in manifest['home']:
        source = home / rel
        if not source.exists():
            continue
        saved = backup / rel
        saved.parent.mkdir(parents=True, exist_ok=True)
        if source.is_dir():
            shutil.copytree(source, saved)
        else:
            shutil.copy2(source, saved)
    settings_path = home / '.config/serpantinum/settings.json'
    if settings_path.exists():
        shutil.copy2(settings_path, backup / 'settings.json')

    for rel in manifest['home']:
        if rel.startswith(prefix):
            if not apply_patch:
                continue
            source = staging / rel[len(prefix):]
        else:
            source = repo / 'home' / rel
        if not source.exists():
            continue
        target = home / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        if source.is_dir():
            shutil.copytree(source, target, dirs_exist_ok=True)
        else:
            shutil.copy2(source, target)
    if options.settings:
        current = json.loads(settings_path.read_text()) if settings_path.exists() else {}
        merge(current, json.loads((repo / 'settings.json').read_text()))
        settings_path.parent.mkdir(parents=True, exist_ok=True)
        settings_path.write_text(json.dumps(current, ensure_ascii=False, indent=2) + '\n')
print('Desktop files restored. Backup:', backup)
print('Reload the shell with: ~/.local/bin/serpantinum reload')
