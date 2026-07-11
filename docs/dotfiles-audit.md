# .dotfiles audit — 2026-07-10

Review of `github.com/Japenner/.dotfiles` (the repo this playbook's `dotfiles`
role clones and stows) for conventions worth porting into this repo. See
issue #11.

## Findings

### 1. No shellcheck coverage for this repo's shell scripts

`.dotfiles` lints its shell scripts with a checked-in `.shellcheckrc`
(`disable=SC1071`). This repo has three root-level shell scripts
(`ansible-run`, `build-dockers`, `clean-env`) that aren't covered by
`make lint` or CI at all — only the Ansible/YAML side (`ansible-lint`,
`yamllint`) is linted.

**Verdict:** actionable. Turned into a follow-up issue, labeled `up next`:
see #41.

### 2. CI and ADRs

`.dotfiles` has no GitHub Actions CI and no ADR log. This repo already has
both (`.github/workflows/ci.yml`, `docs/adr/`) and is ahead here — nothing to
port.

### 3. `CONTEXT.md` domain glossary + routing table

`.dotfiles` carries a `CONTEXT.md` with a terms glossary and a
task-type-to-docs routing table, read by its Claude agent skills. This
repo's `CLAUDE.md` already contains an equivalent domain glossary and a "Key
Decisions" section. A separate routing table adds little here: this repo has
one real workflow shape (add a package/tool to `group_vars/all.yml`, or
touch a role), not the range of task types (`write feature`, `fix bug`,
`author a command`, etc.) that justifies `.dotfiles`' table.

**Verdict:** not applicable — already covered by existing `CLAUDE.md`
content, and the task-type diversity that motivates it in `.dotfiles` isn't
present here.

### 4. README structure

Both repos organize their README similarly (prerequisites, install/run
steps, a command/target table, project structure). `.dotfiles` additionally
has explicit "Contributing" and "License" sections; this repo's README omits
both, though `CLAUDE.md` already states the "public but not soliciting
contributions" stance.

**Verdict:** not applicable — low value for a single-maintainer repo where
the stance is already documented in `CLAUDE.md`.

## Out of scope

No code changes were made under this audit. Idea #1 above was filed as its
own follow-up issue rather than implemented here, per the parent issue's
acceptance criteria.
