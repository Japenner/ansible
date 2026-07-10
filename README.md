# Ansible Desktop Setup

Ansible roles to provision a fresh Ubuntu desktop from scratch — packages, shell, dev tools, dotfiles, and applications.

## Overview

Running the playbook on a bare Ubuntu machine installs and configures everything: SSH keys, ZSH with Oh-My-Zsh, [mise](https://mise.jdx.dev) (Ruby, Node, Python, Go), Docker, FiraCode Nerd Font, dotfiles via stow, and a suite of desktop applications. Work is split into one role per concern under `roles/`, with all data (package lists, repos, versions) in `group_vars/all.yml`. The playbook is idempotent — re-running it skips what's already in place.

## Prerequisites

- Ubuntu 22.04+ on amd64 (see [Known Limitations](#known-limitations) for other architectures)
- `sudo` access
- `make` and `git`
- SSH private key committed (vault-encrypted) at `.ssh/id_ed25519`, copied to `~/.ssh/` by the playbook
- The Ansible vault password — needed to decrypt the SSH key at provision time
- The `ansible.posix` collection (for `authorized_key`), declared in `requirements.yml` and installed by `make install` via `ansible-galaxy collection install -r requirements.yml`

> `auth_codes/` holds additional vault-encrypted secrets (API keys, tokens). They are an encrypted store kept alongside the repo; the playbook itself does not consume them.

## Provisioning

### Bootstrap from scratch

On a fresh machine with no Ansible installed:

```bash
curl -fsSL https://raw.githubusercontent.com/Japenner/ansible/main/ansible-run | bash
```

This installs Ansible via the official PPA, then runs `ansible-pull --ask-vault-pass` to clone the repo and execute `ubuntu.yml`. You'll be prompted for the vault password before any role runs — the `ssh` role's vault-encrypted key copy needs it to succeed.

### Run locally

With the repo cloned:

```bash
make install   # install Ansible via the official PPA (Ubuntu) and required collections
make run       # provision this machine
```

`make run` calls `ansible-playbook --ask-vault-pass --ask-become-pass ubuntu.yml` — you'll be prompted for the vault password and your sudo password.

Run `make` (or `make help`) to list all targets:

| Target | What it does |
| --- | --- |
| `make install` | Install Ansible via the official PPA and collections from `requirements.yml` |
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

Available tags: `ssh`, `font`, `core`, `productivity`, `docker`, `lazydocker`, `zsh`, `mise` (alias `asdf`), `dotfiles`, `stow`, `projects`, `install`, `repo`.

## What Gets Installed

| Category | Details |
| --- | --- |
| Shell | ZSH, Oh-My-Zsh, zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting |
| Dev tools | mise (Ruby, Node.js, Python, Go), Docker CE + Lazydocker, GitHub CLI |
| Fonts | FiraCode Nerd Font v3.2.1 |
| Dotfiles | Cloned from `github.com/Japenner/.dotfiles`, applied via `.local/bin/dotfiles/setup.zsh` — including git config (identity, includeIf work/personal switching) via its own stow-managed `.gitconfig` |
| Core packages | build-essential, cmake, clangd, ripgrep, fzf, tmux, picom, stow, and more |
| Desktop apps | Brave Browser, Slack, Signal, Discord, Obsidian, RustDesk |
| Personal repos | Cloned or updated under `~/repos/personal/` |

## Development / Testing

`ansible-lint`, `yamllint`, and a `--syntax-check` run on every push and pull request via GitHub Actions (`.github/workflows/ci.yml`). A second job builds the `new-computer` test image and actually runs the playbook inside it, scoped to `--tags core,fonts,zsh,mise,deb_packages,repo_packages` — the subset that needs neither a vault password nor SSH access. `ssh`, `dotfiles`, and `personal_projects` are excluded from CI for that reason and are only exercised locally; `docker` is also excluded because starting the dockerd service needs a privileged container ([#33](https://github.com/Japenner/ansible/issues/33)). Run the same checks locally:

```bash
make check   # syntax check (no extra tooling needed)
make lint    # ansible-lint + yamllint (must be installed)
```

### Tooling versions

CI installs `ansible`, `ansible-lint`, and `yamllint` from `requirements-dev.txt`, which pins each to an exact version (currently `ansible-core` 2.18.x, via `ansible==11.9.0`). This is deliberate: unpinned tooling can change lint/CI behavior on any run with no corresponding code change, making failures hard to bisect.

`make install` pulls Ansible from `ppa:ansible/ansible` (Ubuntu's PPA, not pip) and doesn't pin an exact version — it should stay within the same `ansible-core` 2.18.x range as `requirements-dev.txt` so local and CI runs don't drift apart. If the PPA's current release moves to a different major/minor, bump `requirements-dev.txt` to match rather than letting the two diverge silently.

To bump these pins deliberately: update the versions in `requirements-dev.txt` in their own commit, run `make check` and `make lint` locally against the new versions, and update the `ansible-core` range noted above if it changed.

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

## Known Limitations

- **Non-amd64 hosts aren't fully supported yet.** `mise` and `repo_packages` hardcode `arch=amd64` in their apt source lines (unlike `docker`'s role, which derives the arch correctly), so package installs there fail on arm64 ([#16](https://github.com/Japenner/ansible/issues/16)).
- **The `signal-desktop` repo entry has the wrong apt suite** (`stable` instead of `xenial`), so it currently fails with "does not have a Release file" ([#15](https://github.com/Japenner/ansible/issues/15)).

See the [open issues](https://github.com/Japenner/ansible/issues) for the full cleanup/modernization backlog.

## Teardown

To undo what the playbook installed:

```bash
make clean
```

Purges packages, removes configs, and cleans up APT sources.

## Project Structure

```text
.
├── ubuntu.yml              # Play — lists the roles to run, in order
├── ansible.cfg             # Ansible config (interpreter, inventory, roles_path)
├── inventory.ini           # localhost with a local connection
├── group_vars/
│   └── all.yml             # All data: package lists, repos, versions, users
├── roles/                  # One role per concern
│   ├── ssh/                # SSH keys + GitHub known_hosts
│   ├── fonts/              # FiraCode Nerd Font
│   ├── core/               # Core + productivity apt packages (+ NVIDIA)
│   ├── docker/             # Docker CE + Lazydocker
│   ├── zsh/                # ZSH, Oh-My-Zsh, plugins (git config now owned entirely by dotfiles)
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

## Contributing

Branch off `main`. GitHub Actions runs `yamllint`, `ansible-lint`, `ansible-playbook --syntax-check`, and a real containerized run of the playbook (scoped to the safe tags listed above) on every push and pull request — run `make lint` and `make check` locally before opening a PR. If your change touches a role outside that safe tag set (`ssh`, `dotfiles`, `personal_projects`, `docker`), exercise it locally with `docker run --rm -e TAGS="--ask-vault-pass --tags <role>" -it new-computer` since CI can't run it.

## License

No license specified. This is a personal machine-provisioning setup, kept public for reference — not intended for reuse as-is.
