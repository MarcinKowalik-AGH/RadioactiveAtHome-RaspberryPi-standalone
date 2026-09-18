# Tested production state — 2026-09-18

Author: **Marcin Kowalik <mkowalik@agh.edu.pl>**

## Runtime validation on real hardware

Validated on Raspberry Pi 3 Model B Rev 1.2 with Raspberry Pi OS Lite 32-bit / Raspbian 13 Trixie and Radioactive@Home GRS `04d8:f6fe`.

After a full Raspberry Pi reboot:

```text
radioactive.service: enabled / active
NRestarts=0
radioactive-recorder.timer: active
USB: 04d8:f6fe present
```

The detector reset its hardware timer/counter after reboot and the recorder correctly emitted `status=reset`; the next valid interval resumed normal CPM calculation.

## Second Raspberry Pi reproduction

A second Raspberry Pi was configured on 2026-09-18 from a clean system using the repository scripts and the same validated RADAC/XML payloads. Radioactive service started `active (running)`, recorder timer was active, `NRestarts=0`, and a baseline record was produced.

## v1.2.0 self-contained payload verification

The v1.2.0 repository payload was checked before publication:

```text
scripts/install.sh: bash -n PASS
RADAC XZ: xz -t PASS
RADAC executable SHA-256:
966025a8f96726d2a76230fbf1ebe39dc9cc2a597e15f594686f48e96bf75306
sensor XML SHA-256:
87b4573a291820b5818c201ac148d5e09a2a1fc5f801f3aebecd80f483b3af31
```

The XZ payload stored in Git reconstructs byte-for-byte to the same RADAC executable used on the validated Raspberry Pi systems.

## HTTP API validation

Validated HTTP API from macOS over LAN:

```text
/sensors.json -> Radioactive available=true; status=ok
/radioactive.json -> valid current measurement
/sensors.csv -> valid single-row CSV
sensor-http-api.service -> active (running)
```
