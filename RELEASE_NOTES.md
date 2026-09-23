# v1.2.1 — Radioactive@Home Raspberry Pi standalone

**Release date:** 2026-09-18  
**Author / maintainer:** Marcin Kowalik <mkowalik@agh.edu.pl>  
**License for original repository code and documentation:** MIT

## Highlights

- Updated the optional shared HTTP API to version 1.1.
- Preserves the latest valid calculated CPM/dose while a current row is a reset/baseline row.
- Adds explicit provenance fields: `measurement_timestamp_utc`, `using_last_valid`, `current`, and `latest_valid`.
- Adds fallback to rotated `measurements.csv-*` archives.
- Keeps the validated persistent 21-sample RADAC work-block runner and reset handling.
- Keeps self-contained ARM32 installation using byte-preserved historical RADAC 1.78 artifacts with SHA-256 verification.

## Third-party preservation boundary

The RADAC executable and sensor XML in `legacy/upstream/radac-1.78/` are historical third-party artifacts. They are not authored by Marcin Kowalik and are not covered by the MIT license in the repository root. See `THIRD_PARTY_NOTICE.md`.
