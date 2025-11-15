variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "num_public_subnets" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "num_private_subnets" {
  description = "Number of private subnets"
  type        = number
  default     = 2
}
