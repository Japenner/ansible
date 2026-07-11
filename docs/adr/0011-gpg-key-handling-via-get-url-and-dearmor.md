# ADR-0011: GPG key handling via get_url + gpg --dearmor, not apt_key

**Date:** 2026-07-09
**Status:** amended — see Update below

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

## Update (2026-07-11)

PR #28 (issue #17) migrated `repo_packages` from `apt_repository` + this
manual `get_url`/`gpg --dearmor` dance to `ansible.builtin.deb822_repository`,
which fetches and converts the key itself via `signed_by: {{ item.gpg_key_url
}}`. The `armored` flag and the manual dearmor step no longer exist for
`repo_packages`; `group_vars/all.yml` entries just set `gpg_key_url` and let
the module handle the rest. The `docker` role isn't on `deb822_repository`
and still does its own manual `get_url` + `gpg --dearmor` exactly as
described above — the original decision stands there unchanged.
