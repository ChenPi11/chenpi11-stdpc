#!/bin/bash

TEMP_FILE="/sys/class/thermal/thermal_zone0/temp"
THRESHOLD=90000

if [ -f "$TEMP_FILE" ]; then
    TEMP=$(cat "$TEMP_FILE")
    if [ "$TEMP" -gt "$THRESHOLD" ]; then
        exit 1
    fi
fi
exit 0
