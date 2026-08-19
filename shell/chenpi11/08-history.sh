#!/bin/bash

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL="ignoreboth"

# Append to the history file, don't overwrite it.
if [ -n "$BASH_VERSION" ]; then
    shopt -s histappend
fi

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1).
# Bash/Zsh
export HISTSIZE=1000
# Bash
export HISTFILESIZE=100000
# Zsh
export SAVEHIST=100000

if [ -n "$BASH_VERSION" ]; then
    HISTFILE=~/.bash_history
elif [ -n "$ZSH_VERSION" ]; then
    HISTFILE=~/.zsh_history
    setopt EXTENDED_HISTORY
    setopt HIST_IGNORE_ALL_DUPS
    setopt HIST_IGNORE_SPACE
    setopt INC_APPEND_HISTORY
    setopt SHARE_HISTORY
fi
