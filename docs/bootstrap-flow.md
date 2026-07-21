# Bootstrap flow — from a freshly formatted machine to a working environment

## The flow

1. **Only manual step** on a fresh Debian/Ubuntu machine:

   ```bash
   sudo apt update && sudo apt install -y curl git && \
     bash <(curl -fsSL https://raw.githubusercontent.com/henricos/setup-linux/main/setup.sh)
   ```

2. `setup.sh` detects it is running from a pipe, clones this repository over
   **anonymous HTTPS** (the repo is public — no git credentials needed) and
   re-executes from the checkout.

3. The whiptail menu appears. Select whatever the machine needs: apt
   repositories, applications, server basics, system folders, WSL browser
   integration.

4. The last menu item, **Dotfiles**, clones the sibling
   [`dotfiles`](https://github.com/henricos/dotfiles) repository (also public,
   also anonymous HTTPS) and runs its `bin/bootstrap.sh`, then offers to run
   `dot setup` — which asks for the age key passphrase and restores SSH keys,
   git identities and shell configuration.

5. After the dotfiles step, open a new terminal and switch repository remotes
   from HTTPS to SSH (the summary prints a reminder).

The only secret that lives outside the repositories is the **age key
passphrase** (in your head / password manager).

## Division of responsibilities

| Repository | Owns | Secrets |
|---|---|---|
| `setup-linux` (this) | System: apt repos, packages, machine config | None, ever |
| `dotfiles` | Identity: SSH keys, gitconfigs, ssh config, env vars, bashrc, aliases | sops+age encrypted |

Rule of thumb: if it requires `sudo` and changes the *system*, it belongs
here; if it is *personal configuration or credentials*, it belongs in
`dotfiles`.

## Security rationale (why both repos can be public)

- This repository contains only package installation and system configuration
  commands — audited (files and full git history): no tokens, keys or
  passwords ever committed.
- The `dotfiles` repository encrypts every secret with sops+age. The age
  private key is itself stored passphrase-encrypted (`age -p`, scrypt). Its
  security anchors entirely on the passphrase strength: once public, the
  ciphertexts are downloadable forever, so the passphrase must be strong and
  an emergency key-rotation plan must exist.
- A pre-commit hook in `dotfiles` blocks accidental plaintext commits.

## WSL browser integration

The old `host_edge` update-alternatives hack was replaced by
[`wslu`](https://wslutiliti.es/)'s `wslview`, which opens URLs in the
Windows default browser:

- **This repo** (WSL menu item): installs `wslu` and registers `wslview` as
  the `x-www-browser` alternative — apps that use `xdg-open` ignore
  `$BROWSER`, hence the alternatives registration.
- **dotfiles**: exports `BROWSER=wslview` for apps that honor the variable.
