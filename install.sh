#!/bin/bash -eux

pushd "${BASH_SOURCE%/*}" >/dev/null

case "$OSTYPE" in
	darwin*)
		./scripts/osx/install-homebrew.sh
		./scripts/osx/install-homebrew-pkgs.sh
		./scripts/tmux/install-plugins.sh
		;;
	linux*)
		;;
	*)
		echo "unknown: $OSTYPE"
		;;
esac

./stow.sh

popd >/dev/null
