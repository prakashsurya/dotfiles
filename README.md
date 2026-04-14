# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

**Platform:** Linux x86_64 only.

## Bootstrap a new machine

```bash
# Step 1: install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# Step 2: init and apply (prompts will appear)
~/.local/bin/chezmoi init --apply github.com/prakashsurya/dotfiles
```

The two-step form is required — piping directly from `curl` replaces stdin,
causing chezmoi to skip prompts and produce incomplete configuration.

Alternatively, if you have already cloned the repo:

```bash
./install.sh
```

This installs chezmoi (if missing), runs `chezmoi init --apply` on first run,
or `chezmoi apply` on subsequent runs. Can be re-run safely at any time.

You will be prompted for:
- GitHub personal access token
- OneLogin client_id / client_secret
- OneLogin role ARN
- OneLogin AWS app IDs (x2)

## Day-to-day usage

```bash
chezmoi edit ~/.gitconfig     # edit a dotfile in your $EDITOR
chezmoi diff                  # preview pending changes
chezmoi apply                 # apply changes to $HOME
chezmoi update                # pull latest from GitHub + apply
```

To add a new dotfile:

```bash
chezmoi add ~/.some-config-file         # plain file
chezmoi add --template ~/.some-file     # as a template (for machine-specific values)
```

Then commit from the source directory:

```bash
cd $(chezmoi source-path)
git add -A && git commit -m "feat: add ..." && git push
```

## After bootstrapping — manual steps

These are intentionally not automated:

1. **SSH key + git-utils**: Generate a key, add it to GitHub, then re-apply:
   ```bash
   ssh-keygen -t ed25519
   # Add the public key to GitHub (Settings → SSH keys) and authorized_keys
   chezmoi apply
   ```
   The second `chezmoi apply` detects `~/.ssh/id_ed25519` and automatically
   clones the private `delphix/git-utils` repo, then pins Python 3.10.7 via pyenv.
2. **Set fish as default shell**: `chsh -s $(which fish)`
3. **Neovim plugins**: Launch `nvim` — kickstart.nvim uses lazy.nvim which auto-installs plugins on first run (the nvim config is pulled unmodified from upstream via chezmoiexternal)
4. **Support tools server access**: The `support-tools-ssh` script is not managed by
   these dotfiles. Follow the internal setup guide to install it and its dependencies
   (granted, AWS SSM plugin, assume profile):
   [support-tools server access instructions](https://perforce.atlassian.net/wiki/spaces/DLXSUP/pages/1558225912/support-tools+server+access+instructions)

5. **Jenkins tokens**: Add manually after setup:
   ```bash
   git config --global dlpx.jenkins-token-selfservice-jenkins-delphix-com <token>
   git config --global dlpx.jenkins-token-masking-jenkins-delphix-com <token>
   git config --global dlpx.jenkins-token-saas-jenkins-eng-tools-general-aws-delphixcloud-com <token>
   git config --global dlpx.jenkins-token-ops-jenkins-delphix-com <token>
   git config --global dlpx.jenkins-token-selfservice-jenkins-eng-tools-prd-aws-delphixcloud-com <token>
   git config --global dlpx.jenkins-token-ops-jenkins-eng-tools-prd-aws-delphixcloud-com <token>
   ```

## Notes

- **Architecture**: The neovim bootstrap script downloads a Linux x86_64 binary
  and the fish config hardcodes the corresponding PATH entry. ARM is not supported.
- **git-utils Python version**: The `07-pin-git-utils-python` chezmoi script pins
  Python 3.10.7. If git-utils changes its requirement, update `PYTHON_VERSION` in
  `home/.chezmoiscripts/run_onchange_after_07-pin-git-utils-python.sh`.

## Repository structure

```
dotfiles/
├── README.md
├── install.sh                       # bootstrap wrapper (installs chezmoi, inits or applies)
├── .chezmoiroot                     # points chezmoi source root to home/
└── home/
    ├── .chezmoi.toml.tmpl           # machine config (prompts on first run)
    ├── .chezmoidata/packages.toml   # apt package list
    ├── .chezmoiexternal.toml.tmpl   # external git repos (nvim, tmux, git-utils when SSH key exists)
    ├── .chezmoiignore               # chezmoi ignore patterns (currently empty)
    ├── .chezmoiscripts/
    │   ├── run_onchange_before_01-install-packages.sh.tmpl
    │   ├── run_onchange_after_02-install-pyenv.sh
    │   ├── run_onchange_after_04-install-neovim.sh
    │   ├── run_onchange_after_05-install-gh.sh
    │   ├── run_onchange_after_06-install-claude.sh
    │   └── run_onchange_after_07-pin-git-utils-python.sh
    ├── dot_gitconfig.tmpl           # → ~/.gitconfig
    ├── dot_tmux.conf                # → ~/.tmux.conf
    ├── dot_onelogin-aws.config.tmpl # → ~/.onelogin-aws.config
    ├── dot_config/fish/config.fish.tmpl # → ~/.config/fish/config.fish
    └── dot_ssh/config.tmpl          # → ~/.ssh/config
```
