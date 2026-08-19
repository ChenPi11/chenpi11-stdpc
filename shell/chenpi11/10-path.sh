#!/bin/bash

paths_add() {
    while [ $# -gt 0 ]; do
        if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
            if [ -z "$PATH" ]; then
                PATH="$1"
            else
                PATH="$PATH:$1"
            fi
        fi
        shift
    done
}

paths_add "$HOME/bin" \
"$HOME/.local/bin" \
"/usr/local/bin" \
"/usr/bin" \
"/bin" \
"/usr/local/sbin" \
"/usr/sbin" \
"/sbin" \
"/usr/local/games" \
"/usr/games"
