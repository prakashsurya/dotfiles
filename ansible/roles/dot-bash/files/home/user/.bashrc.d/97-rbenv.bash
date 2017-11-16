#!/bin/bash

#
# Configure environment to support rbenv.
# For details, see: https://github.com/rbenv/rbenv/blob/master/README.md
#
# We have to be a little careful, as we want to ensure "$RBENV_ROOT/bin"
# is at the front of the $PATH. Thus, we need to ensure this file is
# loaded relatively late in the list of sourced "bashrc.d" files, in
# case any of the other files also modify $PATH.
#
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
if [[ "$(type -t rbenv)" != "function" ]]; then
	#
	# We must protect this with the conditional to avoid an infinite
	# loop. For details, see: https://github.com/pyenv/pyenv/issues/264
	#
	eval "$(rbenv init -)"
fi
