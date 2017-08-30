#!/bin/bash

shopt -s checkwinsize
shopt -s histappend

alias ls='ls --human-readable --classify --color=auto'
alias ll='ls -l'
alias la='ll --almost-all'
alias lr='la --recursive'
alias vi='vim'

alias j='jrnl'
alias s='ssh'
alias c='clear'
alias g='git'

export EDITOR='/usr/bin/vim'
export GREP_COLOR='1;33'
export HISTCONTROL=ignoreboth
export HISTFILESIZE=2000
export HISTSIZE=1000
export HISTTIMEFORMAT='%F %T '
export PAGER='less'
export PATH="$HOME/bin:$PATH"
export TERM='xterm-256color'

#
# Various executable utilities (scripts, binaries, etc.) in this
# directory, so it needs to be apart of the PATH so these utilities can
# be easily accessible.
#
export PATH="$HOME/.local/bin:$PATH"

#
# Load any additional files found in the ".bashrc.d" directory.
#
for file in `ls $HOME/.bashrc.d/*.bash | sort -n`; do
	[ ! -e "${file}.disabled" ] && [ -r "${file}" ] && source "${file}"
done
unset file
