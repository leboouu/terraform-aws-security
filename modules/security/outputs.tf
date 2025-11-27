# ============================================================================
# Security Module Outputs
# ============================================================================

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].id : null
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].arn : null
}

output "config_recorder_id" {
  description = "The ID of the AWS Config recorder"
  value       = var.enable_config ? aws_config_configuration_recorder.main[0].id : null
}

output "security_hub_arn" {
  description = "The ARN of Security Hub"
  value       = var.enable_security_hub ? aws_securityhub_account.main[0].id : null
}

output "kms_key_eks_arn" {
  description = "The ARN of the KMS key for EKS"
  value       = aws_kms_key.eks.arn
}

output "kms_key_rds_arn" {
  description = "The ARN of the KMS key for RDS"
  value       = aws_kms_key.rds.arn
}

output "kms_key_secrets_arn" {
  description = "The ARN of the KMS key for Secrets Manager"
  value       = aws_kms_key.secrets.arn
}


output "kms_key_sns_arn" {
  description = "The ARN of the KMS key for SNS"
  value       = aws_kms_key.sns.arn
}

output "kms_key_cloudtrail_arn" {
  description = "The ARN of the KMS key for CloudTrail"
  value       = var.enable_cloudtrail ? aws_kms_key.cloudtrail[0].arn : null
}