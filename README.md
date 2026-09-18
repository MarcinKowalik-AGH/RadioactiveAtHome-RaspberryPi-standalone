# Radioactive@Home sensor on Raspberry Pi — standalone preservation

**Version:** `1.2.0`  
**Author:** **Marcin Kowalik**  
**E-mail:** **mkowalik@agh.edu.pl**  
**GitHub:** `MarcinKowalik-AGH`  
**Validated:** `2026-09-18`

This project keeps a legacy **Radioactive@Home** USB radiation sensor useful after the original BOINC infrastructure ceased to be a dependable data path. It runs the historical RADAC application locally on Raspberry Pi, supervises its 21-sample work-block lifecycle, preserves raw observations, calculates CPM and an estimated dose rate, and exposes local controls for the detector backlight and buzzer.

> Preservation / reverse-engineering project by **Marcin Kowalik <mkowalik@agh.edu.pl>**. It is not affiliated with the former Radioactive@Home project, BOINC, Microchip, or the original detector authors.

## Validated hardware and software

```text
Host: Raspberry Pi 3 Model B Rev 1.2
OS: Raspberry Pi OS Lite 32-bit / Raspbian GNU/Linux 13 (trixie)
Architecture: armv7l
Kernel validated: 6.18.39+rpt-rpi-v7

Detector: Radioactive@Home GRS
USB VID:PID: 04d8:f6fe
Hardware revision: 3.01 / 0x0301 / decimal 769
USB product: microchip radioactiveathome.org GRS
```

## What is included

```text
src/                 recorder + persistent RADAC runner
scripts/             install, import, control, health check, uninstall
systemd/             sensor, recorder and timer units
logrotate/            calculated-data rotation
journald/             bounded system journal configuration
docs/en/              detailed English manual
docs/pl/              detailed Polish manual
legacy/               preserved upstream RADAC runtime + optional archive importer
examples/             raw and calculated data examples
```

## Bundled preserved upstream files

Version 1.2.0 is self-contained for the validated ARM32 Raspberry Pi target. The repository includes a byte-preserved, XZ-compressed copy of the historical Radioactive@Home RADAC 1.78 executable and the matching sensor XML under `legacy/upstream/radac-1.78/`.

The installer verifies all preserved artifacts before use:

```text
radac_1.78_armv6l-unknown-linux-gnueabihf
SHA-256: 966025a8f96726d2a76230fbf1ebe39dc9cc2a597e15f594686f48e96bf75306

sensors_raspberry_1.78.xml
SHA-256: 87b4573a291820b5818c201ac148d5e09a2a1fc5f801f3aebecd80f483b3af31
```

These are preserved third-party upstream artifacts, not authored by Marcin Kowalik and not covered by this repository's MIT license. See `THIRD_PARTY_NOTICE.md`.

## Fast installation

```bash
sudo apt update
sudo apt install -y git python3 util-linux usbutils logrotate coreutils xz-utils
git clone https://github.com/MarcinKowalik-AGH/RadioactiveAtHome-RaspberryPi-standalone.git
cd RadioactiveAtHome-RaspberryPi-standalone
sudo ./scripts/install.sh
```

No old BOINC directory, archive or second Raspberry Pi is required. Import from a historical BOINC archive remains supported as an optional compatibility path:

```bash
sudo ./scripts/install.sh /path/to/RPI_BOINC_PROJECTS_*.tar.gz
```

## Daily operation

```bash
rahctl status
sudo rahctl backlight on
sudo rahctl backlight off
sudo rahctl buzzer on
sudo rahctl buzzer off
sudo rahctl debug on
sudo rahctl debug off
sudo rahctl rebuild
rahctl storage
```

Production defaults are buzzer OFF, backlight OFF and debug OFF.

## Data model

RADAC stores cumulative hardware time and cumulative counts. Correct CPM therefore comes from consecutive deltas, not from dividing a cumulative count by only the latest interval.

```text
CPM = delta_counts * 60000 / delta_ms
estimated µSv/h = CPM / 171.2
```

The dose value is a compatibility estimate, **not calibrated professional dosimetry**.

## The 21-sample block lifecycle

RADAC 1.78 was designed as a BOINC application. On the validated sensor it completes a block after 21 samples. Running the binary directly under `Restart=always` therefore creates a restart storm even though RADAC exits successfully.

`radioactive-runner` fixes this:

1. keeps the service itself persistent;
2. detects a complete 21-record `data.bin`;
3. runs the recorder once before archival;
4. moves the completed raw block into `/opt/radioactive/raw-blocks/` without copying the payload;
5. starts the next RADAC block;
6. treats an early clean RADAC exit as a delayed retry, not as a crash.

## Reboot handling

A Raspberry Pi / detector reboot can reset the hardware timer and cumulative count. The recorder detects that rollback and writes `status=reset`; the following valid interval resumes normal CPM calculation. This path was validated on real hardware.

## Optional local HTTP API

A validated read-only HTTP API can expose the current Radioactive@Home and Quake-Catcher state on a trusted LAN:

```text
/sensors.json
/sensors.csv
/radioactive.json
/radioactive.csv
/qcn.json
/qcn.csv
/qcn/event/latest.json
```

Install it separately so the core detector setup does not claim port 80 automatically:

```bash
sudo ./integration/http-api/install.sh
```

The API runs as `www-data`, receives only `CAP_NET_BIND_SERVICE`, suppresses per-request logging, and does not create another sensor-data log. It was validated from macOS against the Raspberry Pi on 2026-09-13. Do not forward this unauthenticated port directly from the public Internet.

See [`docs/en/HTTP_API.md`](docs/en/HTTP_API.md).

## Documentation

Polish: [`README_PL.md`](README_PL.md) and [`docs/pl/`](docs/pl/)  
English: [`docs/en/`](docs/en/)

## Author

**Marcin Kowalik**  
E-mail: **mkowalik@agh.edu.pl**

## License

Original code and documentation authored for this repository: MIT.

The preserved historical Radioactive@Home RADAC executable and sensor XML under `legacy/upstream/` are third-party upstream artifacts and are excluded from the MIT grant. Their provenance and currently verified licensing information are documented in `THIRD_PARTY_NOTICE.md`.
