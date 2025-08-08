#!/bin/bash

#=======================================================================
# JT-Tools - Script d'installation et de configuration système
# Version: 2.0.0
# Auteur: Fontaine Johnny
# Description: Script complet pour l'installation d'outils système,
#              serveur web LAMP (Apache, MariaDB, PHP) avec menu
#              interactif et diverses options de maintenance.
# Date: $(date +%Y-%m-%d)
#=======================================================================

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Variables globales
VERSION="2.0.0"
AUTHOR="Fontaine Johnny"
LOG_FILE="/tmp/jt-tools.log"

# Fonction pour le logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Fonction pour afficher le header avec figlet si disponible
show_header() {
    clear
    echo -e "${CYAN}=================================================================${NC}"
    if command -v figlet >/dev/null 2>&1; then
        echo -e "${PURPLE}"
        figlet -f small "JT-Tools"
        echo -e "${NC}"
    else
        echo -e "${BOLD}${PURPLE}                    JT-TOOLS${NC}"
    fi
    echo -e "${YELLOW}                    Version $VERSION${NC}"
    echo -e "${GREEN}                 Auteur: $AUTHOR${NC}"
    echo -e "${CYAN}=================================================================${NC}"
    echo -e "${BLUE}Description:${NC}"
    echo -e "${WHITE}Ce script permet l'installation automatisée d'outils système,${NC}"
    echo -e "${WHITE}serveur LAMP (Apache, MariaDB, PHP) avec activation des modules${NC}"
    echo -e "${WHITE}nécessaires et diverses options de maintenance.${NC}"
    echo -e "${CYAN}=================================================================${NC}"
    echo ""
}

# Fonction pour afficher le menu principal
show_menu() {
    echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${BOLD}                    MENU PRINCIPAL                           ${NC}${YELLOW}│${NC}"
    echo -e "${YELLOW}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}1.${NC} ${CYAN}Mise à jour système complète                        ${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}2.${NC} ${CYAN}Installer les outils de base                        ${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}3.${NC} ${CYAN}Installer serveur web LAMP (Apache+MariaDB+PHP)    ${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}4.${NC} ${CYAN}Configuration avancée Apache                        ${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}5.${NC} ${CYAN}Gestion MariaDB/MySQL                               ${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}6.${NC} ${CYAN}Information système                                 ${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}7.${NC} ${CYAN}Nettoyage système                                   ${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}8.${NC} ${CYAN}Afficher les logs                                   ${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${RED}0.${NC} ${RED}Quitter                                             ${YELLOW}│${NC}"
    echo -e "${YELLOW}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# Fonction pour vérifier le bon déroulement de la commande de mise à jour
check_update_and_upgrade() {
    echo -e "${BLUE}ℹ️  Mise à jour du système en cours...${NC}"
    log_message "Début de la mise à jour système"
    
    # Exécuter la commande et capturer le statut de sortie
    if apt update && apt full-upgrade -y > /dev/null; then
        echo -e "${GREEN}✅ La commande de mise à jour s'est déroulée avec succès.${NC}"
        log_message "Mise à jour système réussie"
        return 0
    else
        echo -e "${RED}❌ La commande de mise à jour a rencontré une erreur.${NC}" >&2
        log_message "Erreur lors de la mise à jour système"
        return 1
    fi
}

# Figlet 
verif_install_figlet() {
    if ! command -v figlet >/dev/null 2>&1; then
        echo -e "${YELLOW}⚙️  figlet non trouvé. Installation...${NC}"
        sudo apt install -y figlet
        if [ "$?" -eq 0 ]; then
            echo -e "${GREEN}✅ L'installation de figlet s'est déroulée avec succès.${NC}"
            log_message "Installation de figlet réussie"
        else
            echo -e "${RED}❌ L'installation de figlet a rencontré une erreur.${NC}"
            log_message "Erreur lors de l'installation de figlet"
        fi
    else
        echo -e "${GREEN}✅ figlet déjà présent.${NC}"
    fi
}

# Installation des outils de base
verif_install_outils() {
    echo -e "${BLUE}ℹ️  Installation des outils de base...${NC}"
    local pkgs="dnsutils cifs-utils nmon python3 htop sl inxi fastfetch radeontop build-essential gcc git curl net-tools figlet \
    glances bmon btop cmatrix toilet lolcat fortune cowsay duf findutils intel-gpu-tools intel-microcode ncdu needrestart unattended-upgrades"
    
    for pkg in $pkgs; do
        if ! dpkg -l | grep -qw $pkg && ! command -v $pkg >/dev/null 2>&1; then
            echo -e "${YELLOW}⚙️  $pkg non installé, installation...${NC}"
            sudo apt-get install -y $pkg
            if [ "$?" -eq 0 ]; then
                echo -e "${GREEN}✅ Installation de $pkg réussie.${NC}"
                log_message "Installation de $pkg réussie"
            else
                echo -e "${RED}❌ L'installation de $pkg a rencontré une erreur.${NC}"
                log_message "Erreur lors de l'installation de $pkg"
            fi
        else
            echo -e "${GREEN}✅ $pkg déjà présent.${NC}"
        fi
    done
}

# Installation du serveur LAMP
install_lamp_server() {
    echo -e "${BLUE}ℹ️  Installation du serveur LAMP (Apache + MariaDB + PHP)...${NC}"
    log_message "Début installation serveur LAMP"
    
    # Installation d'Apache
    echo -e "${YELLOW}⚙️  Installation d'Apache2...${NC}"
    sudo apt install -y apache2
    if [ "$?" -eq 0 ]; then
        echo -e "${GREEN}✅ Apache2 installé avec succès.${NC}"
        sudo systemctl enable apache2
        sudo systemctl start apache2
        log_message "Installation Apache2 réussie"
    else
        echo -e "${RED}❌ Erreur lors de l'installation d'Apache2.${NC}"
        log_message "Erreur installation Apache2"
        return 1
    fi
    
    # Installation de MariaDB
    echo -e "${YELLOW}⚙️  Installation de MariaDB...${NC}"
    sudo apt install -y mariadb-server mariadb-client
    if [ "$?" -eq 0 ]; then
        echo -e "${GREEN}✅ MariaDB installé avec succès.${NC}"
        sudo systemctl enable mariadb
        sudo systemctl start mariadb
        log_message "Installation MariaDB réussie"
        
        echo -e "${CYAN}ℹ️  Sécurisation de MariaDB recommandée. Exécuter 'sudo mysql_secure_installation' manuellement.${NC}"
    else
        echo -e "${RED}❌ Erreur lors de l'installation de MariaDB.${NC}"
        log_message "Erreur installation MariaDB"
        return 1
    fi
    
    # Installation de PHP
    echo -e "${YELLOW}⚙️  Installation de PHP et modules...${NC}"
    sudo apt install -y php php-mysql libapache2-mod-php php-cli php-curl php-gd php-mbstring php-xml php-zip php-json php-common php-bcmath
    if [ "$?" -eq 0 ]; then
        echo -e "${GREEN}✅ PHP et modules installés avec succès.${NC}"
        log_message "Installation PHP réussie"
    else
        echo -e "${RED}❌ Erreur lors de l'installation de PHP.${NC}"
        log_message "Erreur installation PHP"
        return 1
    fi
    
    # Activation des modules Apache
    echo -e "${YELLOW}⚙️  Activation des modules Apache...${NC}"
    sudo a2enmod rewrite
    sudo a2enmod ssl
    sudo a2enmod headers
    sudo a2enmod deflate
    sudo a2enmod expires
    
    # Redémarrage d'Apache
    sudo systemctl restart apache2
    
    # Test de configuration
    if systemctl is-active --quiet apache2 && systemctl is-active --quiet mariadb; then
        echo -e "${GREEN}🎉 Serveur LAMP installé et configuré avec succès !${NC}"
        echo -e "${CYAN}ℹ️  Apache: http://$(hostname -I | awk '{print $1}')${NC}"
        echo -e "${CYAN}ℹ️  Fichiers web: /var/www/html/${NC}"
        log_message "Installation serveur LAMP terminée avec succès"
    else
        echo -e "${RED}❌ Problème avec les services. Vérifiez les logs.${NC}"
        log_message "Problème avec les services LAMP"
    fi
}

# Configuration avancée Apache
configure_apache() {
    echo -e "${BLUE}ℹ️  Configuration avancée d'Apache...${NC}"
    
    # Création d'un virtual host par défaut sécurisé
    sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerAdmin admin@localhost
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
    
    # Configuration de sécurité
    sudo tee /etc/apache2/conf-available/security-headers.conf > /dev/null <<EOF
<IfModule mod_headers.c>
    Header always set X-Frame-Options SAMEORIGIN
    Header always set X-Content-Type-Options nosniff
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
</IfModule>
EOF
    
    sudo a2enconf security-headers
    sudo systemctl reload apache2
    
    echo -e "${GREEN}✅ Configuration Apache avancée appliquée.${NC}"
}

# Gestion MariaDB
manage_mariadb() {
    echo -e "${BLUE}ℹ️  Gestion MariaDB...${NC}"
    echo -e "${YELLOW}1.${NC} Sécuriser l'installation"
    echo -e "${YELLOW}2.${NC} Créer une base de données"
    echo -e "${YELLOW}3.${NC} Afficher le statut"
    echo -e "${YELLOW}4.${NC} Retour au menu principal"
    echo ""
    read -p "Votre choix: " db_choice
    
    case $db_choice in
        1)
            sudo mysql_secure_installation
            ;;
        2)
            read -p "Nom de la base de données: " dbname
            read -p "Nom d'utilisateur: " dbuser
            read -s -p "Mot de passe: " dbpass
            echo ""
            sudo mysql -e "CREATE DATABASE $dbname; CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass'; GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost'; FLUSH PRIVILEGES;"
            echo -e "${GREEN}✅ Base de données créée.${NC}"
            ;;
        3)
            sudo systemctl status mariadb
            ;;
    esac
}

# Informations système
show_system_info() {
    echo -e "${BLUE}ℹ️  Informations système:${NC}"
    echo ""
    
    if command -v fastfetch >/dev/null 2>&1; then
        fastfetch
    elif command -v inxi >/dev/null 2>&1; then
        inxi -F
    else
        echo -e "${CYAN}Système:${NC} $(uname -a)"
        echo -e "${CYAN}Uptime:${NC} $(uptime)"
        echo -e "${CYAN}Mémoire:${NC}"
        free -h
        echo -e "${CYAN}Disque:${NC}"
        df -h
    fi
}

# Nettoyage système
system_cleanup() {
    echo -e "${BLUE}ℹ️  Nettoyage du système...${NC}"
    
    sudo apt autoremove -y
    sudo apt autoclean
    sudo apt clean
    
    # Nettoyage des logs anciens
    sudo journalctl --vacuum-time=7d
    
    echo -e "${GREEN}✅ Nettoyage terminé.${NC}"
    log_message "Nettoyage système effectué"
}

# Affichage des logs
show_logs() {
    echo -e "${BLUE}ℹ️  Logs du script:${NC}"
    if [ -f "$LOG_FILE" ]; then
        tail -20 "$LOG_FILE"
    else
        echo -e "${YELLOW}Aucun log trouvé.${NC}"
    fi
}

# Fonction pour pause
pause() {
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction principale
main() {
    # Vérification des privilèges root pour certaines opérations
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}⚠️  Ce script ne doit pas être exécuté en tant que root.${NC}"
        echo -e "${YELLOW}Utilisez sudo pour les commandes qui en ont besoin.${NC}"
        exit 1
    fi
    
    # Initialisation
    log_message "Démarrage de JT-Tools v$VERSION"
    
    # Boucle principale du menu
    while true; do
        show_header
        show_menu
        
        read -p "$(echo -e ${GREEN}Votre choix [0-8]: ${NC})" choice
        
        case $choice in
            1)
                check_update_and_upgrade
                pause
                ;;
            2)
                verif_install_figlet
                verif_install_outils
                pause
                ;;
            3)
                install_lamp_server
                pause
                ;;
            4)
                configure_apache
                pause
                ;;
            5)
                manage_mariadb
                pause
                ;;
            6)
                show_system_info
                pause
                ;;
            7)
                system_cleanup
                pause
                ;;
            8)
                show_logs
                pause
                ;;
            0)
                echo -e "${GREEN}Au revoir !${NC}"
                log_message "Arrêt de JT-Tools"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Choix invalide. Veuillez choisir entre 0 et 8.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Gestion des signaux
trap 'echo -e "\n${RED}Script interrompu par l utilisateur${NC}"; exit 1' INT TERM

# Lancement du script
main