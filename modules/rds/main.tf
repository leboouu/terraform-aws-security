# ============================================================================
# MODULES/RDS/main.tf
# ============================================================================

# ============================================================================
# DB SUBNET GROUP
# ============================================================================

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-subnet-group"
    }
  )
}

# ============================================================================
# DB PARAMETER GROUP
# ============================================================================

# Configuration minimale sans SSL forcé
resource "aws_db_parameter_group" "main" {
  name   = "secure-cloud-production-db-params"
  family = var.parameter_group_family

  # Separate dynamic and static parameters
  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method  # Use "immediate" for dynamic, "pending-reboot" for static
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  postgres_parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    },
    {
      name  = "log_statement"
      value = "all"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"
    },
    {
      name  = "ssl"
      value = "1"
    }
  ]
  
  mysql_parameters = [
    {
      name  = "slow_query_log"
      value = "1"
    },
    {
      name  = "long_query_time"
      value = "2"
    },
    {
      name  = "require_secure_transport"
      value = "ON"
    }
  ]
}

# ============================================================================
# DB INSTANCE
# ============================================================================

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-db"
  
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_id
  
  db_name  = var.database_name
  username = var.master_username
  password = random_password.master_password.result
  port     = var.engine == "postgres" ? 5432 : 3306
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  
  multi_az               = var.multi_az
  publicly_accessible    = false
  deletion_protection    = var.deletion_protection
  skip_final_snapshot    = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? 7 : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.kms_key_id : null
  
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? var.monitoring_role_arn : null
  
  auto_minor_version_upgrade = true
  apply_immediately          = false
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db"
    }
  )
  
  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier
    ]
  }
}

# ============================================================================
# RANDOM PASSWORD
# ============================================================================

resource "random_password" "master_password" {
  length  = 32
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ============================================================================
# SECURITY GROUP
# ============================================================================

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-sg"
    }
  )
}

resource "aws_security_group_rule" "rds_ingress_cidr" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  
  type              = "ingress"
  from_port         = var.engine == "postgres" ? 5432 : 3306
  to_port           = var.engine == "postgres" ? 5432 : 3306
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.rds.id
  description       = "Allow database access from private subnets"
}

resource "aws_security_group_rule" "rds_ingress_sg" {
  count = length(var.allowed_security_groups)
  
  type                     = "ingress"
  from_port                = var.engine == "postgres" ? 5432 : 3306
  to_port                  = var.engine == "postgres" ? 5432 : 3306
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_groups[count.index]
  security_group_id        = aws_security_group.rds.id
  description              = "Allow database access from application security group"
}

resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
  description       = "Allow all outbound traffic"
}

# ============================================================================
# CLOUDWATCH ALARMS
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "RDS CPU utilization is too high"
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
  
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "database_memory" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "256000000"  # 256 MB
  alarm_description   = "RDS freeable memory is too low"
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
  
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "database_storage" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "2000000000"  # 2 GB
  alarm_description   = "RDS free storage space is too low"
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
  
  tags = var.common_tags
}
