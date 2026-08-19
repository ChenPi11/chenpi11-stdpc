#!/bin/bash

set -e

if [ -d "/data/data/com.termux" ]; then
    echo -e "\033[33mSKIP: on Termux.\033[0m"
    exit 0
fi

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

ask_input()
{
    read -rp "$1 [$2]: " input
    if [ -z "$input" ]; then
        input=$2
    fi
    echo "$input"
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

checks useradd sudo

if [ -d /home/admin ]; then
    echo -e "\033[32mSKIP: Skip configure admin user since it already exists.\033[0m"
    configure_admin=1
else
    if ask_yesno "Do you want to configure admin user?"; then
        configure_admin=1
        useradd -d /home/admin -G root -o -u 0 admin
    else
        configure_admin=0
    fi
fi

if [ -f /etc/sudoers.d/01_admin_runas ] || [ -f /etc/sudoers.d/02_chenpi11 ]; then
    echo -e "\033[32mSKIP: Skip configure sudoers since it already exists.\033[0m"
else
    if ask_yesno "Do you want to configure sudoers?"; then
        echo -e "\033[36mConfiguring sudoers...\033[0m"
        if [ "$configure_admin" -eq 1 ]; then
            record_exec sh -c 'echo "Defaults:chenpi11 runas_default=admin" > /etc/sudoers.d/01_admin_runas'
        fi
        record_exec sh -c 'echo "chenpi11 ALL=(ALL) ALL" > /etc/sudoers.d/02_chenpi11'
    fi
    
    if ask_yesno "Do you want to test sudo?"; then
        echo -e "\033[36mTesting sudo...\033[0m"
        record_exec sudo sh -c "echo \$HOME"
    fi
fi

if [ -f /etc/doas.conf ]; then
    echo -e "\033[32mSKIP: Skip configure doas since it already exists.\033[0m"
else
    if ask_yesno "Do you want to configure doas?"; then
        checks doas
        echo -e "\033[36mConfiguring doas...\033[0m"
        conf_install_dir=$(ask_input "Install doas.conf to" "/etc")
        record_exec sh -c "cat > $conf_install_dir/doas.conf <<'EOF'
    permit persist chenpi11 as admin
    permit nopass admin as root
    EOF"
        if [ ! -f /etc/pam.d/doas ] && [ -d /etc/pam.d ]; then
            if [ ! -f /etc/pam.d/sudo ]; then
                echo -e "\033[33mWarning: /etc/pam.d/sudo not found, skipping PAM configuration for doas.\033[0m"
            else
                record_exec cp -a /etc/pam.d/sudo /etc/pam.d/doas
            fi
        fi
        
        if ask_yesno "Do you want to test doas?"; then
            echo -e "\033[36mTesting doas...\033[0m"
            record_exec doas sh -c "echo \$HOME"
        fi
    fi
fi
sync
