# ============================================================================
# SCRIPTS/destroy.sh
# ============================================================================

#!/bin/bash
set -e

# ============================================================================
# Script de destruction de l'infrastructure AWS
# ============================================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Variables
ENVIRONMENT="${ENVIRONMENT:-dev}"
AWS_REGION="${AWS_REGION:-eu-west-1}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Avertissement
show_warning() {
    echo ""
    log_error "⚠️  ⚠️  ⚠️  ATTENTION ⚠️  ⚠️  ⚠️"
    echo ""
    log_error "Vous êtes sur le point de DÉTRUIRE l'infrastructure suivante:"
    echo ""
    echo "  Environnement: ${ENVIRONMENT}"
    echo "  Région AWS: ${AWS_REGION}"
    echo ""
    log_error "Cette action est IRRÉVERSIBLE!"
    log_error "Toutes les ressources seront supprimées!"
    echo ""
    
    # Protection pour l'environnement production
    if [ "$ENVIRONMENT" = "production" ]; then
        log_error "🚨 ENVIRONNEMENT DE PRODUCTION DÉTECTÉ! 🚨"
        echo ""
        read -p "Tapez 'DELETE-PRODUCTION' pour confirmer: " -r
        if [ "$REPLY" != "DELETE-PRODUCTION" ]; then
            log_info "Destruction annulée"
            exit 0
        fi
    fi
    
    read -p "Tapez 'yes' pour confirmer la destruction: " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        log_info "Destruction annulée"
        exit 0
    fi
}

# Sauvegarde avant destruction
backup_before_destroy() {
    log_info "Création d'une sauvegarde de sécurité..."
    
    BACKUP_DIR="$ROOT_DIR/backups/before-destroy"
    mkdir -p "$BACKUP_DIR"
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    
    cd "$ROOT_DIR"
    
    # Sauvegarde des outputs
    terraform output -json > "$BACKUP_DIR/outputs-${TIMESTAMP}.json" 2>/dev/null || true
    
    # Sauvegarde du state
    cp terraform.tfstate "$BACKUP_DIR/terraform.tfstate-${TIMESTAMP}" 2>/dev/null || true
    
    log_info "Sauvegarde créée dans: $BACKUP_DIR"
}

# Suppression des ressources Kubernetes
delete_kubernetes_resources() {
    log_info "Suppression des ressources Kubernetes..."
    
    if command -v kubectl &> /dev/null; then
        CLUSTER_NAME=$(terraform output -raw eks_cluster_name 2>/dev/null || echo "")
        
        if [ -n "$CLUSTER_NAME" ]; then
            aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION" 2>/dev/null || true
            
            # Supprimer les applications
            kubectl delete -f "$ROOT_DIR/kubernetes/applications/" --ignore-not-found=true 2>/dev/null || true
            
            # Supprimer les Prisma Defenders
            kubectl delete -f "$ROOT_DIR/kubernetes/prisma-defenders/" --ignore-not-found=true 2>/dev/null || true
            
            log_info "Ressources Kubernetes supprimées"
        fi
    fi
}

# Destruction Terraform
terraform_destroy() {
    log_info "Destruction de l'infrastructure Terraform..."
    
    cd "$ROOT_DIR"
    
    terraform destroy \
        -var-file="environments/${ENVIRONMENT}/terraform.tfvars" \
        -auto-approve
    
    log_info "Infrastructure détruite"
}

# Nettoyage
cleanup() {
    log_info "Nettoyage des fichiers temporaires..."
    
    cd "$ROOT_DIR"
    
    rm -f tfplan
    rm -f outputs.json
    rm -f tfsec-report.json
    rm -f cost-estimate.json
    
    log_info "Nettoyage terminé"
}

# Fonction principale
main() {
    echo "════════════════════════════════════════════════════════════"
    echo "  💣 Destruction Infrastructure AWS"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    # Avertissement
    show_warning
    
    # Sauvegarde
    backup_before_destroy
    
    # Suppression Kubernetes
    delete_kubernetes_resources
    
    # Destruction Terraform
    terraform_destroy
    
    # Nettoyage
    cleanup
    
    echo ""
    echo "════════════════════════════════════════════════════════════"
    log_info "✅ Infrastructure détruite"
    echo "════════════════════════════════════════════════════════════"
}

# Exécution
main "$@"
