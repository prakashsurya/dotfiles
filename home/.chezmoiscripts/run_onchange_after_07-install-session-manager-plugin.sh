#!/bin/bash
# See: https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-debian-and-ubuntu.html
set -euo pipefail

if command -v session-manager-plugin &>/dev/null; then
    echo "AWS Session Manager plugin already installed, skipping."
    exit 0
fi

echo "Installing AWS Session Manager plugin..."
PLUGIN_TMPDIR=$(mktemp -d)
trap 'rm -rf "${PLUGIN_TMPDIR}"' EXIT

case "$(uname -m)" in
    x86_64)  ARCH="ubuntu_64bit" ;;
    aarch64) ARCH="ubuntu_arm64" ;;
    *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
esac

curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/${ARCH}/session-manager-plugin.deb" \
    -o "${PLUGIN_TMPDIR}/session-manager-plugin.deb"
sudo dpkg -i "${PLUGIN_TMPDIR}/session-manager-plugin.deb"

echo "AWS Session Manager plugin installed."
