# ADR-0013: CI runs static checks only, not a full playbook execution

**Date:** 2026-07-09
**Status:** accepted

## Context

This playbook provisions a real desktop — installing packages, writing SSH
keys, changing the default shell, cloning external repos. Running it
end-to-end in a GitHub Actions runner would mean either running destructive
system changes against the CI VM or standing up and maintaining a
provisioning-safe container environment in CI itself, on every push and PR,
just to get a signal that's already covered locally by `make test`/`make
docker`.

## Decision

`.github/workflows/ci.yml` installs `ansible`, `ansible-lint`, and
`yamllint`, then runs `yamllint .`, `ansible-lint`, and `ansible-playbook
--syntax-check ubuntu.yml` — static analysis and syntax verification only.
It does not build the Docker test images or execute the playbook against
any container or host.

## Consequences

CI stays fast, has no side effects, and needs no privileged setup, but a
green CI run only proves the playbook is syntactically valid and lint-clean
— it does not prove any role's logic actually works. Anything touching role
behavior must still be verified locally via `make test`/`make docker`
before being trusted; CLAUDE.md's testing guidance calls this out explicitly
so it isn't assumed away by "CI is green."
