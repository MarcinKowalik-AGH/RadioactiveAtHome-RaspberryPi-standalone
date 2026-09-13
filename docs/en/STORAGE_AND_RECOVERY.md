# Storage and recovery — Radioactive@Home

Author: **Marcin Kowalik <mkowalik@agh.edu.pl>**

Raw blocks are tiny and retained as the source of truth. Calculated data is rotated monthly. `rahctl rebuild` reconstructs measurements from all archived raw blocks plus the current block.
