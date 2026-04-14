#!/bin/bash
# Installs Claude Code using the native install method.
# See: https://code.claude.com/docs/en/quickstart#native-install-recommended
set -euo pipefail

if command -v claude &>/dev/null; then
    echo "Claude Code already installed, skipping."
    exit 0
fi

echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash
echo "Claude Code installed."