# backend.tf
# Configuration complète du backend S3

terraform {
  backend "s3" {
    # Configuration du bucket
    bucket = "amzn-s3-terraform-b"
    key    = "terraform.tfstate"
    region = "us-east-2"
    
    # Sécurité
    encrypt = true
    
    # Verrouillage d'état avec DynamoDB (empêche les modifications concurrentes)
    # Créez d'abord la table DynamoDB avec:
    # aws dynamodb create-table \
    #   --table-name terraform-state-lock \
    #   --attribute-definitions AttributeName=LockID,AttributeType=S \
    #   --key-schema AttributeName=LockID,KeyType=HASH \
    #   --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
    dynamodb_table = "terraform-state-lock"
    
    # Options additionnelles
    skip_credentials_validation = false
    skip_metadata_api_check     = false
    force_path_style            = false
  }
}

# ===================================
# Organisation par environnement
# ===================================

# Pour dev:
# key = "env:/dev/terraform.tfstate"

# Pour staging:
# key = "env:/staging/terraform.tfstate"

# Pour production:
# key = "env:/prod/terraform.tfstate"

# ===================================
# Configuration avec workspaces
# ===================================

# Si vous utilisez terraform workspace, Terraform créera automatiquement:
# s3://bucket/env:/workspace-name/terraform.tfstate

# Exemples:
# - workspace "dev"     → env:/dev/terraform.tfstate
# - workspace "staging" → env:/staging/terraform.tfstate
# - workspace "prod"    → env:/prod/terraform.tfstate