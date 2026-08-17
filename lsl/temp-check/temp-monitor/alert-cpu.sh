#!/bin/sh

while ! /opt/temp-monitor/temp-check-cpu.sh
do
	sudo -u chenpi11 XDG_RUNTIME_DIR=/run/user/2000 pw-play /opt/temp-monitor/beep_cpu.wav
	sleep 0.4
done
