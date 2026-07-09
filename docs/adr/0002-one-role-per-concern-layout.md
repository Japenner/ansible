# ADR-0002: One-role-per-concern layout under roles/

**Date:** 2026-07-09
**Status:** accepted

## Context

The playbook originally lived as a flat `tasks/ubuntu/*.yml` tree wired
together with linear `include_tasks` calls. As the number of concerns grew
(SSH, fonts, core packages, Docker, zsh, mise, dotfiles, personal projects,
deb packages, repo packages), the flat structure made it hard to see task
boundaries, reuse per-concern variables, or run/test one concern in
isolation. PR #12 restructured the whole playbook around Ansible roles as
part of a broader modernization pass.

## Decision

Each concern gets its own role under `roles/<name>/`, with its tasks in
`roles/<name>/tasks/main.yml` (or split further into files like
`install.yml` and pulled in via `include_tasks`, e.g. `deb_packages` and
`repo_packages` looping over per-item installs). `ubuntu.yml` composes the
whole machine by listing roles in order under a single `roles:` key.

## Consequences

Each concern is now independently readable, taggable, and testable, and
adding a new concern means adding a new role rather than threading another
include into a growing flat list. The cost is Ansible's standard
role-directory boilerplate (`tasks/`, and only the subdirectories a role
actually needs) for every concern, even small ones — accepted as worthwhile
given how many concerns this playbook already covers.
