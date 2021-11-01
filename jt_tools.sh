!#/bin/sh
echo "mise à jour"
apt update && apt -y full-upgrade > /dev/null
echo "Installation des Outils..."
apt install dnsutils cifs-utils nmon bpytop python3 htop sl inxi neofetch build-essentials gcc git curl
