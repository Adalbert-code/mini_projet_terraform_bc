#!/bin/bash
# =============================================================================
# Script Bash pour générer le schéma de l'infrastructure Terraform
# =============================================================================

set -e

# Paramètres par défaut
OUTPUT_FORMAT="${1:-png}"
OUTPUT_FILE="${2:-infrastructure}"
OPEN_AFTER="${3:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/../app"
OUTPUT_DIR="$SCRIPT_DIR/../docs"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Créer le dossier docs s'il n'existe pas
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    echo -e "${GREEN}Dossier 'docs' créé${NC}"
fi

# Vérifier si Graphviz est installé
if ! command -v dot &> /dev/null; then
    echo -e "${RED}Graphviz n'est pas installé!${NC}"
    echo ""
    echo -e "${YELLOW}Installez-le avec une des commandes suivantes:${NC}"
    echo -e "${CYAN}  Ubuntu/Debian: sudo apt-get install graphviz${NC}"
    echo -e "${CYAN}  MacOS: brew install graphviz${NC}"
    echo -e "${CYAN}  CentOS/RHEL: sudo yum install graphviz${NC}"
    exit 1
fi

echo -e "${CYAN}=== Génération du schéma d'infrastructure ===${NC}"
echo ""

# Se déplacer dans le dossier app
cd "$APP_DIR"

# Vérifier si Terraform est initialisé
if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}Initialisation de Terraform...${NC}"
    terraform init -backend=false > /dev/null 2>&1
fi

# Générer le graphe
DOT_FILE="$OUTPUT_DIR/$OUTPUT_FILE.dot"
OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_FILE.$OUTPUT_FORMAT"

echo -e "${YELLOW}Génération du fichier DOT...${NC}"
terraform graph > "$DOT_FILE"

echo -e "${YELLOW}Conversion en $OUTPUT_FORMAT...${NC}"
dot -T"$OUTPUT_FORMAT" "$DOT_FILE" -o "$OUTPUT_PATH"

# Nettoyer le fichier DOT intermédiaire
rm -f "$DOT_FILE"

echo ""
echo -e "${GREEN}Schéma généré avec succès!${NC}"
echo -e "${CYAN}Fichier: $OUTPUT_PATH${NC}"

# Ouvrir le fichier si demandé
if [ "$OPEN_AFTER" = "true" ]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open "$OUTPUT_PATH"
    elif command -v open &> /dev/null; then
        open "$OUTPUT_PATH"
    fi
fi
