# Installation — Radioactive@Home standalone

Author: **Marcin Kowalik <mkowalik@agh.edu.pl>**

Validated target: Raspberry Pi 3B, Raspberry Pi OS Lite 32-bit / Raspbian 13 Trixie, detector `04d8:f6fe`.

```bash
git clone https://github.com/MarcinKowalik-AGH/RadioactiveAtHome-RaspberryPi-standalone.git
cd RadioactiveAtHome-RaspberryPi-standalone
sudo ./scripts/install.sh /home/pi/RPI_BOINC_PROJECTS_YYYYMMDD_HHMMSS.tar.gz
rahctl status
```

The installer verifies the legacy files, backs up existing configuration, preserves existing data and enables the systemd services.

## Optional HTTP API

After the sensor itself is working, optionally run:

```bash
sudo ./integration/http-api/install.sh
```

The installer refuses to replace another service already using TCP/80. See `docs/en/HTTP_API.md`.
