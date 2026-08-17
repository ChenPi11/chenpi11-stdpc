#!/bin/sh

while ! /opt/temp-monitor/temp-check-dsk.sh
do
	sudo -u chenpi11 XDG_RUNTIME_DIR=/run/user/2000 pw-play /opt/temp-monitor/beep_dsk.wav
	sleep 0.4
done
