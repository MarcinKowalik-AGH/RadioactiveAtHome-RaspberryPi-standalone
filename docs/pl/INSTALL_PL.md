# Instalacja — Radioactive@Home standalone

Autor: **Marcin Kowalik <mkowalik@agh.edu.pl>**

## Wymagania

- Raspberry Pi 3B lub zgodny Linux ARM uruchamiający historyczne binarium armhf;
- Raspberry Pi OS Lite 32-bit / Trixie jest konfiguracją zweryfikowaną;
- czujnik `04d8:f6fe`;
- własne archiwum starego projektu BOINC zawierające RADAC 1.78 i `sensors_raspberry_1.78.xml`.

## 1. System

```bash
sudo apt update
sudo apt full-upgrade -y
sudo reboot
```

Po restarcie sprawdź:

```bash
lsusb | grep 04d8:f6fe
```

## 2. Pobranie projektu

```bash
git clone https://github.com/MarcinKowalik-AGH/RadioactiveAtHome-RaspberryPi-standalone.git
cd RadioactiveAtHome-RaspberryPi-standalone
```

## 3. Instalacja z własnego archiwum

```bash
sudo ./scripts/install.sh /home/pi/RPI_BOINC_PROJECTS_YYYYMMDD_HHMMSS.tar.gz
```

Instalator sprawdza SHA-256 starych plików, robi backup istniejącej konfiguracji do `/root/radioactive-backup-*`, zachowuje istniejące dane i uruchamia systemd.

## 4. Weryfikacja

```bash
rahctl status
sudo ./scripts/healthcheck.sh
```

Oczekiwane: `radioactive.service = active`, `NRestarts=0`, czujnik USB widoczny, recorder timer aktywny.

## Opcjonalne HTTP API

Po uruchomieniu sensora można opcjonalnie wykonać:

```bash
sudo ./integration/http-api/install.sh
```

Instalator nie nadpisuje innej usługi zajmującej TCP/80. Szczegóły: `docs/pl/HTTP_API_PL.md`.
