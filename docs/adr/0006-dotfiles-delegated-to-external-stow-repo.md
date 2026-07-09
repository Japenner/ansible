# ADR-0006: Dotfiles delegated to an external stow-managed repo

**Date:** 2026-07-09
**Status:** accepted

## Context

Dotfiles (shell config, editor config, etc.) change far more often than this
provisioning playbook, and are already independently maintained in a
separate personal repo (`Japenner/.dotfiles`) using GNU Stow to symlink files
into place. Reimplementing that symlink logic as Ansible tasks here would
duplicate a working setup and create two sources of truth for the same
files.

## Decision

The `dotfiles` role only clones `git@github.com:{{ github_account
}}/.dotfiles.git` to `/home/{{ user }}/.dotfiles` and runs that repo's own
`.local/bin/dotfiles/setup.zsh`, which performs the actual `stow` calls. This
playbook does not manage individual dotfile symlinks itself.

## Consequences

Dotfile changes only need to happen in one place (the `.dotfiles` repo), and
this playbook stays a thin bootstrap step rather than a second dotfiles
manager. The tradeoff is a hard dependency on that external repo's own
script working correctly — a break in `.dotfiles`' `setup.zsh` is invisible
to this repo's own tests and lint.
