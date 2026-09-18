# Installation — Radioactive@Home standalone

Author: **Marcin Kowalik <mkowalik@agh.edu.pl>**

Validated target: Raspberry Pi 3B, Raspberry Pi OS Lite 32-bit / Raspbian 13 Trixie, detector `04d8:f6fe`.

## Fresh self-contained installation

```bash
sudo apt update
sudo apt install -y git python3 util-linux usbutils logrotate coreutils xz-utils
git clone https://github.com/MarcinKowalik-AGH/RadioactiveAtHome-RaspberryPi-standalone.git
cd RadioactiveAtHome-RaspberryPi-standalone
sudo ./scripts/install.sh
rahctl status
```

Version 1.2.0 includes the validated preserved RADAC 1.78 ARM32 runtime and matching sensor XML. The installer verifies SHA-256 before installing either file.

Existing measurement data and valid installed legacy files are preserved. Existing files with unexpected hashes cause installation to stop rather than silently replace unknown data.

## Optional historical archive import

```bash
sudo ./scripts/install.sh /path/to/RPI_BOINC_PROJECTS_*.tar.gz
```

## Optional HTTP API

```bash
sudo ./integration/http-api/install.sh
```

The API installer refuses to replace another service already using TCP/80. See `docs/en/HTTP_API.md`.
