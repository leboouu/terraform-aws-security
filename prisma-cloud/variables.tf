variable "prisma_access_key" {
  description = "Prisma Cloud access key"
  type        = string
  sensitive   = true
}

variable "prisma_secret_key" {
  description = "Prisma Cloud secret key"
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "AWS account ID to integrate with Prisma Cloud"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key for the account"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key for the account"
  type        = string
  sensitive   = true
}
