#!/bin/bash

set -e

force_install=0

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

if [ -f "$HOME/.config/kitty/kitty.conf" ] && [ $force_install -eq 0 ]; then
    echo -e "\033[32mSKIP: Kitty config already exists. Use -f to force install.\033[0m"
else
    record_exec mkdir -p "$HOME/.config/kitty"
    record_exec cp -fv kitty.conf "$HOME/.config/kitty/kitty.conf"
fi

if [ -f "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml" ] && [ $force_install -eq 0 ]; then
    echo -e "\033[32mSKIP: XFCE4 Terminal config already exists. Use -f to force install.\033[0m"
else
    record_exec mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
    record_exec cp -fv xfce4-terminal.xml "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml"
fi
