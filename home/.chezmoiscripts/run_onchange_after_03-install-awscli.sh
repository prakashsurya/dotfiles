#!/bin/bash
# See: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
set -euo pipefail

if command -v aws &>/dev/null; then
    echo "AWS CLI already installed, skipping."
    exit 0
fi

echo "Installing AWS CLI v2..."
AWSCLI_TMPDIR=$(mktemp -d)
trap 'rm -rf "${AWSCLI_TMPDIR}"' EXIT

curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" \
    -o "${AWSCLI_TMPDIR}/awscliv2.zip"
unzip -q "${AWSCLI_TMPDIR}/awscliv2.zip" -d "${AWSCLI_TMPDIR}"
sudo "${AWSCLI_TMPDIR}/aws/install"

echo "AWS CLI installed to /usr/local/bin/aws"
