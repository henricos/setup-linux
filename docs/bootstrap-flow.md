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

3. The interactive menu appears: pick a block, then mark the items the
   machine needs — baseline tools, apt repositories, applications,
   configuration (folders + dotfiles), WSL browser integration.

4. The Configurações block — meant to run **last**, after apps and repos —
   creates the repository folders and **clones** the sibling
   [`dotfiles`](https://github.com/henricos/dotfiles) repository, which is
   **private**. The item installs the GitHub CLI (`gh`, distro apt) and
   authenticates via the **device flow**: `gh auth login --web` prints a
   one-time code to type at `github.com/login/device` from any browser —
   the phone works, so headless machines are fine. `gh auth setup-git` then
   lets plain `git` clone over HTTPS with the gh token. No token, password
   or key is ever typed on the new machine. The clone is the only
   integration point — there is deliberately no bootstrap chaining: the
   dotfiles repo owns its own setup experience, so the next step is manual:

   ```bash
   ~/github/henricos/dotfiles/bin/dot setup
   ```

   That installs the dotfiles prerequisites (sops, age — sudo only when
   something is missing), asks for the age key passphrase and restores SSH
   keys, git identities and shell configuration (the setup summary prints
   this reminder).

5. After the dotfiles bootstrap, open a new terminal and switch repository
   remotes from HTTPS to SSH. The gh token has broad scope (`repo`), so once
   the real SSH keys are in place, `gh auth logout` is a good hygiene step.

The only secret that lives outside the repositories is the **age key
passphrase** (in your head / password manager). The GitHub authentication
happens per machine via device flow — nothing to carry around.

## Division of responsibilities

| Repository | Owns | Secrets |
|---|---|---|
| `setup-linux` (this) | System: apt repos, packages, machine config | None, ever |
| `dotfiles` | Identity: SSH keys, gitconfigs, ssh config, env vars, bashrc, aliases | sops+age encrypted |

Rule of thumb: if it requires `sudo` and changes the *system*, it belongs
here; if it is *personal configuration or credentials*, it belongs in
`dotfiles`.

## Security rationale

- **This repository is public**: it contains only package installation and
  system configuration commands — audited (files and full git history): no
  tokens, keys or passwords ever committed.
- **The `dotfiles` repository is private** and additionally encrypts every
  secret with sops+age; the age private key is itself stored
  passphrase-encrypted (`age -p`, scrypt). Two independent layers: an
  attacker would need both read access to the private repo *and* the age
  passphrase. Keeping it private also hides metadata (env var names, key
  file names, commit history) and keeps the age-key ciphertext off the
  public internet.
- Cloning the private repo on a fresh machine uses the GitHub CLI device
  flow — the only credential involved is the GitHub session in the browser
  where the one-time code is typed (protected by 2FA).
- A pre-commit hook in `dotfiles` blocks accidental plaintext commits.

## WSL browser integration

The old `host_edge` update-alternatives hack was replaced by
[`wslu`](https://wslutiliti.es/)'s `wslview`, which opens URLs in the
Windows default browser:

- **This repo** (WSL menu item): installs `wslu` and registers `wslview` as
  the `x-www-browser` alternative — apps that use `xdg-open` ignore
  `$BROWSER`, hence the alternatives registration.
- **dotfiles**: exports `BROWSER=wslview` for apps that honor the variable.
