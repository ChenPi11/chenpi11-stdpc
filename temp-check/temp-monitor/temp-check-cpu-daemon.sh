#!/bin/bash

while true; do
    if ! /opt/temp-monitor/temp-check-cpu.sh; then
        /bin/bash /opt/temp-monitor/alert-cpu.sh
    fi
    sleep 5
done
