# Sprzęt i protokół — Radioactive@Home

Autor: **Marcin Kowalik <mkowalik@agh.edu.pl>**

Zweryfikowany sensor: `04d8:f6fe`, produkt `microchip radioactiveathome.org GRS`, rewizja 3.01. USB wystawia vendor-specific HID. Historyczny RADAC 1.78 potrafi otworzyć go na Trixie 32-bit bez BOINC.

Debug RADAC potwierdził funkcje modelu: `switch_gmsupply`, `switch_backlight`, `switch_buzzer`, `reset_counters`. Projekt produkcyjnie używa tylko bezpiecznych ustawień backlight i buzzer. Nie automatyzuje odcinania zasilania GM ani resetowania liczników.

Domyślny czas próbki RADAC: 240 s; `num_samples=21`.
