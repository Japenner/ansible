# Ansible Desktop Setup

Ansible playbooks to provision a fresh Ubuntu desktop from scratch — packages, shell, dev tools, dotfiles, and applications.

## Overview

Running `ansible-run` on a bare Ubuntu machine installs and configures everything: SSH keys, ZSH with Oh-My-Zsh, ASDF (Ruby, Node, Python, Go), Docker, FiraCode Nerd Font, dotfiles via stow, and a suite of desktop applications. The playbook is idempotent — re-running it skips what's already in place.

## Prerequisites

- Ubuntu 22.04+
- `sudo` access
- SSH private key at `.ssh/id_ed25519` in the repo root (copied to `~/.ssh/` by the playbook)
- Ansible vault password (required for tasks that decrypt `auth_codes/` secrets)

## Provisioning

### Bootstrap from scratch

On a fresh machine with no Ansible installed:

```bash
curl -fsSL https://raw.githubusercontent.com/Japenner/ansible/master/ansible-run | bash
```

This installs Ansible via the official PPA, then runs `ansible-pull` to clone the repo and execute `ubuntu.yml`.

### Run locally

If Ansible is already installed and the repo is cloned:

```bash
# Install Ansible (if needed)
./install

# Run the full playbook
./run ubuntu
```

`./run` wraps `ansible-playbook --ask-vault-pass --ask-become-pass` — you'll be prompted for the vault password and your sudo password.

To run a subset of tasks, pass a tag directly to `ansible-playbook`:

```bash
ansible-playbook --ask-vault-pass --ask-become-pass --tags ssh ubuntu.yml
```

Available tags: `ssh`, `zsh`, `asdf`, `core`, `productivity`, `dotfiles`, `font`, `projects`, `repo`, `install`.

## What Gets Installed

| Category | Details |
|---|---|
| Shell | ZSH, Oh-My-Zsh, powerlevel10k, zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting |
| Dev tools | ASDF (Ruby, Node.js, Python, Go), Docker CE, GitHub CLI |
| Fonts | FiraCode Nerd Font v3.2.1 |
| Dotfiles | Cloned from `github.com/Japenner/.dotfiles`, applied via `bin/setup.zsh` |
| Core packages | build-essential, cmake, clangd, ripgrep, fzf, tmux, picom, stow, and more |
| Desktop apps | Brave Browser, Slack, Signal, Discord, Obsidian, RustDesk |
| Personal repos | Cloned or updated under `~/repos/personal/` |

## Development / Testing

Docker images let you test the playbook without a real machine:

```bash
./build-dockers
```

Builds two images:
- `new-computer` — general desktop setup
- `nvim-computer` — Neovim-focused setup

## Teardown

To undo everything the playbook installed:

```bash
./clean-env
```

Purges packages, removes configs, and cleans up APT sources.

## Project Structure

```
.
├── ubuntu.yml           # Main playbook — vars, task order, package lists
├── ansible.cfg          # Ansible config (interpreter, inventory, host key checking)
├── ansible-run          # Bootstrap script for fresh machines
├── install              # Installs Ansible via PPA
├── run                  # Wraps ansible-playbook with vault/become prompts
├── build-dockers        # Builds Docker test images
├── clean-env            # Removes all installed packages and configs
├── .ssh/                # SSH keys copied to ~/.ssh/ during provisioning
├── auth_codes/          # Vault-encrypted secrets (API keys, etc.)
└── tasks/ubuntu/        # Task files included by ubuntu.yml
    ├── ssh-setup.yml
    ├── git-setup.yml
    ├── core-setup.yml
    ├── docker-setup.yml
    ├── zsh-setup.yml
    ├── asdf-setup.yml
    ├── fonts-setup.yml
    ├── dotfiles-setup.yml
    ├── personal-projects.yml
    ├── deb-package-setup.yml
    └── repo-package-setup.yml
```
