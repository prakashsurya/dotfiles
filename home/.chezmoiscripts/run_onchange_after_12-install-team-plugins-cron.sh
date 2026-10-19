#!/bin/bash
# Schedules ~/.local/bin/update-team-claude-plugins daily. The entry replaces
# any earlier one rather than being appended, so re-running leaves one copy;
# changing it here re-runs this script on next apply.
set -euo pipefail

if ! command -v crontab &>/dev/null; then
    echo "crontab not found, skipping team plugin update schedule."
    exit 0
fi

# shellcheck disable=SC2016 # $HOME is expanded by cron's shell, not here.
ENTRY='17 6 * * * $HOME/.local/bin/update-team-claude-plugins >>$HOME/.cache/update-team-claude-plugins.log 2>&1'

{
    crontab -l 2>/dev/null | grep -vF update-team-claude-plugins || true
    echo "$ENTRY"
} | crontab -
echo "Scheduled update-team-claude-plugins daily."
