# Tested production state — 2026-09-13

Author: **Marcin Kowalik <mkowalik@agh.edu.pl>**

After a full Raspberry Pi reboot:

```text
radioactive.service: enabled / active
NRestarts=0
radioactive-recorder.timer: active
USB: 04d8:f6fe present
```

The detector reset its hardware timer/counter after reboot:

```text
3733850,1160,...
16540,1,...,r,...
244550,75,...,n,...
```

The recorder produced:

```text
... 3733850,1160,350190,104,17.8189,0.104082,...,ok
... 16540,1,,,,,...,reset
... 244550,75,228010,74,19.4728,0.113743,...,ok
```

This validates reset detection and correct continuation after reboot.

## HTTP API validation

Validated HTTP API from macOS over LAN:

```text
/sensors.json -> Radioactive available=true; status=ok
/radioactive.json -> 20.9948 CPM / 0.122633 µSv/h in the validation snapshot
/sensors.csv -> valid single-row CSV
sensor-http-api.service -> active (running)
```
