# Decisions — 2026-07 redesign

Record of the decisions that turned the old step-by-step README collection
(`setup-workstation`) into the interactive `setup-linux` script.

## Why an interactive script (and why not before)

The original repo deliberately avoided a single Bash script: too many
environment variations (personal vs. work machine, Linux vs. WSL) and a
monolithic script breaks midway over time, leaving the setup half-done.

What changed:

- The personal vs. work software split no longer exists in practice.
- Secrets and identity moved to the `dotfiles` project (fixed SSH keys,
  sops+age), removing the "generate and register keys" step entirely.
- An **interactive menu with per-item selection and per-item failure
  isolation** gives the balance the old README format was compensating for:
  automation, but with control and resilience.

## Structural decisions

- **Single menu, no machine profiles.** Items are picked manually on each
  run; environment-specific items (WSL, Ubuntu-only packages) appear only
  when the environment matches. Everything starts unchecked.
- **Repo renamed to `setup-linux`** — it now also covers the Debian home
  server, so "workstation" was wrong. The empty `setup-home-server` repo is
  deleted; this repo absorbs its (never written) scope.
- **Old numbered READMEs (01–05) removed** — replaced by the script plus this
  `docs/` folder.
- **Public repo, anonymous HTTPS bootstrap** — see `bootstrap-flow.md`.

## Item-by-item triage of the old steps

| Old step | Destination |
|---|---|
| 01 curl/git/openssh-client | Kept — "Básico" block |
| 02 SSH keygen + registering keys on GitHub/Azure | **Removed** — fixed keys live encrypted in `dotfiles`, already registered on services |
| 02 `files/config` (SSH) and `.gitconfig*` | **Removed** — `dotfiles` versions newer copies (ed25519, 3 identities) |
| 02 repo folders | Kept — "Sistema" block; now `~/github/henricos`, `~/github/jarbas-caramello`, `~/azuregit` (no more `/mnt/c/...`, no `~/github/techne`) |
| 02 difftool (Meld/WinMerge) | **Removed** — no longer used |
| 03 apt repos + upgrade | Kept — "Repositórios" block, per-repo selection |
| 04 apps | Kept — "Apps" block, per-app selection |
| 05 java-switch aliases | Moved to `dotfiles` |
| 05 git prompt + `.env` loading in bashrc | **Removed** — `dotfiles` `shell/bashrc.sh` owns shell config |
| 05 `host_edge` update-alternatives | **Replaced** by `wslu`/`wslview` (WSL block); `BROWSER=wslview` in `dotfiles` |
| 05 `.hushlogin` | Moved to `dotfiles` |
| (new) openssh-server, Docker Engine | Added — "Servidor" block for the Debian home server |

## Known fixes over the old commands

- `gpg --dearmor` now uses `--yes` (the old commands hang on re-run).
- `ttf-mscorefonts-installer` EULA is preseeded via debconf (the old command
  blocked on an ncurses dialog).
- Microsoft prod repo URL uses the *upstream* numeric version from
  `/etc/os-release`; the old `lsb_release -rs` produced broken URLs on Zorin.

## Follow-ups outside this repo

- `dotfiles`: take over java aliases, `.hushlogin`, `BROWSER=wslview`
  (its env still has `host_edge`); pre-publication cleanup (internal IP/host
  in `ssh/config`); strong age passphrase + documented rotation plan.
- Make both repos public; delete `setup-home-server` on GitHub.
