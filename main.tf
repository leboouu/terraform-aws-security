terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  num_public_subnets   = var.num_public_subnets
  num_private_subnets  = var.num_private_subnets
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  node_group_name    = var.node_group_name
  node_instance_type = var.node_instance_type
  node_desired_capacity = var.node_desired_capacity
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
}

module "rds" {
  source = "./modules/rds"

  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  instance_class          = var.instance_class
  engine                  = var.engine
  engine_version          = var.engine_version
  allocated_storage       = var.allocated_storage
  subnet_ids              = module.vpc.private_subnet_ids
  vpc_id                  = module.vpc.vpc_id
  kms_key_id              = var.kms_key_id
  backup_retention_period = var.backup_retention_period
  multi_az                = var.multi_az
  storage_encrypted       = var.storage_encrypted
}
