# ADR-0004: Per-role tags convention

**Date:** 2026-07-09
**Status:** accepted

## Context

A full provisioning run installs everything from SSH keys to desktop
applications, but in practice it's often useful to re-run or debug just one
concern — for example, re-applying zsh plugin changes without reinstalling
every apt package. Without tagging, isolating a single concern would require
commenting out roles in `ubuntu.yml` or running a separate playbook.

## Decision

Every task carries a `tags:` entry matching its role name (see `ubuntu.yml`
and the README's tag list), so a single concern can be provisioned in
isolation with `ansible-playbook --tags zsh ubuntu.yml`. The apt-cache-update
pre-task is tagged `always` so it runs regardless of which tag is selected.

## Consequences

Any role can be re-run or debugged independently without touching the rest
of the playbook, which matters for a desktop that's already provisioned and
only needs incremental updates. The cost is a small amount of tagging
discipline — every new task added to a role must carry the matching tag, or
it silently falls outside `--tags <role>` runs.
