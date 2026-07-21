#!/usr/bin/env bash
# Block: Básico — baseline tools, repository folders and the dotfiles clone.

register_item curl "Básico" "curl"
check_curl() { command -v curl >/dev/null; }
install_curl() { apt_install curl; }

register_item git "Básico" "git"
check_git() { command -v git >/dev/null; }
install_git() { apt_install git; }

register_item openssh_client "Básico" "openssh-client"
check_openssh_client() { command -v ssh >/dev/null; }
install_openssh_client() { apt_install openssh-client; }

register_item folder_henricos "Básico" "Pasta ~/github/henricos"
check_folder_henricos() { [[ -d "$HOME/github/henricos" ]]; }
install_folder_henricos() { run_cmd mkdir -p "$HOME/github/henricos"; }

register_item folder_jarbas "Básico" "Pasta ~/github/jarbas-caramello"
check_folder_jarbas() { [[ -d "$HOME/github/jarbas-caramello" ]]; }
install_folder_jarbas() { run_cmd mkdir -p "$HOME/github/jarbas-caramello"; }

register_item folder_azuregit "Básico" "Pasta ~/azuregit"
check_folder_azuregit() { [[ -d "$HOME/azuregit" ]]; }
install_folder_azuregit() { run_cmd mkdir -p "$HOME/azuregit"; }

# Clone only — no bootstrap chaining. The dotfiles repo owns its own setup
# experience; the final summary points to its bootstrap as the next step.
DOTFILES_URL="https://github.com/henricos/dotfiles.git"
DOTFILES_DIR="$HOME/github/henricos/dotfiles"

register_item dotfiles_clone "Básico" "Clonar o projeto dotfiles"
check_dotfiles_clone() { [[ -d "$DOTFILES_DIR/.git" ]]; }
install_dotfiles_clone() {
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        run_cmd git -C "$DOTFILES_DIR" pull --ff-only || true
    else
        mkdir -p "$(dirname "$DOTFILES_DIR")"
        run_cmd git clone "$DOTFILES_URL" "$DOTFILES_DIR"
    fi
    echo "Próximo passo (fora deste script): $DOTFILES_DIR/bin/bootstrap.sh"
}
