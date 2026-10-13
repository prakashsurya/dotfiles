#!/bin/bash
# Installs pinned developer tools into ~/.local (already on PATH, no root):
#   go          — needed by hugo (the KG site's Hextra theme is a Go module)
#               and by 09-install-language-servers (gopls)
#   hugo        — previews the knowledge-graph site; keep in step with
#               HUGO_VERSION in knowledge-graph/.github/workflows/site.yml
#   ShellCheck  — shell linting
#   shfmt       — shell formatting
# Bumping a version below changes this file's hash, so chezmoi re-runs it on
# the next apply; each tool is skipped when the pinned version is present.
set -euo pipefail

GO_VERSION="1.27.1"
HUGO_VERSION="0.167.0"
SHELLCHECK_VERSION="0.11.0"
SHFMT_VERSION="3.14.1"

BIN="$HOME/.local/bin"
OPT="$HOME/.local/opt"
mkdir -p "$BIN" "$OPT"

TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT

if [ "$("$BIN/go" env GOVERSION 2>/dev/null)" = "go$GO_VERSION" ]; then
    echo "go $GO_VERSION already installed, skipping."
else
    echo "Installing go $GO_VERSION..."
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
        -o "$TMPDIR/go.tar.gz"
    rm -rf "$OPT/go"
    tar -C "$OPT" -xzf "$TMPDIR/go.tar.gz"
    ln -sfn "$OPT/go/bin/go" "$BIN/go"
    ln -sfn "$OPT/go/bin/gofmt" "$BIN/gofmt"
fi

if "$BIN/hugo" version 2>/dev/null | grep -q "^hugo v$HUGO_VERSION-"; then
    echo "hugo $HUGO_VERSION already installed, skipping."
else
    echo "Installing hugo $HUGO_VERSION..."
    curl -fsSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz" \
        -o "$TMPDIR/hugo.tar.gz"
    tar -C "$TMPDIR" -xzf "$TMPDIR/hugo.tar.gz" hugo
    install -m 755 "$TMPDIR/hugo" "$BIN/hugo"
fi

if "$BIN/shellcheck" --version 2>/dev/null | grep -q "^version: $SHELLCHECK_VERSION$"; then
    echo "shellcheck $SHELLCHECK_VERSION already installed, skipping."
else
    echo "Installing shellcheck $SHELLCHECK_VERSION..."
    curl -fsSL "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" \
        -o "$TMPDIR/shellcheck.tar.xz"
    tar -C "$TMPDIR" -xJf "$TMPDIR/shellcheck.tar.xz"
    install -m 755 "$TMPDIR/shellcheck-v${SHELLCHECK_VERSION}/shellcheck" "$BIN/shellcheck"
fi

if [ "$("$BIN/shfmt" --version 2>/dev/null)" = "v$SHFMT_VERSION" ]; then
    echo "shfmt $SHFMT_VERSION already installed, skipping."
else
    echo "Installing shfmt $SHFMT_VERSION..."
    curl -fsSL "https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_linux_amd64" \
        -o "$TMPDIR/shfmt"
    install -m 755 "$TMPDIR/shfmt" "$BIN/shfmt"
fi

echo "Developer tools installed."
