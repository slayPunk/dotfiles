#!/usr/bin/env python3
"""Read desktop sensors once; avoid waking a suspended NVIDIA GPU."""
import json
from pathlib import Path
import subprocess


def read(path):
    try:
        return path.read_text().strip()
    except OSError:
        return None


def number(path, scale=1):
    try:
        return round(int(read(path)) / scale)
    except (TypeError, ValueError):
        return None


def collect():
    result = {'cpu_temp': None, 'gpu_temp': None,
              'cpu_fan_rpm': None, 'gpu_fan_rpm': None, 'gpu_state': 'unavailable'}
    for hwmon in Path('/sys/class/hwmon').glob('hwmon*'):
        name = read(hwmon / 'name')
        if name == 'coretemp':
            for label in hwmon.glob('temp*_label'):
                if (read(label) or '').startswith('Package id'):
                    value = number(label.with_name(label.name.replace('_label', '_input')), 1000)
                    if value is not None:
                        result['cpu_temp'] = max(result['cpu_temp'] or value, value)
        elif name == 'acer':
            result['cpu_fan_rpm'] = number(hwmon / 'fan1_input')
            result['gpu_fan_rpm'] = number(hwmon / 'fan2_input')

    nvidia = Path('/sys/bus/pci/drivers/nvidia')
    devices = [entry for entry in nvidia.glob('????:??:??.?')
               if (read(entry / 'class') or '').startswith('0x03')]
    if not devices:
        return result
    if all(read(entry / 'power/runtime_status') == 'suspended' for entry in devices):
        result['gpu_state'] = 'sleep'
        return result
    try:
        query = subprocess.run(
            ['nvidia-smi', '--query-gpu=temperature.gpu', '--format=csv,noheader,nounits'],
            capture_output=True, text=True, timeout=2, check=True)
        values = [int(line.strip()) for line in query.stdout.splitlines() if line.strip().isdigit()]
        if values:
            result['gpu_temp'] = max(values)
            result['gpu_state'] = 'active'
    except (OSError, ValueError, subprocess.SubprocessError):
        pass
    return result


if __name__ == '__main__':
    print(json.dumps(collect()))
