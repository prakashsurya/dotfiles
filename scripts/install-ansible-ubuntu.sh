#!/bin/bash -ex

if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root." 1>&2
        exit 1
fi

apt-get update
apt-get install -y software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get install -y ansible
