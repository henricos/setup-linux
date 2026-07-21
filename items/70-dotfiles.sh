#!/usr/bin/env bash
# Block: Dotfiles — hand over identity/personal config to the dotfiles project.
#
# Everything personal (SSH keys, gitconfigs, ssh config, env, shell) lives in
# the dotfiles repo (sops+age encrypted). This item only clones it over
# anonymous HTTPS and runs its bootstrap.

DOTFILES_URL="https://github.com/henricos/dotfiles.git"
DOTFILES_DIR="$HOME/github/henricos/dotfiles"

register_item dotfiles "Dotfiles" "Clonar e inicializar o projeto dotfiles"
check_dotfiles() { [[ -d "$DOTFILES_DIR/.git" ]]; }
install_dotfiles() {
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        git -C "$DOTFILES_DIR" pull --ff-only || true
    else
        mkdir -p "$(dirname "$DOTFILES_DIR")"
        git clone "$DOTFILES_URL" "$DOTFILES_DIR"
    fi
    bash "$DOTFILES_DIR/bin/bootstrap.sh"
    local answer=""
    read -r -p "Executar 'dot setup' agora? Pedirá a passphrase da chave age. [s/N] " answer
    if [[ "$answer" =~ ^[sS]$ ]]; then
        "$DOTFILES_DIR/bin/dot" setup
    else
        echo "Quando quiser: $DOTFILES_DIR/bin/dot setup"
    fi
}
