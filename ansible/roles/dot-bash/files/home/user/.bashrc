#!/bin/bash

shopt -s checkwinsize
shopt -s histappend

alias ls='ls --human-readable --classify --color=auto'
alias ll='ls -l'
alias la='ll --almost-all'
alias lr='la --recursive'
alias vi='vim'

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
# We handle the liquidprompt file a little differently. We only want
# this file to be sourced when running from an interactive shell, i.e.
# not from a script or scp. Thus, we prevent the logic below from
# loading it by not using the ".bash" file extention, and instead,
# condintionally load it here.
#
[[ $- = *i* ]] && source $HOME/.bashrc.d/liquidprompt

for file in `ls $HOME/.bashrc.d/*.bash | sort -n`; do
	[ -r $file ] && source $file
done
unset file
