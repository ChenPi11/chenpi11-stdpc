#!/bin/bash

if [ -n "$BASH_VERSION" ]; then
    if [ -f /usr/share/doc/pkgfile/command-not-found.bash ]; then
        # shellcheck source=/dev/null
        source /usr/share/doc/pkgfile/command-not-found.bash
    fi
elif [ -n "$ZSH_VERSION" ]; then
    if [ -f /usr/share/doc/pkgfile/command-not-found.zsh ]; then
        # ArchLinux
        # shellcheck source=/dev/null
        source /usr/share/doc/pkgfile/command-not-found.zsh
    elif [ -f /usr/lib/command-not-found ]; then
        # Debian
        command_not_found_handler()
        {
            /usr/lib/command-not-found -- "$1"
            return $?
        }
    fi
fi
