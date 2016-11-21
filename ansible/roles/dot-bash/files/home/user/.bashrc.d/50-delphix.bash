#!/bin/bash

# To force Eclipse to use gtk2
export SWT_GTK3=0

#
# Add Delphix specific paths if they exist:
#
# * ~/bin/dlpx contains various one-off scripts to ease interaction with
#   Delphix infrastructure.
#
# * ~/dev/dlpx-git-utils holds Delphix software development utilities.
#
[ -d "$HOME/bin/dlpx" ] && export PATH="$HOME/bin/dlpx:$PATH"
[ -d "$HOME/dev/dlpx-git-utils" ] && \
       export PATH="$HOME/dev/dlpx-git-utils/bin:$PATH"
