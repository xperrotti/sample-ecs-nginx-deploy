# ---------------------------------------------------------------------------------------------------------------------
# ALB MODULE
# Creates an Application Load Balancer with HTTP→HTTPS redirect and HTTPS listener
# Supports cross-account Route53: ALB in workload account, DNS record in management account
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.dns]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb" "main" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = var.name
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# TARGET GROUP (IP type for Fargate awsvpc)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb_target_group" "main" {
  name        = "${var.name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-tg"
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# HTTPS LISTENER (port 443)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# HTTP LISTENER (port 80 — redirects to HTTPS)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE53 A RECORD (alias to ALB — in management account where hosted zone lives)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route53_record" "app" {
  provider = aws.dns

  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
