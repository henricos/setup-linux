#!/usr/bin/env bash
# core.sh — item registry, runner, logging and apt helpers.

COLOR_RED=$'\033[0;31m'
COLOR_GREEN=$'\033[0;32m'
COLOR_YELLOW=$'\033[1;33m'
COLOR_BLUE=$'\033[0;34m'
COLOR_CYAN=$'\033[0;36m'
COLOR_GRAY=$'\033[90m'
COLOR_BOLD=$'\033[1m'
COLOR_DIM=$'\033[2m'
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

# --- command display ---------------------------------------------------------

# show_cmd <command line> — highlights the command being executed. It ends by
# switching back to gray so the command's own output stays de-emphasized.
show_cmd() {
    printf '  %s$ %s%s\n' "${COLOR_BOLD}${COLOR_CYAN}" "$*" "${COLOR_OFF}${COLOR_GRAY}"
}

# run_cmd <command...> — show it highlighted, then execute it.
run_cmd() {
    show_cmd "$@"
    "$@"
}

# --- runner ------------------------------------------------------------------

# run_items <id...> — runs each item in an isolated subshell. A failing item
# is recorded and never aborts the remaining ones. Command lines are shown
# highlighted (show_cmd/run_cmd); everything else renders in gray.
run_items() {
    local id rc
    for id in "$@"; do
        run_header "${ITEM_DESC[$id]}"
        printf '==> %s\n' "${ITEM_DESC[$id]}" >> "$LOG_FILE"
        printf '%s' "$COLOR_GRAY"
        # tee keeps stdin attached to the TTY, so interactive items still work.
        ( set -euo pipefail; "install_$id" ) 2>&1 | tee -a "$LOG_FILE"
        rc=${PIPESTATUS[0]}
        printf '%s' "$COLOR_OFF"
        if (( rc == 0 )); then
            ITEM_RESULT[$id]=ok
            printf '\n  %s✓ %s%s\n' "$COLOR_GREEN" "${ITEM_DESC[$id]}" "$COLOR_OFF"
        else
            ITEM_RESULT[$id]=failed
            printf '\n  %s✗ %s%s  %s(detalhes: %s)%s\n' \
                "$COLOR_RED" "${ITEM_DESC[$id]}" "$COLOR_OFF" \
                "$COLOR_DIM" "$LOG_FILE" "$COLOR_OFF"
        fi
    done
}

print_summary() {
    local id failures=0 ran=0
    for id in "${ITEMS[@]}"; do
        [[ -n "${ITEM_RESULT[$id]:-}" ]] && (( ran += 1 ))
    done
    (( ran == 0 )) && return 0

    run_header "Resumo"
    for id in "${ITEMS[@]}"; do
        case "${ITEM_RESULT[$id]:-}" in
            ok)     printf '  %s✓ %s%s\n' "$COLOR_GREEN" "${ITEM_DESC[$id]}" "$COLOR_OFF" ;;
            failed) printf '  %s✗ %s%s\n' "$COLOR_RED" "${ITEM_DESC[$id]}" "$COLOR_OFF"; (( failures += 1 )) ;;
        esac
    done
    printf '\n'
    if [[ "${ITEM_RESULT[dotfiles_clone]:-}" == "ok" ]]; then
        log_info "Próximo passo: execute ~/github/henricos/dotfiles/bin/bootstrap.sh para instalar chaves e configurações pessoais; depois troque os remotes dos repositórios de HTTPS para SSH."
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
    run_cmd sudo apt-get update && touch "$APT_STAMP"
}

apt_install() {
    ensure_apt_updated
    run_cmd sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

# add_keyring <name> <url> — download and dearmor a signing key.
# --yes makes re-runs overwrite instead of hanging on a gpg prompt.
add_keyring() {
    local name=$1 url=$2
    command -v gpg >/dev/null 2>&1 || apt_install gnupg
    run_cmd sudo install -d -m 0755 /etc/apt/keyrings
    show_cmd "curl -fsSL $url | sudo gpg --dearmor --yes -o /etc/apt/keyrings/$name.gpg"
    curl -fsSL "$url" | sudo gpg --dearmor --yes -o "/etc/apt/keyrings/$name.gpg"
}

# write_source <name> <deb line> — write the sources file only when its
# content differs, forcing a new apt-get update on the next install.
write_source() {
    local name=$1 line=$2
    local file="/etc/apt/sources.list.d/$name.list"
    if [[ ! -f "$file" || "$(cat "$file")" != "$line" ]]; then
        show_cmd "echo '$line' | sudo tee $file"
        echo "$line" | sudo tee "$file" >/dev/null
        rm -f "$APT_STAMP"
    fi
}
