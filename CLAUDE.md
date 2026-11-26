# CLAUDE.md

## Hard Rules

1. **Platform — Linux x86_64 only.** Refuse or flag any change that introduces ARM/macOS support or breaks x86_64 assumptions.
2. **Idempotency** — Every new install script must guard with `command -v <tool>` (or equivalent) before acting. Scripts must not fail or repeat side effects on re-run.
3. **Script numbering** — Scripts under `home/.chezmoiscripts/` are numbered to reflect dependency order, not append order. A tool that depends on pyenv belongs after `02-install-pyenv`; a tool with no dependencies can go at the end.
4. **Templates** — Only add `.tmpl` extension when the file actually contains a `{{ }}` expression. Do not pre-emptively templatize plain files.
5. **Verify before done** — After any change, run `chezmoi diff` (preview) then `chezmoi apply --dry-run` before claiming the task complete, and `scripts/check-profile.sh <name>` for every profile in `profileNames`.
6. **Profiles** — Nothing in the base layer may assume a particular environment. Anything environment-specific is gated on `.profile`: whole files and scripts in `home/.chezmoiignore`, parts of a file with `{{ if eq .profile "<name>" }}`, and list-shaped differences (apt packages, Claude marketplaces, plugins, permissions) in `home/.chezmoidata/profiles.toml`. Claude rules for one profile go in `home/private_dot_claude/profile/<name>.md`. README "Adding a profile" is the checklist.

## Chezmoi Conventions

- **Source root:** `home/` (set by `.chezmoiroot`)
- **Dotfile naming:** `dot_` prefix → `~/.<name>` in `$HOME`; `.tmpl` suffix → processed as Go template
- **Script prefixes:** `run_once_*` runs once ever; `run_onchange_*` reruns when file hash changes; `run_always_*` reruns on every apply
- **Script ordering:** `before_` / `after_` controls position relative to dotfile sync; numeric prefix controls order within each group
- **Template variables:** defined in `home/.chezmoi.toml.tmpl` (prompted on first run, including `profile`), `home/.chezmoidata/packages.toml` and `home/.chezmoidata/profiles.toml`
- **SSH key gate:** `{{ if stat (joinPath .chezmoi.homeDir ".ssh" "id_ed25519") }}` — guards scripts that require private repo access

## Key Files

```
home/.chezmoi.toml.tmpl                    # template variables / prompts (add new vars here)
home/.chezmoidata/packages.toml            # apt package list
home/.chezmoidata/profiles.toml            # profile names + per-profile lists (plugins, marketplaces, ...)
home/.chezmoiexternal.toml.tmpl           # external repos (nvim, tmux, git-utils)
home/.chezmoiscripts/                      # install scripts (numbered by dependency order)
home/dot_config/fish/private_config.fish.tmpl # fish shell config
home/dot_gitconfig.tmpl                   # git config
home/private_dot_ssh/config.tmpl                  # SSH config
home/private_dot_claude/                   # → ~/.claude (private_ ⇒ mode 0700)
home/private_dot_claude/profile/           # per-profile Claude rules, imported by CLAUDE.md
scripts/check-profile.sh                   # render + check one profile in a temp $HOME
```

- **`private_` attribute:** `private_<name>` targets mode `0700`/`0600`. Required
  for `~/.claude` (dir) and `~/.claude/settings.json` (mode `600`) — without it
  chezmoi targets the umask default and the first apply widens them.
- **`modify_` scripts:** `modify_<name>` is an executable that receives the
  target's current contents on stdin and writes the desired contents to stdout.
  Use it when another tool co-owns the file (see
  `home/private_dot_claude/modify_private_settings.json.tmpl`). Per Hard Rule 4
  it takes a `.tmpl` suffix only because it contains `{{ }}` expressions.
