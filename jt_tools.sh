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
    glances bmon btop cmatrix toilet lolcat fortune cowsay duf findutils intel-gpu-tools intel-microcode ncdu"
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

clear
echo "ℹ️ Mise à jour en cours..."
check_update_and_upgrade
echo "ℹ️ Bienvenue..."
verif_install_figlet
echo "ℹ️ Installation des outils..."
verif_install_outils
