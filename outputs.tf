# ============================================================================
# outputs.tf
# ============================================================================

# ============================================================================
# VPC OUTPUTS
# ============================================================================

output "vpc_id" {
  description = "ID du VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block du VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs des subnets publics"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs des subnets privés"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs des subnets de base de données"
  value       = module.vpc.database_subnet_ids
}

output "nat_gateway_ips" {
  description = "IPs publiques des NAT Gateways"
  value       = module.vpc.nat_gateway_ips
}

# ============================================================================
# EKS OUTPUTS
# ============================================================================

output "eks_cluster_id" {
  description = "ID du cluster EKS"
  value       = module.eks.cluster_id
}

output "eks_cluster_name" {
  description = "Nom du cluster EKS"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint du cluster EKS"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "eks_cluster_security_group_id" {
  description = "ID du security group du cluster EKS"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_security_group_id" {
  description = "ID du security group des nodes EKS"
  value       = module.eks.node_security_group_id
}

output "eks_oidc_provider_arn" {
  description = "ARN du provider OIDC pour IRSA"
  value       = module.eks.oidc_provider_arn
}

output "configure_kubectl" {
  description = "Commande pour configurer kubectl"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

# ============================================================================
# RDS OUTPUTS
# ============================================================================

output "rds_endpoint" {
  description = "Endpoint de la base de données RDS"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "Nom de la base de données"
  value       = module.rds.db_instance_name
}

output "rds_port" {
  description = "Port de la base de données"
  value       = module.rds.db_instance_port
}

output "rds_security_group_id" {
  description = "ID du security group RDS"
  value       = module.rds.security_group_id
}

# ============================================================================
# ALB OUTPUTS
# ============================================================================

output "alb_dns_name" {
  description = "DNS name du Load Balancer"
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID du Load Balancer"
  value       = module.alb.zone_id
}

output "alb_arn" {
  description = "ARN du Load Balancer"
  value       = module.alb.arn
}

# ============================================================================
# SECURITY OUTPUTS
# ============================================================================

output "guardduty_detector_id" {
  description = "ID du detector GuardDuty"
  value       = module.security.guardduty_detector_id
  sensitive   = true
}

output "cloudtrail_name" {
  description = "Nom du trail CloudTrail"
  value       = module.security.cloudtrail_name
}

output "cloudtrail_s3_bucket" {
  description = "Bucket S3 pour CloudTrail"
  value       = module.security.cloudtrail_s3_bucket
}

output "security_hub_arn" {
  description = "ARN de Security Hub"
  value       = module.security.security_hub_arn
}

# ============================================================================
# KMS OUTPUTS
# ============================================================================

output "kms_key_eks_arn" {
  description = "ARN de la clé KMS pour EKS"
  value       = module.security.kms_key_eks_arn
}

output "kms_key_rds_arn" {
  description = "ARN de la clé KMS pour RDS"
  value       = module.security.kms_key_rds_arn
}

output "kms_key_secrets_arn" {
  description = "ARN de la clé KMS pour Secrets Manager"
  value       = module.security.kms_key_secrets_arn
}

# ============================================================================
# MONITORING OUTPUTS
# ============================================================================

output "cloudwatch_log_group_name" {
  description = "Nom du log group CloudWatch"
  value       = "/aws/eks/${module.eks.cluster_name}"
}

output "sns_topic_alerts_arn" {
  description = "ARN du topic SNS pour les alertes"
  value       = module.security.sns_topic_arn
}

# ============================================================================
# CONNECTION STRINGS
# ============================================================================

output "connection_strings" {
  description = "Chaînes de connexion pour les services"
  value = {
    rds_connection = "postgresql://${module.rds.db_instance_username}:PASSWORD@${module.rds.db_instance_endpoint}/${module.rds.db_instance_name}"
    eks_cluster    = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
  }
  sensitive = true
}

# ============================================================================
# COST ESTIMATION
# ============================================================================

output "estimated_monthly_cost" {
  description = "Coût mensuel estimé (USD)"
  value = {
    eks_control_plane = 72
    ec2_nodes        = var.eks_node_desired_size * (var.eks_enable_spot_instances ? 15 : 45)
    rds              = var.rds_instance_class == "db.t3.micro" ? 15 : 50
    alb              = 20
    nat_gateway      = var.single_nat_gateway ? 35 : 105
    data_transfer    = 50
    guardduty        = 30
    total_estimated  = "~${72 + (var.eks_node_desired_size * (var.eks_enable_spot_instances ? 15 : 45)) + (var.rds_instance_class == "db.t3.micro" ? 15 : 50) + 20 + (var.single_nat_gateway ? 35 : 105) + 50 + 30}"
  }
}
