#!/bin/bash
# Installs the language servers behind the Claude Code LSP plugins enabled in
# 10-install-claude-plugins (clangd comes from apt via packages.toml):
#   gopls       — gopls-lsp;   built with go from 08-install-dev-tools
#   pyright     — pyright-lsp; npm package, like ccstatusline
#   jdtls       — jdtls-lsp;   Eclipse JDT.LS, needs Java 17+ at runtime
# Everything goes into ~/.local, so no root. Bumping a version below re-runs
# this script on the next apply.
set -euo pipefail

GOPLS_VERSION="0.23.0"
PYRIGHT_VERSION="1.1.414"
# JDT.LS publishes no stable "latest" release; track the snapshot and
# reinstall by deleting ~/.local/opt/jdtls.
JDTLS_URL="https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz"

BIN="$HOME/.local/bin"
OPT="$HOME/.local/opt"
mkdir -p "$BIN" "$OPT"

if [ ! -x "$BIN/go" ]; then
    echo "go not found, skipping gopls."
elif "$BIN/gopls" version 2>/dev/null | grep -q " v$GOPLS_VERSION$"; then
    echo "gopls $GOPLS_VERSION already installed, skipping."
else
    echo "Installing gopls $GOPLS_VERSION..."
    GOBIN="$BIN" "$BIN/go" install "golang.org/x/tools/gopls@v$GOPLS_VERSION"
fi

if ! command -v npm &>/dev/null; then
    echo "npm not found, skipping pyright."
elif [ "$(npm ls -g --prefix "$HOME/.local" --depth=0 --json 2>/dev/null \
        | jq -r '.dependencies.pyright.version // empty')" = "$PYRIGHT_VERSION" ]; then
    echo "pyright $PYRIGHT_VERSION already installed, skipping."
else
    echo "Installing pyright $PYRIGHT_VERSION..."
    # Some images ship a root-owned ~/.npm; use a cache dir we own.
    npm install -g --prefix "$HOME/.local" --cache "$HOME/.cache/npm" "pyright@$PYRIGHT_VERSION"
fi

if [ -x "$OPT/jdtls/bin/jdtls" ]; then
    echo "jdtls already installed, skipping."
else
    echo "Installing jdtls (latest snapshot)..."
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "${TMPDIR}"' EXIT
    curl -fsSL "$JDTLS_URL" -o "$TMPDIR/jdtls.tar.gz"
    mkdir -p "$OPT/jdtls"
    tar -C "$OPT/jdtls" -xzf "$TMPDIR/jdtls.tar.gz"
    ln -sfn "$OPT/jdtls/bin/jdtls" "$BIN/jdtls"
fi

echo "Language servers installed."
