#!/bin/bash
# Adds Claude Code marketplaces and installs all plugins listed in each
# private marketplace manifest. Both `marketplace add` and `plugin install`
# are idempotent (exit 0 if already present), so this script is safe to
# re-run. Adding a new line below changes the file hash, which makes chezmoi
# re-run the script on next apply.
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

MARKETPLACE="prakashsurya-claude-plugins"
claude plugin marketplace add git@github.com:prakashsurya/claude-plugins.git

MANIFEST="$HOME/.claude/plugins/marketplaces/$MARKETPLACE/.claude-plugin/marketplace.json"
mapfile -t plugins < <(jq -r '.plugins[].name' "$MANIFEST")

for plugin in "${plugins[@]}"; do
    echo "Installing ${plugin}@${MARKETPLACE}..."
    claude plugin install "${plugin}@${MARKETPLACE}" --scope user
done

# Anthropic's official marketplace — cherry-pick individual plugins rather
# than installing everything in it.
OFFICIAL_MARKETPLACE="claude-plugins-official"
claude plugin marketplace add anthropics/claude-plugins-official

for plugin in superpowers; do
    echo "Installing ${plugin}@${OFFICIAL_MARKETPLACE}..."
    claude plugin install "${plugin}@${OFFICIAL_MARKETPLACE}" --scope user
done

echo "Done."
