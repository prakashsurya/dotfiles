#!/bin/bash
# Installs the GitHub CLI (gh) by adding the official apt repository.
# See: https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian
set -euo pipefail

if command -v gh &>/dev/null; then
    echo "GitHub CLI already installed, skipping."
    exit 0
fi

echo "Installing GitHub CLI..."
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
sudo mkdir -p -m 755 /etc/apt/sources.list.d
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update -qq
sudo apt-get install -y gh
echo "GitHub CLI installed."
