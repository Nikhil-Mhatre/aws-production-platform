# ==============================================================================
# APPLICATION LOAD BALANCER
# ==============================================================================
# The Application Load Balancer is the public entry point for LaunchPad API.
#
# Traffic flow:
#
# Internet
#    |
#    | HTTP :80
#    v
# ALB
#    |
#    | HTTP :3000
#    v
# ECS Fargate
#
# The ALB is deployed into public subnets across multiple Availability Zones.
#
# ECS tasks remain in private application subnets and are never directly
# exposed to the internet.
# ==============================================================================

resource "aws_lb" "this" {
  name = "${var.project_name}-${var.environment}-alb"

  load_balancer_type = "application"

  # ALB is internet-facing because it is the public entry point for the API.
  internal = false

  # Place the ALB in public subnets across multiple Availability Zones.
  subnets = var.public_subnet_ids

  # Allow the ALB to receive traffic from the internet.
  security_groups = [
    var.alb_security_group_id
  ]

  # Drop invalid/malformed requests before they reach the application.
  drop_invalid_header_fields = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb"
  })
}


# ==============================================================================
# TARGET GROUP
# ==============================================================================
# The target group represents the ECS tasks that receive traffic from the ALB.
#
# Because ECS Fargate uses awsvpc networking, targets are registered using
# their private IP addresses.
# ==============================================================================

resource "aws_lb_target_group" "this" {
  vpc_id = var.vpc_id
  name   = "${var.project_name}-${var.environment}-tg"

  port     = var.target_port
  protocol = "HTTP"

  # ECS Fargate tasks are registered by private IP address.
  target_type = "ip"

  # Health check endpoint exposed by LaunchPad API.
  health_check {
    enabled = true

    path = "/health"

    protocol = "HTTP"

    port = "traffic-port"

    healthy_threshold   = 2
    unhealthy_threshold = 3

    timeout  = 5
    interval = 30

    matcher = "200"
  }

  # Give the application time to initialize before considering it unhealthy.
  deregistration_delay = 30

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-target-group"
  })
}


# ==============================================================================
# HTTP LISTENER
# ==============================================================================
# The listener accepts HTTP traffic from clients and forwards requests to the
# ECS target group.
#
# HTTPS can be added later using an ACM certificate.
# ==============================================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-http-listener"
  })
}
