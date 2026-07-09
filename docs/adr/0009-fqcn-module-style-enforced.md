# ADR-0009: FQCN module style enforced throughout

**Date:** 2026-07-09
**Status:** accepted

## Context

Ansible allows referencing modules by short name (`copy`, `apt`, `file`) or
by fully-qualified collection name (`ansible.builtin.copy`). Before the PR
#12 modernization pass, the playbook mixed both styles across task files,
which made it unclear which collection a given module actually came from
and complicated linting under `ansible-lint`'s stricter `production` profile
(which flags bare module names).

## Decision

All tasks use fully-qualified collection names — `ansible.builtin.*` for
core modules (`apt`, `file`, `get_url`, `git`, `unarchive`, `copy`, `user`,
`known_hosts`, etc.) and `ansible.posix.*` for the one module that needs it
(`authorized_key`). Raw `ansible.builtin.shell`/`command` are used only when
no builtin module already covers the operation.

## Consequences

Task files are unambiguous about which collection provides each module, and
`ansible-lint`'s `production` profile passes cleanly. New tasks must match
this convention — reintroducing a bare module name is a lint regression, not
just a style nit.
