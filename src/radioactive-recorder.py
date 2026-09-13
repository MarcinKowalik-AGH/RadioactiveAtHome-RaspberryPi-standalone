#!/usr/bin/python3
# Radioactive@Home measurement recorder
# Author: Marcin Kowalik <mkowalik@agh.edu.pl>
# Copyright (c) 2026 Marcin Kowalik
# SPDX-License-Identifier: MIT

import csv
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

CURRENT_INPUT = Path("/opt/radioactive/data.bin")
RAW_ARCHIVE = Path("/opt/radioactive/raw-blocks")
OUTPUT = Path("/opt/radioactive/measurements.csv")
STATE = Path("/var/lib/radioactive-recorder/state.json")

CPM_PER_USVH = 171.2
MIN_INTERVAL_MS = 180000
REBUILD = "--rebuild" in sys.argv

HEADER = [
    "timestamp_utc", "timer_ms", "counter", "delta_ms", "delta_counts",
    "cpm", "dose_uSv_h_est", "revision", "device_id", "status",
]


def parse_timestamp(value):
    dt = datetime.strptime(value.strip(), "%Y-%m-%d %H:%M:%S")
    return dt.replace(tzinfo=timezone.utc)


def parse_file(path):
    records = []
    try:
        with open(path, "r", errors="replace", encoding="utf-8") as handle:
            for row in csv.reader(handle):
                if len(row) != 6:
                    continue
                try:
                    records.append({
                        "timer_ms": int(row[0]),
                        "counter": int(row[1]),
                        "timestamp": parse_timestamp(row[2]),
                        "revision": int(row[3]),
                        "sample_type": row[4].strip(),
                        "device_id": int(row[5]),
                    })
                except Exception:
                    continue
    except FileNotFoundError:
        pass
    return records


def load_records():
    if not REBUILD:
        return parse_file(CURRENT_INPUT)

    records = []
    if RAW_ARCHIVE.is_dir():
        for path in sorted(RAW_ARCHIVE.glob("data-*.bin")):
            records.extend(parse_file(path))
    records.extend(parse_file(CURRENT_INPUT))

    unique = {}
    for r in records:
        key = (r["timestamp"], r["timer_ms"], r["counter"], r["device_id"])
        unique[key] = r
    return sorted(unique.values(), key=lambda r: (r["timestamp"], r["timer_ms"], r["counter"]))


def load_state():
    try:
        with open(STATE, "r", encoding="utf-8") as handle:
            return json.load(handle)
    except Exception:
        return None


def save_state(state):
    STATE.parent.mkdir(parents=True, exist_ok=True)
    tmp = STATE.with_name(STATE.name + ".tmp")
    with open(tmp, "w", encoding="utf-8") as handle:
        json.dump(state, handle)
        handle.flush()
        os.fsync(handle.fileno())
    os.replace(tmp, STATE)


def row_for(record, state):
    iso = record["timestamp"].isoformat().replace("+00:00", "Z")

    if state is None:
        return [iso, record["timer_ms"], record["counter"], "", "", "", "",
                record["revision"], record["device_id"], "baseline"]

    prev_timer = int(state["timer_ms"])
    prev_counter = int(state["counter"])
    prev_device = int(state["device_id"])

    if (record["device_id"] != prev_device or
            record["timer_ms"] <= prev_timer or
            record["counter"] < prev_counter):
        return [iso, record["timer_ms"], record["counter"], "", "", "", "",
                record["revision"], record["device_id"], "reset"]

    delta_ms = record["timer_ms"] - prev_timer
    delta_counts = record["counter"] - prev_counter

    if delta_ms < MIN_INTERVAL_MS:
        return [iso, record["timer_ms"], record["counter"], delta_ms, delta_counts, "", "",
                record["revision"], record["device_id"], "short_interval"]

    cpm = delta_counts * 60000.0 / delta_ms
    dose = cpm / CPM_PER_USVH
    return [iso, record["timer_ms"], record["counter"], delta_ms, delta_counts,
            f"{cpm:.4f}", f"{dose:.6f}", record["revision"], record["device_id"], "ok"]


def state_from(record):
    return {
        "timestamp": record["timestamp"].isoformat(),
        "timer_ms": record["timer_ms"],
        "counter": record["counter"],
        "device_id": record["device_id"],
    }


def main():
    records = load_records()
    if not records:
        return 0

    state = None if REBUILD else load_state()

    if REBUILD:
        OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        tmp_output = OUTPUT.with_name(OUTPUT.name + ".rebuild.tmp")
        with open(tmp_output, "w", newline="", encoding="utf-8") as handle:
            writer = csv.writer(handle)
            writer.writerow(HEADER)
            for record in records:
                writer.writerow(row_for(record, state))
                state = state_from(record)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(tmp_output, OUTPUT)
        save_state(state)
        return 0

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    write_header = not OUTPUT.exists() or OUTPUT.stat().st_size == 0
    with open(OUTPUT, "a", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        if write_header:
            writer.writerow(HEADER)

        for record in records:
            if state is not None:
                last_ts = datetime.fromisoformat(state["timestamp"])
                if record["timestamp"] <= last_ts:
                    continue
            writer.writerow(row_for(record, state))
            state = state_from(record)
            save_state(state)

        handle.flush()
        os.fsync(handle.fileno())

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
