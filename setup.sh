#!/usr/bin/env bash
#
# setup-linux — interactive setup for freshly formatted Debian/Ubuntu machines.
#
# Zero-config entry point (public repo, anonymous HTTPS clone):
#
#   sudo apt update && sudo apt install -y curl git && \
#     bash <(curl -fsSL https://raw.githubusercontent.com/henricos/setup-linux/main/setup.sh)
#
# When piped (no repo checkout around), the script clones itself into
# $REPO_DIR and re-executes from there. When run from a checkout, it goes
# straight to the menu.
#
# Operator-facing messages are pt-BR by design (see AGENTS.md).

set -u -o pipefail

# Overridable for testing branches/forks of the bootstrap flow.
REPO_URL="${SETUP_LINUX_REPO_URL:-https://github.com/henricos/setup-linux.git}"
REPO_DIR="${SETUP_LINUX_REPO_DIR:-$HOME/github/henricos/setup-linux}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

# --- bootstrap mode ----------------------------------------------------------

if [[ -z "$SCRIPT_DIR" || ! -f "$SCRIPT_DIR/lib/core.sh" ]]; then
    echo "[setup] Modo bootstrap: preparando o repositório em $REPO_DIR ..."
    if ! command -v git >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y git
    fi
    if [[ -d "$REPO_DIR/.git" ]]; then
        git -C "$REPO_DIR" pull --ff-only || true
    else
        mkdir -p "$(dirname "$REPO_DIR")"
        if ! git clone "$REPO_URL" "$REPO_DIR"; then
            echo "[setup] Falha ao clonar $REPO_URL. Verifique a rede e tente novamente." >&2
            exit 1
        fi
    fi
    exec bash "$REPO_DIR/setup.sh" "$@"
fi

# --- normal mode -------------------------------------------------------------

source "$SCRIPT_DIR/lib/core.sh"
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/ui.sh"

for item_file in "$SCRIPT_DIR"/items/*.sh; do
    # shellcheck disable=SC1090
    source "$item_file"
done

main() {
    initial_checks
    request_sudo
    log_info "Log desta execução: $LOG_FILE"

    # Level 1: pick a block; level 2: mark items and confirm. Quitting the
    # main menu prints the session summary.
    while main_menu; do
        if item_menu "$UI_CHOSEN_BLOCK"; then
            run_items "${UI_SELECTED_ITEMS[@]}"
            printf '\n'
            read -rp "  Enter para voltar ao menu..." _ || true
        fi
    done

    print_summary
}

main "$@"
