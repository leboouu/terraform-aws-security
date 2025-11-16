# ============================================================================
# MODULES/VPC/variables.tf
# ============================================================================

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement (dev/staging/production)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
}

variable "availability_zones" {
  description = "Liste des zones de disponibilité"
  type        = list(string)
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
  description = "CIDR blocks pour les subnets database"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Activer le NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Utiliser un seul NAT Gateway"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Activer le VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Activer DNS hostnames"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Activer DNS support"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Activer VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Durée de rétention des Flow Logs"
  type        = number
  default     = 90
}

variable "common_tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}
