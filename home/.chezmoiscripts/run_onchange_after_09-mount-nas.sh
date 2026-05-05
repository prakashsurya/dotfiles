#!/bin/bash
# Creates the support-tools group (GID 4000), adds the current user to it,
# appends the /nas NFSv4 line to /etc/fstab, and mounts /nas.
# GID is pinned to 4000 because the NFS server resolves ownership by raw GID;
# a mismatched GID would silently break access to files even though the mount
# itself succeeds.
set -euo pipefail

# 1. Create the group with pinned GID if missing.
if ! getent group support-tools >/dev/null; then
    echo "Creating support-tools group with GID 4000..."
    sudo groupadd -g 4000 support-tools
fi

# 2. Add the current user to the group if not already a member.
added_to_group=0
if ! id -nG "$USER" | tr ' ' '\n' | grep -qxF support-tools; then
    echo "Adding $USER to support-tools group..."
    sudo usermod -aG support-tools "$USER"
    added_to_group=1
fi

# 3. Ensure the mount point exists, then append the canonical /nas fstab line if missing.
sudo mkdir -p /nas
if ! grep -qE '^\s*support-tools-nas\.delphix\.com:/\s+/nas\s' /etc/fstab; then
    echo "Appending /nas line to /etc/fstab..."
    echo 'support-tools-nas.delphix.com:/  /nas  nfs4  defaults,_netdev  0  0' \
        | sudo tee -a /etc/fstab >/dev/null
fi

# 4. Mount /nas if it is not already mounted; warn-and-continue on failure
#    so chezmoi apply succeeds even when the NFS server is unreachable
#    (e.g., running this repo on a host outside the Delphix network).
if ! mountpoint -q /nas; then
    if ! sudo mount /nas; then
        echo "warning: 'sudo mount /nas' failed (NFS server unreachable?). fstab is in place — a reboot or 'sudo mount /nas' will pick it up." >&2
    fi
fi

if [ "$added_to_group" = 1 ]; then
    echo "note: log out and back in (or 'newgrp support-tools') for group membership to take effect."
fi
