variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for the ALB"
  type        = list(string)
}

variable "target_groups" {
  description = "List of target group configurations"
  type = list(object({
    name_prefix      = string
    backend_protocol = string
    backend_port     = number
    target_type      = string
    health_check = object({
      enabled             = bool
      interval            = number
      path                = string
      port                = string
      healthy_threshold   = number
      unhealthy_threshold = number
      timeout             = number
      protocol            = string
      matcher             = string
    })
  }))
  default = []
}

variable "http_tcp_listeners" {
  description = "List of HTTP/TCP listener configurations"
  type = list(object({
    port               = number
    protocol           = string
    target_group_index = number
  }))
  default = []
}

variable "name" {
  description = "Name of the ALB"
  type        = string
}

variable "load_balancer_type" {
  description = "Type of load balancer"
  type        = string
  default     = "application"
}

variable "internal" {
  description = "Whether the load balancer is internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Enable HTTP/2"
  type        = bool
  default     = true
}

variable "access_logs_enabled" {
  description = "Enable access logs"
  type        = bool
  default     = true
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "Prefix for access logs"
  type        = string
  default     = "alb"
}

variable "enable_waf" {
  description = "Enable WAF"
  type        = bool
  default     = true
}

variable "waf_blocked_countries" {
  description = "List of blocked countries for WAF"
  type        = list(string)
  default     = []
}

variable "waf_log_destination_arn" {
  description = "ARN for WAF log destination"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags for the ALB"
  type        = map(string)
  default     = {}
}
