# ADR-0008: Dual package-install mechanism — repo_packages vs deb_packages

**Date:** 2026-07-09
**Status:** accepted

## Context

Desktop applications this playbook installs come from vendors with two
different distribution models: some (Slack, Signal, Brave, VS Code) publish
a signed apt repository that can be added once and kept updated via normal
`apt` upgrades; others (RustDesk, Discord, Obsidian) only publish standalone
`.deb` release assets with no apt repo at all. A single install mechanism
can't cleanly cover both without either faking a repo for `.deb`-only apps
or losing apt-managed upgrades for the ones that do publish a repo.

## Decision

Two distinct data-driven mechanisms live in `group_vars/all.yml` and are
handled by dedicated roles: `repo_packages` adds a signed apt repository
(GPG key fetched via `get_url`, dearmored if `armored: true`, then installed
via `apt`) for vendors that publish one; `deb_packages` downloads a specific
`.deb` file by URL (with pinned `version`/`arch`) and installs it directly.
Adding a new app means picking the mechanism based on what the vendor
publishes, not conflating the two.

## Consequences

Each app is installed the way its vendor actually intended, and apt-repo
apps get proper upgrade tracking through normal `apt` operations while
`.deb`-only apps are pinned and idempotency-checked via `dpkg-query`. The
cost is two parallel code paths and two data shapes in `group_vars/all.yml`
to keep straight when adding a new package.
