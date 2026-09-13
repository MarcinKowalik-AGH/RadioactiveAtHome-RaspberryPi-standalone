# Eksploatacja — Radioactive@Home

Autor: **Marcin Kowalik <mkowalik@agh.edu.pl>**

## Sterowanie

```bash
rahctl status
sudo rahctl backlight on|off
sudo rahctl buzzer on|off
sudo rahctl debug on|off
rahctl storage
```

Zmiana backlight/buzzer/debug wymaga restartu RADAC, ponieważ ustawienia są przekazywane przy starcie aplikacji. Runner zachowuje częściowy blok i kontynuuje pracę.

## Bloki 21 próbek

RADAC 1.78 kończy blok po 21 próbkach. Runner przed przeniesieniem bloku wymusza przeliczenie ostatnich rekordów. Ukończony `data.bin` jest przenoszony (rename na tym samym filesystemie) do `raw-blocks`, co nie powoduje ponownego zapisu całej zawartości.

## Odbudowa pomiarów

```bash
sudo rahctl rebuild
```

Rebuild czyta wszystkie `raw-blocks/data-*.bin` oraz bieżący `data.bin`, deduplikuje i sortuje rekordy, a następnie atomowo tworzy `measurements.csv`.

## Reboot/reset

Po restarcie sprzętowy timer i counter mogą zacząć od zera. Recorder zapisuje wtedy `status=reset`; dopiero kolejny wystarczająco długi interwał otrzymuje CPM i µSv/h.

## Stan HTTP API

Jeżeli zainstalowano opcjonalne API:

```bash
systemctl status sensor-http-api.service --no-pager
curl -s http://127.0.0.1/sensors.json | python3 -m json.tool
```
