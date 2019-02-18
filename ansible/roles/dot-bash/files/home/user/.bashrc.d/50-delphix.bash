#!/bin/bash

#
# Add Delphix specific paths if they exist:
#
# * ~/bin/dlpx contains various one-off scripts to ease interaction with
#   Delphix infrastructure.
#
# * ~/dev/dlpx-git-utils holds Delphix software development utilities.
#
[ -d "$HOME/bin/dlpx" ] && export PATH="$HOME/bin/dlpx:$PATH"
[ -d "$HOME/projects/git-utils" ] && \
       export PATH="$HOME/projects/git-utils/bin:$PATH"
