# Ansible Desktop Setup

Ansible roles to provision a fresh Ubuntu desktop from scratch — packages, shell, dev tools, dotfiles, and applications.

## Overview

Running the playbook on a bare Ubuntu machine installs and configures everything: SSH keys, ZSH with Oh-My-Zsh, [mise](https://mise.jdx.dev) (Ruby, Node, Python, Go), Docker, FiraCode Nerd Font, dotfiles via stow, and a suite of desktop applications. Work is split into one role per concern under `roles/`, with all data (package lists, repos, versions) in `group_vars/all.yml`. The playbook is idempotent — re-running it skips what's already in place.

## Prerequisites

- Ubuntu 22.04+
- `sudo` access
- `make` and `git`
- SSH private key committed (vault-encrypted) at `.ssh/id_ed25519`, copied to `~/.ssh/` by the playbook
- The Ansible vault password — needed to decrypt the SSH key at provision time

> `auth_codes/` holds additional vault-encrypted secrets (API keys, tokens). They are an encrypted store kept alongside the repo; the playbook itself does not consume them.

## Provisioning

### Bootstrap from scratch

On a fresh machine with no Ansible installed:

```bash
curl -fsSL https://raw.githubusercontent.com/Japenner/ansible/master/ansible-run | bash
```

This installs Ansible via the official PPA, then runs `ansible-pull` to clone the repo and execute `ubuntu.yml`.

### Run locally

With the repo cloned:

```bash
make install   # install Ansible via the official PPA (Ubuntu)
make run       # provision this machine
```

`make run` calls `ansible-playbook --ask-vault-pass --ask-become-pass ubuntu.yml` — you'll be prompted for the vault password and your sudo password.

Run `make` (or `make help`) to list all targets:

| Target | What it does |
|---|---|
| `make install` | Install Ansible via the official PPA |
| `make run` | Provision this machine (prompts for vault + sudo passwords) |
| `make check` | Syntax-check the playbook |
| `make lint` | Run `ansible-lint` and `yamllint` |
| `make test` | Build the test image, then syntax-check inside it |
| `make docker` | Build the Docker test images |
| `make clean` | Remove installed packages and configs |

### Running a subset

Every role is tagged, so you can provision one concern at a time:

```bash
ansible-playbook --ask-vault-pass --ask-become-pass --tags ssh ubuntu.yml
```

Available tags: `ssh`, `git`, `font`, `core`, `productivity`, `docker`, `lazydocker`, `zsh`, `mise` (alias `asdf`), `dotfiles`, `stow`, `projects`, `install`, `repo`.

## What Gets Installed

| Category | Details |
|---|---|
| Shell | ZSH, Oh-My-Zsh, powerlevel10k, zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting |
| Dev tools | mise (Ruby, Node.js, Python, Go), Docker CE + Lazydocker, GitHub CLI |
| Fonts | FiraCode Nerd Font v3.2.1 |
| Dotfiles | Cloned from `github.com/Japenner/.dotfiles`, applied via `bin/setup.zsh` |
| Core packages | build-essential, cmake, clangd, ripgrep, fzf, tmux, picom, stow, and more |
| Desktop apps | Brave Browser, Slack, Signal, Discord, Obsidian, RustDesk |
| Personal repos | Cloned or updated under `~/repos/personal/` |

## Development / Testing

`ansible-lint`, `yamllint`, and a `--syntax-check` run on every push and pull request via GitHub Actions (`.github/workflows/ci.yml`). Run the same checks locally:

```bash
make check   # syntax check (no extra tooling needed)
make lint    # ansible-lint + yamllint (must be installed)
```

A Docker image lets you exercise the playbook without a real machine:

```bash
make docker  # builds new-computer and nvim-computer images
make test    # builds the image, then syntax-checks inside it
```

`make docker` builds two tags from the single `Dockerfile`:
- `new-computer` — general desktop setup
- `nvim-computer` — adds Neovim (`--build-arg INSTALL_NVIM=true`)

Tasks that decrypt secrets need a vault password at run time:

```bash
docker run --rm -e TAGS="--ask-vault-pass" -it new-computer
```

## Teardown

To undo what the playbook installed:

```bash
make clean
```

Purges packages, removes configs, and cleans up APT sources.

## Project Structure

```
.
├── ubuntu.yml              # Play — lists the roles to run, in order
├── ansible.cfg             # Ansible config (interpreter, inventory, roles_path)
├── inventory.ini           # localhost with a local connection
├── group_vars/
│   └── all.yml             # All data: package lists, repos, versions, users
├── roles/                  # One role per concern
│   ├── ssh/                # SSH keys + GitHub known_hosts
│   ├── git/                # Global git config
│   ├── fonts/              # FiraCode Nerd Font
│   ├── core/               # Core + productivity apt packages (+ NVIDIA)
│   ├── docker/             # Docker CE + Lazydocker
│   ├── zsh/                # ZSH, Oh-My-Zsh, plugins, themes
│   ├── mise/               # mise version manager + global languages
│   ├── dotfiles/           # Clone + stow ~/.dotfiles
│   ├── personal_projects/  # Clone/update repos under ~/repos/personal
│   ├── deb_packages/       # .deb installs (RustDesk, Discord, Obsidian)
│   └── repo_packages/      # APT-repo installs (Slack, Signal, Brave)
├── Makefile                # install / run / check / lint / test / docker / clean
├── Dockerfile              # Test harness image (nvim variant via build arg)
├── ansible-run             # Remote curl|bash bootstrap (ansible-pull)
├── build-dockers           # Builds the Docker test images
├── clean-env               # Teardown script
├── .github/workflows/ci.yml
├── .ssh/                   # Vault-encrypted SSH keys
└── auth_codes/             # Vault-encrypted secret store
```
