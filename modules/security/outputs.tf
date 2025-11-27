# ============================================================================
# MODULES/SECURITY/outputs.tf
# ============================================================================

output "guardduty_detector_id" {
  description = "ID du detector GuardDuty"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].id : null
}

output "cloudtrail_name" {
  description = "Nom du trail CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].name : null
}

output "cloudtrail_s3_bucket" {
  description = "Bucket S3 pour CloudTrail"
  value       = var.enable_cloudtrail ? aws_s3_bucket.cloudtrail[0].id : null
}

output "security_hub_arn" {
  description = "ID du compte Security Hub"
  value       = var.enable_security_hub ? aws_securityhub_account.main[0].id : null
}

output "kms_key_eks_arn" {
  description = "ARN de la clé KMS pour EKS"
  value       = aws_kms_key.eks.arn
}

output "kms_key_rds_arn" {
  description = "ARN de la clé KMS pour RDS"
  value       = aws_kms_key.rds.arn
}

output "kms_key_secrets_arn" {
  description = "ARN de la clé KMS pour Secrets Manager"
  value       = aws_kms_key.secrets.arn
}

output "kms_key_cloudwatch_arn" {
  description = "ARN de la clé KMS pour CloudWatch"
  value       = aws_kms_key.cloudwatch.arn
}

output "kms_key_sns_arn" {
  description = "ARN de la clé KMS pour SNS"
  value       = aws_kms_key.sns.arn
}

output "sns_topic_arn" {
  description = "ARN du topic SNS pour alertes"
  value       = aws_sns_topic.security_alerts.arn
}
