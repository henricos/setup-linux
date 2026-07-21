# Architecture

## Overview

`setup.sh` is a single entry point with two modes:

- **Bootstrap mode** — when executed via pipe (`bash <(curl ...)`), there is no
  `lib/` next to the script. It ensures `git`, clones this repository over
  anonymous HTTPS into `~/github/henricos/setup-linux` (or `git pull --ff-only`
  if already there) and re-executes itself from the checkout.
- **Normal mode** — sources `lib/*.sh`, sources every `items/*.sh` (glob order
  defines menu order), loops over the two-level menu (pick a block, then mark
  items and confirm), runs the selected items and prints a session summary on
  quit.

```
setup.sh          entry point (bootstrap + orchestration)
lib/core.sh       item registry, runner, logging, apt/keyring helpers
lib/detect.sh     is_wsl, distro_family/codename/version, initial checks
lib/ui.sh         pure-CLI two-level menu (blocks → items)
items/NN-*.sh     declarative item registry, one file per block
```

## UI

No curses/dialog tools — plain `printf` + ANSI colors + `read`, in the style
of the `dev-tools` scripts. Level 1 lists the blocks (with item/installed
counts); level 2 lists the block's items with `[x]`/`[ ]` toggles (numbers
toggle, `A` all, `N` none, `C` confirms, `V` goes back). Because it is plain
stdin/stdout, the whole menu is scriptable in tests by piping input.

During execution, each command line is echoed highlighted (bold cyan, `$ `
prefix) via `run_cmd`/`show_cmd`, while command output renders in dark gray
so it stays visually secondary.

## Item model

Every unit of work is an *item* registered declaratively:

```bash
register_item <id> <block> <description> [condition_fn]
```

- `install_<id>` — required. Does the work. Must be idempotent.
- `check_<id>` — optional. Returns 0 when the item is already applied; the
  menu shows a `✓` suffix.
- `condition_fn` — optional visibility predicate (`is_wsl`, `not_wsl`,
  `is_ubuntu_family`). The item is only listed when it returns 0.

Item ids are also function-name suffixes, so they use `snake_case`.

### Adding a new item

1. Pick the block file in `items/` (or create `items/NN-newblock.sh`).
2. Register it and implement the functions:

```bash
register_item mytool "Apps" "My Tool"
check_mytool() { command -v mytool >/dev/null; }
install_mytool() { apt_install mytool; }
```

That's all — the menu, runner, logging and summary pick it up automatically.

## Execution model

- `set -u -o pipefail` globally. **Never `set -e` globally** — the menu loop
  relies on non-zero returns (go back, quit, EOF on `read`) as normal flow.
- Each item runs in a subshell with `set -euo pipefail`, piped through
  `tee -a $LOG_FILE`. `tee` keeps stdin attached to the TTY, so interactive
  items (the dotfiles age passphrase prompt) still work.
- A failing item is recorded as `failed` and never aborts the remaining items.
  The summary lists ✓/✗ per item and the script exits 1 if anything failed.
- `sudo -v` runs upfront with a background keepalive, so long installs never
  stop to ask for the password again.
- Logs: `~/.local/state/setup-linux/<timestamp>.log`.

## apt helpers and dependencies

There is no dependency resolver. Each installer is self-sufficient: it calls
the idempotent `ensure_repo_*` helper for any apt repository it needs (e.g.
`install_code` calls `ensure_repo_microsoft_code`). The "Repositórios" menu
items are thin wrappers over the same helpers, so selection order never
matters.

- `apt_install` — lazy `apt-get update`: runs once per execution (stamp file),
  re-forced whenever `write_source` changes a sources file.
- `add_keyring <name> <url>` — downloads and dearmors into
  `/etc/apt/keyrings/<name>.gpg`. Uses `gpg --dearmor --yes` so re-runs
  overwrite instead of hanging on a prompt.
- `write_source <name> <deb line>` — writes
  `/etc/apt/sources.list.d/<name>.list` only when content differs.

## Distro support

Targets are Debian/Ubuntu-family only: Zorin desktop (Ubuntu-based),
WSL Ubuntu and a Debian home server.

- `distro_family()` — `ubuntu` (including derivatives via `ID_LIKE`) or
  `debian`. Used to branch Docker (`download.docker.com/linux/<family>`) and
  Microsoft prod (`packages.microsoft.com/<family>/<version>/prod`) URLs.
- `distro_codename()` — `UBUNTU_CODENAME` falling back to `VERSION_CODENAME`,
  which resolves the *upstream* codename on derivatives like Zorin.
- `distro_version()` — numeric upstream version. **Never** `lsb_release -rs`:
  on derivatives it returns the derivative's own version and produces broken
  Microsoft repo URLs.

Debian-specific notes:

- `ttf-mscorefonts-installer` lives in the `contrib` component; the item fails
  with instructions when contrib is not enabled.
- `openjdk-11-jdk` does not exist on Debian 12+; the item is hidden via
  `is_ubuntu_family`.
