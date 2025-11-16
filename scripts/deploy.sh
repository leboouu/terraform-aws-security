# ============================================================================
# SCRIPTS/deploy.sh
# ============================================================================

#!/bin/bash
set -e

# ============================================================================
# Script de déploiement automatisé de l'infrastructure AWS sécurisée
# ============================================================================

# Couleurs pour les outputs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
PROJECT_NAME="${PROJECT_NAME:-secure-cloud-app}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
AWS_REGION="${AWS_REGION:-eu-west-1}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifications préalables
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier Terraform
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform n'est pas installé"
        exit 1
    fi
    
    terraform_version=$(terraform version -json | jq -r '.terraform_version')
    log_success "Terraform version: $terraform_version"
    
    # Vérifier AWS CLI
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI n'est pas installé"
        exit 1
    fi
    
    aws_version=$(aws --version)
    log_success "AWS CLI: $aws_version"
    
    # Vérifier kubectl
    if ! command -v kubectl &> /dev/null; then
        log_warning "kubectl n'est pas installé (optionnel)"
    else
        kubectl_version=$(kubectl version --client -o json | jq -r '.clientVersion.gitVersion')
        log_success "kubectl version: $kubectl_version"
    fi
    
    # Vérifier jq
    if ! command -v jq &> /dev/null; then
        log_error "jq n'est pas installé"
        exit 1
    fi
    
    # Vérifier les credentials AWS
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "Credentials AWS non configurés ou invalides"
        exit 1
    fi
    
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    log_success "AWS Account ID: $AWS_ACCOUNT_ID"
}

# Validation de la configuration
validate_terraform() {
    log_info "Validation de la configuration Terraform..."
    
    cd "$ROOT_DIR"
    
    # Formatter le code
    terraform fmt -recursive
    
    # Validation syntaxique
    if ! terraform validate; then
        log_error "Validation Terraform échouée"
        exit 1
    fi
    
    log_success "Configuration Terraform valide"
}

# Sécurité - Scan avec tfsec
security_scan() {
    log_info "Scan de sécurité avec tfsec..."
    
    if command -v tfsec &> /dev/null; then
        tfsec "$ROOT_DIR" --format json > tfsec-report.json
        
        CRITICAL_ISSUES=$(jq '[.results[] | select(.severity=="CRITICAL")] | length' tfsec-report.json)
        HIGH_ISSUES=$(jq '[.results[] | select(.severity=="HIGH")] | length' tfsec-report.json)
        
        if [ "$CRITICAL_ISSUES" -gt 0 ]; then
            log_error "❌ $CRITICAL_ISSUES problèmes CRITIQUES détectés!"
            jq '.results[] | select(.severity=="CRITICAL")' tfsec-report.json
            exit 1
        fi
        
        if [ "$HIGH_ISSUES" -gt 0 ]; then
            log_warning "⚠️  $HIGH_ISSUES problèmes HIGH détectés"
            jq '.results[] | select(.severity=="HIGH")' tfsec-report.json
        fi
        
        log_success "Scan de sécurité terminé"
    else
        log_warning "tfsec n'est pas installé, scan de sécurité ignoré"
    fi
}

# Estimation des coûts
estimate_costs() {
    log_info "Estimation des coûts avec Infracost..."
    
    if command -v infracost &> /dev/null; then
        infracost breakdown --path "$ROOT_DIR" --format json > cost-estimate.json
        
        MONTHLY_COST=$(jq -r '.totalMonthlyCost' cost-estimate.json)
        log_info "💰 Coût mensuel estimé: \$MONTHLY_COST"
    else
        log_warning "infracost n'est pas installé, estimation des coûts ignorée"
    fi
}

# Initialisation Terraform
terraform_init() {
    log_info "Initialisation de Terraform..."
    
    cd "$ROOT_DIR"
    
    terraform init -upgrade
    
    log_success "Terraform initialisé"
}

# Planification
terraform_plan() {
    log_info "Planification des changements Terraform..."
    
    cd "$ROOT_DIR"
    
    terraform plan -out=tfplan -var-file="environments/${ENVIRONMENT}/terraform.tfvars"
    
    log_success "Plan Terraform créé: tfplan"
}

# Demande de confirmation
confirm_deployment() {
    echo ""
    log_warning "⚠️  Vous êtes sur le point de déployer sur l'environnement: ${ENVIRONMENT}"
    log_warning "⚠️  Région AWS: ${AWS_REGION}"
    log_warning "⚠️  Account ID: ${AWS_ACCOUNT_ID}"
    echo ""
    
    read -p "Voulez-vous continuer? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        log_info "Déploiement annulé"
        exit 0
    fi
}

# Application
terraform_apply() {
    log_info "🚀 Déploiement de l'infrastructure..."
    
    cd "$ROOT_DIR"
    
    if terraform apply -auto-approve tfplan; then
        log_success "✅ Infrastructure déployée avec succès!"
    else
        log_error "❌ Échec du déploiement"
        exit 1
    fi
}

# Configuration kubectl
configure_kubectl() {
    log_info "Configuration de kubectl..."
    
    CLUSTER_NAME=$(terraform output -raw eks_cluster_name 2>/dev/null || echo "")
    
    if [ -n "$CLUSTER_NAME" ]; then
        aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"
        log_success "kubectl configuré pour le cluster: $CLUSTER_NAME"
        
        # Vérifier la connexion
        if kubectl get nodes &> /dev/null; then
            log_success "Connexion au cluster réussie"
            kubectl get nodes
        else
            log_warning "Impossible de se connecter au cluster (peut prendre quelques minutes)"
        fi
    else
        log_warning "Cluster EKS non trouvé dans les outputs"
    fi
}

# Déploiement des ressources Kubernetes
deploy_kubernetes_resources() {
    log_info "Déploiement des ressources Kubernetes..."
    
    if [ -d "$ROOT_DIR/kubernetes" ]; then
        # Déployer Prisma Defenders
        if [ -f "$ROOT_DIR/kubernetes/prisma-defenders/daemonset.yaml" ]; then
            kubectl apply -f "$ROOT_DIR/kubernetes/prisma-defenders/"
            log_success "Prisma Defenders déployés"
        fi
        
        # Déployer les Network Policies
        if [ -d "$ROOT_DIR/kubernetes/network-policies" ]; then
            kubectl apply -f "$ROOT_DIR/kubernetes/network-policies/"
            log_success "Network Policies déployées"
        fi
        
        # Déployer les applications
        if [ -d "$ROOT_DIR/kubernetes/applications" ]; then
            kubectl apply -f "$ROOT_DIR/kubernetes/applications/"
            log_success "Applications déployées"
        fi
    else
        log_warning "Répertoire kubernetes/ non trouvé"
    fi
}

# Vérification post-déploiement
post_deployment_checks() {
    log_info "Vérifications post-déploiement..."
    
    cd "$ROOT_DIR"
    
    # Vérifier les outputs Terraform
    log_info "Outputs Terraform:"
    terraform output -json > outputs.json
    
    # Afficher les informations importantes
    if [ -s outputs.json ]; then
        echo ""
        log_info "📊 Informations de déploiement:"
        echo ""
        
        VPC_ID=$(jq -r '.vpc_id.value // empty' outputs.json)
        [ -n "$VPC_ID" ] && echo "  VPC ID: $VPC_ID"
        
        EKS_CLUSTER=$(jq -r '.eks_cluster_name.value // empty' outputs.json)
        [ -n "$EKS_CLUSTER" ] && echo "  EKS Cluster: $EKS_CLUSTER"
        
        RDS_ENDPOINT=$(jq -r '.rds_endpoint.value // empty' outputs.json)
        [ -n "$RDS_ENDPOINT" ] && echo "  RDS Endpoint: $RDS_ENDPOINT"
        
        ALB_DNS=$(jq -r '.alb_dns_name.value // empty' outputs.json)
        [ -n "$ALB_DNS" ] && echo "  ALB DNS: $ALB_DNS"
        
        echo ""
    fi
    
    # Vérifier la santé du cluster EKS
    if command -v kubectl &> /dev/null && kubectl get nodes &> /dev/null; then
        log_info "État du cluster Kubernetes:"
        kubectl get nodes
        kubectl get pods --all-namespaces | head -20
    fi
}

# Sauvegarde de l'état
backup_state() {
    log_info "Sauvegarde de l'état Terraform..."
    
    BACKUP_DIR="$ROOT_DIR/backups"
    mkdir -p "$BACKUP_DIR"
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/terraform-${ENVIRONMENT}-${TIMESTAMP}.tar.gz"
    
    cd "$ROOT_DIR"
    tar -czf "$BACKUP_FILE" \
        terraform.tfstate* \
        .terraform/ \
        tfplan \
        outputs.json \
        2>/dev/null || true
    
    log_success "État sauvegardé dans: $BACKUP_FILE"
}

# Génération de documentation
generate_documentation() {
    log_info "Génération de la documentation..."
    
    if command -v terraform-docs &> /dev/null; then
        cd "$ROOT_DIR"
        terraform-docs markdown table . > TERRAFORM.md
        log_success "Documentation générée: TERRAFORM.md"
    else
        log_warning "terraform-docs n'est pas installé"
    fi
}

# Fonction principale
main() {
    echo "════════════════════════════════════════════════════════════"
    echo "  🚀 Déploiement Infrastructure AWS Sécurisée"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    # Étape 1: Vérifications
    check_prerequisites
    
    # Étape 2: Validation
    validate_terraform
    
    # Étape 3: Scan de sécurité
    security_scan
    
    # Étape 4: Estimation des coûts
    estimate_costs
    
    # Étape 5: Initialisation
    terraform_init
    
    # Étape 6: Planification
    terraform_plan
    
    # Étape 7: Confirmation
    confirm_deployment
    
    # Étape 8: Application
    terraform_apply
    
    # Étape 9: Configuration kubectl
    configure_kubectl
    
    # Étape 10: Déploiement Kubernetes
    deploy_kubernetes_resources
    
    # Étape 11: Vérifications
    post_deployment_checks
    
    # Étape 12: Sauvegarde
    backup_state
    
    # Étape 13: Documentation
    generate_documentation
    
    echo ""
    echo "════════════════════════════════════════════════════════════"
    log_success "✅ Déploiement terminé avec succès!"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    log_info "Pour configurer kubectl:"
    echo "  aws eks update-kubeconfig --name $EKS_CLUSTER --region $AWS_REGION"
    echo ""
    log_info "Pour accéder aux outputs:"
    echo "  terraform output"
    echo ""
}

# Gestion des erreurs
trap 'log_error "Une erreur est survenue. Déploiement interrompu."; exit 1' ERR

# Exécution
main "$@"
