#!/bin/bash

set -o vi
shopt -s checkwinsize
shopt -s histappend

alias df='df --human-readable'
alias du='du --human-readable'
alias grep='grep --color=auto'
alias ls='ls --human-readable --classify --color=auto'
alias ll='ls -l'
alias la='ll --almost-all'
alias lr='la --recursive'
alias mkdir='mkdir --parents --verbose'
alias vi='vim'

alias s='ssh'
alias c='clear'
alias g='git'

export EDITOR='/usr/bin/vim'
export GIT_PS1_SHOWUPSTREAM="verbose"
export GREP_COLOR='1;33'
export HISTCONTROL=ignoreboth
export HISTFILESIZE=2000
export HISTSIZE=1000
export HISTTIMEFORMAT='%F %T '
export PAGER='less'
export PATH="$HOME/bin:$PATH"
export TERM='xterm-256color'
export PS1="\e[0;33m\H \u \d \t \w\$(__git_ps1 ' (%s)')\n\$ \e[0m"

for file in `ls $HOME/.bashrc.d/*.bash | sort -n`; do
	[ -r $file ] && source $file
done
unset file
