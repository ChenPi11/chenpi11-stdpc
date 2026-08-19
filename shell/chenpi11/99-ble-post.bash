#!/bin/bash

if [ -f /usr/share/blesh/ble.sh ]; then
    [[ ${BLE_VERSION-} ]] && ble-attach
fi
