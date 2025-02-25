#!/bin/bash -eux

pushd "${BASH_SOURCE%/*}" >/dev/null

stow -t "$HOME" home $@

popd >/dev/null
