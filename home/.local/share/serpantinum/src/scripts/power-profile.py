#!/usr/bin/env python3
"""Read Acer's exact thermal profile and coordinate it with the CPU profile."""
import json
import os
from pathlib import Path
import subprocess
import sys

CPU_PROFILES = {
    'low-power': 'power-saver',
    'quiet': 'power-saver',
    'balanced': 'balanced',
    'balanced-performance': 'balanced',
    'performance': 'performance',
}


def device():
    for entry in Path('/sys/class/platform-profile').glob('platform-profile-*'):
        if (entry / 'name').read_text().strip() == 'acer-wmi':
            return entry
    raise RuntimeError('Acer platform profiles are unavailable')


def status(entry):
    return {
        'profile': (entry / 'profile').read_text().strip(),
        'choices': [value for value in (entry / 'choices').read_text().split()
                    if value in CPU_PROFILES],
    }


def main():
    entry = device()
    if len(sys.argv) == 1:
        return status(entry)
    if len(sys.argv) != 3 or sys.argv[1] != '--set':
        raise ValueError('Usage: power-profile.py [--set PROFILE]')
    target = sys.argv[2]
    if target not in CPU_PROFILES or target not in status(entry)['choices']:
        raise ValueError('Unsupported power profile: ' + target)
    profile_path = entry / 'profile'
    # Check access before changing the CPU when an exact extra mode is requested.
    if target in ('quiet', 'balanced-performance') and not os.access(profile_path, os.W_OK):
        raise PermissionError('Cannot write the Acer profile; check the udev rule')
    subprocess.run(['powerprofilesctl', 'set', CPU_PROFILES[target]],
                   check=True, capture_output=True, text=True, timeout=10)
    if profile_path.read_text().strip() != target:
        profile_path.write_text(target + '\n')
    result = status(entry)
    if result['profile'] != target:
        raise RuntimeError('The firmware did not apply the requested profile')
    return result


if __name__ == '__main__':
    try:
        print(json.dumps(main()))
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as exc:
        detail = getattr(exc, 'stderr', None) or str(exc)
        print(json.dumps({'error': detail.strip()}))
        sys.exit(1)
