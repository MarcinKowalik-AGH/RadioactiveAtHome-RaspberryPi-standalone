# Operations — Radioactive@Home

Author: **Marcin Kowalik <mkowalik@agh.edu.pl>**

```bash
rahctl status
sudo rahctl backlight on|off
sudo rahctl buzzer on|off
sudo rahctl debug on|off
sudo rahctl rebuild
rahctl storage
```

RADAC 1.78 ends each validated work block after 21 samples. The persistent runner archives a completed block and starts the next one without causing a systemd restart storm.

## HTTP API status

If the optional API is installed:

```bash
systemctl status sensor-http-api.service --no-pager
curl -s http://127.0.0.1/sensors.json | python3 -m json.tool
```
