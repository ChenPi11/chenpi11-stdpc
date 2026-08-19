#!/bin/bash

if command -v fzf &> /dev/null; then
    if [ -n "$BASH_VERSION" ]; then
        eval "$(fzf --bash)"
    elif [ -n "$ZSH_VERSION" ]; then
        eval "$(fzf --zsh)"
    fi
fi
