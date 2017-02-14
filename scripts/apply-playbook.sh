#!/bin/bash -ex

TOP=$(git rev-parse --show-toplevel 2>/dev/null)

if [[ -z "$TOP" ]]; then
	echo "Must be run inside the git repsitory."
	exit 1
fi

if [[ $EUID -eq 0 ]]; then
	echo "This script must not be run as root." 1>&2
	exit 1
fi

if [[ ! -f $TOP/ansible/venv/bin/activate ]]; then
	$TOP/scripts/virtualenv-install.sh
fi

source $TOP/ansible/venv/bin/activate
ansible-playbook -i $TOP/ansible/inventory $TOP/ansible/playbook.yml
