# ============================================================================
# MODULES/EKS/variables.tf
# ============================================================================

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement"
  type        = string
}

variable "cluster_version" {
  description = "Version du cluster EKS"
  type        = string
  default     = "1.28"
}

variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs des subnets pour le cluster"
  type        = list(string)
}

variable "node_groups" {
  description = "Map of node group configurations"
  type = map(object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    labels         = map(string)
    taints         = list(object({
      key    = string
      value  = string
      effect = string
    }))
    tags           = map(string)
  }))
  default = {}
}

variable "cluster_log_types" {
  description = "Types de logs à activer"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  description = "Durée de rétention des logs"
  type        = number
  default     = 90
}

variable "enable_irsa" {
  description = "Activer IRSA"
  type        = bool
  default     = true
}

variable "enable_cluster_encryption" {
  description = "Activer le chiffrement du cluster"
  type        = bool
  default     = true
}

variable "cluster_encryption_kms_key_arn" {
  description = "ARN de la clé KMS pour le chiffrement"
  type        = string
}

variable "node_encryption_kms_key_arn" {
  description = "ARN de la clé KMS pour les nodes"
  type        = string
}

variable "service_ipv4_cidr" {
  description = "CIDR pour les services Kubernetes"
  type        = string
  default     = "172.20.0.0/16"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs autorisés pour l'accès public"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_cluster_autoscaler" {
  description = "Activer le Cluster Autoscaler"
  type        = bool
  default     = true
}

variable "enable_metrics_server" {
  description = "Activer le Metrics Server"
  type        = bool
  default     = true
}

variable "vpc_cni_addon_version" {
  description = "Version de l'addon VPC CNI"
  type        = string
  default     = null
}

variable "coredns_addon_version" {
  description = "Version de l'addon CoreDNS"
  type        = string
  default     = null
}

variable "kube_proxy_addon_version" {
  description = "Version de l'addon kube-proxy"
  type        = string
  default     = null
}

variable "ebs_csi_driver_addon_version" {
  description = "Version de l'addon EBS CSI Driver"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}

data "aws_region" "current" {}
