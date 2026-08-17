#!/bin/bash

THRESHOLD=50

if [ $(id -u) -ne 0 ]; then
   echo ERROR: $@ must run as root.
   exit 0
fi

TEMP=$(nvme smart-log /dev/nvme0 | awk '/temperature/ {print $3}')
if [ "$TEMP" -gt "$THRESHOLD" ]; then
    exit 1
fi
exit 0
