# Ansible Desktop Setup

This repository contains a collection of Ansible playbooks and shell scripts to automate setting up a new desktop environment on Ubuntu. It includes installing necessary packages, configuring development tools, and setting up essential applications.

## Prerequisites

- Ubuntu-based system
- `sudo` privileges
- Internet connection

## Installation

To install Ansible, run the following script:

```bash
./install
```

Alternatively, you can install Ansible manually:

```bash
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

## Running Ansible Playbooks

To execute an Ansible playbook, run the following command:

```bash
./run <playbook-file>
```

Example:

```bash
./run local
```

This will prompt for the Ansible Vault password and system password for privileged operations.

## Automated Ansible Pull

To pull the latest Ansible configurations from the repository and apply them automatically, run:

```bash
./ansible-run
```

## Docker Setup

To build Docker images for setting up a new machine, run:

```bash
./build-dockers
```

This will build:

- `new-computer`: General desktop setup container
- `nvim-computer`: Container with Neovim setup

## Cleaning Up the Environment

To remove installed packages and configurations, run:

```bash
./clean-env
```

This script removes:

- Node.js, npm, and related packages
- Zsh and Oh-My-Zsh
- Docker and its configurations
- GitHub CLI (`gh`)
- Slack, Obsidian, and Lazydocker
- Essential and productivity packages (e.g., `tmux`, `fzf`, `ripgrep`)
- Brave Browser
- Cleans up system residual files

## Directory Structure

```plaintext
    .
    ├── ansible-run
    ├── build-dockers
    ├── clean-env
    ├── install
    ├── run
    ├── Dockerfile
    ├── local.yml
    ├── tasks/
    │   ├── asdf-setup.yml
    │   ├── brave-setup.yml
    │   ├── core-setup.yml
    │   ├── docker-setup.yml
    │   ├── dotfiles.yml
    │   ├── git-setup.yml
    │   ├── npm-packages.yml
    │   ├── nvim-setup.yml
    │   ├── personal-projects.yml
    │   ├── productivity-tools.yml
    │   ├── slack-setup.yml
    │   ├── ssh-setup.yml
    │   ├── zsh-setup.yml
    ├── ubuntu.yml
    └── TODO.md
```

## Ansible Playbooks

### `local.yml`

This is the main playbook that sets up the local machine. It includes:

- SSH key setup
- Git configuration
- Core package installation
- Docker setup
- Zsh setup
- ASDF version manager installation
- NPM global packages installation
- Slack installation
- Personal projects setup
- Neovim installation
- Brave browser installation
- Dotfiles setup
- Productivity tools installation

### Additional Playbooks

Located under `tasks/ubuntu/`, these include configurations for:

- Various software installations (Discord, Obsidian, Rustdesk, Signal, etc.)
- Fonts and UI customization
- Repository and package management

## Contribution

Feel free to fork and modify this setup according to your requirements. Pull requests are welcome!

## License

This project is licensed under the MIT License.
