# ADR-0011: GPG key handling via get_url + gpg --dearmor, not apt_key

**Date:** 2026-07-09
**Status:** accepted

## Context

Third-party apt repositories (Slack, Signal, Brave, VS Code) each publish a
GPG signing key, but not consistently in the same format — some publish
ASCII-armored keys, others publish binary keyrings directly. The playbook
previously wrote ASCII-armored keys straight into binary `signed-by`
keyrings, which apt silently rejects, breaking signature verification for
Slack and Signal. The obvious alternative, Ansible's `apt_key` module, is
deprecated upstream and slated for removal.

## Decision

`roles/repo_packages/tasks/install.yml` downloads each vendor's key with
`ansible.builtin.get_url`. If `item.armored` is true (set per-entry in
`group_vars/all.yml`'s `repo_packages` list), the key is fetched to a temp
path and run through `gpg --dearmor` (guarded by `creates:`) into
`/usr/share/keyrings/{{ item.name }}-archive-keyring.gpg`; otherwise the
binary key is written directly to that same keyring path. The apt source
line then references that keyring via `signed-by=`.

## Consequences

Repo-based installs work correctly regardless of which key format a vendor
publishes, and the playbook has no dependency on the deprecated `apt_key`
module. The tradeoff is one extra per-vendor flag (`armored`) that must be
set correctly in `group_vars/all.yml` when onboarding a new repo-based app —
getting it wrong reproduces the exact bug this decision fixed.
