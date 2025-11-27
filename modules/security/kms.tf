# ============================================================================
# MODULES/SECURITY/kms.tf
# ============================================================================

# KMS Key for EKS encryption
resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS cluster and node encryption"
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"

  tags = var.common_tags
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.project_name}-${var.environment}-eks"
  target_key_id = aws_kms_key.eks.key_id
}

# KMS Key for CloudTrail encryption
resource "aws_kms_key" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  description             = "KMS key for CloudTrail log encryption"
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"

  tags = var.common_tags
}

resource "aws_kms_alias" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  name          = "alias/${var.project_name}-${var.environment}-cloudtrail"
  target_key_id = aws_kms_key.cloudtrail[0].key_id
}

# KMS Key for CloudWatch logs encryption
resource "aws_kms_key" "cloudwatch" {
  count = var.enable_cloudtrail ? 1 : 0

  description             = "KMS key for CloudWatch logs encryption"
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"

  tags = var.common_tags
}

resource "aws_kms_alias" "cloudwatch" {
  count = var.enable_cloudtrail ? 1 : 0

  name          = "alias/${var.project_name}-${var.environment}-cloudwatch"
  target_key_id = aws_kms_key.cloudwatch[0].key_id
}
