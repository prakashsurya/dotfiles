#!/bin/bash
# Adds Claude Code marketplaces and installs plugins. Both `marketplace add`
# and `plugin install` are idempotent (exit 0 if already present), so this
# script is safe to re-run. Adding a new line below changes the file hash,
# which makes chezmoi re-run the script on next apply.
set -euo pipefail

if ! command -v claude &>/dev/null; then
    echo "claude not found, skipping plugin setup."
    exit 0
fi

# Private marketplace — requires an SSH key for the git@ clone.
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "No SSH key, skipping plugin setup."
    exit 0
fi

echo "Configuring Claude Code marketplaces and plugins..."
claude plugin marketplace add git@github.com:prakashsurya/claude-plugins.git
claude plugin install llm-wiki@prakashsurya-claude-plugins --scope user
echo "Done."
