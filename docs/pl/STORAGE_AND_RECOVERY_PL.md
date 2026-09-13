# Pamięć masowa i odzyskiwanie — Radioactive@Home

Autor: **Marcin Kowalik <mkowalik@agh.edu.pl>**

Radioactive zapisuje bardzo mało danych: typowo jedna próbka co ~4 minuty. Ukończone bloki raw mają około 1 kB, więc nawet wieloletnie przechowywanie jest lekkie dla karty SD.

`measurements.csv` i `stderr.txt` są rotowane miesięcznie, do 24 rotacji, z kompresją i awaryjnym limitem 5 MiB. Journal systemowy ma limit 100 MiB / 1 miesiąc.

Źródłem prawdy są `raw-blocks` + bieżący `data.bin`. `sudo rahctl rebuild` może odtworzyć `measurements.csv`.
