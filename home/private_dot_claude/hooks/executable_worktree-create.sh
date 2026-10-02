#!/usr/bin/env bash
# Claude Code WorktreeCreate hook: place every worktree Claude Code creates
# (EnterWorktree, `claude --worktree`, Agent isolation) at
#
#     ~/src/worktrees/<slug>/<repo>
#
# so the worktrees of a change spanning several repos sit side by side in one
# project directory, instead of scattered across each repo's
# .claude/worktrees/. CLAUDE_WORKTREE_ROOT overrides ~/src/worktrees.
#
# Contract (verified against Claude Code 2.1.283): stdin is JSON carrying
# `name` (the requested worktree name) and `cwd`; stdout must be exactly the
# absolute worktree path and nothing else. A non-zero exit fails creation.
# Configuring this hook replaces Claude Code's built-in `git worktree add`,
# so this script creates the branch and worktree itself.
#
# No WorktreeRemove hook is paired with this on purpose: without one, Claude
# Code falls back to its own `git worktree remove` for hook-created
# worktrees, keeping its lock-ownership and dirty-tree checks.
#
# Naming:
#   projects/<slug>       -> branch projects/<slug>, dir <root>/<slug>/<repo>
#   HF-1610 (existing)    -> branch HF-1610,         dir <root>/HF-1610/<repo>
#   anything else bare    -> branch worktree-<name>, dir <root>/_scratch/<repo>-<name>
#
# "Anything else bare" covers Claude Code's generated names (agent-a1b2c3d,
# wf-…, or a random slug when EnterWorktree is called without a name): a
# name with no "/" is a project only if that branch already exists locally
# or on origin.
#
# An existing local branch is checked out as-is, never reset; a branch that
# exists on origin (fetched fresh, so a just-created hotfix branch is seen) is
# created from it; otherwise the branch is created from origin's default
# branch, as the built-in implementation does.
set -euo pipefail

# Everything except the final path goes to a log that is replayed on stderr
# only on failure, since stray stdout would corrupt the path Claude reads.
# Fds 3 and 4 hold Claude's real stdout/stderr; every git call closes them so
# a daemonized child (auto-gc after fetch) cannot hold Claude's pipe open.
log=$(mktemp)
trap 'rc=$?; [ "$rc" -ne 0 ] && cat "$log" >&4; rm -f "$log"' EXIT
exec 3>&1 4>&2 >>"$log" 2>&1

git() {
	command git "$@" 3>&- 4>&-
}

die() {
	echo "worktree-create: $*"
	exit 1
}

command -v jq >/dev/null || die "jq is required"

input=$(cat)
name=$(jq -r '.name // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
[ -n "$name" ] || die "no worktree name on stdin"
[ -n "$cwd" ] || die "no cwd on stdin"

root=${CLAUDE_WORKTREE_ROOT:-$HOME/src/worktrees}
[[ $root == /* ]] || die "worktree root '$root' is not an absolute path"

# Resolve the main checkout, even when cwd is itself inside a worktree.
common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir) ||
	die "$cwd is not inside a git repository"
if [ "$(basename "$common")" = .git ]; then
	main=$(dirname "$common")
else
	main=$(git -C "$cwd" rev-parse --show-toplevel)
fi
repo=$(basename "$main")

has_ref() {
	git -C "$main" show-ref --verify --quiet "$1"
}

git check-ref-format --branch "$name" >/dev/null ||
	die "'$name' is not a valid branch name"

# Refresh origin's copy of the branch so one created upstream since the
# last fetch is found. A missing remote branch or a failed fetch is fine.
if ! has_ref "refs/heads/$name"; then
	timeout 120 git -C "$main" fetch --quiet origin \
		"+refs/heads/$name:refs/remotes/origin/$name" 3>&- 4>&- || true
fi

if [[ $name == */* ]] || has_ref "refs/heads/$name" ||
	has_ref "refs/remotes/origin/$name"; then
	branch=$name
	dir="$root/${name##*/}/$repo"
else
	branch="worktree-$name"
	dir="$root/_scratch/$repo-$name"
fi
git check-ref-format --branch "$branch" >/dev/null ||
	die "'$branch' is not a valid branch name"

# Re-entering an existing worktree of this repo on the same branch is fine;
# anything else at that path is not ours to touch.
if [ -e "$dir" ]; then
	existing=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)
	[ "$existing" = "$common" ] ||
		die "$dir exists and is not a worktree of $main"
	current=$(git -C "$dir" branch --show-current)
	[ "$current" = "$branch" ] ||
		die "$dir is already the worktree for branch '$current', not '$branch'"
	echo "$dir" >&3
	exit 0
fi

if has_ref "refs/heads/$branch"; then
	add=("$branch")
else
	if has_ref "refs/remotes/origin/$branch"; then
		base="origin/$branch"
	else
		default=$(git -C "$main" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)
		default=${default#origin/}
		if [ -z "$default" ]; then
			for b in develop main master; do
				if has_ref "refs/remotes/origin/$b"; then
					default=$b
					break
				fi
			done
		fi
		base=HEAD
		if [ -n "$default" ]; then
			# A failed fetch is not fatal: base on whatever origin ref we have.
			timeout 120 git -C "$main" fetch --quiet origin "$default" 3>&- 4>&- || true
			if has_ref "refs/remotes/origin/$default"; then
				base="origin/$default"
			fi
		fi
	fi
	add=(--no-track -b "$branch" "$base")
fi

parent=$(dirname "$dir")
mkdir -p "$parent"
if ! git -C "$main" worktree add "$dir" "${add[@]}"; then
	rmdir "$parent" 2>/dev/null || true
	die "git worktree add failed for $dir"
fi

echo "$dir" >&3
