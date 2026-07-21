#!/usr/bin/env bash
# Block: WSL — Windows Subsystem for Linux integration.

register_item wsl_browser "WSL" "Browser padrão do Windows (wslu/wslview)" is_wsl
check_wsl_browser() {
    command -v wslview >/dev/null &&
        [[ "$(readlink -f /etc/alternatives/x-www-browser 2>/dev/null)" == "$(command -v wslview)" ]]
}
install_wsl_browser() {
    apt_install wslu
    local wslview_path
    wslview_path=$(command -v wslview)
    # Apps honoring $BROWSER get BROWSER=wslview from the dotfiles project;
    # xdg-open ignores $BROWSER, hence the alternatives registration.
    sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser "$wslview_path" 1
    sudo update-alternatives --set x-www-browser "$wslview_path"
}
