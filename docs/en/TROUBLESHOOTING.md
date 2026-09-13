# Troubleshooting — Radioactive@Home

Author: **Marcin Kowalik <mkowalik@agh.edu.pl>**

Check `lsusb | grep 04d8:f6fe`, `systemctl status radioactive.service`, `systemctl show radioactive.service -p NRestarts`, and `journalctl -u radioactive.service`. A rapidly increasing restart count usually means systemd is launching RADAC directly instead of the persistent runner.
