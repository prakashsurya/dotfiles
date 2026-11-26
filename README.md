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
- Machine profile (see [Profiles](#profiles)); the default is `delphix` on
  a Delphix internal-claude image and `personal` anywhere else
- GitHub personal access token
- `delphix` only: OneLogin client_id / client_secret, role ARN, AWS app IDs (x2)
- any other profile: the git email

## Profiles

Each machine has one profile, stored as `profile` in
`~/.config/chezmoi/chezmoi.toml`. Every machine gets the base layer; the
profile adds the rest.

| Layer | What it adds |
|---|---|
| base | fish, tmux, neovim, gh, pyenv, dev tools, language servers, Claude Code with `superpowers`, llm-wiki, the worktree hook, the general `~/.claude/CLAUDE.md` |
| `delphix` | OneLogin, the `[dlpx]` git section, DCenter SSH hosts, git-utils, Delphix fish PATH and env, the Delphix and personal Claude marketplaces and plugins, the team-plugin update job, session-manager-plugin, the Delphix repo conventions, `~/.claude/profile/delphix.md` |
| `personal` | `~/.claude/profile/personal.md` only |

Where profiles differ:

- `home/.chezmoidata/profiles.toml` — the profile names, plus list-shaped
  differences: extra apt packages, Claude marketplaces, plugins and
  permissions.
- `home/.chezmoiignore` — files and scripts a profile doesn't get.
- `{{ if eq .profile "..." }}` blocks inside templates.
- `home/private_dot_claude/profile/<name>.md` — the profile's Claude rules,
  imported by `~/.claude/CLAUDE.md`.

**Existing machines** set up before profiles existed: run `chezmoi init`
once. It asks only for the profile and keeps every other answer. Until
then `chezmoi apply` refuses to run.

**Changing a machine's profile:** edit `profile` in
`~/.config/chezmoi/chezmoi.toml`, run `chezmoi init` (it asks for anything
the new profile needs), then `chezmoi apply`. Files only the old profile
had are left in place; delete them by hand.

**Adding a profile:**

1. Add its name to `profileNames` in `home/.chezmoidata/profiles.toml`
   and to the profile prompt's choices in `home/.chezmoi.toml.tmpl`.
2. Add `[profiles.<name>]` to `profiles.toml` if it needs extra packages,
   marketplaces, plugins or permissions.
3. Create `home/private_dot_claude/profile/<name>.md`.
4. Gate any files or template blocks only it should get.
5. Run `scripts/check-profile.sh <name>` and the existing profiles'
   checks.

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

Steps marked *delphix* apply only to that profile.

These are intentionally not automated:

1. **SSH key**: Generate a key, add it to GitHub, then re-apply:
   ```bash
   ssh-keygen -t ed25519
   # Add the public key to GitHub (Settings → SSH keys) and authorized_keys
   chezmoi apply
   ```
   The second `chezmoi apply` detects `~/.ssh/id_ed25519` and, gated on that
   key, does the private-repo work: clones `prakashsurya/llm-wiki` to
   `~/llm-wiki` and, on *delphix*, clones `delphix/git-utils` (then pins
   Python 3.10.7 via pyenv) and installs the Claude plugins from the private
   marketplace. None of those happen on the first apply.
2. **Set fish as default shell**: `chsh -s $(which fish)`
3. **Disable SSH password login**: On *delphix*, two files need updating — the
   main config and the Delphix-specific drop-in which re-enables
   keyboard-interactive auth (elsewhere, only the first `sed`):
   ```bash
   sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
   sudo sed -i -e 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' \
               -e 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' \
               /etc/ssh/sshd_config.d/9-delphix.conf
   sudo systemctl restart ssh
   ```
   Ensure your SSH key is in `~/.ssh/authorized_keys` before doing this. Verify with:
   ```bash
   sudo sshd -T | grep -E 'passwordauthentication|kbdinteractiveauthentication'
   ```
4. **Neovim plugins**: Launch `nvim` — kickstart.nvim uses lazy.nvim which auto-installs plugins on first run (the nvim config is pulled unmodified from upstream via chezmoiexternal)
5. **Jenkins tokens** (*delphix*): Add manually after setup, to
   `~/.gitconfig.local`:
   ```bash
   git config --file ~/.gitconfig.local dlpx.jenkins-token-selfservice-jenkins-delphix-com <token>
   git config --file ~/.gitconfig.local dlpx.jenkins-token-masking-jenkins-delphix-com <token>
   git config --file ~/.gitconfig.local dlpx.jenkins-token-saas-jenkins-eng-tools-general-aws-delphixcloud-com <token>
   git config --file ~/.gitconfig.local dlpx.jenkins-token-ops-jenkins-delphix-com <token>
   git config --file ~/.gitconfig.local dlpx.jenkins-token-selfservice-jenkins-eng-tools-prd-aws-delphixcloud-com <token>
   git config --file ~/.gitconfig.local dlpx.jenkins-token-ops-jenkins-eng-tools-prd-aws-delphixcloud-com <token>
   ```

## Notes

- **Architecture**: The neovim bootstrap script downloads a Linux x86_64 binary
  and the fish config hardcodes the corresponding PATH entry. ARM is not supported.
- **git-utils Python version**: The `07-pin-git-utils-python` chezmoi script pins
  Python 3.10.7. If git-utils changes its requirement, update `PYTHON_VERSION` in
  `home/.chezmoiscripts/run_always_after_07-pin-git-utils-python.sh`.
- **Bundle access**: `/nas` comes pre-mounted on these VM images (systemd `nas.mount`
  unit + `support-tools` group, baked into the image). No dotfiles-managed setup is
  needed — this superseded the old `support-tools-ssh` flow (AWS SSM jump host +
  `granted` role assumption), which has been removed from these dotfiles.

## Repository structure

```
dotfiles/
├── README.md
├── install.sh                       # bootstrap wrapper (installs chezmoi, inits or applies)
├── scripts/check-profile.sh         # renders one profile into a temp $HOME and checks it
├── .chezmoiroot                     # points chezmoi source root to home/
└── home/
    ├── .chezmoi.toml.tmpl           # machine config (prompts on first run)
    ├── .chezmoidata/packages.toml   # apt package list
    ├── .chezmoidata/profiles.toml   # profile names and per-profile lists
    ├── .chezmoiexternal.toml.tmpl   # external git repos (nvim, tmux; git-utils + llm-wiki when SSH key exists)
    ├── .chezmoiignore               # never-track guard for ~/.claude runtime state and secrets
    ├── .chezmoiscripts/
    │   ├── run_onchange_before_01-install-packages.sh.tmpl
    │   ├── run_onchange_after_02-install-pyenv.sh
    │   ├── run_onchange_after_04-install-neovim.sh
    │   ├── run_onchange_after_05-install-gh.sh
    │   ├── run_onchange_after_06-install-claude.sh
    │   ├── run_onchange_after_10-install-claude-plugins.sh.tmpl
    │   └── run_always_after_07-pin-git-utils-python.sh
    ├── dot_gitconfig.tmpl           # → ~/.gitconfig
    ├── dot_tmux.conf                # → ~/.tmux.conf
    ├── dot_onelogin-aws.config.tmpl # → ~/.onelogin-aws.config
    ├── dot_config/fish/config.fish.tmpl # → ~/.config/fish/config.fish
    ├── dot_config/go/env.tmpl       # → ~/.config/go/env (GOPATH → ~/.local/share/go)
    ├── private_dot_ssh/config.tmpl  # → ~/.ssh/config (private_ ⇒ mode 0700)
    └── private_dot_claude/          # → ~/.claude  (private_ ⇒ mode 0700)
        ├── CLAUDE.md.tmpl           # → ~/.claude/CLAUDE.md (general rules; imports the profile file)
        ├── profile/<name>.md        # → ~/.claude/profile/<name>.md (this machine's profile only)
        ├── modify_private_settings.json.tmpl # jq-merges dotfiles-owned keys into ~/.claude/settings.json
        └── conventions/.gitkeep     # → ~/.claude/conventions/ (repo-specific working rules)
```

`.chezmoiignore` is a defensive block, not a deployment filter: nothing in it
is in the source tree today. It exists so a future `chezmoi add ~/.claude`
cannot sweep credentials, session state, the voice corpus, or handoff notes
into this repo — which is **public**.
