# ============================================================================
# main.tf
# ============================================================================

# ============================================================================
# PROVIDERS CONFIGURATION
# ============================================================================

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = merge(
      var.common_tags,
      {
        Project     = var.project_name
        Environment = var.environment
        ManagedBy   = "Terraform"
        Owner       = var.owner_email
        CostCenter  = var.cost_center
      }
    )
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================================================
# LOCAL VARIABLES
# ============================================================================

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      Environment = var.environment
      Terraform   = "true"
      Region      = local.region
    }
  )

  azs = slice(data.aws_availability_zones.available.names, 0, length(var.availability_zones))

  cluster_name = "${var.project_name}-${var.environment}"
}

# ============================================================================
# VPC MODULE
# ============================================================================

module "vpc" {
  source = "./modules/vpc"

  project_name    = var.project_name
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr

  availability_zones    = local.azs
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs

  enable_nat_gateway    = var.enable_nat_gateway
  single_nat_gateway    = var.single_nat_gateway
  enable_vpn_gateway    = var.enable_vpn_gateway
  enable_dns_hostnames  = true
  enable_dns_support    = true

  enable_flow_logs         = var.enable_flow_logs
  flow_logs_retention_days = var.flow_logs_retention_days

  common_tags = local.common_tags
}

# ============================================================================
# EKS MODULE
# ============================================================================

module "eks" {
  source = "./modules/eks"

  project_name    = var.project_name
  environment     = var.environment
  cluster_version = var.eks_cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  node_groups = {
    general = {
      name           = "general"
      instance_types = var.eks_node_instance_types
      capacity_type  = var.eks_enable_spot_instances ? "SPOT" : "ON_DEMAND"

      desired_size = var.eks_node_desired_size
      min_size     = var.eks_node_min_size
      max_size     = var.eks_node_max_size
      disk_size    = var.eks_node_disk_size

      labels = {
        role        = "general"
        environment = var.environment
      }

      taints = []

      tags = {
        NodeGroup = "general"
      }
    }
  }

  cluster_log_types              = var.eks_cluster_log_types
  enable_irsa                    = var.eks_enable_irsa
  enable_cluster_encryption      = var.eks_enable_encryption
  cluster_encryption_kms_key_arn = module.security.kms_key_eks_arn
  node_encryption_kms_key_arn    = module.security.kms_key_eks_arn

  common_tags = local.common_tags

  depends_on = [module.vpc]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# ============================================================================
# RDS MODULE
# ============================================================================

module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  environment  = var.environment

  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.database_subnet_ids
  allowed_cidr_blocks  = module.vpc.private_subnet_cidrs
  allowed_security_groups = [module.eks.node_security_group_id]

  engine                = var.rds_engine
  engine_version        = var.rds_engine_version
  instance_class        = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage

  database_name   = var.rds_database_name
  master_username = var.rds_master_username

  backup_retention_period = var.rds_backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  multi_az                  = var.rds_multi_az
  deletion_protection       = var.rds_enable_deletion_protection
  skip_final_snapshot       = var.environment != "production"
  ##final_snapshot_identifier = "${var.project_name}-${var.environment}-final-snapshot"

  enabled_cloudwatch_logs_exports = var.rds_engine == "postgres" ? ["postgresql", "upgrade"] : ["error", "general", "slowquery"]

  storage_encrypted            = true
  kms_key_id                   = module.security.kms_key_rds_arn
  performance_insights_enabled = var.rds_enable_performance_insights

  monitoring_interval = var.enable_enhanced_monitoring ? 60 : 0
  monitoring_role_arn = var.enable_enhanced_monitoring ? aws_iam_role.rds_monitoring[0].arn : null

  common_tags = local.common_tags

  depends_on = [module.vpc, module.security]
}

# IAM Role for Enhanced Monitoring RDS
resource "aws_iam_role" "rds_monitoring" {
  count = var.enable_enhanced_monitoring ? 1 : 0

  name = "${var.project_name}-${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.enable_enhanced_monitoring ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ============================================================================
# ALB MODULE
# ============================================================================

module "alb" {
  source = "./modules/alb"

  name            = "${var.project_name}-${var.environment}-alb"
  environment     = var.environment
  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnet_ids
  security_groups = [aws_security_group.alb.id]

  # Configuration des target groups
  target_groups = [
    {
      name_prefix      = "tg-"
      protocol         = "HTTP"
      port             = 80
      target_type      = "ip"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-299"
      }
    }
  ]

  # Configuration des listeners
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  # Configuration des logs ALB
  enable_deletion_protection = var.environment == "production" ? true : false
  
  access_logs = {
    enabled = true
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "logs"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-alb"
    }
  )

  depends_on = [module.vpc]
}
# Security Group pour l'ALB
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # À restreindre en production
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}
# S3 Bucket for ALB logs
resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.project_name}-${var.environment}-alb-logs-${local.account_id}"

  tags = local.common_tags
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    id     = "alb_logs_lifecycle"
    status = "Enabled"

    prefix = "logs/"  # Replace with your desired prefix, e.g., for ALB logs

    # Add other rule attributes as needed (e.g., expiration, transitions)
    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowELBRootAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}

data "aws_elb_service_account" "main" {}

# ============================================================================
# SECURITY MODULE
# ============================================================================

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment

  enable_guardduty    = var.enable_guardduty
  enable_cloudtrail   = var.enable_cloudtrail
  enable_config       = var.enable_config
  enable_security_hub = var.enable_security_hub

  cloudtrail_s3_bucket_name = "${var.project_name}-${var.environment}-cloudtrail-${local.account_id}"
  config_s3_bucket_name     = "${var.project_name}-${var.environment}-config-${local.account_id}"

  security_alerts_email = var.security_team_email
  ops_alerts_email      = var.ops_team_email

  common_tags = local.common_tags
}

# ============================================================================
# SECRETS MANAGER - RDS PASSWORD
# ============================================================================

resource "random_password" "rds_password" {
  length  = 32
  special = true

  # Exclude characters that may cause problems in URLs
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "rds_password" {
  name        = "${var.project_name}-${var.environment}-rds-password"
  description = "Master password for the RDS database"

  kms_key_id = module.security.kms_key_secrets_arn

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = aws_secretsmanager_secret.rds_password.id

  secret_string = jsonencode({
    username = var.rds_master_username
    password = random_password.rds_password.result
    engine   = var.rds_engine
    host     = module.rds.db_instance_endpoint
    port     = module.rds.db_instance_port
    dbname   = var.rds_database_name
  })
}

# ============================================================================
# CLOUDWATCH LOG GROUPS
# ============================================================================

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/${var.project_name}/${var.environment}/application"
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = module.security.kms_key_cloudwatch_arn

  tags = local.common_tags
}

# ============================================================================
# SNS TOPICS FOR ALERTS
# ============================================================================

resource "aws_sns_topic" "alerts" {
  name              = "${var.project_name}-${var.environment}-alerts"
  display_name      = "Security and operational alerts"
  kms_master_key_id = module.security.kms_key_sns_arn

  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "security_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.security_team_email
}

resource "aws_sns_topic_subscription" "ops_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.ops_team_email
}

# ============================================================================
# CLOUDWATCH ALARMS
# ============================================================================

# Alarm for high CPU utilization of EKS cluster
resource "aws_cloudwatch_metric_alarm" "eks_high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-eks-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert if CPU utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = module.eks.cluster_name
  }

  tags = local.common_tags
}

# Alarm for high memory utilization of EKS cluster
resource "aws_cloudwatch_metric_alarm" "eks_high_memory" {
  alarm_name          = "${var.project_name}-${var.environment}-eks-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert if memory utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = module.eks.cluster_name
  }

  tags = local.common_tags
}

# Alarm for RDS connections
resource "aws_cloudwatch_metric_alarm" "rds_high_connections" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert if the number of connections exceeds 80"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_id
  }

  tags = local.common_tags
}

# ============================================================================
# FINAL OUTPUTS
# ============================================================================

output "deployment_summary" {
  description = "Deployment summary"
  value = {
    project_name     = var.project_name
    environment      = var.environment
    region           = local.region
    vpc_id           = module.vpc.vpc_id
    eks_cluster_name = module.eks.cluster_name
    rds_endpoint     = module.rds.db_instance_endpoint
    alb_dns_name     = module.alb.dns_name
  }
}


# Cloudflare provider configuration
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Cloudflare module
module "cloudflare" {
  source = "./modules/cloudflare"

  zone_name  = var.cloudflare_zone_name
  common_tags = local.common_tags
}

