#!/bin/bash

### Server setup script ###

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Detect the operating system
OS=""
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
fi

install_packages_ubuntu() {
    echo -e "${GREEN}[+] Installing Packages on Ubuntu...${NC}"
    curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list

    sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y && sudo apt autoclean -y && sudo apt autoremove -y
    sudo apt install -y vim curl zsh git gcc net-tools ruby ruby-dev cloudflare-warp tmux build-essential postgresql make python3-apt python3-distutils bind9 certbot python3-certbot-nginx libssl-dev zip unzip jq nginx pkg-config mysql-server php php-curl php-fpm php-mysql dnsutils whois python3-pip ca-certificates gnupg

    # Installing Docker
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome-stable_current_amd64.deb
    rm -f google-chrome-stable_current_amd64.deb
}

install_packages_centos() {
    echo -e "${GREEN}[+] Installing Packages on CentOS...${NC}"
    sudo yum update -y
    sudo yum install -y epel-release
    sudo yum install -y vim curl zsh git gcc net-tools ruby ruby-devel tmux postgresql postgresql-server postgresql-devel python3 python3-pip bind-utils certbot python3-certbot-nginx openssl-devel zip unzip jq nginx mysql-server php php-curl php-fpm php-mysql

    # Installing Docker
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker

    wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    sudo yum localinstall -y google-chrome-stable_current_x86_64.rpm
    rm -f google-chrome-stable_current_x86_64.rpm

}

install_packages_fedora() {
    echo -e "${GREEN}[+] Installing Packages on Fedora...${NC}"
    sudo dnf update -y
    sudo dnf install -y vim curl zsh git gcc net-tools ruby ruby-devel tmux postgresql postgresql-server postgresql-devel python3 python3-pip bind-utils certbot python3-certbot-nginx openssl-devel zip unzip jq nginx mysql-server php php-curl php-fpm php-mysql

    # Installing Docker
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker

    wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    sudo dnf localinstall -y google-chrome-stable_current_x86_64.rpm
    rm -f google-chrome-stable_current_x86_64.rpm

}


install_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
}

install_misc() {
    curl -Ls https://github.com/ipinfo/cli/releases/download/ipinfo-2.10.1/deb.sh | sh
    curl -L https://sourcegraph.com/.api/src-cli/src_linux_amd64 -o /usr/local/bin/src
    chmod +x /usr/local/bin/src
    warp-cli register
    warp-cli set-mode proxy
    warp-cli set-proxy-port 5423
}

install_tools_from_source() {
    echo -e "${GREEN}[+] Installing Tools from source...${NC}"
    mkdir -p Tools && cd Tools

    install_tool() {
        local repo=$1
        local post_install_cmds=$2
        local tool_name=$(basename "$repo" .git)
        
        git clone "$repo"
        cd "$tool_name"
        eval "$post_install_cmds"
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}[+] Successfully installed $tool_name${NC}"
        else
            echo -e "${RED}[-] Failed to install $tool_name${NC}"
        fi
        cd -
    }

    install_tool https://github.com/blechschmidt/massdns.git "make && sudo make install"
    install_tool https://github.com/robertdavidgraham/masscan.git "make && sudo make install"
    install_tool https://github.com/xnl-h4ck3r/waymore.git "sudo python3 setup.py install"
    install_tool https://github.com/xnl-h4ck3r/xnLinkFinder.git "sudo python3 setup.py install"
    install_tool https://github.com/sqlmapproject/sqlmap.git ""
    install_tool https://github.com/0xacb/recollapse.git "pip3 install --user --upgrade -r requirements.txt && chmod +x install.sh && ./install.sh"
    install_tool https://github.com/jim3ma/crunch.git "make && sudo make install"

    pip install git+https://github.com/xnl-h4ck3r/urless.git
    pip3 install dnsgen uro py-altdns==1.0.2
    cargo install x8
    cargo install ripgen
    gem install wpscan
}

install_go() {
    get_latest_go_version() {
        curl -s https://go.dev/dl/ | grep -oP 'go[0-9]+\.[0-9]+\.[0-9]' | sort -uV | tail -1
    }

    GO_VERSION=$(get_latest_go_version)

    if [[ -z "$GO_VERSION" ]]; then
        echo -e "${RED}Failed to fetch the latest Go version. Aborting.${NC}"
        exit 1
    fi

    GO_BINARY_URL="https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz"
    INSTALL_DIR="/usr/local"

    curl -OL "$GO_BINARY_URL"
    sudo tar -C "$INSTALL_DIR" -xzf "${GO_VERSION}.linux-amd64.tar.gz"

    echo "export PATH=\$PATH:$INSTALL_DIR/go/bin" >> "$HOME/.bashrc"
    source "$HOME/.bashrc"

    echo "export PATH=\$PATH:$INSTALL_DIR/go/bin" >> "$HOME/.zshrc"
    echo "export PATH=\$PATH:$HOME/go/bin" >> "$HOME/.zshrc"
    echo "unalias gau" >> "$HOME/.zshrc"
    source "$HOME/.zshrc"

    rm "${GO_VERSION}.linux-amd64.tar.gz"

    if go version &> /dev/null; then
        echo -e "${GREEN}[+] Installing go tools...${NC}"
        install_go_package() {
            package=$1
            if go install $package &> /dev/null; then
                echo -e "${GREEN}[+] Successfully installed $package${NC}"
            else
                echo -e "${RED}[-] Failed to install $package${NC}"
            fi
        }

        install_go_package github.com/tomnomnom/waybackurls@latest
        install_go_package github.com/projectdiscovery/alterx/cmd/alterx@latest
        install_go_package github.com/projectdiscovery/dnsx/cmd/dnsx@latest
        install_go_package github.com/projectdiscovery/tlsx/cmd/tlsx@latest
        install_go_package github.com/tomnomnom/anew@latest
        install_go_package github.com/glebarez/cero@latest
        install_go_package github.com/iangcarroll/cookiemonster/cmd/cookiemonster@latest
        install_go_package github.com/ffuf/ffuf/v2@latest
        install_go_package github.com/lc/gau/v2/cmd/gau@latest
        install_go_package github.com/jaeles-project/gospider@latest
        install_go_package github.com/projectdiscovery/httpx/cmd/httpx@latest
        install_go_package github.com/hahwul/dalfox/v2@latest
        install_go_package github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
        install_go_package github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
        install_go_package github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
        install_go_package github.com/tomnomnom/unfurl@latest
        install_go_package github.com/projectdiscovery/asnmap/cmd/asnmap@latest
        install_go_package github.com/xm1k3/cent@latest
        install_go_package github.com/projectdiscovery/chaos-client/cmd/chaos@latest
        install_go_package github.com/OJ/gobuster/v3@latest
        install_go_package github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
        install_go_package github.com/projectdiscovery/katana/cmd/katana@latest
        install_go_package github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest
        install_go_package github.com/projectdiscovery/notify/cmd/notify@latest
        install_go_package github.com/d3mondev/puredns/v2@latest
        install_go_package github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
        install_go_package github.com/projectdiscovery/uncover/cmd/uncover@latest
        install_go_package github.com/ImAyrix/cut-cdn@latest
        install_go_package github.com/sw33tLie/sns@latest
        install_go_package github.com/BishopFox/jsluice/cmd/jsluice@latest
        install_go_package github.com/ImAyrix/fallparams@latest
        install_go_package github.com/glitchedgitz/cook/v2/cmd/cook@latest
        install_tool https://github.com/assetnote/kiterunner.git "make build && ln -s $(pwd)/dist/kr /usr/local/bin/kr"
    fi
}

# Main logic
case $OS in
    ubuntu)
        install_packages_ubuntu
        ;;
    centos)
        install_packages_centos
        ;;
    fedora)
        install_packages_fedora
        ;;
    *)
        echo -e "${RED}Unsupported operating system: $OS${NC}"
        exit 1
        ;;
esac

install_rust
install_misc
install_tools_from_source
install_go

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo -e "${GREEN}[+] Setup Complete!${NC}"
