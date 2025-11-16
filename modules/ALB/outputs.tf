# ============================================================================
# MODULES/ALB/outputs.tf
# ============================================================================

output "arn" {
  description = "ARN du Load Balancer"
  value       = aws_lb.main.arn
}

output "dns_name" {
  description = "DNS name du Load Balancer"
  value       = aws_lb.main.dns_name
}

output "zone_id" {
  description = "Zone ID du Load Balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN du Target Group"
  value       = aws_lb_target_group.main.arn
}

output "security_group_id" {
  description = "ID du Security Group"
  value       = aws_security_group.alb.id
}

output "waf_web_acl_arn" {
  description = "ARN du WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].arn : null
}