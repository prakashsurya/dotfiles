#!/bin/bash -eux

mkdir -p "$HOME/.tmux/plugins"
cd "$HOME/.tmux/plugins"

function install_plugin() {
	local plugin="$1"
	[[ -d "$plugin" ]] || git clone "https://github.com/tmux-plugins/$plugin"
}

while read -r plugin; do
	install_plugin "$plugin"
done <<-EOF
	tmux-pain-control
	tmux-sensible
EOF
