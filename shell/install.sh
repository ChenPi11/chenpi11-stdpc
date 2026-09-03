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

checks bash zsh mkdir cp htop oh-my-posh

if [ -d "$HOME/.local/share/chenpi11" ] && [ $force_install -eq 0 ]; then
    echo -e "\033[1;32mSKIP: ~/.local/share/chenpi11 already exists. \033[0m"
else
    record_exec rm -rvf "$HOME/.local/share/chenpi11"
    record_exec mkdir -vp "$HOME/.local/share/chenpi11"
    record_exec cp -vr chenpi11/* "$HOME/.local/share/chenpi11"
fi

# Install .zshrc
if [ -f "$HOME/.zshrc" ] && [ $force_install -eq 0 ]; then
    echo -e "\033[1;32mSKIP: ~/.zshrc already exists. \033[0m"
else
    record_exec cp -v zshrc "$HOME/.zshrc"
fi

# Install .bashrc
if [ -f "$HOME/.bashrc" ] && [ $force_install -eq 0 ]; then
    echo -e "\033[1;32mSKIP: ~/.bashrc already exists. \033[0m"
else
    record_exec cp -v bashrc "$HOME/.bashrc"
    record_exec rm -fv "$HOME/.bash_profile"
    record_exec ln -sv "$HOME/.bashrc" "$HOME/.bash_profile"
fi

# Install htoprc
if [ -f "$HOME/.config/htop/htoprc" ] && [ $force_install -eq 0 ]; then
    echo -e "\033[1;32mSKIP: ~/.config/htop/htoprc already exists. \033[0m"
else
    record_exec mkdir -vp "$HOME/.config/htop"
    record_exec cp -v htoprc "$HOME/.config/htop/htoprc"
fi

if ask_yesno "Do you want to test Bash?"; then
    record_exec bash || true
fi

if ask_yesno "Do you want to test Zsh?"; then
    record_exec zsh || true
fi

if ask_yesno "Do you want to test Htop?"; then
    record_exec htop || true
fi

if ask_yesno "Do you want to install PowerShel profile?"; then
    if [ -f "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1" ] && [ $force_install -eq 0 ]; then
        echo -e "\033[1;32mSKIP: ~/.config/powershell/Microsoft.PowerShell_profile.ps1 already exists. \033[0m"
    else
        record_exec rm -rvf "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
        record_exec rm -rvf "$HOME/.config/powershell/Microsoft.VSCode_profile.ps1"
        record_exec mkdir -vp "$HOME/.config/powershell"
        record_exec pwsh -Command "Install-Module -Name Terminal-Icons -Force -Scope CurrentUser"
        record_exec cp -v Microsoft.PowerShell_profile.ps1 "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
        record_exec ln -sv "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1" "$HOME/.config/powershell/Microsoft.VSCode_profile.ps1"
    fi

    if ask_yesno "Do you want to test PowerShell?"; then
        checks pwsh
        record_exec pwsh || true
    fi
fi
