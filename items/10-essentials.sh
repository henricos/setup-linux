#!/usr/bin/env bash
# Block: Básico — baseline CLI tools.

register_item essentials "Básico" "curl, git e openssh-client"
check_essentials() {
    command -v curl >/dev/null && command -v git >/dev/null && command -v ssh >/dev/null
}
install_essentials() {
    apt_install curl git openssh-client
}
