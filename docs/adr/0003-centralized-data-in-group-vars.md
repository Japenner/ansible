# ADR-0003: Centralized data in group_vars/all.yml

**Date:** 2026-07-09
**Status:** accepted

## Context

Package lists, pinned versions, repo URLs, and plugin lists are the parts of
this playbook that change most often — a new deb package, a bumped font
version, a new zsh plugin. Before the PR #12 restructuring, this kind of
data was scattered inline across task files, making it easy to miss an
occurrence when updating a version or package list, and coupling data
changes to task-file edits.

## Decision

All such data lives in `group_vars/all.yml` (package lists per category,
`mise_global_tools`, `zsh_plugins`, `project_repos`, `deb_packages`,
`repo_packages`, etc.). Roles read from these variables via loops; they
never hardcode package names, URLs, or versions directly in `tasks/*.yml`.

## Consequences

Adding or updating a package, plugin, or pinned version is a one-line change
in `group_vars/all.yml`, without touching role logic. Roles stay generic
loop-and-install logic rather than data holders. The tradeoff is an extra
indirection when reading a role's tasks in isolation — you have to cross-
reference `group_vars/all.yml` to see what's actually installed.
