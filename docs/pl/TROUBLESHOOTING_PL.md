# Diagnostyka — Radioactive@Home

Autor: **Marcin Kowalik <mkowalik@agh.edu.pl>**

## Sensor niewidoczny

```bash
lsusb | grep 04d8:f6fe
dmesg -T | tail -100
```

## Restart storm

Jeżeli `NRestarts` rośnie co kilka sekund, sprawdź czy usługa używa `/usr/local/sbin/radioactive-runner`, a nie bezpośrednio binarium RADAC:

```bash
systemctl cat radioactive.service
systemctl show radioactive.service -p NRestarts
```

## Brak nowych obliczeń

```bash
tail -20 /opt/radioactive/data.bin
systemctl status radioactive-recorder.timer
journalctl -u radioactive-recorder.service -n 50
```

## Odbudowa

```bash
sudo rahctl rebuild
```
