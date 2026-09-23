# Legacy / upstream Radioactive@Home artifacts

Version 1.2.1 keeps the validated historical runtime files needed by RADAC in `legacy/upstream/radac-1.78/`, so a fresh installation no longer depends on an old BOINC directory.

The preserved executable is stored XZ-compressed. The installer verifies the compressed artifact, decompresses it, verifies the original executable SHA-256, and only then installs it.

The old `scripts/import_legacy_files.sh` path is retained for users who prefer to supply their own archived BOINC project files.

See `THIRD_PARTY_NOTICE.md` for provenance and licensing boundaries.
