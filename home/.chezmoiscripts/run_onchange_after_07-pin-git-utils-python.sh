#!/bin/bash
set -euo pipefail

GIT_UTILS_DIR="$HOME/.local/share/git-utils"
PYTHON_VERSION="3.10.7"
PYENV="$HOME/.pyenv/bin/pyenv"

# Only run if git-utils was cloned (i.e. SSH key existed during chezmoi apply).
if [ ! -d "$GIT_UTILS_DIR" ]; then
    exit 0
fi

# Install the required Python version if missing.
if [ -x "$PYENV" ] && ! "$PYENV" versions --bare | grep -qx "$PYTHON_VERSION"; then
    echo "Installing Python $PYTHON_VERSION for git-utils..."
    "$PYENV" install "$PYTHON_VERSION"
fi

# Pin the version inside the git-utils directory.
if [ -x "$PYENV" ]; then
    echo "$PYTHON_VERSION" > "$GIT_UTILS_DIR/.python-version"
    echo "git-utils pinned to Python $PYTHON_VERSION."
fi
