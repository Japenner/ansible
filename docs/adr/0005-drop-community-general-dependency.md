# ADR-0005: Drop the community.general collection dependency

**Date:** 2026-07-09
**Status:** accepted

## Context

The playbook previously had a `git` role that used modules from the
`community.general` collection to manage git configuration on the
provisioned machine. Git config for this user is now owned entirely by the
external dotfiles repo (`github.com/Japenner/.dotfiles`, applied via GNU
Stow), which makes an Ansible-managed git config role redundant — it would
just be fighting stow for ownership of the same files.

## Decision

The `git` role was deleted, and with it the only reason this repo depended
on `community.general`. The collection is not reintroduced for any other
purpose; git config management stays entirely in the dotfiles repo.

## Consequences

One fewer external collection to install and keep compatible with
`ansible-core` version bumps, and no ambiguity about which system owns git
config (dotfiles repo, not this playbook). Any future task that might reach
for a `community.general` module should instead check whether an
`ansible.builtin` module or an existing role already covers it, per this
repo's forbidden-approaches guidance.
