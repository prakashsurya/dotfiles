#!/bin/bash

#
# We only want this file to be sourced when running from an interactive
# shell, i.e. not from a script or scp. Thus, we prevent the logic above
# from loading it by not using the ".bash" file extention, and instead,
# conditionally load it here.
#
# Also note, this file must be source *after* the environment is
# manipulated via pyenv and direnv. Otherwise, the LP_ENABLE_RUNTIME
# functionality will not work correctly.
#
[[ $- == *i* ]] && source $HOME/.bashrc.d/liquidprompt
