# ============================================================================
# MODULES/SECURITY/guardduty.tf
# ============================================================================

resource "aws_guardduty_detector" "main" {
  count  = var.enable_guardduty ? 1 : 0
  enable = true
  
  datasources {
    s3_logs {
      enable = true
    }
    
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }
  
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  
  tags = var.common_tags
}

# Export des findings vers S3
resource "aws_guardduty_publishing_destination" "s3" {
  count = var.enable_guardduty ? 1 : 0
  
  detector_id     = aws_guardduty_detector.main[0].id
  destination_arn = aws_s3_bucket.guardduty_findings[0].arn
  kms_key_arn     = aws_kms_key.guardduty[0].arn
  
  destination_type = "S3"
  
  depends_on = [aws_s3_bucket_policy.guardduty_findings]
}

# S3 Bucket pour les findings
resource "aws_s3_bucket" "guardduty_findings" {
  count  = var.enable_guardduty ? 1 : 0
  bucket = "${var.project_name}-${var.environment}-guardduty-findings-${data.aws_caller_identity.current.account_id}"
  
  tags = var.common_tags
}

resource "aws_s3_bucket_versioning" "guardduty_findings" {
  count  = var.enable_guardduty ? 1 : 0
  bucket = aws_s3_bucket.guardduty_findings[0].id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "guardduty_findings" {
  count  = var.enable_guardduty ? 1 : 0
  bucket = aws_s3_bucket.guardduty_findings[0].id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.guardduty[0].id
    }
  }
}

resource "aws_s3_bucket_public_access_block" "guardduty_findings" {
  count  = var.enable_guardduty ? 1 : 0
  bucket = aws_s3_bucket.guardduty_findings[0].id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "guardduty_findings" {
  count  = var.enable_guardduty ? 1 : 0
  bucket = aws_s3_bucket.guardduty_findings[0].id
  
  rule {
    id     = "archive-findings"
    status = "Enabled"
    
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    
    expiration {
      days = 2555
    }
  }
}

resource "aws_s3_bucket_policy" "guardduty_findings" {
  count  = var.enable_guardduty ? 1 : 0
  bucket = aws_s3_bucket.guardduty_findings[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGuardDutyPutObject"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.guardduty_findings[0].arn}/*"
      },
      {
        Sid    = "AllowGuardDutyGetBucketLocation"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action   = "s3:GetBucketLocation"
        Resource = aws_s3_bucket.guardduty_findings[0].arn
      }
    ]
  })
}

# EventBridge pour les findings critiques
resource "aws_cloudwatch_event_rule" "guardduty_high_severity" {
  count = var.enable_guardduty ? 1 : 0
  
  name        = "${var.project_name}-${var.environment}-guardduty-high-severity"
  description = "Capture GuardDuty HIGH and CRITICAL severity findings"
  
  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [
        { "numeric" = [">=" , 7] }
      ]
    }
  })
  
  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "guardduty_sns" {
  count = var.enable_guardduty ? 1 : 0
  
  rule      = aws_cloudwatch_event_rule.guardduty_high_severity[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.security_alerts.arn
}
