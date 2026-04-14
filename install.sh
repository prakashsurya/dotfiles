#!/bin/bash
set -euo pipefail

# Step 1: install chezmoi (skip if already present)
if ! command -v chezmoi &>/dev/null && [ ! -x "$HOME/.local/bin/chezmoi" ]; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
fi

# Resolve chezmoi binary — prefer PATH, fall back to ~/.local/bin
CHEZMOI="$(command -v chezmoi 2>/dev/null || echo "$HOME/.local/bin/chezmoi")"

# Step 2: init and apply (prompts will appear on first run)
CHEZMOI_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi/chezmoi.toml"
if [ ! -f "$CHEZMOI_CONFIG" ]; then
    "$CHEZMOI" init --apply github.com/prakashsurya/dotfiles
else
    "$CHEZMOI" apply
fi
