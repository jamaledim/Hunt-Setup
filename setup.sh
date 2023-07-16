#!/bin/bash

### Server setup script ###


if [[ `cat /etc/os-release | grep ubuntu` ]];then

echo "[+] Installing Packages..."

curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list

apt update && apt upgrade && apt full-upgrade && apt autoclean && apt autoremove &>/dev/null
apt install -y vim curl zsh git gcc net-tools ruby ruby-dev cloudflare-warp tmux build-essential postgresql make python3-apt python3-distutils bind9 certbot python3-certbot-nginx libssl-dev zip unzip jq nginx pkg-config mysql-server php php-curl php-fpm php-mysql dnsutils whois python3-pip &> /dev/null

fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
curl -Ls https://github.com/ipinfo/cli/releases/download/ipinfo-2.10.1/deb.sh | sh
curl -L https://sourcegraph.com/.api/src-cli/src_linux_amd64 -o /usr/local/bin/src
chmod +x /usr/local/bin/src
warp-cli register
warp-cli set-mode proxy
warp-cli set-proxy-port 5423

echo "[+] Installing Tools from source..."
mkdir -p Tools && cd Tools 

git clone https://github.com/blechschmidt/massdns.git;
cd massdns && make
sudo make install  
cd -

git clone https://github.com/robertdavidgraham/masscan
cd masscan && make
sudo make install
cd -

git clone https://github.com/xnl-h4ck3r/waymore.git
cd waymore
sudo python3 setup.py install
cd -

git clone https://github.com/xnl-h4ck3r/xnLinkFinder.git
cd xnLinkFinder && sudo python3 setup.py install
cd -

git clone https://github.com/phor3nsic/favicon_hash_shodan.git
cd favicon_hash_shodan && pip3 install -r requirements.txt
cd -


git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev

cargo install x8

cargo install ripgen

git clone https://github.com/devanshbatham/ParamSpider
cd ParamSpider
pip3 install -r requirements.txt 
cd -

pip3 install dnsgen uro py-altdns==1.0.2

git clone https://github.com/assetnote/kiterunner.git
cd kiterunner && make build 
ln -s $(pwd)/dist/kr /usr/local/bin/kr 
cd -

git clone https://github.com/0xacb/recollapse.git
cd recollapse && pip3 install --user --upgrade -r requirements.txt
chmod +x install.sh && ./install.sh
cd -

git clone https://github.com/jim3ma/crunch.git
cd crunch
make 
make install
cd -

git clone git clone https://github.com/mha4065/fAllParams.git
cd fAllParams
pip3 install -r requirements.txt
chmod +x fAllParams.py
cd -

gem install wpscan




echo "[+] Installing go tools... "
go install github.com/tomnomnom/waybackurls@latest &> /dev/null
go install github.com/projectdiscovery/alterx/cmd/alterx@latest &> /dev/null
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest &> /dev/null
go install github.com/projectdiscovery/tlsx/cmd/tlsx@latest &> /dev/null
go install -v github.com/tomnomnom/anew@latest &> /dev/null
go install github.com/glebarez/cero@latest &> /dev/null
go install github.com/iangcarroll/cookiemonster/cmd/cookiemonster@latest &> /dev/null
go install github.com/ffuf/ffuf/v2@latest &> /dev/null
go install github.com/lc/gau/v2/cmd/gau@latest &>/dev/null
go install github.com/jaeles-project/gospider@latest &> /dev/null
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest &> /dev/null
go install github.com/hahwul/dalfox/v2@latest &> /dev/null
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest &> /dev/null
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest &> /dev/null
go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest &> /dev/null
go install github.com/tomnomnom/unfurl@latest &> /dev/null
go install github.com/projectdiscovery/asnmap/cmd/asnmap@latest &> /dev/null
go install -v github.com/xm1k3/cent@latest &> /dev/null
go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest &> /dev/null
go install github.com/OJ/gobuster/v3@latest &> /dev/null
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest &> /dev/null
go install github.com/projectdiscovery/katana/cmd/katana@latest &> /dev/null
go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest &> /dev/null
go install -v github.com/projectdiscovery/notify/cmd/notify@latest &> /dev/null
go install github.com/d3mondev/puredns/v2@latest &> /dev/null
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &> /dev/null
go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest &> /dev/null
go install github.com/ImAyrix/cut-cdn@latest &> /dev/null
go install github.com/sw33tLie/sns@latest &> /dev/null
go install github.com/BishopFox/jsluice/cmd/jsluice@latest &>/dev/null


sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
