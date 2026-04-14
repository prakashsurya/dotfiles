#!/bin/bash
set -euo pipefail

if [ -f "/opt/nvim-linux-x86_64/bin/nvim" ]; then
    echo "Neovim already installed, skipping."
    exit 0
fi

echo "Installing Neovim (latest)..."
NVIM_TMPDIR=$(mktemp -d)
trap 'rm -rf "${NVIM_TMPDIR}"' EXIT
curl -L "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" \
    -o "${NVIM_TMPDIR}/nvim.tar.gz"
sudo tar -C /opt -xzf "${NVIM_TMPDIR}/nvim.tar.gz"
echo "Neovim installed to /opt/nvim-linux-x86_64"
