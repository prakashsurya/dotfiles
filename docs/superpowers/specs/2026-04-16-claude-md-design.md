---
title: CLAUDE.md Design for dotfiles repo
date: 2026-04-16
status: approved
---

# CLAUDE.md Design

## Goal

Give Claude Code enough context to assist with two primary tasks in this chezmoi-managed dotfiles repo:

1. Adding or modifying install scripts under `.chezmoiscripts/`
2. Editing dotfile templates (`dot_*`, `*.tmpl`)

The file should be rules-first and concise — not a second README.

## Approach

Rules-first (Approach B): open with hard constraints, follow with just enough structural context to apply them. No duplication of README prose. Chezmoi's explicit naming conventions are self-documenting; what Claude needs are the non-obvious rules.

## Hard Rules (Section 1)

Five constraints, ordered by blast radius:

1. **Platform** — Linux x86_64 only. Flag or refuse any change that introduces ARM/macOS support or breaks x86_64 assumptions.
2. **Idempotency** — Every new install script must guard with `command -v <tool>` (or equivalent) before acting. Scripts must not fail or produce duplicate side effects on re-run.
3. **Script numbering** — Scripts under `.chezmoiscripts/` are numbered to reflect dependency order, not merely append order. A tool that depends on pyenv goes after `02-install-pyenv`.
4. **Templates** — Only add `.tmpl` extension when the file actually contains a `{{ }}` expression. Do not pre-emptively templatize.
5. **Verify before done** — After any change, run `chezmoi diff` then `chezmoi apply --dry-run` before claiming the task complete.

## Chezmoi Conventions (Section 2)

Compact reference so Claude can apply the rules without inferring from filenames:

- **Source root:** `home/` (set by `.chezmoiroot`)
- **Dotfile naming:** `dot_` prefix maps to `~/.<filename>`; `.tmpl` suffix means Go template processing
- **Script prefixes:** `run_once_*` = runs once ever; `run_onchange_*` = reruns when file hash changes; `run_always_*` = reruns on every apply
- **Script ordering:** `before_` / `after_` controls order relative to dotfile sync; numeric prefix controls order within each group
- **Template variables:** defined in `home/.chezmoi.toml.tmpl` (prompted on first run) and `home/.chezmoidata/packages.toml`
- **SSH key gate:** `{{ if stat (joinPath .chezmoi.homeDir ".ssh" "id_ed25519") }}` — used to guard scripts that need private repo access

## Key Files (Section 3)

Minimal orientation map:

```
home/.chezmoi.toml.tmpl                       # template variables / prompts
home/.chezmoidata/packages.toml               # apt package list
home/.chezmoiexternal.toml.tmpl               # external repos (nvim, tmux, git-utils)
home/.chezmoiscripts/                         # install scripts (numbered by dependency order)
home/dot_config/fish/config.fish.tmpl         # fish shell config
home/dot_gitconfig.tmpl                       # git config
home/dot_ssh/config.tmpl                      # SSH config
```

## Out of Scope

- Workflow prose (covered by README)
- Bootstrap instructions (covered by README)
- Architecture explanation (derivable from chezmoi conventions + filenames)
