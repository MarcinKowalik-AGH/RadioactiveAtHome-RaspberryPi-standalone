# Format danych — Radioactive@Home

Autor: **Marcin Kowalik <mkowalik@agh.edu.pl>**

## data.bin

Sześć pól CSV:

```text
timer_ms,counter,timestamp_utc,revision,sample_type,device_id
```

Przykład:

```text
244550,75,2026-9-13 13:14:29,769,n,81327870
```

`revision=769` odpowiada `0x0301` / hardware 3.01. `device_id=81327870` odpowiada `0x04d8f6fe`.

Typy obserwowane podczas walidacji: `f` pierwszy odczyt bloku, `n` kolejny, `r` odczyt po resecie licznika.

## measurements.csv

```text
timestamp_utc,timer_ms,counter,delta_ms,delta_counts,cpm,dose_uSv_h_est,revision,device_id,status
```

Statusy: `baseline`, `ok`, `short_interval`, `reset`.
