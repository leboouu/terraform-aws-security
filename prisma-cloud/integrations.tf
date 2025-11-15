terraform {
  required_providers {
    prismacloud = {
      source  = "PaloAltoNetworks/prismacloud"
      version = "~> 1.3"
    }
  }
}

provider "prismacloud" {
  access_key = var.prisma_access_key
  secret_key = var.prisma_secret_key
}

resource "prismacloud_cloud_account" "aws" {
  name       = "AWS Account ${var.aws_account_id}"
  cloud_type = "aws"
  aws {
    account_id  = var.aws_account_id
    role_arn    = "arn:aws:iam::${var.aws_account_id}:role/PrismaCloudRole"
    external_id = "external-id-placeholder"  # Replace with actual external ID
  }
  group_ids = ["default"]
}
