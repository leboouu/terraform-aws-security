# ============================================================================
# MODULES/RDS/variables.tf
# ============================================================================

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement"
  type        = string
}

variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs des subnets pour RDS"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks autorisés à accéder à RDS"
  type        = list(string)
  default     = []
}

variable "allowed_security_groups" {
  description = "Security groups autorisés à accéder à RDS"
  type        = list(string)
  default     = []
}

variable "engine" {
  description = "Moteur de base de données"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Version du moteur"
  type        = string
}

variable "instance_class" {
  description = "Classe d'instance RDS"
  type        = string
}

variable "allocated_storage" {
  description = "Stockage alloué (GB)"
  type        = number
}

variable "max_allocated_storage" {
  description = "Stockage maximum pour auto-scaling"
  type        = number
}

variable "database_name" {
  description = "Nom de la base de données"
  type        = string
}

variable "master_username" {
  description = "Nom d'utilisateur master"
  type        = string
}

variable "backup_retention_period" {
  description = "Période de rétention des backups"
  type        = number
}

variable "backup_window" {
  description = "Fenêtre de backup"
  type        = string
}

variable "maintenance_window" {
  description = "Fenêtre de maintenance"
  type        = string
}

variable "multi_az" {
  description = "Activer multi-AZ"
  type        = bool
}

variable "deletion_protection" {
  description = "Protection contre la suppression"
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Ignorer le snapshot final"
  type        = bool
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Types de logs à exporter vers CloudWatch"
  type        = list(string)
  default     = []
}

variable "storage_encrypted" {
  description = "Activer le chiffrement du stockage"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN de la clé KMS"
  type        = string
}

variable "performance_insights_enabled" {
  description = "Activer Performance Insights"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "Intervalle de monitoring (secondes)"
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "ARN du rôle IAM pour le monitoring"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags supplémentaires"
  type        = map(string)
  default     = {}
}

variable "parameter_group_family" {
  description = "Famille du groupe de paramètres"
  type        = string
}
# Example of parameter definitions
variable "db_parameters" {
  default = [
    {
      name         = "max_connections"
      value        = "100"
      apply_method = "immediate"  # Dynamic parameter
    },
    {
      name         = "shared_buffers"
      value        = "256MB"
      apply_method = "pending-reboot"  # Static parameter (requires reboot)
    }
  ]
}