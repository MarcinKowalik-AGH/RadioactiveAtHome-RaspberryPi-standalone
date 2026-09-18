# Changelog

Author: **Marcin Kowalik <mkowalik@agh.edu.pl>**

## 1.2.0 — 2026-09-18

- Made fresh ARM32 installation self-contained: no old BOINC archive or second Raspberry Pi is required.
- Bundled the preserved upstream RADAC 1.78 executable as an XZ-compressed legacy artifact and the matching sensor XML.
- Added SHA-256 verification of the XZ archive, reconstructed executable and XML before installation.
- Retained optional import from historical BOINC archives for compatibility.
- Added explicit third-party provenance/licensing notice separating preserved Radioactive@Home artifacts from the repository MIT license.
- Included the directory-source importer exit-status fix validated during installation of the second Raspberry Pi.


## 1.1.0 — 2026-09-13

- Added optional shared read-only HTTP API on port 80 with JSON and CSV endpoints.
- Added hardened `sensor-http-api.service` running as `www-data` with only `CAP_NET_BIND_SERVICE`.
- Added API installer/uninstaller, Polish/English API manual and tested JSON/CSV examples.
- API validated locally and from macOS over LAN; per-request HTTP logging is intentionally disabled to avoid unnecessary microSD writes.
- Preserved the v1.0.0 production acquisition path unchanged: 21-sample RADAC runner, reset handling, rebuild support and `NRestarts=0`.

## 1.0.0 — 2026-09-13

First production-ready preservation release, validated on real hardware after a full Raspberry Pi reboot.

- Radioactive@Home GRS v3.01 (`04d8:f6fe`) standalone acquisition on Raspberry Pi OS 13 Trixie 32-bit.
- Legacy RADAC 1.78 import with SHA-256 verification; binary is not redistributed.
- Persistent `radioactive-runner` handling the legacy 21-sample RADAC work-block lifecycle without systemd restart storms.
- Correct counter/timer delta processing, reset detection, short-interval rejection, CPM and estimated µSv/h.
- Rebuild support from archived raw blocks plus the current `data.bin`.
- Backlight, buzzer and RADAC debug control via `rahctl`.
- systemd autostart, recorder timer, bounded journal and log rotation.
- Full reboot validation: hardware counter reset was detected as `status=reset`; the next 228.010 s interval with 74 counts was correctly reported as 19.4728 CPM / 0.113743 µSv/h.
