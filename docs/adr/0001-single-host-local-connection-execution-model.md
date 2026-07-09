# ADR-0001: Single-host, local-connection execution model

**Date:** 2026-07-09
**Status:** accepted

## Context

This repo provisions one personal Ubuntu desktop from scratch — shell, dev
tools, dotfiles, applications. There is no fleet of machines to manage, no
remote inventory, and no need to reach hosts over SSH from a control node.
Modeling it as a multi-host, remote-inventory Ansible project would add
inventory files, connection plugins, and privilege-escalation wiring that
serve a use case this repo doesn't have.

## Decision

The playbook (`ubuntu.yml`) targets `hosts: localhost` with
`ansible_connection=local`, and `ansible.cfg` points `inventory` at a
single-entry `inventory.ini`. Every task runs directly on the machine
executing `ansible-playbook` — there is no remote host to connect to.

## Consequences

Setup stays simple: no SSH connection plugin, no per-host variable
resolution, no inventory grouping logic. Tasks that need root use `become:
true` against the local machine directly. The tradeoff is that this
structure doesn't generalize to provisioning a second machine remotely
without rework — that's an explicitly rejected use case, not an oversight.
