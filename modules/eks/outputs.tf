# ============================================================================
# MODULES/EKS/outputs.tf
# ============================================================================

output "cluster_id" {
  description = "ID du cluster EKS"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "Nom du cluster EKS"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "ARN du cluster EKS"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint du cluster EKS"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Version du cluster EKS"
  value       = aws_eks_cluster.main.version
}

output "cluster_security_group_id" {
  description = "ID du security group du cluster"
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "ID du security group des nodes"
  value       = aws_security_group.node_group.id
}

output "cluster_ca_certificate" {
  description = "Certificat CA du cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "oidc_provider_arn" {
  description = "ARN du provider OIDC"
  value       = var.enable_irsa ? aws_iam_openid_connect_provider.eks[0].arn : null
}

output "oidc_provider_url" {
  description = "URL du provider OIDC"
  value       = var.enable_irsa ? aws_iam_openid_connect_provider.eks[0].url : null
}

output "node_group_ids" {
  description = "IDs des node groups"
  value       = { for k, v in aws_eks_node_group.main : k => v.id }
}

output "node_group_arns" {
  description = "ARNs des node groups"
  value       = { for k, v in aws_eks_node_group.main : k => v.arn }
}

output "node_group_status" {
  description = "Status des node groups"
  value       = { for k, v in aws_eks_node_group.main : k => v.status }
}
