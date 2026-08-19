#!/bin/sh

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -n "$BASH_VERSION" ] && [ -f ~/.bash_aliases ]; then
    # shellcheck source=/dev/null
    . ~/.bash_aliases
fi

alias lcat=/bin/cat
alias cat='bat -pp'
alias 1='cd ..'
alias 2='cd ../..'
alias 3='cd ../../..'
alias 4='cd ../../../..'
alias 5='cd ../../../../..'
alias 6='cd ../../../../../..'
alias 7='cd ../../../../../../..'
alias 8='cd ../../../../../../../..'
alias 9='cd ../../../../../../../../..'
alias _='sudo '
alias mounts='findmnt -a'
alias afind='ack -il'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias gc1='git clone --recursive --depth=1'
alias globurl='noglob urlglobber '
alias grep='grep --color=auto'
alias md='mkdir -p'
alias rd=rmdir
alias lls=/bin/ls
alias ls="eza --color=auto"
alias l='eza -lZbah --icons'
alias la='eza -lZabgh --icons'
alias ll='eza -lZbg --icons'
alias lsa='eza -lbagR --icons'
alias lst='eza -lTabgh --icons'
alias diff='diff --color'
alias dd='dd status=progress'
alias xz='xz -v'
alias a='source .venv/bin/activate'
alias makedev='make -f Makefile.devel'
alias cmake='cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
