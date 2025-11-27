#!/bin/bash

# Script pour corriger la dépendance circulaire Terraform
# Usage: ./fix-cycle.sh

set -e

echo "=== Diagnostic de la dépendance circulaire ==="
echo ""

# 1. Analyser le graphe de dépendances
echo "1. Analyse du graphe de dépendances..."
terraform graph > graph.dot 2>/dev/null || echo "  ⚠️  Erreur lors de la génération du graphe"

# 2. Trouver où sont définis les providers
echo ""
echo "2. Configuration actuelle des providers Helm/Kubernetes:"
grep -A 10 'provider "helm"' *.tf 2>/dev/null || echo "  Provider Helm non trouvé"
echo ""
grep -A 10 'provider "kubernetes"' *.tf 2>/dev/null || echo "  Provider Kubernetes non trouvé"

# 3. Trouver les data sources problématiques
echo ""
echo "3. Data sources EKS:"
grep -n 'data "aws_eks_cluster"' *.tf 2>/dev/null
grep -n 'data "aws_eks_cluster_auth"' *.tf 2>/dev/null

# 4. Trouver les helm_release dans le module EKS
echo ""
echo "4. Helm releases dans le module EKS:"
find modules/eks -name "*.tf" -exec grep -l "helm_release" {} \; 2>/dev/null || echo "  Aucun trouvé"

echo ""
echo "=== Solutions proposées ==="
echo ""
echo "Option 1: Déploiement en deux étapes (Rapide)"
echo "Option 2: Réorganiser la configuration (Recommandé)"
echo "Option 3: Séparer les addons Helm en module distinct"
echo ""

read -p "Choisissez une option (1, 2, ou 3): " choice

case $choice in
  1)
    echo ""
    echo "=== Déploiement en deux étapes ==="
    echo ""
    echo "Étape 1: Créer l'infrastructure de base"
    echo "----------------------------------------"
    echo "terraform apply -target=module.vpc -auto-approve"
    echo "terraform apply -target=module.eks -auto-approve"
    echo ""
    echo "Étape 2: Déployer les addons Helm"
    echo "----------------------------------------"
    echo "terraform apply -auto-approve"
    echo ""
    read -p "Voulez-vous exécuter maintenant? (o/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Oo]$ ]]; then
      echo "Création du VPC..."
      terraform apply -target=module.vpc -auto-approve
      
      echo ""
      echo "Création du cluster EKS..."
      terraform apply -target=module.eks -auto-approve
      
      echo ""
      echo "Déploiement des addons..."
      terraform apply -auto-approve
      
      echo ""
      echo "✅ Déploiement terminé!"
    fi
    ;;
    
  2)
    echo ""
    echo "=== Réorganisation de la configuration ==="
    echo ""
    
    # Créer une sauvegarde
    echo "Création de sauvegardes..."
    cp providers.tf providers.tf.bak 2>/dev/null || cp main.tf main.tf.bak
    
    echo ""
    echo "Modification des providers pour utiliser les outputs du module..."
    
    # Créer un nouveau fichier providers.tf
    cat > providers.tf.new <<'EOF'
# providers.tf
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Configuration Kubernetes - utiliser les outputs du module EKS
provider "kubernetes" {
  host                   = try(module.eks.cluster_endpoint, "")
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  token                  = try(module.eks.cluster_token, "")
}

# Configuration Helm - utiliser les outputs du module EKS
provider "helm" {
  kubernetes {
    host                   = try(module.eks.cluster_endpoint, "")
    cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
    token                  = try(module.eks.cluster_token, "")
  }
}
EOF
    
    echo "✅ Nouveau fichier providers.tf.new créé"
    echo ""
    echo "Vérifiez le contenu avec: cat providers.tf.new"
    echo "Puis remplacez: mv providers.tf.new providers.tf"
    ;;
    
  3)
    echo ""
    echo "=== Création d'un module addons séparé ==="
    echo ""
    
    # Créer la structure du module
    mkdir -p modules/eks-addons
    
    cat > modules/eks-addons/main.tf <<'EOF'
# modules/eks-addons/main.tf
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.11.0"
  
  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  
  set {
    name  = "awsRegion"
    value = var.aws_region
  }
}
EOF

    cat > modules/eks-addons/variables.tf <<'EOF'
variable "cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
}
EOF

    echo "✅ Module eks-addons créé dans modules/eks-addons/"
    echo ""
    echo "Supprimez les helm_release du module EKS et ajoutez dans main.tf:"
    echo ""
    echo 'module "eks_addons" {'
    echo '  source = "./modules/eks-addons"'
    echo '  '
    echo '  cluster_name = module.eks.cluster_name'
    echo '  aws_region   = var.aws_region'
    echo '  '
    echo '  depends_on = [module.eks]'
    echo '}'
    ;;
    
  *)
    echo "Option invalide"
    exit 1
    ;;
esac

echo ""
echo "=== Vérification ==="
terraform validate

echo ""
echo "=== Test du plan ==="
terraform plan -lock=false