# ADR-0010: Makefile as the single entry point

**Date:** 2026-07-09
**Status:** accepted

## Context

The playbook previously exposed separate `install`, `run`, and `clean-env`
shell scripts as its interface, with no single place listing what operations
were available or how to invoke lint/test/syntax-check. As tooling grew
(Docker test images, CI-equivalent lint/syntax checks), remembering and
discovering the right script or raw `ansible-playbook`/`ansible-lint`
invocation became its own source of friction (PR #12).

## Decision

A single `Makefile` is the entry point for every operation: `install`
(install Ansible via the official PPA), `run` (provision this machine),
`check` (syntax-check), `lint` (`ansible-lint` + `yamllint`), `docker`
(build test images via `build-dockers`), `test` (build then syntax-check
inside the container), and `clean` (`clean-env`). `make help` (the default
target) lists all of them from inline `##` comments.

## Consequences

There's one discoverable, self-documenting interface for every operation
instead of remembering separate script names or raw tool invocations, and CI
can call the same `make` targets a developer would run locally. The
`install`/`run`/`clean-env` scripts still exist underneath but are no longer
meant to be invoked directly — new operations should be added as Makefile
targets, not new standalone scripts.
