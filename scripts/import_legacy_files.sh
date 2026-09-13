#!/bin/bash
# Import validated legacy Radioactive@Home files from the user's own archive.
# Author: Marcin Kowalik <mkowalik@agh.edu.pl>
# SPDX-License-Identifier: MIT
set -euo pipefail

EXPECTED_RADAC="966025a8f96726d2a76230fbf1ebe39dc9cc2a597e15f594686f48e96bf75306"
EXPECTED_XML="87b4573a291820b5818c201ac148d5e09a2a1fc5f801f3aebecd80f483b3af31"

if [[ $# -ne 1 ]]; then
    echo "Usage: sudo $0 /path/to/RPI_BOINC_PROJECTS_*.tar.gz-or-extracted-directory"
    exit 1
fi

SOURCE="$1"
TMP=""
cleanup() { [[ -n "$TMP" && -d "$TMP" ]] && rm -rf "$TMP"; }
trap cleanup EXIT

if [[ -d "$SOURCE" ]]; then
    SEARCH_ROOT="$SOURCE"
elif [[ -f "$SOURCE" ]]; then
    TMP=$(mktemp -d)
    tar -xzf "$SOURCE" -C "$TMP"
    SEARCH_ROOT="$TMP"
else
    echo "Source not found: $SOURCE" >&2
    exit 1
fi

RADAC=$(find "$SEARCH_ROOT" -type f -name 'radac_1.78_armv6l-unknown-linux-gnueabihf' -print -quit)
XML=$(find "$SEARCH_ROOT" -type f -name 'sensors_raspberry_1.78.xml' -print -quit)

[[ -n "$RADAC" ]] || { echo "RADAC binary not found"; exit 1; }
[[ -n "$XML" ]] || { echo "sensors_raspberry_1.78.xml not found"; exit 1; }

RADAC_SHA=$(sha256sum "$RADAC" | awk '{print $1}')
XML_SHA=$(sha256sum "$XML" | awk '{print $1}')

[[ "$RADAC_SHA" == "$EXPECTED_RADAC" ]] || { echo "Unexpected RADAC SHA-256: $RADAC_SHA"; exit 1; }
[[ "$XML_SHA" == "$EXPECTED_XML" ]] || { echo "Unexpected sensors XML SHA-256: $XML_SHA"; exit 1; }

install -d -m 0755 /opt/radioactive
install -m 0755 "$RADAC" /opt/radioactive/radac_1.78_armv6l-unknown-linux-gnueabihf
install -m 0644 "$XML" /opt/radioactive/sensors.xml

echo "Legacy files imported and verified."
echo "Author of this importer: Marcin Kowalik <mkowalik@agh.edu.pl>"
