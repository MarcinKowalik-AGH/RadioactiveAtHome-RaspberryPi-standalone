#!/bin/bash
# Radioactive@Home standalone uninstaller
# Author: Marcin Kowalik <mkowalik@agh.edu.pl>
# SPDX-License-Identifier: MIT
set -euo pipefail

if [[ $EUID -ne 0 ]]; then echo "Run through sudo."; exit 1; fi
PURGE=0
[[ "${1:-}" == "--purge-data" ]] && PURGE=1

systemctl disable --now radioactive.service 2>/dev/null || true
systemctl disable --now radioactive-recorder.timer 2>/dev/null || true
rm -f /etc/systemd/system/radioactive.service /etc/systemd/system/radioactive-recorder.service /etc/systemd/system/radioactive-recorder.timer
rm -f /usr/local/sbin/radioactive-runner /usr/local/sbin/radioactive-recorder /usr/local/sbin/rahctl
rm -f /etc/logrotate.d/radioactive-data
systemctl daemon-reload

if [[ $PURGE -eq 1 ]]; then
    rm -rf /opt/radioactive /var/lib/radioactive-recorder
    echo "Software and data removed."
else
    echo "Software removed. Data and legacy files preserved in /opt/radioactive and /var/lib/radioactive-recorder."
    echo "Use --purge-data only if you intentionally want to delete them."
fi
