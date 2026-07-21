#!/usr/bin/env bash
# core.sh — item registry, runner, logging and apt helpers.

COLOR_RED=$'\033[0;31m'
COLOR_GREEN=$'\033[0;32m'
COLOR_YELLOW=$'\033[0;33m'
COLOR_BLUE=$'\033[0;34m'
COLOR_OFF=$'\033[0m'

LOG_DIR="$HOME/.local/state/setup-linux"
LOG_FILE="$LOG_DIR/$(date +%Y%m%d-%H%M%S).log"
# Per-run stamp: apt-get update runs once per run, re-forced by write_source.
APT_STAMP="$LOG_DIR/.apt-updated.$$"

mkdir -p "$LOG_DIR"

declare -a ITEMS=()
# shellcheck disable=SC2034  # ITEM_BLOCK is consumed by lib/ui.sh
declare -A ITEM_BLOCK=() ITEM_DESC=() ITEM_CONDITION=() ITEM_RESULT=()

SUDO_KEEPALIVE_PID=""

log_info()  { echo "${COLOR_BLUE}[setup]${COLOR_OFF} $*"; }
log_warn()  { echo "${COLOR_YELLOW}[setup]${COLOR_OFF} $*"; }
log_error() { echo "${COLOR_RED}[setup]${COLOR_OFF} $*" >&2; }

cleanup() {
    [[ -n "$SUDO_KEEPALIVE_PID" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
    rm -f "$APT_STAMP"
}
trap cleanup EXIT

# --- item registry -----------------------------------------------------------

# register_item <id> <block> <description> [condition_fn]
#
# Conventions (docs/architecture.md):
#   install_<id>  required; does the work, must be idempotent.
#   check_<id>    optional; returns 0 when already installed (✓ in the menu).
#   condition_fn  optional; item is only listed when it returns 0
#                 (e.g. is_wsl, not_wsl, is_ubuntu_family).
register_item() {
    local id=$1
    ITEMS+=("$id")
    # shellcheck disable=SC2034  # consumed by lib/ui.sh
    ITEM_BLOCK[$id]=$2
    ITEM_DESC[$id]=$3
    ITEM_CONDITION[$id]=${4:-}
}

item_visible() {
    local condition=${ITEM_CONDITION[$1]}
    [[ -z "$condition" ]] || "$condition"
}

item_installed() {
    local check_fn="check_$1"
    declare -F "$check_fn" >/dev/null && "$check_fn"
}

# --- runner ------------------------------------------------------------------

# run_items <id...> — runs each item in an isolated subshell. A failing item
# is recorded and never aborts the remaining ones.
run_items() {
    log_info "Log desta execução: $LOG_FILE"
    local id
    for id in "$@"; do
        echo
        log_info "==> ${ITEM_DESC[$id]}" | tee -a "$LOG_FILE"
        # tee keeps stdin attached to the TTY, so interactive items still work.
        ( set -euo pipefail; "install_$id" ) 2>&1 | tee -a "$LOG_FILE"
        if (( PIPESTATUS[0] == 0 )); then
            ITEM_RESULT[$id]=ok
        else
            ITEM_RESULT[$id]=failed
        fi
    done
}

print_summary() {
    echo
    log_info "Resumo:"
    local id failures=0
    for id in "${ITEMS[@]}"; do
        case "${ITEM_RESULT[$id]:-}" in
            ok)     echo "  ${COLOR_GREEN}✓ ${ITEM_DESC[$id]}${COLOR_OFF}" ;;
            failed) echo "  ${COLOR_RED}✗ ${ITEM_DESC[$id]}${COLOR_OFF}"; (( failures += 1 )) ;;
        esac
    done
    echo
    if [[ "${ITEM_RESULT[dotfiles]:-}" == "ok" ]]; then
        log_info "Lembrete: com as chaves SSH instaladas, abra um novo terminal e troque os remotes dos repositórios de HTTPS para SSH."
    fi
    if (( failures > 0 )); then
        log_error "$failures item(ns) falharam. Detalhes: $LOG_FILE"
        exit 1
    fi
    log_info "Tudo certo. Log: $LOG_FILE"
}

# --- sudo --------------------------------------------------------------------

request_sudo() {
    if ! sudo -v; then
        log_error "É necessário sudo para continuar."
        exit 1
    fi
    # Keep the sudo timestamp fresh during long installs.
    ( while true; do sudo -n true; sleep 60; done ) &
    SUDO_KEEPALIVE_PID=$!
}

# --- apt helpers -------------------------------------------------------------

ensure_apt_updated() {
    [[ -f "$APT_STAMP" ]] && return 0
    sudo apt-get update && touch "$APT_STAMP"
}

apt_install() {
    ensure_apt_updated
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

# add_keyring <name> <url> — download and dearmor a signing key.
# --yes makes re-runs overwrite instead of hanging on a gpg prompt.
add_keyring() {
    local name=$1 url=$2
    command -v gpg >/dev/null 2>&1 || apt_install gnupg
    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL "$url" | sudo gpg --dearmor --yes -o "/etc/apt/keyrings/$name.gpg"
}

# write_source <name> <deb line> — write the sources file only when its
# content differs, forcing a new apt-get update on the next install.
write_source() {
    local name=$1 line=$2
    local file="/etc/apt/sources.list.d/$name.list"
    if [[ ! -f "$file" || "$(cat "$file")" != "$line" ]]; then
        echo "$line" | sudo tee "$file" >/dev/null
        rm -f "$APT_STAMP"
    fi
}

ensure_whiptail() {
    command -v whiptail >/dev/null 2>&1 || apt_install whiptail
}
