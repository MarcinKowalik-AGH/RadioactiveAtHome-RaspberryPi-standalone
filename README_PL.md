# Radioactive@Home na Raspberry Pi — samodzielne zachowanie i eksploatacja

**Wersja:** `1.2.0`  
**Autor:** **Marcin Kowalik**  
**E-mail:** **mkowalik@agh.edu.pl**  
**GitHub:** `MarcinKowalik-AGH`  
**Walidacja na sprzęcie:** `2026-09-18`

Projekt pozwala dalej używać starego czujnika **Radioactive@Home** bez działającej infrastruktury BOINC. Historyczny program RADAC pracuje lokalnie na Raspberry Pi, a dodatkowe skrypty obsługują jego cykl 21-próbkowych bloków, zapisują dane źródłowe, obliczają CPM i szacowane µSv/h oraz pozwalają sterować podświetleniem i buzzerem.

> Projekt zachowawczy / reverse-engineering: **Marcin Kowalik <mkowalik@agh.edu.pl>**. Projekt nie jest oficjalną kontynuacją Radioactive@Home i nie jest powiązany z BOINC, Microchip ani autorami pierwotnego sprzętu.

## Zweryfikowany zestaw

```text
Raspberry Pi 3 Model B Rev 1.2
Raspberry Pi OS Lite 32-bit / Raspbian 13 Trixie
armv7l
kernel 6.18.39+rpt-rpi-v7

Radioactive@Home GRS
VID:PID 04d8:f6fe
hardware 3.01 / 0x0301 / 769
```

## Najważniejsze funkcje

- praca bez serwera BOINC;
- autostart systemd;
- trwały `radioactive-runner` obsługujący zakończenie bloków po 21 próbkach;
- zachowanie źródłowych bloków `data.bin`;
- poprawne liczenie `delta_ms`, `delta_counts`, CPM i szacowanego µSv/h;
- wykrywanie resetu licznika po restarcie zasilania;
- odrzucanie zbyt krótkich interwałów diagnostycznych;
- odbudowa `measurements.csv` z archiwalnych bloków raw i bieżącego `data.bin`;
- `rahctl` do statusu, LED/backlight, buzzera i debug;
- rotacja danych i limit dziennika systemowego.

## Instalacja skrócona

Od wersji 1.2.0 repozytorium jest samowystarczalne dla zweryfikowanego Raspberry Pi ARM32. Zawiera zachowaną historyczną binarkę RADAC 1.78 w postaci XZ oraz odpowiadający jej `sensors_raspberry_1.78.xml`.

```bash
sudo apt update
sudo apt install -y git python3 util-linux usbutils logrotate coreutils xz-utils
git clone https://github.com/MarcinKowalik-AGH/RadioactiveAtHome-RaspberryPi-standalone.git
cd RadioactiveAtHome-RaspberryPi-standalone
sudo ./scripts/install.sh
```

Nie jest już potrzebne stare archiwum BOINC ani kopiowanie plików z innego Raspberry Pi. Instalator przed użyciem sprawdza SHA-256 obu zachowanych artefaktów. Import własnego starego archiwum pozostaje opcjonalnie obsługiwany.

Zachowane pliki RADAC/XML są artefaktami upstream Radioactive@Home, nie są autorstwa Marcina Kowalika i nie obejmuje ich licencja MIT tego repozytorium. Szczegóły: `THIRD_PARTY_NOTICE.md`.

## Sterowanie

```bash
rahctl status
sudo rahctl backlight on|off
sudo rahctl buzzer on|off
sudo rahctl debug on|off
sudo rahctl rebuild
rahctl storage
```

## Dane

```text
/opt/radioactive/data.bin                    bieżący blok raw
/opt/radioactive/raw-blocks/data-*.bin       ukończone bloki raw
/opt/radioactive/measurements.csv            obliczone pomiary
/var/lib/radioactive-recorder/state.json     stan inkrementalnego rejestratora
```

Wzór:

```text
CPM = delta_counts * 60000 / delta_ms
szacowane µSv/h = CPM / 171.2
```

Wartość µSv/h jest wartością orientacyjną zgodną z historycznym przelicznikiem, a nie wynikiem wzorcowanego dozymetru.

## Potwierdzony reboot

Po pełnym restarcie Raspberry licznik sprzętowy zresetował się. Rejestrator prawidłowo zapisał `status=reset`, a następny interwał 228,010 s / 74 impulsy został policzony jako 19,4728 CPM / 0,113743 µSv/h. Usługa pozostała `active`, `NRestarts=0`.

Pełna instrukcja: [`docs/pl/INSTALL_PL.md`](docs/pl/INSTALL_PL.md), [`docs/pl/OPERATIONS_PL.md`](docs/pl/OPERATIONS_PL.md), [`docs/pl/TROUBLESHOOTING_PL.md`](docs/pl/TROUBLESHOOTING_PL.md).

## Opcjonalne lokalne HTTP API

Zweryfikowany moduł tylko-do-odczytu może wystawić bieżące dane obu sensorów w zaufanej sieci LAN:

```text
/sensors.json
/sensors.csv
/radioactive.json
/radioactive.csv
/qcn.json
/qcn.csv
/qcn/event/latest.json
```

Instaluje się go osobno, aby podstawowa instalacja sensora nie zajmowała automatycznie portu 80:

```bash
sudo ./integration/http-api/install.sh
```

API działa jako `www-data`, ma tylko `CAP_NET_BIND_SERVICE`, nie loguje każdego żądania i nie tworzy dodatkowego logu pomiarowego. Zostało zweryfikowane 13.09.2026 również z komputera macOS w LAN. Nie należy przekierowywać tego nieuwierzytelnionego portu bezpośrednio z Internetu.

Szczegóły: [`docs/pl/HTTP_API_PL.md`](docs/pl/HTTP_API_PL.md).

## Autor

**Marcin Kowalik**  
**mkowalik@agh.edu.pl**


## Licencja

Kod i dokumentacja utworzone w tym repozytorium: MIT. Zachowane pliki upstream Radioactive@Home w `legacy/upstream/` są wyłączone z licencji MIT; szczegóły i pochodzenie opisuje `THIRD_PARTY_NOTICE.md`.
