# ============================================================================
# variables.tf
# ============================================================================

# ============================================================================
# PROJECT VARIABLES
# ============================================================================

variable "project_name" {
  description = "Nom du projet - utilisé pour le prefixe des ressources"
  type        = string
  default     = "secure-cloud"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Le nom du projet doit contenir uniquement des minuscules, chiffres et tirets"
  }
}

variable "environment" {
  description = "Environnement de déploiement"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "L'environnement doit être dev, staging ou production"
  }
}

variable "owner_email" {
  description = "Email du propriétaire du projet"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Email invalide"
  }
}

variable "cost_center" {
  description = "Centre de coûts pour la facturation"
  type        = string
  default     = "IT-Security"
}

# ============================================================================
# AWS CONFIGURATION
# ============================================================================

variable "aws_region" {
  description = "Région AWS pour le déploiement"
  type        = string
  default     = "us-east-2"
  
  validation {
    condition = contains([
      "eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1",
      "us-east-1", "us-east-2", "us-west-1", "us-west-2"
    ], var.aws_region)
    error_message = "Région AWS non supportée"
  }
}

variable "aws_profile" {
  description = "Profil AWS CLI à utiliser"
  type        = string
  default     = "clouud-security"
}

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "CIDR block invalide"
  }
}

variable "availability_zones" {
  description = "Liste des zones de disponibilité"
  type        = list(string)
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Au moins 2 zones de disponibilité sont requises"
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks pour les subnets publics"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks pour les subnets privés"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks pour les subnets de base de données"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Activer le NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Utiliser un seul NAT Gateway (économie de coûts)"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Activer le VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Activer VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Durée de rétention des Flow Logs en jours"
  type        = number
  default     = 90
}

# ============================================================================
# EKS CONFIGURATION
# ============================================================================

variable "eks_cluster_version" {
  description = "Version du cluster EKS"
  type        = string
  default     = "1.28"
}

variable "eks_node_instance_types" {
  description = "Types d'instances pour les nodes EKS"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Nombre désiré de nodes EKS"
  type        = number
  default     = 3
  
  validation {
    condition     = var.eks_node_desired_size >= 2
    error_message = "Au moins 2 nodes sont recommandés pour la haute disponibilité"
  }
}

variable "eks_node_min_size" {
  description = "Nombre minimum de nodes EKS"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Nombre maximum de nodes EKS"
  type        = number
  default     = 5
}

variable "eks_node_disk_size" {
  description = "Taille du disque pour les nodes EKS (GB)"
  type        = number
  default     = 50
}

variable "eks_enable_spot_instances" {
  description = "Utiliser des instances Spot pour réduire les coûts"
  type        = bool
  default     = true
}

variable "eks_enable_irsa" {
  description = "Activer IRSA (IAM Roles for Service Accounts)"
  type        = bool
  default     = true
}

variable "eks_enable_encryption" {
  description = "Activer le chiffrement des secrets EKS"
  type        = bool
  default     = true
}

variable "eks_cluster_log_types" {
  description = "Types de logs à activer pour le cluster EKS"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# ============================================================================
# RDS CONFIGURATION
# ============================================================================

variable "rds_engine" {
  description = "Moteur de base de données"
  type        = string
  default     = "postgres"
  
  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.rds_engine)
    error_message = "Moteur non supporté"
  }
}

variable "rds_engine_version" {
  description = "Version du moteur de base de données"
  type        = string
  default     = "15.4"
}

variable "rds_instance_class" {
  description = "Classe d'instance RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Stockage alloué en GB"
  type        = number
  default     = 20
  
  validation {
    condition     = var.rds_allocated_storage >= 20
    error_message = "Le stockage minimum est de 20 GB"
  }
}

variable "rds_max_allocated_storage" {
  description = "Stockage maximum pour l'auto-scaling"
  type        = number
  default     = 100
}

variable "rds_database_name" {
  description = "Nom de la base de données"
  type        = string
  default     = "appdb"
}

variable "rds_master_username" {
  description = "Nom d'utilisateur master"
  type        = string
  default     = "dbadmin"
}

variable "rds_backup_retention_period" {
  description = "Durée de rétention des backups en jours"
  type        = number
  default     = 7
  
  validation {
    condition     = var.rds_backup_retention_period >= 1 && var.rds_backup_retention_period <= 35
    error_message = "La rétention doit être entre 1 et 35 jours"
  }
}

variable "rds_multi_az" {
  description = "Activer le déploiement multi-AZ"
  type        = bool
  default     = true
}

variable "rds_enable_performance_insights" {
  description = "Activer Performance Insights"
  type        = bool
  default     = true
}

variable "rds_enable_deletion_protection" {
  description = "Activer la protection contre la suppression"
  type        = bool
  default     = true
}

# ============================================================================
# SECURITY CONFIGURATION
# ============================================================================

variable "enable_guardduty" {
  description = "Activer AWS GuardDuty"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Activer AWS CloudTrail"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Activer AWS Config"
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Activer AWS Security Hub"
  type        = bool
  default     = true
}

variable "security_team_email" {
  description = "Email de l'équipe de sécurité pour les alertes"
  type        = string
}

variable "ops_team_email" {
  description = "Email de l'équipe ops pour les alertes"
  type        = string
}

# ============================================================================
# MONITORING CONFIGURATION
# ============================================================================

variable "cloudwatch_log_retention_days" {
  description = "Durée de rétention des logs CloudWatch"
  type        = number
  default     = 90
}

variable "enable_enhanced_monitoring" {
  description = "Activer le monitoring avancé"
  type        = bool
  default     = true
}

# ============================================================================
# PRISMA CLOUD CONFIGURATION
# ============================================================================

variable "prisma_cloud_url" {
  description = "URL de l'API Prisma Cloud"
  type        = string
  default     = "https://api.prismacloud.io"
}

variable "prisma_cloud_access_key_id" {
  description = "Access Key ID Prisma Cloud"
  type        = string
  sensitive   = true
  default     = ""
}

variable "prisma_cloud_secret_key" {
  description = "Secret Key Prisma Cloud"
  type        = string
  sensitive   = true
  default     = ""
}

# ============================================================================
# CLOUDFLARE CONFIGURATION
# ============================================================================

variable "cloudflare_zone_name" {
  description = "Nom de la zone Cloudflare"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Token API Cloudflare"
  type        = string
  sensitive   = true
  default     = ""
}

# ============================================================================
# TAGS
# ============================================================================

variable "common_tags" {
  description = "Tags communs à appliquer à toutes les ressources"
  type        = map(string)
  default     = {}
}
