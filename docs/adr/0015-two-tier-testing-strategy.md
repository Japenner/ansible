# ADR-0015: Two-tier testing strategy — static checks vs. execution

**Date:** 2026-07-09
**Status:** accepted

## Context

Verifying an Ansible playbook can mean very different things: confirming it
parses and lints cleanly, or confirming it actually behaves correctly when
run. The former is fast and side-effect-free enough to run on every push;
the latter requires an actual (or containerized) target machine and takes
meaningfully longer. Conflating the two — or only ever doing the fast one —
either slows down every CI run or lets real behavioral regressions slip
through as long as syntax stays valid.

## Decision

Testing is split into two explicit tiers, each with its own Makefile
targets: `make check`/`make lint` (`--syntax-check`, `ansible-lint`,
`yamllint` — no execution) and `make test`/`make docker` (builds the
`new-computer`/`nvim-computer` Docker images from the repo's own
`Dockerfile` and can actually run the playbook inside a container). CI
currently wires up only the first tier.

## Consequences

Fast static feedback is available on every push via CI, while real
behavioral verification is available on demand via Docker without needing a
disposable real machine. The tradeoff, made explicit in CLAUDE.md, is that a
green CI run says nothing about whether role logic actually works — anyone
changing role behavior must run the Docker tier locally rather than trusting
CI alone.
