#!/bin/bash

if command -v oh-my-posh &> /dev/null; then
    if [ -n "$OMP_THEME_PATH" ]; then
        eval "$(oh-my-posh init bash --config "$OMP_THEME_PATH")"
    elif [ -f "/usr/share/oh-my-posh/themes/powerlevel10k_rainbow.omp.json" ]; then
        eval "$(oh-my-posh init bash --config /usr/share/oh-my-posh/themes/powerlevel10k_rainbow.omp.json)"
    elif [ -f "/lsl/ArchLinux/usr/share/oh-my-posh/themes/powerlevel10k_rainbow.omp.json" ]; then
        eval "$(oh-my-posh init bash --config /lsl/ArchLinux/usr/share/oh-my-posh/themes/powerlevel10k_rainbow.omp.json)"
    fi
fi
