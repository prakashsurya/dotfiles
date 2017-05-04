#!/bin/bash

# To force Eclipse to use gtk2
export SWT_GTK3=0

#
# Add Delphix specific paths if they exist:
#
# * ~/.local/bin is used by "pip install --user"
#
# * ~/bin/dlpx contains various one-off scripts to ease interaction with
#   Delphix infrastructure.
#
# * ~/dev/dlpx-git-utils holds Delphix software development utilities.
#
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin/dlpx" ] && export PATH="$HOME/bin/dlpx:$PATH"
[ -d "$HOME/projects/git-utils" ] && \
       export PATH="$HOME/projects/git-utils/bin:$PATH"
