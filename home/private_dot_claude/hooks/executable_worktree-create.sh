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
#   HF-1610               -> branch HF-1610,         dir <root>/HF-1610/<repo>
#   agent-a1b2c3d (etc.)  -> branch worktree-<name>, dir <root>/_scratch/<repo>-<name>
#
# An existing local branch is checked out as-is, never reset; a branch that
# exists only on origin is created from it; otherwise the branch is created
# from origin's default branch, as the built-in implementation does.
set -euo pipefail

# Everything except the final path goes to a log that is replayed on stderr
# only on failure, since stray stdout would corrupt the path Claude reads.
log=$(mktemp)
trap 'rc=$?; [ "$rc" -ne 0 ] && cat "$log" >&4; rm -f "$log"' EXIT
exec 3>&1 4>&2 >>"$log" 2>&1

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

# Resolve the main checkout, even when cwd is itself inside a worktree.
common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir) ||
	die "$cwd is not inside a git repository"
if [ "$(basename "$common")" = .git ]; then
	main=$(dirname "$common")
else
	main=$(git -C "$cwd" rev-parse --show-toplevel)
fi
repo=$(basename "$main")
root=${CLAUDE_WORKTREE_ROOT:-$HOME/src/worktrees}

# Names Claude Code generates for throwaway worktrees (mirrors its own list).
ephemeral='^(agent-a[0-9a-f]{16}|agent-a[0-9a-f]{7}|wf_[0-9a-f]{8}-[0-9a-f]{3}-[0-9]+|wf-[0-9]+|bridge-[A-Za-z0-9_]+(-[A-Za-z0-9_]+)*|job-[a-zA-Z0-9._-]{1,55}-[0-9a-f]{8}|bg-[a-zA-Z0-9._-]{1,55}-[0-9a-f]{8})$'
if [[ $name =~ $ephemeral ]]; then
	branch="worktree-$name"
	dir="$root/_scratch/$repo-$name"
else
	branch=$name
	slug=${name##*/}
	[ -n "$slug" ] || die "cannot derive a slug from name '$name'"
	dir="$root/$slug/$repo"
fi
git check-ref-format --branch "$branch" >/dev/null ||
	die "'$branch' is not a valid branch name"

# Re-entering an existing worktree of this repo is fine; anything else at
# that path is not ours to touch.
if [ -e "$dir" ]; then
	existing=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)
	[ "$existing" = "$common" ] ||
		die "$dir exists and is not a worktree of $main"
	echo "$dir" >&3
	exit 0
fi

mkdir -p "$(dirname "$dir")"

if git -C "$main" show-ref --verify --quiet "refs/heads/$branch"; then
	git -C "$main" worktree add "$dir" "$branch"
else
	if ! git -C "$main" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
		default=$(git -C "$main" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)
		default=${default#origin/}
		if [ -z "$default" ]; then
			for b in develop main master; do
				if git -C "$main" show-ref --verify --quiet "refs/remotes/origin/$b"; then
					default=$b
					break
				fi
			done
		fi
		# A failed fetch is not fatal: base on whatever origin ref we have.
		if [ -n "$default" ]; then
			timeout 120 git -C "$main" fetch --quiet origin "$default" || true
		fi
	fi
	if git -C "$main" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
		base="origin/$branch"
	elif [ -n "${default:-}" ]; then
		base="origin/$default"
	else
		base=HEAD
	fi
	git -C "$main" worktree add --no-track -b "$branch" "$dir" "$base"
fi

echo "$dir" >&3
