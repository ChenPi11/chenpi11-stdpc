#!/bin/bash

set -e

force_install=0

if [ -d "/data/data/com.termux" ]; then
    echo -e "\033[33mSKIP: on Termux.\033[0m"
    exit 0
fi

while getopts "f" opt; do
    case $opt in
        f)
            force_install=1
            ;;
        *)
            echo "Usage: $0 [-f]"
            exit 1
            ;;
    esac
done

if [ -d "/opt/temp-monitor" ] && [ $force_install -eq 0 ]; then
    echo -e "\033[32mTemp Monitor is already installed.\033[0m"
    exit 0
fi

if [ ! -d temp-monitor ]; then
    echo -e "\033[31mError: Please run this script at source code directory.\033[0m"
    exit 1
fi

check()
{
    if [ -z "$(command -v "$1")" ]; then
        printf "\033[31m%s\033[0m " "$1"
        export check_failed=1
    else
        printf "\033[32m%s\033[0m " "$1"
    fi
}

checks()
{
    export check_failed=0
    printf "Checking required commands... "
    for cmd in "$@"; do
        check "$cmd"
    done
    printf "\n"
    if [ $check_failed -eq 1 ]; then
        echo -e "\033[31mError: Please install the above missing commands.\033[0m"
        exit 1
    fi
}

checks sh /bin/bash sleep systemctl sudo pw-play awk nvme

if [ "$UID" -ne 0 ]; then
    echo -e "\033[31mError: Please run this script as root.\033[0m"
    exit 1
fi

ask_yesno()
{
    while true; do
        read -rp "$1 [y/n]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

record_exec()
{
    echo -e "\033[36m$*\033[0m"
    "$@"
}

do_install()
{
    echo "Installing Temp Monitor..."
    record_exec install -v -d -m 755 /opt/temp-monitor
    record_exec install -v -m 755 temp-monitor/* /opt/temp-monitor/
    record_exec install -v -m 755 temp-monitor-cpu.service /etc/systemd/system/
    record_exec install -v -m 755 temp-monitor-dsk.service /etc/systemd/system/
    record_exec install -v -m 755 temp /usr/local/bin/
    record_exec systemctl daemon-reload
    record_exec systemctl enable temp-monitor-cpu
    record_exec systemctl enable temp-monitor-dsk
    record_exec sync
    if ask_yesno "Do you want to start Temp Monitor now?"; then
        record_exec systemctl start temp-monitor-cpu
        record_exec systemctl start temp-monitor-dsk
        if ask_yesno "Do you want to test the Temp Monitor now?"; then
            record_exec touch /tmp/.temp-monitor-test.cpu
            record_exec sleep 5
            record_exec touch /tmp/.temp-monitor-test.dsk
        fi
    fi
}

do_install
