# CLAUDE.md

## Hard Rules

1. **Platform — Linux x86_64 only.** Refuse or flag any change that introduces ARM/macOS support or breaks x86_64 assumptions.
2. **Idempotency** — Every new install script must guard with `command -v <tool>` (or equivalent) before acting. Scripts must not fail or repeat side effects on re-run.
3. **Script numbering** — Scripts under `home/.chezmoiscripts/` are numbered to reflect dependency order, not append order. A tool that depends on pyenv belongs after `02-install-pyenv`; a tool with no dependencies can go at the end.
4. **Templates** — Only add `.tmpl` extension when the file actually contains a `{{ }}` expression. Do not pre-emptively templatize plain files.
5. **Verify before done** — After any change, run `chezmoi diff` (preview) then `chezmoi apply --dry-run` before claiming the task complete.

## Chezmoi Conventions

- **Source root:** `home/` (set by `.chezmoiroot`)
- **Dotfile naming:** `dot_` prefix → `~/.<name>` in `$HOME`; `.tmpl` suffix → processed as Go template
- **Script prefixes:** `run_once_*` runs once ever; `run_onchange_*` reruns when file hash changes; `run_always_*` reruns on every apply
- **Script ordering:** `before_` / `after_` controls position relative to dotfile sync; numeric prefix controls order within each group
- **Template variables:** defined in `home/.chezmoi.toml.tmpl` (prompted on first run) and `home/.chezmoidata/packages.toml`
- **SSH key gate:** `{{ if stat (joinPath .chezmoi.homeDir ".ssh" "id_ed25519") }}` — guards scripts that require private repo access

## Key Files

```
home/.chezmoi.toml.tmpl                    # template variables / prompts (add new vars here)
home/.chezmoidata/packages.toml            # apt package list
home/.chezmoiexternal.toml.tmpl           # external repos (nvim, tmux, git-utils)
home/.chezmoiscripts/                      # install scripts (numbered by dependency order)
home/dot_config/fish/config.fish.tmpl     # fish shell config
home/dot_gitconfig.tmpl                   # git config
home/dot_ssh/config.tmpl                  # SSH config
```
