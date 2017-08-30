#!/bin/bash

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
if [[ $- == *i* ]] && [[ -n "$SSH_CONNECTION" ]] && \
    [[ -z "$TMUX" ]] && hash tmux &>/dev/null; then
	tmux new-session -As ssh && exit
fi
