#!/bin/bash
# Radioactive@Home production health check
# Author: Marcin Kowalik <mkowalik@agh.edu.pl>
# SPDX-License-Identifier: MIT
set -u

echo "===== USB ====="
lsusb | grep -i '04d8:f6fe' || echo "ERROR: detector not present"
echo
echo "===== SERVICE ====="
systemctl is-enabled radioactive.service || true
systemctl is-active radioactive.service || true
systemctl show radioactive.service -p NRestarts -p MainPID -p ActiveState -p SubState
echo
echo "===== RECORDER TIMER ====="
systemctl is-enabled radioactive-recorder.timer || true
systemctl is-active radioactive-recorder.timer || true
echo
echo "===== RAW ====="
tail -5 /opt/radioactive/data.bin 2>/dev/null || true
echo
echo "===== MEASUREMENTS ====="
tail -5 /opt/radioactive/measurements.csv 2>/dev/null || true
echo
echo "===== STORAGE ====="
df -h /
du -sh /opt/radioactive 2>/dev/null || true

echo
echo "===== OPTIONAL HTTP API ====="
if systemctl cat sensor-http-api.service >/dev/null 2>&1; then
    systemctl is-enabled sensor-http-api.service || true
    systemctl is-active sensor-http-api.service || true
    if command -v python3 >/dev/null 2>&1; then
        python3 - <<'PY'
import json, urllib.request
try:
    data=json.load(urllib.request.urlopen("http://127.0.0.1/sensors.json", timeout=3))
    print("HTTP API: OK")
    print("generated_utc:", data.get("generated_utc"))
except Exception as e:
    print("HTTP API: ERROR:", e)
PY
    fi
else
    echo "sensor-http-api.service not installed (optional)"
fi
