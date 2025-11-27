# ============================================================================
# MODULES/SECURITY/secrets.tf
# ============================================================================

# SNS Topic pour les alertes de sécurité
resource "aws_sns_topic" "security_alerts" {
  name              = "${var.project_name}-${var.environment}-security-alerts"
  display_name      = "Security Alerts"
  kms_master_key_id = aws_kms_key.sns.id
  
  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "security_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.security_alerts_email
}

# SNS Topic pour les alertes opérationnelles
resource "aws_sns_topic" "ops_alerts" {
  name              = "${var.project_name}-${var.environment}-ops-alerts"
  display_name      = "Operational Alerts"
  kms_master_key_id = aws_kms_key.sns.id
  
  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "ops_email" {
  topic_arn = aws_sns_topic.ops_alerts.arn
  protocol  = "email"
  endpoint  = var.ops_alerts_email
}