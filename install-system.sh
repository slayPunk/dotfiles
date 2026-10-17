#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$EUID" != 0 ]]; then
    echo 'Run this script with sudo after building the driver.' >&2
    exit 1
fi
if [[ ! -f "$repo_dir/.build/src/facer.ko" ]]; then
    echo 'First run: bash ~/desktop-config/build-driver.sh' >&2
    exit 1
fi
module_version="$(modinfo -F vermagic "$repo_dir/.build/src/facer.ko")"
if [[ "$module_version" != "$(uname -r) "* ]]; then
    echo 'The saved module was built for a different kernel; rebuild it first.' >&2
    exit 1
fi
backup_dir="/var/backups/desktop-config/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
python3 - "$repo_dir" "$backup_dir" <<'PY'
import json
from pathlib import Path
import shutil
import sys
repo, backup = map(Path, sys.argv[1:])
for destination in json.loads((repo / 'managed.json').read_text())['system']:
    target = Path(destination)
    source = repo / 'system' / destination.lstrip('/')
    if not source.is_file():
        continue
    if target.exists():
        saved = backup / destination.lstrip('/')
        saved.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(target, saved)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)
    target.chmod(source.stat().st_mode & 0o777)
PY
install -m 644 "$repo_dir/.build/src/facer.ko" /opt/turbo-fan/src/facer.ko
sed -i "s/^KERNELVERSION=.*/KERNELVERSION=\"$(uname -r)\"/" /opt/turbo-fan/service.sh
udevadm control --reload-rules
systemctl daemon-reload
systemctl enable turbo-fan.service
echo "System files restored; backup: $backup_dir"
echo 'Restart the computer to load the rebuilt driver.'
