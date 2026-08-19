#!/bin/bash

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
if [ -n "$BASH_VERSION" ]; then
    shopt -s checkwinsize
fi

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
if [ -n "$BASH_VERSION" ]; then
    shopt -s globstar
fi
