#!/bin/bash

#
# Configure environment to support pyenv.
# For details, see: https://github.com/pyenv/pyenv/blob/master/README.md
#
# We have to be a little careful, as we want to ensure "$PYENV_ROOT/bin"
# is at the front of the $PATH. Thus, we need to ensure this file is
# loaded relatively late in the list of sourced "bashrc.d" files, in
# case any of the other files also modify $PATH.
#
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if [[ "$(type -t pyenv)" != "function" ]]; then
	#
	# We must protect this with the conditional to avoid an invinite
	# loop. For details, see: https://github.com/pyenv/pyenv/issues/264
	#
	eval "$(pyenv init -)"
	eval "$(pyenv virtualenv-init -)"
fi
