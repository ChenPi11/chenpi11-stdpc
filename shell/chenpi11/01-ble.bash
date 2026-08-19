#!/bin/bash

# Load Bash Line Editor (BLE)
if [ -f /usr/share/blesh/ble.sh ] && [[ $- == *i* ]] && [[ -t 0 ]] && [[ -t 1 ]]; then
    # shellcheck source=/dev/null
    source /usr/share/blesh/ble.sh --noattach
fi
