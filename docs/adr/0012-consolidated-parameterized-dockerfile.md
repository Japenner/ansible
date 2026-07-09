# ADR-0012: Consolidated, parameterized Dockerfile for test images

**Date:** 2026-07-09
**Status:** accepted

## Context

The playbook previously shipped three separate Dockerfiles for its test
harness, all pinned to the EOL `ubuntu:focal` base image, each with a `CMD`
that ran `ansible-playbook ... local.yml` — a playbook file that no longer
existed after `ubuntu.yml` became the entry point. None of the three could
actually run the current playbook without editing the Dockerfile itself.

## Decision

Replace all three with a single `Dockerfile`, parameterized by build args:
`UBUNTU_VERSION` (default `24.04`) for the base image, and `INSTALL_NVIM`
(default `false`) to optionally add the Neovim PPA and package. The image
creates a `jacob` user at uid/gid 1000 (removing Ubuntu's built-in `ubuntu`
user first to avoid a collision) and its `CMD` runs
`ansible-playbook ${TAGS} ubuntu.yml` against the actual current playbook
entry point.

## Consequences

One Dockerfile to maintain instead of three, always targeting a supported
Ubuntu base and the playbook file that actually exists. Building the
`nvim-computer` variant is a build-arg away instead of a separate file to
keep in sync. The tradeoff is that both variants now share one build
context, so a change intended for one image (e.g. an nvim-specific tweak)
must be gated behind `INSTALL_NVIM` rather than isolated in its own file.
