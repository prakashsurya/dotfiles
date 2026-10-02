#!/bin/bash
# Installs ccstatusline, the command behind Claude Code's statusLine in
# ~/.claude/settings.json. Its layout lives in ~/.config/ccstatusline/.
# Installed into ~/.local (already on PATH) so it needs no root, and pinned
# so bumping the version below re-runs this script on next apply.
# See: https://github.com/sirmalloc/ccstatusline
set -euo pipefail

VERSION="2.2.22"
PREFIX="$HOME/.local"

if ! command -v npm &>/dev/null; then
    echo "npm not found, skipping ccstatusline install."
    exit 0
fi

if [ "$(npm ls -g --prefix "$PREFIX" --depth=0 --json 2>/dev/null \
        | jq -r '.dependencies.ccstatusline.version // empty')" = "$VERSION" ]; then
    echo "ccstatusline $VERSION already installed, skipping."
    exit 0
fi

echo "Installing ccstatusline $VERSION..."
# Some images ship a root-owned ~/.npm; use a cache dir we own.
npm install -g --prefix "$PREFIX" --cache "$HOME/.cache/npm" "ccstatusline@$VERSION"
echo "ccstatusline installed."
