#!/bin/bash

# Script de vérification des dépendances nécessaires
# Auteur: Yilizire - EFREI Paris M2

set -e

echo "=========================================="
echo "🔍 Vérification des dépendances..."
echo "=========================================="
echo ""

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteur d'erreurs
ERRORS=0

# Fonction de vérification
check_command() {
    local cmd=$1
    local name=$2
    local install_hint=$3
    
    if command -v $cmd &> /dev/null; then
        echo -e "${GREEN}✅ $name est installé${NC}"
        # Cas spécial pour kubectl
        if [ "$cmd" = "kubectl" ]; then
            $cmd version --client 2>&1 | head -n 1 | sed 's/^/   /'
        else
            $cmd --version 2>&1 | head -n 1 | sed 's/^/   /'
        fi
    else
        echo -e "${RED}❌ $name n'est pas installé${NC}"
        echo -e "${YELLOW}   💡 Installation: $install_hint${NC}"
        ERRORS=$((ERRORS + 1))
    fi
    echo ""
}

# Vérification de Docker
check_command "docker" "Docker" "apt-get install docker.io"

# Vérification de Packer
check_command "packer" "Packer" "wget https://releases.hashicorp.com/packer/1.10.0/packer_1.10.0_linux_amd64.zip && unzip packer_*.zip && sudo mv packer /usr/local/bin/"

# Vérification de K3d
check_command "k3d" "K3d" "curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash"

# Vérification de kubectl
check_command "kubectl" "kubectl" "curl -LO https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && sudo install kubectl /usr/local/bin/"

# Vérification d'Ansible
check_command "ansible" "Ansible" "pip install ansible"

# Vérification de Python
check_command "python3" "Python 3" "apt-get install python3"

echo "=========================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Toutes les dépendances sont installées !${NC}"
    echo "=========================================="
    exit 0
else
    echo -e "${RED}❌ $ERRORS dépendance(s) manquante(s)${NC}"
    echo "=========================================="
    exit 1
fi
