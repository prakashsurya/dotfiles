#!/bin/bash
set -euo pipefail
if [ -d "$HOME/.pyenv" ]; then
    echo "pyenv already installed, skipping."
    exit 0
fi
echo "Installing pyenv..."
curl -fsSL https://pyenv.run | bash
echo "pyenv installed to $HOME/.pyenv"
