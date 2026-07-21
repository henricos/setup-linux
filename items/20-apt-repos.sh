#!/usr/bin/env bash
# Block: Repositórios — third-party apt repositories.
#
# The ensure_repo_* helpers are idempotent and are also called by the app
# installers (items/30-apps.sh, items/40-server.sh), so selection order in
# the menu never matters. The menu items below are thin wrappers over them.

ensure_microsoft_keyring() {
    [[ -f /etc/apt/keyrings/microsoft.gpg ]] ||
        add_keyring microsoft "https://packages.microsoft.com/keys/microsoft.asc"
}

ensure_repo_microsoft_edge() {
    ensure_microsoft_keyring
    write_source microsoft-edge "deb [signed-by=/etc/apt/keyrings/microsoft.gpg arch=amd64] https://packages.microsoft.com/repos/edge stable main"
}

ensure_repo_microsoft_code() {
    ensure_microsoft_keyring
    write_source microsoft-code "deb [signed-by=/etc/apt/keyrings/microsoft.gpg arch=amd64] https://packages.microsoft.com/repos/code stable main"
}

# Distro-versioned Microsoft repo (msodbcsql18 and friends). Branches by
# family: packages.microsoft.com/{ubuntu/<ver>|debian/<ver>}/prod.
ensure_repo_microsoft_prod() {
    ensure_microsoft_keyring
    write_source microsoft-prod "deb [signed-by=/etc/apt/keyrings/microsoft.gpg arch=amd64] https://packages.microsoft.com/$(distro_family)/$(distro_version)/prod $(distro_codename) main"
}

ensure_repo_google_chrome() {
    [[ -f /etc/apt/keyrings/google.gpg ]] ||
        add_keyring google "https://dl-ssl.google.com/linux/linux_signing_key.pub"
    write_source google-chrome "deb [signed-by=/etc/apt/keyrings/google.gpg arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"
}

ensure_repo_antigravity() {
    [[ -f /etc/apt/keyrings/antigravity.gpg ]] ||
        add_keyring antigravity "https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg"
    write_source antigravity "deb [signed-by=/etc/apt/keyrings/antigravity.gpg arch=amd64] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main"
}

ensure_repo_dbeaver() {
    [[ -f /etc/apt/keyrings/dbeaver.gpg ]] ||
        add_keyring dbeaver "https://dbeaver.io/debs/dbeaver.gpg.key"
    write_source dbeaver "deb [signed-by=/etc/apt/keyrings/dbeaver.gpg arch=amd64] https://dbeaver.io/debs/dbeaver-ce /"
}

# Docker branches by family: download.docker.com/linux/{ubuntu|debian}.
ensure_repo_docker() {
    [[ -f /etc/apt/keyrings/docker.gpg ]] ||
        add_keyring docker "https://download.docker.com/linux/$(distro_family)/gpg"
    write_source docker "deb [signed-by=/etc/apt/keyrings/docker.gpg arch=amd64] https://download.docker.com/linux/$(distro_family) $(distro_codename) stable"
}

# --- menu items ---------------------------------------------------------------

register_item repo_microsoft_edge "Repositórios" "Repositório Microsoft Edge"
check_repo_microsoft_edge() { [[ -f /etc/apt/sources.list.d/microsoft-edge.list ]]; }
install_repo_microsoft_edge() { ensure_repo_microsoft_edge; }

register_item repo_microsoft_code "Repositórios" "Repositório Microsoft VS Code"
check_repo_microsoft_code() { [[ -f /etc/apt/sources.list.d/microsoft-code.list ]]; }
install_repo_microsoft_code() { ensure_repo_microsoft_code; }

register_item repo_microsoft_prod "Repositórios" "Repositório Microsoft prod (ODBC etc.)"
check_repo_microsoft_prod() { [[ -f /etc/apt/sources.list.d/microsoft-prod.list ]]; }
install_repo_microsoft_prod() { ensure_repo_microsoft_prod; }

register_item repo_google_chrome "Repositórios" "Repositório Google Chrome"
check_repo_google_chrome() { [[ -f /etc/apt/sources.list.d/google-chrome.list ]]; }
install_repo_google_chrome() { ensure_repo_google_chrome; }

register_item repo_antigravity "Repositórios" "Repositório Antigravity"
check_repo_antigravity() { [[ -f /etc/apt/sources.list.d/antigravity.list ]]; }
install_repo_antigravity() { ensure_repo_antigravity; }

register_item repo_dbeaver "Repositórios" "Repositório DBeaver"
check_repo_dbeaver() { [[ -f /etc/apt/sources.list.d/dbeaver.list ]]; }
install_repo_dbeaver() { ensure_repo_dbeaver; }

register_item repo_docker "Repositórios" "Repositório Docker"
check_repo_docker() { [[ -f /etc/apt/sources.list.d/docker.list ]]; }
install_repo_docker() { ensure_repo_docker; }

register_item system_upgrade "Repositórios" "Atualizar o sistema (update + upgrade)"
install_system_upgrade() {
    sudo apt-get update && touch "$APT_STAMP"
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
}
