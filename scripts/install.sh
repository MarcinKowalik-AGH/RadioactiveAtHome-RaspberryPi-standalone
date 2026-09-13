#!/bin/bash
# Radioactive@Home standalone installer
# Author: Marcin Kowalik <mkowalik@agh.edu.pl>
# SPDX-License-Identifier: MIT
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo ./scripts/install.sh [legacy-archive-or-directory]"
    exit 1
fi

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TS=$(date +%Y%m%d_%H%M%S)
BACKUP="/root/radioactive-backup-$TS"
mkdir -p "$BACKUP"

backup_if_exists() {
    local src="$1"
    if [ -e "$src" ]; then
        mkdir -p "$BACKUP$(dirname "$src")"
        cp -a "$src" "$BACKUP$src"
    fi
}

if [[ $# -ge 1 ]]; then
    "$ROOT/scripts/import_legacy_files.sh" "$1"
fi

for cmd in python3 flock lsusb logrotate sha256sum; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing dependency: $cmd" >&2
        echo "Install: sudo apt update && sudo apt install -y python3 util-linux usbutils logrotate coreutils" >&2
        exit 1
    fi
done

RADAC=/opt/radioactive/radac_1.78_armv6l-unknown-linux-gnueabihf
SENSORS=/opt/radioactive/sensors.xml
[[ -x "$RADAC" ]] || { echo "Missing $RADAC - import legacy files first."; exit 1; }
[[ -f "$SENSORS" ]] || { echo "Missing $SENSORS - import legacy files first."; exit 1; }

for f in /usr/local/sbin/radioactive-runner /usr/local/sbin/radioactive-recorder /usr/local/sbin/rahctl /etc/systemd/system/radioactive.service /etc/systemd/system/radioactive-recorder.service /etc/systemd/system/radioactive-recorder.timer /etc/logrotate.d/radioactive-data /etc/systemd/journald.conf.d/sensor-limits.conf; do
    backup_if_exists "$f"
done

echo "Backup: $BACKUP"

systemctl stop radioactive.service 2>/dev/null || true
systemctl stop radioactive-recorder.timer 2>/dev/null || true

install -d -m 0755 /opt/radioactive/raw-blocks /opt/radioactive/archive /var/lib/radioactive-recorder /etc/systemd/journald.conf.d
install -m 0755 "$ROOT/src/radioactive-runner" /usr/local/sbin/radioactive-runner
install -m 0755 "$ROOT/src/radioactive-recorder.py" /usr/local/sbin/radioactive-recorder
install -m 0755 "$ROOT/scripts/rahctl" /usr/local/sbin/rahctl

if [[ ! -f /opt/radioactive/init_data.xml ]]; then
cat > /opt/radioactive/init_data.xml <<'XML'
<app_init_data>
    <project_preferences>
        <buzzer>0</buzzer>
        <backlight>0</backlight>
        <radacdebug>0</radacdebug>
    </project_preferences>
</app_init_data>
XML
else
    echo "Preserving existing /opt/radioactive/init_data.xml"
fi

install -m 0644 "$ROOT/systemd/radioactive.service" /etc/systemd/system/radioactive.service
install -m 0644 "$ROOT/systemd/radioactive-recorder.service" /etc/systemd/system/radioactive-recorder.service
install -m 0644 "$ROOT/systemd/radioactive-recorder.timer" /etc/systemd/system/radioactive-recorder.timer
install -m 0644 "$ROOT/logrotate/radioactive-data" /etc/logrotate.d/radioactive-data
install -m 0644 "$ROOT/journald/sensor-limits.conf" /etc/systemd/journald.conf.d/sensor-limits.conf

python3 -m py_compile /usr/local/sbin/radioactive-recorder
bash -n /usr/local/sbin/radioactive-runner
systemctl daemon-reload
systemctl reset-failed radioactive.service || true
systemctl restart systemd-journald
systemctl enable --now radioactive.service
systemctl enable --now radioactive-recorder.timer

sleep 3

echo
echo "===== RADIOACTIVE ====="
systemctl --no-pager --full status radioactive.service || true
echo
echo "===== RECORDER ====="
systemctl --no-pager --full status radioactive-recorder.timer || true
echo
echo "Installation complete."
echo "Author: Marcin Kowalik <mkowalik@agh.edu.pl>"
echo "Status: rahctl status"
