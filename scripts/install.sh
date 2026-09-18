#!/bin/bash
# Radioactive@Home standalone installer
# Author: Marcin Kowalik <mkowalik@agh.edu.pl>
# SPDX-License-Identifier: MIT
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo ./scripts/install.sh [optional-legacy-archive-or-directory]"
    exit 1
fi

ROOT=$(cd "$(dirname "$0")/.." && pwd)
PROJECT_VERSION=$(cat "$ROOT/VERSION" 2>/dev/null || echo "unknown")
TS=$(date +%Y%m%d_%H%M%S)
BACKUP="/root/radioactive-backup-$TS"
mkdir -p "$BACKUP"

RADAC=/opt/radioactive/radac_1.78_armv6l-unknown-linux-gnueabihf
SENSORS=/opt/radioactive/sensors.xml
BUNDLED_XZ="$ROOT/legacy/upstream/radac-1.78/radac_1.78_armv6l-unknown-linux-gnueabihf.xz"
BUNDLED_XML="$ROOT/legacy/upstream/radac-1.78/sensors_raspberry_1.78.xml"

EXPECTED_RADAC="966025a8f96726d2a76230fbf1ebe39dc9cc2a597e15f594686f48e96bf75306"
EXPECTED_XML="87b4573a291820b5818c201ac148d5e09a2a1fc5f801f3aebecd80f483b3af31"
EXPECTED_XZ="645ec28d948341fdcbd34db396d98427d7bd48bbd11e34c36a41dac6dabfdc57"

backup_if_exists() {
    local src="$1"
    if [ -e "$src" ]; then
        mkdir -p "$BACKUP$(dirname "$src")"
        cp -a "$src" "$BACKUP$src"
    fi
}

for cmd in python3 flock lsusb logrotate sha256sum xz; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing dependency: $cmd" >&2
        echo "Install: sudo apt update && sudo apt install -y python3 util-linux usbutils logrotate coreutils xz-utils" >&2
        exit 1
    fi
done

# Optional backward-compatible import from a user's old BOINC archive.
if [[ $# -ge 1 ]]; then
    "$ROOT/scripts/import_legacy_files.sh" "$1"
fi

install_bundled_legacy() {
    [[ -f "$BUNDLED_XZ" ]] || { echo "Missing bundled RADAC archive: $BUNDLED_XZ" >&2; exit 1; }
    [[ -f "$BUNDLED_XML" ]] || { echo "Missing bundled sensor XML: $BUNDLED_XML" >&2; exit 1; }

    echo "$EXPECTED_XZ  $BUNDLED_XZ" | sha256sum -c -
    echo "$EXPECTED_XML  $BUNDLED_XML" | sha256sum -c -

    local tmp
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' RETURN

    xz -t "$BUNDLED_XZ"
    xz -dc "$BUNDLED_XZ" > "$tmp/radac"
    echo "$EXPECTED_RADAC  $tmp/radac" | sha256sum -c -

    install -d -m 0755 /opt/radioactive
    install -m 0755 "$tmp/radac" "$RADAC"
    install -m 0644 "$BUNDLED_XML" "$SENSORS"
    rm -rf "$tmp"
    trap - RETURN
    echo "Bundled preserved Radioactive@Home RADAC 1.78 files installed and verified."
}

# Fresh installation is self-contained. Existing validated legacy files are preserved.
if [[ ! -e "$RADAC" || ! -e "$SENSORS" ]]; then
    install_bundled_legacy
fi

[[ -x "$RADAC" ]] || { echo "Missing executable: $RADAC" >&2; exit 1; }
[[ -f "$SENSORS" ]] || { echo "Missing file: $SENSORS" >&2; exit 1; }
echo "$EXPECTED_RADAC  $RADAC" | sha256sum -c -
echo "$EXPECTED_XML  $SENSORS" | sha256sum -c -

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
systemctl reset-failed radioactive.service 2>/dev/null || true
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
echo "Version: $PROJECT_VERSION"
echo "Author: Marcin Kowalik <mkowalik@agh.edu.pl>"
echo "Status: rahctl status"
