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
# Configure environment to support pyenv.
# For details, see: https://github.com/pyenv/pyenv/blob/master/README.md
#
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if [[ "$(type -t pyenv)" != "function" ]]; then
	#
	# We must protect this with the conditional to avoid an invinite
	# loop. For details, see: https://github.com/pyenv/pyenv/issues/264
	#
	eval "$(pyenv init -)"
fi

#
# We handle the liquidprompt file a little differently. We only want
# this file to be sourced when running from an interactive shell, i.e.
# not from a script or scp. Thus, we prevent the logic below from
# loading it by not using the ".bash" file extention, and instead,
# condintionally load it here.
#
[[ "$-" == *i* ]] && source $HOME/.bashrc.d/liquidprompt

for file in `ls $HOME/.bashrc.d/*.bash | sort -n`; do
	[ -r $file ] && source $file
done
unset file

#
# When connecting to a system using SSH, if tmux is available,
# automatically attach to the existing tmux session, or start a new
# session if one does not already exist.
#
# When inside of a tmux session, the "$TMUX" environment variable will
# be set, so we rely on this to prevent recursively attaching to the
# tmux session when already inside of a session. Also, we only want to
# start and/or attach to a tmux session if this is an interactive login.
#
# Additionally, when tmux exits with a successful exit code, we
# automatically call "exit" so that we close the remote connection
# immediately after exiting the tmux session. This way, simply detaching
# from the tmux session will return back to the local system, rather
# than having to then exit the remote (non-tmux) shell as well.
#
# With that said, we need to be a little careful, though, because if
# tmux were to crash (e.g. due to tmux itself mis-behaving), we don't
# want our ".bashrc" to prevent us from obtaining a non-tmux shell (e.g.
# to debug the situation on the remote system). Thus, we only want to
# call exit when tmux exits successfully, and avoid exiting the non-tmux
# remote shell when tmux exits with any non-successful error code.
#
if [[ "$-" == *i* ]] && [[ -n "$SSH_CONNECTION" ]] && \
    [[ -z "$TMUX" ]] && hash tmux &>/dev/null; then
	tmux new-session -As ssh && exit
fi
