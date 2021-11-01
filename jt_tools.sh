!#/bin/sh
echo "Mise à jour..."
apt update && apt full-upgrade -y > /dev/null
echo "Installation des Outils..."
apt install dnsutils cifs-utils nmon python3 figlet htop sl inxi neofetch build-essentials gcc git curl net-tools -y
echo "Installation de bpytop"
apt install -y bpytop
