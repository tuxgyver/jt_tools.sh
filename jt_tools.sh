 !#/bin/sh

# Fonction pour vérifier le bon déroulement de la commande de mise à jour
check_update_and_upgrade() {
    # Exécuter la commande et capturer le statut de sortie
    if apt update && apt full-upgrade -y > /dev/null; then
        echo "✅ La commande de mise à jour s'est déroulée avec succès."
        return 0
    else
        echo "❌ La commande de mise à jour a rencontré une erreur." >&2
        return 1
    fi
}

# Fliglet 
verif_install_figlet() {
    if ! command -v figlet >/dev/null 2>&1; then
        echo "⚙️ figlet non trouvé. Installation..."
        sudo apt install -y figlet
        if [ "$?" -eq 0 ]; then
            echo "✅ L'installation s'est déroulée avec succès."
        else
            echo "❌ L'installation a rencontré une erreur."
        fi
    else
        figlet JT-Tools
    fi
}

verif_install_outils() {
    local pkgs="dnsutils cifs-utils nmon python3 htop sl inxi fastfetch radeontop build-essential gcc git curl net-tools figlet \
    glances bmon btop cmatrix toilet lolcat fortune cowsay duf findutils intel-gpu-tools intel-microcode ncdu needrestart unattended-upgrades"
    for pkg in $pkgs; do
        if ! dpkg -l | grep -qw $pkg && ! command -v $pkg >/dev/null 2>&1; then
            echo "$pkg non installé, installation..."
            sudo apt-get install -y $pkg
            if [ "$?" -eq 0 ]; then
                echo "✅ L'installation s'est déroulée avec succès."
            else
                echo "❌ L'installation a rencontré une erreur."
            fi
        else
            echo "✅ $pkg déjà présent."
        fi
    done
}

optimisations(){
    # Ajuste le nombre maximal de fichiers qui peuvent être ouverts simultanément sur le système. 
    sudo sysctl -w fs.file-max=1000000
    # Ajuste le paramètre de configuration du protocole TCP qui contrôle le nombre maximal de "buckètes" (groupes) de connexions TCP en temps réel.
    sudo sysctl -w net.ipv4.tcp_max_tw_buckets=40000
    # Ajuste le nombre maximal de connexions simultanées sur un seul socket (soy)
    sudo sysctl -w net.core.somaxconn=1024
    # Ajuste le nombre maximal d'orphans (processus qui n'ont pas de parent) qui peuvent exister en même temps
    sudo sysctl -w net.ipv4.tcp_max_orphans=5000
    # Ajuste le nombre maximal de mappings (mappings de mémoire) qui peuvent être créés
    sudo sysctl -w vm.max_map_count=65536
    # Ajuste le nombre maximal de fichiers qui peuvent être ouverts simultanément sur le système
    sudo sysctl -w fs.nr_open=4096
    # Ajuste la durée pendant laquelle TCP maintient une connexion active en attente d'un paquet de réinitialisation (keep-alive)
    sudo sysctl -w net.ipv4.tcp_keepalive_time=60
    # Activez le mode de création des cookies syn pour les connexions TCP
    sudo sysctl -w net.ipv4.tcp_syncookies=1
    # Ajuste le nombre maximal d'éléments qui peuvent être stockés dans la file d'attente des paquets réseau
    sudo sysctl -w net.core.netdev_max_backlog=1000
}

clear
echo "ℹ️ Mise à jour en cours..."
check_update_and_upgrade
echo "ℹ️ Bienvenue..."
verif_install_figlet
echo "ℹ️ Installation des outils..."
verif_install_outils
echo "ℹ️ Optimisations du système..."
optimisations
echo "✅ Installations et optimisations terminées."
