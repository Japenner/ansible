# ADR-0007: mise replaces asdf as the language version manager

**Date:** 2026-07-09
**Status:** accepted

## Context

The playbook previously installed language runtimes (Ruby, Node, Python, Go)
via asdf, cloned from its git HEAD. asdf's v0.16 release was a full Go
rewrite that dropped `asdf.sh` (nothing left to source into the shell) and
removed the `plugin-add`/`global` subcommands the old tasks relied on. Any
fresh provision after that release broke outright (PR #12).

## Decision

Adopt `mise` (https://mise.jdx.dev) as the version manager, installed via its
own signed apt repository (GPG key dearmored into
`/etc/apt/keyrings/mise-archive-keyring.gpg`) rather than a git clone. Global
tool versions are set with `mise use --global <item>` looping over
`mise_global_tools` in `group_vars/all.yml`. The `mise` role keeps the `asdf`
tag as an alias so existing muscle-memory (`--tags asdf`) still works.

## Consequences

Runtime installation is no longer at the mercy of upstream asdf's breaking
rewrites, and installing via a signed apt repo matches the pattern already
used for `repo_packages`. The cost is a one-time migration: any workflow or
doc referencing asdf directly (rather than the `asdf` tag alias) needed
updating, and `mise`'s apt source hardcodes `arch=amd64` (tracked separately
as issue #16, not fixed by this decision).
