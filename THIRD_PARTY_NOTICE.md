# Third-party notice

This repository contains preservation code and documentation authored by **Marcin Kowalik <mkowalik@agh.edu.pl>** under the MIT license, plus clearly separated historical upstream artifacts required to keep a Radioactive@Home detector operational.

## Preserved Radioactive@Home upstream artifacts

Location: `legacy/upstream/radac-1.78/`

- `radac_1.78_armv6l-unknown-linux-gnueabihf.xz` — XZ-compressed byte-preserved copy of the historical ARM32 RADAC 1.78 executable recovered from the archived BOINC project directory.
- `sensors_raspberry_1.78.xml` — matching historical sensor definition file.

Validated hashes:

```text
RADAC executable:
966025a8f96726d2a76230fbf1ebe39dc9cc2a597e15f594686f48e96bf75306

RADAC XZ archive:
645ec28d948341fdcbd34db396d98427d7bd48bbd11e34c36a41dac6dabfdc57

sensor XML:
87b4573a291820b5818c201ac148d5e09a2a1fc5f801f3aebecd80f483b3af31
```

These upstream artifacts are **not authored by Marcin Kowalik and are not covered by the MIT license in the repository root**.

Historical project references describe Radioactive@Home software as GPL and contemporary discussion points to a formerly public upstream source directory. The recovered BOINC archive used for this preservation release did not itself contain the corresponding source snapshot or a standalone license file for RADAC 1.78. This repository therefore records provenance and hashes explicitly instead of attributing authorship or a new license to the preserved files.

The v1.2.0 installer does not modify these artifacts. It verifies and installs the preserved executable byte-for-byte.
