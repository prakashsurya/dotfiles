#!/bin/bash
# Renders this repo for one machine profile into a throwaway fake $HOME and
# checks the result. Never touches the real home, chezmoi config or state.
#
#   scripts/check-profile.sh <profile>   e.g. delphix, personal
#   scripts/check-profile.sh missing     config without a profile must fail
#   scripts/check-profile.sh bogus       an unknown profile must fail
#
# Scripts and externals are rendered but never run or cloned.
set -euo pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd)
CASE=${1:?usage: $0 <profile>|missing|bogus}

# Strings that must never reach a non-Delphix machine.
DELPHIX_RE='dlpx|delphix|perforce|onelogin|dcenter|dlpxdc|PerforceAI|Atlassian|git-utils|KG_DIR|prakashsurya-claude-plugins'

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
DST=$T/home
mkdir -p "$DST"

{
    echo '[data]'
    case $CASE in
    missing) ;;
    *) echo "    profile = \"$CASE\"" ;;
    esac
    echo '    email = "someone@example.com"'
    echo '    githubUser = "someone"'
    # Delphix-only values, given only to delphix (and to missing/bogus,
    # whose apply must fail on the profile check, not on a missing key), so
    # a base template that uses one fails the other profiles' checks.
    case $CASE in
    delphix | missing | bogus)
        for k in githubToken ldapUser oneloginUser oneloginEmail dcApiHost \
                oneloginClientId oneloginClientSecret oneloginRoleArn \
                oneloginDefaultAwsAppId oneloginAwsAppId; do
            echo "    $k = \"dummy-$k\""
        done
        ;;
    esac
} >"$T/chezmoi.toml"

cz() {
    HOME=$DST chezmoi --config "$T/chezmoi.toml" --source "$REPO" \
        --destination "$DST" --persistent-state "$T/state.boltdb" \
        --no-tty "$@"
}

fail() {
    echo "FAIL [$CASE]: $*" >&2
    exit 1
}

expect_apply_failure() {
    local want=$1
    if cz apply --exclude=scripts,externals >"$T/out" 2>&1; then
        fail "apply succeeded; expected an error mentioning '$want'"
    fi
    grep -qF "$want" "$T/out" || fail "apply failed without '$want': $(cat "$T/out")"
    echo "PASS [$CASE]"
    exit 0
}

# Machines being migrated have an SSH key, which makes chezmoi render the
# key-gated parts of .chezmoiexternal.toml.tmpl before .chezmoiignore.
case $CASE in
missing | bogus)
    mkdir -p "$DST/.ssh"
    touch "$DST/.ssh/id_ed25519"
    ;;
esac

case $CASE in
missing) expect_apply_failure "profile is not set" ;;
bogus) expect_apply_failure "allowed profiles" ;;
esac

cz apply --exclude=scripts,externals >"$T/out" 2>&1 || fail "apply failed: $(cat "$T/out")"

# Render every script that would run, for grepping, into the fake home.
mapfile -t scripts < <(cz managed --include=scripts)
mkdir -p "$DST/.rendered-scripts"
for s in "${scripts[@]}"; do
    cz cat "$DST/$s" >"$DST/.rendered-scripts/$(basename "$s")" ||
        fail "could not render $s"
done
# The externals file decides what gets cloned; render it too.
cz execute-template <"$REPO/home/.chezmoiexternal.toml.tmpl" \
    >"$DST/.rendered-scripts/chezmoiexternal.toml"

has_script() {
    printf '%s\n' "${scripts[@]}" | grep -q -- "$1"
}

# Every profile must ship its CLAUDE.md profile file and import it.
[ -f "$DST/.claude/profile/$CASE.md" ] || fail ".claude/profile/$CASE.md missing"
last=$(grep -v '^[[:space:]]*$' "$DST/.claude/CLAUDE.md" | tail -n 1)
[ "$last" = "@profile/$CASE.md" ] ||
    fail ".claude/CLAUDE.md ends with '$last', not '@profile/$CASE.md'"
others=$(find "$DST/.claude/profile" -name '*.md' ! -name "$CASE.md")
[ -z "$others" ] || fail "other profiles' files installed: $others"

case $CASE in
delphix)
    for f in .onelogin-aws.config .local/bin/update-team-claude-plugins \
            .claude/conventions/dlpx-qa-gate.md \
            .claude/conventions/knowledge-graph.md \
            .claude/conventions/platform-team-claude-plugins.md; do
        [ -e "$DST/$f" ] || fail "$f missing"
    done
    for s in 07-pin-git-utils-python 12-install-team-plugins-cron \
            13-install-session-manager-plugin; do
        has_script "$s" || fail "script $s would not run"
    done
    ;;
*)
    if hits=$(grep -rIiE -l "$DELPHIX_RE" "$DST"); then
        fail "Delphix-specific content found in: $hits"
    fi
    p10="$DST/.rendered-scripts/10-install-claude-plugins.sh"
    grep -q superpowers "$p10" || fail "script 10 does not install superpowers"
    if grep -qE 'skill-creator|clangd-lsp|pyright-lsp|jdtls-lsp|gopls-lsp' "$p10"; then
        fail "script 10 installs more than superpowers"
    fi
    ;;
esac

echo "PASS [$CASE]"
