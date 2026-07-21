#!/usr/bin/env bash
# Block: Apps — desktop and development applications.

register_item unzip "Apps" "Unzip"
check_unzip() { command -v unzip >/dev/null; }
install_unzip() { apt_install unzip; }

register_item python3 "Apps" "Python 3 (pip, venv, python-is-python3)"
check_python3() { command -v python3 >/dev/null && command -v pip3 >/dev/null; }
install_python3() { apt_install python3 python3-pip python3-venv python-is-python3; }

register_item mscorefonts "Apps" "Microsoft Core Fonts"
check_mscorefonts() { dpkg -s ttf-mscorefonts-installer >/dev/null 2>&1; }
install_mscorefonts() {
    # Preseed the EULA so no ncurses dialog blocks the run.
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" |
        sudo debconf-set-selections
    if [[ "$(distro_family)" == "debian" ]]; then
        ensure_apt_updated
        if ! apt-cache show ttf-mscorefonts-installer >/dev/null 2>&1; then
            echo "No Debian este pacote vem do componente 'contrib'."
            echo "Habilite o contrib nas sources do apt e execute o item novamente."
            return 1
        fi
    fi
    apt_install ttf-mscorefonts-installer
}

# openjdk-11 is not available on Debian 12+, hence the family condition.
register_item openjdk_11 "Apps" "OpenJDK 11" is_ubuntu_family
check_openjdk_11() { dpkg -s openjdk-11-jdk >/dev/null 2>&1; }
install_openjdk_11() { apt_install openjdk-11-jdk; }

register_item openjdk_17 "Apps" "OpenJDK 17"
check_openjdk_17() { dpkg -s openjdk-17-jdk >/dev/null 2>&1; }
install_openjdk_17() { apt_install openjdk-17-jdk; }

register_item chrome "Apps" "Google Chrome"
check_chrome() { command -v google-chrome >/dev/null; }
install_chrome() {
    ensure_repo_google_chrome
    apt_install google-chrome-stable
}

register_item edge "Apps" "Microsoft Edge"
check_edge() { command -v microsoft-edge >/dev/null; }
install_edge() {
    ensure_repo_microsoft_edge
    apt_install microsoft-edge-stable
}

register_item code "Apps" "Visual Studio Code"
check_code() { command -v code >/dev/null; }
install_code() {
    ensure_repo_microsoft_code
    apt_install code
}

register_item dbeaver "Apps" "DBeaver CE"
check_dbeaver() { dpkg -s dbeaver-ce >/dev/null 2>&1; }
install_dbeaver() {
    ensure_repo_dbeaver
    apt_install dbeaver-ce
}

register_item hplip "Apps" "Drivers de impressora HP (hplip)" not_wsl
check_hplip() { dpkg -s hplip >/dev/null 2>&1; }
install_hplip() { apt_install hplip hplip-gui; }

register_item msodbcsql18 "Apps" "Driver ODBC 18 (msodbcsql18)"
check_msodbcsql18() { dpkg -s msodbcsql18 >/dev/null 2>&1; }
install_msodbcsql18() {
    ensure_repo_microsoft_prod
    ensure_apt_updated
    sudo ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt-get install -y msodbcsql18
}
