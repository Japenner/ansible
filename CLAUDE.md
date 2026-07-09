# CLAUDE.md

This is a personal Ansible playbook that provisions a fresh Ubuntu desktop from
scratch: shell, dev tools, dotfiles, and applications. It's public on GitHub
(`Japenner/ansible`) but treated as a personal, single-maintainer setup — not
a library or a project soliciting outside contributions.

## Stack / Architecture

- **Ansible** (`ansible-core`, installed via `ppa:ansible/ansible` or `pip`),
  targeting **Ubuntu 22.04+**, `hosts: localhost` with `ansible_connection=local`.
  This is not a remote-inventory setup — there is no fleet of machines here.
- One role per concern under `roles/`. Every role's tasks live in
  `roles/<name>/tasks/main.yml` (or split into `install.yml` for per-item
  loops via `include_tasks`, see `deb_packages` and `repo_packages`).
- All data — package lists, pinned versions, repo URLs, plugin lists — lives
  in `group_vars/all.yml`. Roles read from it; they don't hardcode data
  inline. If you're adding a new package/tool/repo, it goes in
  `group_vars/all.yml`, not directly in a role's tasks.
- Every task carries a `tags:` entry matching its role (see `ubuntu.yml` and
  the README's tag list) so a single concern can be provisioned in isolation:
  `ansible-playbook --tags zsh ubuntu.yml`.
- Idempotency is enforced per-task: `creates:` on shell/command tasks,
  `stat` checks before clone/copy where the target might already exist
  (see `roles/zsh/tasks/main.yml`'s `.zshrc` guard,
  `roles/personal_projects/tasks/main.yml`'s existence check). Don't add a
  task that re-does work unconditionally on every run.
- Secrets (`.ssh/id_ed25519*`, everything under `auth_codes/`) are committed
  **ansible-vault encrypted** because the repo is public. Never write a
  secret to any tracked file in plaintext, even temporarily, even in a
  throwaway commit that gets amended later — git history is public too.
- Testing has two tiers: `make check`/`make lint` (syntax + static lint, no
  execution) and `make test`/`make docker` (builds the `new-computer` /
  `nvim-computer` Docker images from the repo's own `Dockerfile` and can
  actually run the playbook inside a container). CI
  (`.github/workflows/ci.yml`) currently only does the first tier — it does
  not run the playbook. Don't assume CI passing means the playbook actually
  works; verify with a Docker run for anything touching role logic.

## Execution boundary

Never run the playbook for real (`make run`, or `ansible-playbook` without
`--syntax-check`) against an actual host — this machine included — without
asking first. Docker-based testing (`make test`, `docker build`/`docker run`
against the images this repo builds) is fine to do freely; that's an
isolated container, not a real machine.

## Forbidden approaches

- Don't reintroduce a dependency on the `community.general` collection. It
  was removed when the `git` role was deleted (git config is now owned
  entirely by the dotfiles repo, not this one) — there's no remaining use
  for it here.
- Don't use `ansible.builtin.shell`/`command` where a builtin module already
  covers the same operation (`apt`, `file`, `get_url`, `git`, `unarchive`,
  etc.). The existing roles are consistent about this; match it.
- Don't add a new secret-bearing file without vault-encrypting it before the
  first commit. Check with `head -c 30 <file>` for the `$ANSIBLE_VAULT`
  header before staging anything that looks credential-shaped.

## Domain glossary

- **vault** — `ansible-vault`-encrypted files (`$ANSIBLE_VAULT;1.1;AES256`
  header). Applies to `.ssh/id_ed25519*` and everything in `auth_codes/`.
- **`auth_codes/`** — an encrypted secret store (API keys, tokens, backup
  codes) kept alongside the repo for safekeeping. The playbook itself does
  not read or consume these files; they're just vault-protected storage.
- **stow** — GNU Stow, used by the external dotfiles repo
  (`github.com/Japenner/.dotfiles`) to symlink dotfiles into place. This
  repo's `dotfiles` role clones that repo and invokes its
  `.local/bin/dotfiles/setup.zsh`, which runs the actual `stow` calls.
- **mise** — the version manager used for language runtimes (Ruby, Node,
  Python, Go), replacing asdf. The `mise` role still carries the `asdf` tag
  as an alias for muscle-memory compatibility.
- **`repo_packages`** vs **`deb_packages`** — two different install
  mechanisms. `repo_packages` adds a signed apt repository and installs via
  `apt` (Slack, Signal, Brave, VS Code). `deb_packages` downloads a specific
  `.deb` file by URL and installs it directly (RustDesk, Discord, Obsidian).
  Don't conflate them when adding a new app — pick based on whether the
  vendor publishes an apt repo or just `.deb` release assets.

## Known gaps (see TODO.md and open GitHub issues for the full backlog)

- `mise` and `repo_packages` hardcode `arch=amd64` in their apt source lines
  instead of deriving it like `docker`'s role does — breaks on non-amd64
  hosts (issue #16).
- The `signal-desktop` `repo_packages` entry has the wrong apt suite
  (`stable` instead of `xenial`) — issue #15.
- The one-line `curl | bash` bootstrap (`ansible-run`) doesn't supply a vault
  password, so it currently fails on the `ssh` role — issue #13.

Don't silently "fix" these as a side effect of unrelated work — they're
tracked issues with their own acceptance criteria. If a task requires
touching the same lines, say so explicitly rather than bundling the fix in.

## Output shape

- Implement only what is explicitly asked. Do not refactor adjacent code
  unless instructed.
- Do not use placeholder comments like `# TODO` or `# implement this`. Write
  the real implementation or ask.
- Do not present stub implementations as complete. If a task is unfinished,
  say so explicitly.
- When uncertain about scope or approach, ask before proceeding.

## Key Decisions

- **Single-host, local-connection execution model**: The playbook (`ubuntu.yml`) targets `hosts: localhost` with `ansible_connection=local`, and `ansible.cfg` points `inventory` at a single-entry `inventory.ini`.
- **One-role-per-concern layout under roles/**: Each concern gets its own role under `roles/<name>/`, with its tasks in `roles/<name>/tasks/main.yml` (or split further into files like `install.yml` and pulled in via `include_tasks`, e.g. `deb_packages` and `repo_packages` looping over per-item installs).
- **Centralized data in group_vars/all.yml**: All such data lives in `group_vars/all.yml` (package lists per category, `mise_global_tools`, `zsh_plugins`, `project_repos`, `deb_packages`, `repo_packages`, etc.).
- **Per-role tags convention**: Every task carries a `tags:` entry matching its role name (see `ubuntu.yml` and the README's tag list), so a single concern can be provisioned in isolation with `ansible-playbook --tags zsh ubuntu.yml`.
- **Drop the community.general collection dependency**: The `git` role was deleted, and with it the only reason this repo depended on `community.general`.
- **Dotfiles delegated to an external stow-managed repo**: The `dotfiles` role only clones `git@github.com:{{ github_account }}/.dotfiles.git` to `/home/{{ user }}/.dotfiles` and runs that repo's own `.local/bin/dotfiles/setup.zsh`, which performs the actual `stow` calls.
- **mise replaces asdf as the language version manager**: Adopt `mise` (<https://mise.jdx.dev>) as the version manager, installed via its own signed apt repository (GPG key dearmored into `/etc/apt/keyrings/mise-archive-keyring.gpg`) rather than a git clone.
- **Dual package-install mechanism — repo_packages vs deb_packages**: Two distinct data-driven mechanisms live in `group_vars/all.yml` and are handled by dedicated roles: `repo_packages` adds a signed apt repository for vendors that publish one; `deb_packages` downloads a specific `.deb` file by URL and installs it directly.
- **FQCN module style enforced throughout**: All tasks use fully-qualified collection names — `ansible.builtin.*` for core modules and `ansible.posix.*` for the one module that needs it (`authorized_key`).
- **Makefile as the single entry point**: A single `Makefile` is the entry point for every operation: `install`, `run`, `check`, `lint`, `docker`, `test`, and `clean`.
- **GPG key handling via get_url + gpg --dearmor, not apt_key**: `roles/repo_packages/tasks/install.yml` downloads each vendor's key with `ansible.builtin.get_url`, dearmoring it first when the vendor publishes an ASCII-armored key.
- **Consolidated, parameterized Dockerfile for test images**: A single `Dockerfile`, parameterized by build args (`UBUNTU_VERSION` default `24.04`, `INSTALL_NVIM` default `false`), replaces three separate Dockerfiles pinned to EOL `focal`.

## Session handoff

Generated 2026-07-09.
