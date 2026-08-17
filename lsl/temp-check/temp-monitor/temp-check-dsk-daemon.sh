#!/bin/bash

if ! /opt/temp-monitor/temp-check-dsk.sh
then
	/bin/bash /opt/temp-monitor/alert-dsk.sh
fi
