#!/usr/bin/env bash
# Block: Configurações — repository folders and the dotfiles clone (which
# restores ssh, git and shell configuration). Meant to run near the end,
# after apps and repositories are in place.

register_item folder_henricos "Configurações" "Pasta ~/github/henricos"
check_folder_henricos() { [[ -d "$HOME/github/henricos" ]]; }
install_folder_henricos() { run_cmd mkdir -p "$HOME/github/henricos"; }

register_item folder_jarbas "Configurações" "Pasta ~/github/jarbas-caramello"
check_folder_jarbas() { [[ -d "$HOME/github/jarbas-caramello" ]]; }
install_folder_jarbas() { run_cmd mkdir -p "$HOME/github/jarbas-caramello"; }

register_item folder_azuregit "Configurações" "Pasta ~/azuregit"
check_folder_azuregit() { [[ -d "$HOME/azuregit" ]]; }
install_folder_azuregit() { run_cmd mkdir -p "$HOME/azuregit"; }

# Clone only — no bootstrap chaining. The dotfiles repo owns its own setup
# experience; the final summary points to its bootstrap as the next step.
#
# The dotfiles repo is PRIVATE: the clone authenticates via the GitHub CLI
# device flow (one-time code typed at github.com/login/device from any
# browser, e.g. the phone — works on headless machines too). No token or key
# is ever typed on this machine; `gh auth setup-git` teaches git to use the
# gh token over HTTPS. After the dotfiles bootstrap installs the real SSH
# keys, the remote is switched to SSH and `gh auth logout` is optional.
DOTFILES_URL="https://github.com/henricos/dotfiles.git"
DOTFILES_DIR="$HOME/github/henricos/dotfiles"

register_item dotfiles_clone "Configurações" "Clonar o projeto dotfiles (privado, via gh)"
check_dotfiles_clone() { [[ -d "$DOTFILES_DIR/.git" ]]; }
install_dotfiles_clone() {
    command -v gh >/dev/null || apt_install gh
    if ! gh auth status --hostname github.com >/dev/null 2>&1; then
        echo "O repo dotfiles é privado — autentique com o código único (github.com/login/device):"
        run_cmd gh auth login --hostname github.com --git-protocol https --web
    fi
    run_cmd gh auth setup-git --hostname github.com
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        run_cmd git -C "$DOTFILES_DIR" pull --ff-only || true
    else
        mkdir -p "$(dirname "$DOTFILES_DIR")"
        run_cmd git clone "$DOTFILES_URL" "$DOTFILES_DIR"
    fi
    echo "Próximo passo (fora deste script): $DOTFILES_DIR/bin/dot setup"
}
