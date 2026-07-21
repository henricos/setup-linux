#!/usr/bin/env bash
# Block: Servidor — home server basics.

register_item openssh_server "Servidor" "OpenSSH Server"
check_openssh_server() { dpkg -s openssh-server >/dev/null 2>&1; }
install_openssh_server() {
    apt_install openssh-server
    # Containers used for testing have no systemd; skip service management there.
    if pidof systemd >/dev/null 2>&1; then
        run_cmd sudo systemctl enable --now ssh
    fi
}

register_item docker_engine "Servidor" "Docker Engine"
check_docker_engine() { command -v docker >/dev/null; }
install_docker_engine() {
    ensure_repo_docker
    apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    run_cmd sudo usermod -aG docker "$USER"
    echo "Usuário adicionado ao grupo docker. Faça logout/login para usar docker sem sudo."
}
