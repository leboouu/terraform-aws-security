resource "aws_lb" "main" {
  name               = var.name
  load_balancer_type = var.load_balancer_type
  internal           = var.internal
  vpc_id             = var.vpc_id
  subnets            = var.subnet_ids
  security_groups    = var.security_groups

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2

  dynamic "access_logs" {
    for_each = var.access_logs_enabled ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = var.access_logs_enabled
    }
  }

  tags = var.common_tags
}

# Target Groups
resource "aws_lb_target_group" "main" {
  count = length(var.target_groups)

  name_prefix      = var.target_groups[count.index].name_prefix
  backend_protocol = var.target_groups[count.index].backend_protocol
  backend_port     = var.target_groups[count.index].backend_port
  target_type      = var.target_groups[count.index].target_type
  vpc_id           = var.vpc_id

  health_check {
    enabled             = var.target_groups[count.index].health_check.enabled
    interval            = var.target_groups[count.index].health_check.interval
    path                = var.target_groups[count.index].health_check.path
    port                = var.target_groups[count.index].health_check.port
    healthy_threshold   = var.target_groups[count.index].health_check.healthy_threshold
    unhealthy_threshold = var.target_groups[count.index].health_check.unhealthy_threshold
    timeout             = var.target_groups[count.index].health_check.timeout
    protocol            = var.target_groups[count.index].health_check.protocol
    matcher             = var.target_groups[count.index].health_check.matcher
  }

  tags = var.tags
}

# Listeners
resource "aws_lb_listener" "http_tcp" {
  count = length(var.http_tcp_listeners)

  load_balancer_arn = aws_lb.main.arn
  port              = var.http_tcp_listeners[count.index].port
  protocol          = var.http_tcp_listeners[count.index].protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[var.http_tcp_listeners[count.index].target_group_index].arn
  }
}
