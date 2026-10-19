#!/bin/bash
# Installs AWS's Session Manager plugin, which `aws ssm start-session` needs
# to reach the support-tools servers. AWS ships it as a .deb outside the apt
# mirror, so it can't go in packages.toml. Bumping VERSION re-runs this
# script on next apply; it is skipped when the pinned version is present.
set -euo pipefail

VERSION="1.2.835.0"

if [ "$(dpkg-query -W -f='${Version}' session-manager-plugin 2>/dev/null)" = "$VERSION-1" ]; then
    echo "session-manager-plugin $VERSION already installed, skipping."
    exit 0
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT

echo "Installing session-manager-plugin $VERSION..."
curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/${VERSION}/ubuntu_64bit/session-manager-plugin.deb" \
    -o "$TMPDIR/session-manager-plugin.deb"
sudo apt-get install -y -q "$TMPDIR/session-manager-plugin.deb"
echo "session-manager-plugin installed."
