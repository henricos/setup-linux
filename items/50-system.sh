#!/usr/bin/env bash
# Block: Sistema — machine-level configuration.

register_item repo_folders "Sistema" "Pastas de repositórios (~/github, ~/azuregit)"
check_repo_folders() {
    [[ -d "$HOME/github/henricos" && -d "$HOME/github/jarbas-caramello" && -d "$HOME/azuregit" ]]
}
install_repo_folders() {
    run_cmd mkdir -p "$HOME/github/henricos" "$HOME/github/jarbas-caramello" "$HOME/azuregit"
}
