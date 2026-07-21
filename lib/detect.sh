#!/usr/bin/env bash
# detect.sh — environment detection and initial checks.

is_wsl() {
    [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null
}

not_wsl() { ! is_wsl; }

# distro_family — "ubuntu" (including derivatives like Zorin), "debian"
# or "unknown".
distro_family() {
    local id id_like
    # shellcheck disable=SC1091
    id=$(. /etc/os-release && echo "${ID:-}")
    # shellcheck disable=SC1091
    id_like=$(. /etc/os-release && echo "${ID_LIKE:-}")
    if [[ "$id" == "ubuntu" || "$id_like" == *ubuntu* ]]; then
        echo ubuntu
    elif [[ "$id" == "debian" || "$id_like" == *debian* ]]; then
        echo debian
    else
        echo unknown
    fi
}

is_ubuntu_family() { [[ "$(distro_family)" == "ubuntu" ]]; }

# distro_codename — upstream codename for apt sources. On Ubuntu derivatives
# (Zorin), UBUNTU_CODENAME points to the Ubuntu base release.
distro_codename() {
    # shellcheck disable=SC1091
    ( . /etc/os-release && echo "${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}" )
}

# distro_version — NUMERIC upstream version, e.g. "24.04" (Ubuntu) or "12"
# (Debian), as used by packages.microsoft.com/<family>/<version>/prod.
# Never use `lsb_release -rs` here: on derivatives (Zorin) it returns the
# derivative's own version, producing broken repo URLs.
distro_version() {
    local id
    # shellcheck disable=SC1091
    id=$(. /etc/os-release && echo "${ID:-}")
    if [[ "$id" == "ubuntu" || "$id" == "debian" ]]; then
        # shellcheck disable=SC1091
        ( . /etc/os-release && echo "${VERSION_ID:-}" )
        return
    fi
    case "$(distro_codename)" in
        focal) echo 20.04 ;;
        jammy) echo 22.04 ;;
        noble) echo 24.04 ;;
        *) grep -oP 'DISTRIB_RELEASE=\K.*' /etc/upstream-release/lsb-release 2>/dev/null ;;
    esac
}

initial_checks() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Não execute como root. Use um usuário comum com sudo."
        exit 1
    fi
    if ! command -v sudo >/dev/null 2>&1; then
        log_error "sudo não encontrado. Instale e configure o sudo antes de continuar."
        exit 1
    fi
    if [[ "$(distro_family)" == "unknown" ]]; then
        log_error "Distribuição não suportada (esperado: família Debian/Ubuntu)."
        exit 1
    fi
    if [[ "$(dpkg --print-architecture 2>/dev/null)" != "amd64" ]]; then
        log_warn "Arquitetura diferente de amd64; repositórios externos podem falhar."
    fi
}
