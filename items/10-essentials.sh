#!/usr/bin/env bash
# Block: Básico — baseline tools.

register_item curl "Básico" "curl"
check_curl() { command -v curl >/dev/null; }
install_curl() { apt_install curl; }

register_item git "Básico" "git"
check_git() { command -v git >/dev/null; }
install_git() { apt_install git; }

register_item openssh_client "Básico" "openssh-client"
check_openssh_client() { command -v ssh >/dev/null; }
install_openssh_client() { apt_install openssh-client; }
