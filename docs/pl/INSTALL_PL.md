# Instalacja — Radioactive@Home standalone

Autor: **Marcin Kowalik <mkowalik@agh.edu.pl>**

## Wymagania

- Raspberry Pi 3B lub zgodny Linux ARM uruchamiający binarium armhf;
- Raspberry Pi OS Lite 32-bit / Trixie — konfiguracja zweryfikowana;
- czujnik `04d8:f6fe`.

Od wersji 1.2.0 **nie jest wymagane stare archiwum BOINC**.

## Instalacja

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y git python3 util-linux usbutils logrotate coreutils xz-utils
git clone https://github.com/MarcinKowalik-AGH/RadioactiveAtHome-RaspberryPi-standalone.git
cd RadioactiveAtHome-RaspberryPi-standalone
sudo ./scripts/install.sh
```

Instalator używa zachowanych plików z `legacy/upstream/radac-1.78/`, sprawdza SHA-256 skompresowanego artefaktu, odtworzonej binarki RADAC oraz XML, następnie konfiguruje usługi systemd, rejestrator, rotację i limity journald.

## Opcjonalny import starego archiwum

```bash
sudo ./scripts/install.sh /home/pi/RPI_BOINC_PROJECTS_YYYYMMDD_HHMMSS.tar.gz
```

## Weryfikacja

```bash
rahctl status
sudo ./scripts/healthcheck.sh
```

Oczekiwane: `radioactive.service = active`, `NRestarts=0`, czujnik USB widoczny, recorder timer aktywny.

## Opcjonalne HTTP API

```bash
sudo ./integration/http-api/install.sh
```

Szczegóły: `docs/pl/HTTP_API_PL.md`.
