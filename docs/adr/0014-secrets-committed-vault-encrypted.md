# ADR-0014: Secrets are committed to the repo only ansible-vault encrypted

**Date:** 2026-07-09
**Status:** accepted

## Context

This repo is public on GitHub (`Japenner/ansible`) but needs to carry
genuinely sensitive material to provision a machine end-to-end — an SSH
private key the `ssh` role installs, and an `auth_codes/` store of API keys
and backup codes kept alongside the repo for safekeeping. A public repo
means anything committed in plaintext is permanently exposed, even if
later removed — git history doesn't forget.

## Decision

Every secret-bearing file (`.ssh/id_ed25519*`, everything under
`auth_codes/`) is committed only after being encrypted with `ansible-vault`
(recognizable by the `$ANSIBLE_VAULT;1.1;AES256` header). Nothing
secret-shaped is ever staged in plaintext, even temporarily or in a
throwaway commit meant to be amended later, since the repo's public history
would still carry it.

## Consequences

The repo can safely stay public while still carrying real credentials the
playbook needs (the SSH key) or wants to store (`auth_codes/`). The
tradeoff is that every operation touching these files — provisioning,
editing, testing — needs the vault password, including `make run` and any
Docker run that decrypts the SSH key at runtime. New secret-bearing files
must be checked for the vault header before the first commit, not after.
