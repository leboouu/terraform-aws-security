# ============================================================================
# MODULES/ALB/variables.tf
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
  description = "IDs des subnets pour ALB"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Protection contre la suppression"
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Activer le load balancing cross-zone"
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Activer HTTP/2"
  type        = bool
  default     = true
}

variable "access_logs_enabled" {
  description = "Activer les logs d'accès"
  type        = bool
  default     = true
}

variable "access_logs_bucket" {
  description = "Bucket S3 pour les logs"
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "Préfixe pour les logs"
  type        = string
  default     = "alb"
}

variable "health_check_path" {
  description = "Chemin pour le health check"
  type        = string
  default     = "/health"
}

variable "certificate_arn" {
  description = "ARN du certificat SSL"
  type        = string
  default     = null
}

variable "security_group_ingress_rules" {
  description = "Règles d'ingress pour le security group"
  type        = any
  default     = {}
}

variable "enable_waf" {
  description = "Activer WAF"
  type        = bool
  default     = true
}

variable "waf_blocked_countries" {
  description = "Pays à bloquer via WAF"
  type        = list(string)
  default     = []
}

variable "waf_log_destination_arn" {
  description = "ARN de destination pour les logs WAF"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}
