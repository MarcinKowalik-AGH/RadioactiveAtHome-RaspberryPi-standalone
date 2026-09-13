# Data format — Radioactive@Home

Author: **Marcin Kowalik <mkowalik@agh.edu.pl>**

Raw: `timer_ms,counter,timestamp_utc,revision,sample_type,device_id`. Calculated output adds deltas, CPM, estimated µSv/h and a status (`baseline`, `ok`, `short_interval`, `reset`).
