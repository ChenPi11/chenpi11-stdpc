#!/bin/bash

while true; do
    if ! /opt/temp-monitor/temp-check-dsk.sh; then
        /bin/bash /opt/temp-monitor/alert-dsk.sh
    fi
    sleep 5
done
