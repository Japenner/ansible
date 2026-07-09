# TODO

## Bugs

- **`signal-desktop` repo entry uses the wrong apt suite.** `group_vars/all.yml` sets
  `build: stable` for `signal-desktop`, but Signal's apt repo only ever published
  the `xenial` suite — `https://updates.signal.org/desktop/apt/dists/stable/Release`
  404s, `.../dists/xenial/Release` exists (verified directly). This is why
  `repo_packages` fails with "does not have a Release file." Fix: change `build` to
  `xenial` for that entry.
- **`arch=amd64` is hardcoded in two roles**, unlike `docker`'s role which correctly
  uses `$(dpkg --print-architecture)`. `roles/mise/tasks/main.yml` and
  `roles/repo_packages/tasks/install.yml` both bake `arch=amd64` into the apt source
  line, so on any non-amd64 host (verified on arm64: VS Code failed with "No package
  matching 'code' is available") those repos silently stop offering a matching
  candidate. Should derive the arch dynamically instead.
- Lazydocker's download URL in `roles/docker/tasks/main.yml` is also hardcoded to
  `_Linux_x86_64.tar.gz` — same class of bug as above, no arm64 path.

## Modernization

- `ansible.builtin.apt_repository` is deprecated (shows up as a live deprecation
  warning on every run) and is slated for removal in ansible-core 2.25. Used in
  `roles/mise/tasks/main.yml` and `roles/repo_packages/tasks/install.yml`. Migrate
  both to `ansible.builtin.deb822_repository` before it breaks outright.
- No `requirements.yml`. `roles/ssh/tasks/main.yml` uses `ansible.posix.authorized_key`,
  which isn't a builtin — a bare `pip install ansible-core` (vs. the full `ansible`
  bundle) won't have it. Add a `requirements.yml` declaring `ansible.posix` and wire
  `ansible-galaxy collection install -r requirements.yml` into `make install`/CI.
- `ansible`/`ansible-lint`/`yamllint` are unpinned everywhere (CI's `pip install`, and
  `make install`'s PPA). Worth pinning given the apt_repository deprecation above is a
  live time bomb tied to the ansible-core version.

## Streamlining

- CI (`.github/workflows/ci.yml`) only lints and syntax-checks — it never actually
  runs the playbook. Both bugs above (signal-desktop suite, arm64 arch) would have
  been caught by an actual run. Consider adding a job that does what `make test`
  already does locally (build the Docker image, run the playbook for real) so drift
  like this gets caught in CI instead of by hand.

## Version bumps (pinned, checked against current upstream releases)

- Lazydocker: pinned `v0.23.3` → latest `v0.25.2` (`roles/docker/tasks/main.yml`)
- RustDesk: pinned `1.3.5` → latest `1.4.9` (`group_vars/all.yml` → `deb_packages`)
- Obsidian: pinned `1.7.7` → latest `v1.12.7` (`group_vars/all.yml` → `deb_packages`)
- FiraCode Nerd Font: pinned `v3.2.1` → latest `v3.4.0` (`roles/fonts/tasks/main.yml`)

## Minor / cosmetic

- `.gitignore` still excludes `*.retry` — vestigial from older Ansible defaults;
  modern ansible-core doesn't generate retry files unless `retry_files_enabled` is
  explicitly set. Harmless, just dead weight.
- `ansible.cfg`'s `host_key_checking = False` has no real effect since the only
  inventory entry is `ansible_connection=local` — worth a comment explaining why it's
  there (if anything still needs it) or removing it for clarity.

## Already tracked elsewhere

- Vault password support for the `ansible-pull` bootstrap — [#13](https://github.com/Japenner/ansible/issues/13)
- README/CI referencing a nonexistent `master` branch — [#14](https://github.com/Japenner/ansible/issues/14)
