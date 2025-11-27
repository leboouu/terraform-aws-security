resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnet_ids
  # SUPPRIMEZ CETTE LIGNE COMPLÈTEMENT: vpc_id = var.vpc_id
  
  enable_deletion_protection = var.enable_deletion_protection

  tags = var.tags
}

resource "aws_lb_target_group" "this" {
  count = length(var.target_groups)

  name_prefix = var.target_groups[count.index].name_prefix
  protocol    = var.target_groups[count.index].backend_protocol  # Gardez "protocol", pas "backend_protocol"
  port        = var.target_groups[count.index].backend_port      # Gardez "port", pas "backend_port"
  vpc_id      = var.vpc_id
  target_type = var.target_groups[count.index].target_type

  health_check {
    enabled             = lookup(var.target_groups[count.index].health_check, "enabled", true)
    interval            = lookup(var.target_groups[count.index].health_check, "interval", 30)
    path                = lookup(var.target_groups[count.index].health_check, "path", "/")
    port                = lookup(var.target_groups[count.index].health_check, "port", "traffic-port")
    healthy_threshold   = lookup(var.target_groups[count.index].health_check, "healthy_threshold", 3)
    unhealthy_threshold = lookup(var.target_groups[count.index].health_check, "unhealthy_threshold", 3)
    timeout             = lookup(var.target_groups[count.index].health_check, "timeout", 6)
    protocol            = lookup(var.target_groups[count.index].health_check, "protocol", "HTTP")
    matcher             = lookup(var.target_groups[count.index].health_check, "matcher", "200-299")
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}