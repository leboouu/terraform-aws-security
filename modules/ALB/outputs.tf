output "dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_lb.this.zone_id
}

output "arn" {
  description = "ARN of the ALB"
  value       = aws_lb.this.arn
}