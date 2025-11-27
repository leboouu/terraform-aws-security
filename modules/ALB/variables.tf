variable "name" {
  description = "Name of the ALB"
  type        = string
}

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

variable "tags" {
  description = "Tags for the ALB"
  type        = map(string)
  default     = {}
}

# Dans ./modules/alb/variables.tf
variable "alb_arn" {
  description = "ARN of existing ALB (optional)"
  type        = string
  default     = null  # Rendre optionnelle
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}