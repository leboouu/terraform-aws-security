variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "my-project"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "my-project"
    Environment = "dev"
  }
}

variable "enable_config" {
  description = "Enable AWS Config"
  type        = bool
  default     = true
}

variable "config_s3_bucket_name" {
  description = "Name of the S3 bucket for AWS Config"
  type        = string
  default     = "my-config-bucket"
}

variable "ops_alerts_email" {
  description = "Email address for operational alerts"
  type        = string
  default     = "ops@example.com"
}

variable "enable_guardduty" {
  description = "Enable AWS GuardDuty"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail"
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = true
}

variable "cloudtrail_s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail"
  type        = string
  default     = "my-cloudtrail-bucket"
}

variable "security_alerts_email" {
  description = "Email address for security alerts"
  type        = string
  default     = "security@example.com"
}
