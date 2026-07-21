# setup-linux

Interactive setup script for my freshly formatted Debian/Ubuntu machines:
Zorin desktop, WSL Ubuntu and a Debian home server.

## Usage

On a brand-new machine (the only manual step):

```bash
sudo apt update && sudo apt install -y curl git && \
  bash <(curl -fsSL https://raw.githubusercontent.com/henricos/setup-linux/main/setup.sh)
```

The script clones itself into `~/github/henricos/setup-linux` and opens a
two-level menu: pick a block, then mark only what this machine needs. From
an existing checkout, just run `./setup.sh`.

## What the menu offers

| Block | Items | Shown when |
|---|---|---|
| Básico | curl, git, openssh-client | always |
| Repositórios | Microsoft Edge/VS Code/prod, Google Chrome, Antigravity, DBeaver, Docker; system update+upgrade | always |
| Apps | unzip, Python 3, MS Core Fonts, OpenJDK 11/17, Chrome, Edge, VS Code, DBeaver CE, HP drivers, ODBC 18 | OpenJDK 11: Ubuntu-family only; HP drivers: not on WSL |
| Servidor | OpenSSH Server, Docker Engine | always |
| Sistema | repository folders (`~/github/...`, `~/azuregit`) | always |
| WSL | Windows default browser via `wslu`/`wslview` | WSL only |
| Dotfiles | clone + bootstrap the [dotfiles](https://github.com/henricos/dotfiles) project | always (last) |

## Behavior

- **Idempotent** — re-running any item is safe.
- **Failure-isolated** — a failing item never aborts the rest; the final
  summary shows ✓/✗ per item.
- **Menu status** — items already applied show a ✓ suffix.
- Logs in `~/.local/state/setup-linux/`.

## Relation to `dotfiles`

This repo owns the **system** (apt repos, packages, machine config) and holds
zero secrets. Everything **personal** (SSH keys, git identities, env vars,
shell config) lives encrypted (sops+age) in
[`dotfiles`](https://github.com/henricos/dotfiles), which the last menu item
bootstraps. Details in [`docs/bootstrap-flow.md`](docs/bootstrap-flow.md).

## Development

- Docs in [`docs/`](docs/) are normative — start with
  [`docs/architecture.md`](docs/architecture.md) (includes "adding a new
  item").
- Verify with `bash -n` + `shellcheck -x` and a clean container
  (`ubuntu:24.04` / `debian:12`); see `AGENTS.md`.
